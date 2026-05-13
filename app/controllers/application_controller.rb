class ApplicationController < ActionController::Base
  include Pundit::Authorization

  allow_browser versions: :modern
  stale_when_importmap_changes

  before_action :authenticate_user!
  before_action :set_locale
  before_action :sync_current_user
  before_action :set_paper_trail_whodunnit

  rescue_from Pundit::NotAuthorizedError,   with: :user_not_authorized
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  helper_method :current_theme, :current_company

  # current_company — единая точка получения тенанта. Берётся из
  # Current.company (TenantResolver middleware ставит по subdomain'у),
  # fallback на Company.kept.first для single-tenant установок.
  def current_company
    Current.company ||= Company.kept.first
  end

  def default_url_options(options = {})
    { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }.merge(options)
  end

  private

  def sync_current_user
    Current.user = current_user if respond_to?(:current_user)
  end

  def set_locale
    locale = locale_from_params || locale_from_user || I18n.default_locale
    I18n.locale = locale
  end

  def locale_from_params
    raw = params[:locale].to_s
    raw if I18n.available_locales.map(&:to_s).include?(raw)
  end

  def locale_from_user
    return nil unless user_signed_in?
    raw = current_user.locale.to_s
    raw if I18n.available_locales.map(&:to_s).include?(raw)
  end

  def current_theme
    cookies[:theme].presence_in(%w[light dark]) || "auto"
  end

  def user_not_authorized
    flash[:alert] = t("pundit.not_authorized", default: "Доступ запрещён")
    redirect_back fallback_location: root_path
  end

  def record_not_found
    respond_to do |format|
      format.html { render template: "errors/not_found", status: :not_found, layout: "application" }
      format.json { render json: { error: "not_found" }, status: :not_found }
      format.any  { head :not_found }
    end
  end
end
