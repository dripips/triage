module Settings
  class LanguagesController < SettingsController
    before_action :load_language, only: %i[edit update destroy set_default toggle]

    def index
      @languages = scope.ordered
      @language = scope.new(direction: :ltr, enabled: true)
    end

    def create
      @language = scope.new(language_params)
      if @language.save
        redirect_to settings_languages_path, notice: t("settings.languages.created")
      else
        @languages = scope.ordered
        render :index, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @language.update(language_params)
        redirect_to settings_languages_path, notice: t("settings.languages.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @language.default?
        redirect_to settings_languages_path, alert: t("settings.languages.cant_delete_default")
      else
        @language.discard
        redirect_to settings_languages_path, notice: t("settings.languages.deleted")
      end
    end

    def set_default
      scope.where(company: current_company).update_all(is_default: false)
      @language.update!(is_default: true, enabled: true)
      redirect_to settings_languages_path, notice: t("settings.languages.default_set")
    end

    def toggle
      return redirect_to settings_languages_path, alert: t("settings.languages.cant_disable_default") if @language.default? && @language.enabled?
      @language.update!(enabled: !@language.enabled?)
      redirect_to settings_languages_path
    end

    private

    def scope
      Language.kept.where(company: current_company)
    end

    def load_language
      @language = scope.find(params[:id])
    end

    def language_params
      params.require(:language).permit(:code, :native_name, :english_name, :flag, :direction, :enabled, :position)
    end
  end
end
