source "https://rubygems.org"

# ── Rails 8 stack ─────────────────────────────────────────────────────────
gem "rails", "~> 8.1.3"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "dartsass-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[windows jruby]

# ── Solid: cache / queue / cable on Postgres ──────────────────────────────
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# ── Auth & authorization ──────────────────────────────────────────────────
gem "devise"
gem "devise-i18n"
gem "pundit"
gem "rotp"                  # TOTP 2FA
gem "rqrcode"               # QR for 2FA setup
gem "bcrypt", "~> 3.1.7"    # для API tokens
gem "jwt"                   # для external SSO endpoint

# ── Model essentials ──────────────────────────────────────────────────────
gem "paper_trail"           # audit log
gem "discard"               # soft delete
gem "aasm"                  # state machines (ticket workflows)

# ── Notifications ─────────────────────────────────────────────────────────
gem "noticed", "~> 3.0"

# ── AI / external ─────────────────────────────────────────────────────────
gem "faraday"
gem "faraday-retry"

# ── Boot speed + deploy ───────────────────────────────────────────────────
gem "bootsnap", require: false
gem "kamal",    require: false
gem "thruster", require: false

# ── Active Storage variants ──────────────────────────────────────────────
gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug",          platforms: %i[mri windows], require: "debug/prelude"
  gem "bundler-audit",  require: false
  gem "brakeman",       require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails", "~> 7.1"
  gem "factory_bot_rails"
  gem "capybara"
  gem "selenium-webdriver"
  gem "bullet"
end

group :development do
  gem "web-console"
  gem "rack-mini-profiler"
end
