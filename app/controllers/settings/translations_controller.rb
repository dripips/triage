module Settings
  class TranslationsController < SettingsController
    def index
      @locale = params[:locale_filter].presence || I18n.default_locale.to_s
      @query  = params[:q].to_s.strip

      yaml_keys = flatten_yaml(@locale)
      db_overrides = Translation.where(company: current_company, locale: @locale)
                                .index_by(&:key)

      @entries = yaml_keys.map do |key, yaml_val|
        db = db_overrides[key]
        { key: key, yaml_value: yaml_val, db_value: db&.value, effective: db&.value || yaml_val, id: db&.id }
      end

      db_overrides.each do |key, db|
        next if yaml_keys.key?(key)
        @entries << { key: key, yaml_value: nil, db_value: db.value, effective: db.value, id: db.id }
      end

      @entries.sort_by! { |e| e[:key] }
      @entries.select! { |e| e[:key].include?(@query) || e[:effective].to_s.include?(@query) } if @query.present?
      @total = @entries.size
      @entries = @entries.first(500)
    end

    def update
      key = params[:key].to_s
      value = params[:value].to_s
      locale = params[:locale_code].to_s

      t = Translation.find_or_initialize_by(company: current_company, locale: locale, key: key)
      t.value = value
      t.save!

      redirect_to settings_translations_path(locale_filter: locale, q: params[:q]),
                  notice: t("settings.translations.saved")
    end

    private

    def flatten_yaml(locale)
      translations = I18n.backend.send(:translations)[locale.to_sym] || {}
      flatten_hash(translations, locale)
    end

    def flatten_hash(hash, prefix = "")
      result = {}
      hash.each do |k, v|
        full_key = prefix.present? ? "#{prefix}.#{k}" : k.to_s
        if v.is_a?(Hash)
          result.merge!(flatten_hash(v, full_key))
        else
          result[full_key] = v.to_s
        end
      end
      result
    end
  end
end
