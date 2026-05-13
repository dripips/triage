module Settings
  class PaymentsController < SettingsController
    def show
      setting("payments")
    end

    def update
      setting("payments")
      @setting.merge!(payment_params)
      redirect_to settings_payment_path, notice: t("settings.saved", default: "Настройки сохранены")
    end

    private

    def payment_params
      params.require(:app_setting).permit(
        :enabled, :provider, :stripe_publishable_key, :stripe_secret_key,
        :yookassa_shop_id, :yookassa_secret_key,
        :tinkoff_terminal_key, :tinkoff_secret_key,
        :currency, :tax_rate_percent
      )
    end
  end
end
