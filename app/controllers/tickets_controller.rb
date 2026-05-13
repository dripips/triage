class TicketsController < ApplicationController
  before_action :load_ticket, only: %i[show transition]

  def index
    @tickets = filtered_scope.recent.includes(:ticket_type, :assignee, :reporter).limit(100)
    @open_count   = scope.where(closed_at: nil).count
    @closed_count = scope.where.not(closed_at: nil).count
  end

  def show
    @comments    = @ticket.comments.kept.chronological.includes(:author)
    @new_comment = @ticket.comments.new
    @transitions = @ticket.ticket_type.transitions.select do |_event, cfg|
      Array(cfg["from"]).include?(@ticket.status)
    end
  end

  def new
    @ticket = scope.new(ticket_type_id: params[:ticket_type_id] || default_ticket_type&.id)
  end

  def create
    @ticket = scope.new(ticket_params.merge(reporter: current_user))
    if @ticket.save
      redirect_to ticket_path(@ticket), notice: t("tickets.created", default: "Тикет создан")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def transition
    event = params[:event].to_s
    unless @ticket.can_transition?(event)
      respond_to do |format|
        format.turbo_stream { render :transition_error, status: :unprocessable_entity }
        format.html { redirect_to ticket_path(@ticket), alert: "Invalid transition: #{event}" }
      end
      return
    end
    @ticket.transition!(event, actor: current_user)

    respond_to do |format|
      format.turbo_stream  # → app/views/tickets/transition.turbo_stream.erb
      format.html { redirect_to ticket_path(@ticket), notice: t("tickets.transitioned", default: "Статус обновлён") }
    end
  end

  private

  def scope
    Ticket.kept.where(company: current_company)
  end

  def filtered_scope
    s = scope
    case params[:scope].to_s
    when "mine"   then s = s.where(assignee_id: current_user&.id)
    when "open"   then s = s.where(closed_at: nil)
    when "closed" then s = s.where.not(closed_at: nil)
    end
    s = s.where(priority: Ticket.priorities[params[:priority]]) if Ticket.priorities.key?(params[:priority])
    s = s.where(ticket_type_id: params[:ticket_type_id]) if params[:ticket_type_id].present?
    s = s.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
    s
  end

  helper_method :filter_params, :filter_active?

  def filter_params
    params.permit(:scope, :ticket_type_id, :priority, :assignee_id)
  end

  def filter_active?
    params[:ticket_type_id].present? || params[:priority].present? || params[:assignee_id].present?
  end

  def load_ticket
    @ticket = scope.find(params[:id])
  end

  def ticket_params
    params.require(:ticket).permit(:subject, :description, :ticket_type_id, :priority, :assignee_id)
  end

  def default_ticket_type
    @default_ticket_type ||= TicketType.where(company: current_company).active_types.first
  end
end
