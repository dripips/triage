# Sentry-list доступных локалей. HRMS использует Language model в БД,
# но для Triage v0.3 хватает константного списка — language management
# (per-tenant enable/disable) переедет в Settings позже.
module TriageLocales
  AVAILABLE = [
    { code: "ru", flag: "ru", native_name: "Русский" },
    { code: "en", flag: "gb", native_name: "English" },
    { code: "de", flag: "de", native_name: "Deutsch" }
  ].freeze
end
