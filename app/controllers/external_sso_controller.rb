# GET /sso?token=<jwt>&return_to=<path>
#
# Клиент (внешняя система) редиректит сюда юзера с подписанным JWT.
# Мы декодируем, мэтчим / создаём User по external_id + company,
# логиним через Devise, редиректим на return_to (whitelist same-host).
class ExternalSsoController < ApplicationController
  skip_before_action :authenticate_user!

  def callback
    user, err = ExternalSso.authenticate(company: current_company, token: params[:token])

    unless user
      Rails.logger.warn("[SSO] failed: #{err}")
      redirect_to new_user_session_path, alert: t("sso.failed", default: "Авторизация не удалась: %{e}", e: err)
      return
    end

    sign_in(user, event: :authentication)
    redirect_to safe_return_to, notice: t("sso.welcome", default: "Добро пожаловать")
  end

  private

  # Allowlist: только same-host пути; никаких внешних URL'ов.
  def safe_return_to
    raw = params[:return_to].to_s
    return root_path if raw.blank?
    return raw if raw.start_with?("/") && !raw.start_with?("//")
    root_path
  end
end
