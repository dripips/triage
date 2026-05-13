module Settings
  class SsosController < SettingsController
    def show
      setting("sso")
    end

    def update
      setting("sso")
      @setting.merge!(sso_params)
      redirect_to settings_sso_path, notice: t("settings.saved", default: "Настройки сохранены")
    end

    private

    def sso_params
      params.require(:app_setting).permit(
        :enabled, :secret, :algorithm, :user_id_claim, :email_claim, :name_claim,
        :auto_provision, :default_role
      )
    end
  end
end
