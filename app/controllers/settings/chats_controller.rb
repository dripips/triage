module Settings
  class ChatsController < SettingsController
    def show
      setting("chat")
    end

    def update
      setting("chat")
      @setting.merge!(chat_params)
      redirect_to settings_chat_path, notice: t("settings.saved", default: "Настройки сохранены")
    end

    private

    def chat_params
      params.require(:app_setting).permit(
        :enabled, :allow_customer_chat, :show_typing_indicator,
        :auto_assign_on_reply, :max_idle_minutes, :welcome_message
      )
    end
  end
end
