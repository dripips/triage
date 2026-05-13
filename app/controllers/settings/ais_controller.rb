module Settings
  class AisController < SettingsController
    def show
      setting("ai")
      @ai = TicketAi.new(company: current_company)
      @usage_this_month = AiRun.monthly_cost(current_company)
      @by_kind  = AiRun.by_kind_stats(current_company)
      @by_model = AiRun.by_model_stats(current_company)
      @recent   = AiRun.where(company: current_company).recent.limit(20)
    end

    def update
      setting("ai")
      @setting.merge!(filtered_params)
      redirect_to settings_ai_path, notice: t("settings.saved", default: "Настройки сохранены")
    end

    private

    def filtered_params
      raw = params.require(:app_setting).permit(
        :enabled, :mode, :provider, :model, :api_key, :api_base_url,
        :temperature, :max_tokens, :monthly_budget_usd,
        :autonomous_mode, :chat_monitoring, :auto_assign,
        :auto_categorize, :auto_suggest_reply, :auto_summarize, :auto_sentiment,
        :system_prompt
      )
      raw[:api_key] = @setting.get("api_key") if raw[:api_key].blank?
      raw
    end
  end
end
