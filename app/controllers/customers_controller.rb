class CustomersController < ApplicationController
  before_action :require_staff!
  before_action :load_customer, only: %i[show edit update destroy]

  def index
    @customers = scope.customer_users.order(:name, :email)
  end

  def show; end

  def new
    @customer = scope.new(kind: :customer)
  end

  def create
    @customer = scope.new(customer_params.merge(kind: :customer, role: nil))
    @customer.password ||= SecureRandom.hex(10)
    if @customer.save
      redirect_to customers_path, notice: t("customers.created", default: "Клиент добавлен")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @customer.update(customer_params)
      redirect_to customers_path, notice: t("customers.updated", default: "Клиент обновлён")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @customer.discard
    redirect_to customers_path, notice: t("customers.disabled", default: "Клиент отключён")
  end

  private

  def scope
    User.kept.where(company: current_company)
  end

  def load_customer
    @customer = scope.find(params[:id])
  end

  def customer_params
    params.require(:user).permit(:email, :name, :locale, :external_id, :external_provider, :staff_notes)
  end

  def require_staff!
    redirect_to root_path, alert: t("pundit.not_authorized") unless current_user&.staff?
  end
end
