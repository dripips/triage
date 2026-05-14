class UsersController < ApplicationController
  before_action :require_staff!
  before_action :load_user, only: %i[show edit update destroy]

  def index
    @users = scope.staff_users.order(:name, :email)
  end

  def show; end

  def new
    @user = scope.new(kind: :staff, role: :agent)
  end

  def create
    @user = scope.new(user_params.merge(kind: :staff))
    @user.password ||= SecureRandom.hex(10) if @user.password.blank?
    if @user.save
      redirect_to users_path, notice: t("users.created", default: "Сотрудник добавлен")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: t("users.updated", default: "Профиль обновлён")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.discard
    redirect_to users_path, notice: t("users.disabled", default: "Сотрудник отключён")
  end

  private

  def scope
    User.kept.where(company: current_company)
  end

  def load_user
    @user = scope.find(params[:id])
  end

  def user_params
    permitted = [ :email, :name, :locale, :password, :password_confirmation ]
    permitted << :role if current_user&.admin? || current_user&.superadmin?
    params.require(:user).permit(permitted)
  end

  def require_staff!
    redirect_to root_path, alert: t("pundit.not_authorized") unless current_user&.staff?
  end
end
