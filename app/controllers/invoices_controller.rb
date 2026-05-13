class InvoicesController < ApplicationController
  before_action :load_invoice, only: %i[show edit update]

  def index
    @invoices = scope.recent.includes(:ticket, :user).limit(100)
  end

  def show
    @items = @invoice.invoice_items.order(:position)
  end

  def new
    @ticket = Ticket.kept.where(company: current_company).find(params[:ticket_id]) if params[:ticket_id]
    @invoice = scope.new(ticket: @ticket, user: current_user, currency: default_currency)

    if params[:from_price_list].present?
      pl = PriceList.kept.where(company: current_company).find(params[:from_price_list])
      pl.price_items.active_items.by_position.each do |pi|
        @invoice.invoice_items.build(
          name: pi.name, description: pi.description,
          quantity: 1, unit_price_cents: pi.amount_cents, total_cents: pi.amount_cents
        )
      end
    else
      @invoice.invoice_items.build
    end

    @price_lists = PriceList.kept.where(company: current_company).active_lists
  end

  def create
    @invoice = scope.new(invoice_params.merge(user: current_user))
    @invoice.recalculate_totals

    if @invoice.save
      redirect_to invoice_path(@invoice), notice: t("invoices.created", default: "Счёт создан")
    else
      @price_lists = PriceList.kept.where(company: current_company).active_lists
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @invoice.invoice_items.build if @invoice.invoice_items.empty?
    @price_lists = PriceList.kept.where(company: current_company).active_lists
  end

  def update
    @invoice.assign_attributes(invoice_params)
    @invoice.recalculate_totals

    if @invoice.save
      redirect_to invoice_path(@invoice), notice: t("invoices.updated", default: "Счёт обновлён")
    else
      @price_lists = PriceList.kept.where(company: current_company).active_lists
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def scope
    Invoice.kept.where(company: current_company)
  end

  def load_invoice
    @invoice = scope.find(params[:id])
  end

  def default_currency
    AppSetting.fetch(company: current_company, category: "payments").get("currency") || "RUB"
  end

  def invoice_params
    raw = params.require(:invoice).permit(
      :ticket_id, :currency, :notes, :due_at, :status,
      :discount_percent, :tax_percent, :surcharge_percent, :surcharge_hidden,
      invoice_items_attributes: [ :id, :name, :description, :quantity, :unit_price_rub, :discount_percent, :surcharge_percent, :_destroy ]
    )
    if raw[:invoice_items_attributes]
      raw[:invoice_items_attributes].each do |_idx, item|
        next unless item.is_a?(ActionController::Parameters) || item.is_a?(Hash)
        if item[:unit_price_rub].present?
          item[:unit_price_cents] = (item.delete(:unit_price_rub).to_d * 100).to_i
        end
      end
    end
    raw
  end
end
