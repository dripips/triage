module Settings
  class GeneralsController < SettingsController
    def show
      setting("general")
    end

    def update
      setting("general")
      @setting.merge!(setting_params)
      redirect_to settings_general_path, notice: t("settings.saved", default: "Настройки сохранены")
    end

    private

    def setting_params
      params.require(:app_setting).permit(:company_name, :default_locale, :timezone, :welcome_message)
    end
  end
end
