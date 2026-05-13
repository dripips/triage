class SettingsController < ApplicationController
  before_action :require_admin!

  private

  def require_admin!
    return if current_user&.admin? || current_user&.superadmin?
    redirect_to root_path, alert: t("pundit.not_authorized")
  end

  def setting(category)
    @setting = AppSetting.fetch(company: current_company, category: category)
  end
end
