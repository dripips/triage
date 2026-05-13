module Settings
  class NotificationsController < SettingsController
    def show
      setting("notifications")
    end

    def update
      setting("notifications")
      @setting.merge!(notification_params)
      redirect_to settings_notification_path, notice: t("settings.saved", default: "Настройки сохранены")
    end

    private

    def notification_params
      params.require(:app_setting).permit(
        :email_on_new_ticket, :email_on_comment, :email_on_transition,
        :in_app_enabled, :digest_frequency
      )
    end
  end
end
