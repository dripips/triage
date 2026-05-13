module Settings
  class LanguagesController < SettingsController
    def index
      @languages = TriageLocales::AVAILABLE
      @enabled = enabled_codes
    end

    def toggle
      code = params[:code].to_s
      return redirect_to settings_languages_path unless TriageLocales::AVAILABLE.any? { |l| l[:code] == code }

      setting = AppSetting.fetch(company: current_company, category: "general")
      current = setting.get("enabled_locales") || TriageLocales::AVAILABLE.map { |l| l[:code] }

      if current.include?(code) && current.size > 1
        current.delete(code)
      elsif !current.include?(code)
        current << code
      end

      setting.set!("enabled_locales", current)
      redirect_to settings_languages_path, notice: t("settings.saved")
    end

    private

    def enabled_codes
      setting = AppSetting.fetch(company: current_company, category: "general")
      setting.get("enabled_locales") || TriageLocales::AVAILABLE.map { |l| l[:code] }
    end
  end
end
