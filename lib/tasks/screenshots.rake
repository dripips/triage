namespace :screenshots do
  WIDTH  = 1440
  HEIGHT = 900
  WAIT   = 2.5
  SCREENS_DIR = Rails.root.join("docs", "screenshots")
  APP_URL  = ENV["APP_URL"].presence || "http://localhost:4500"
  EMAIL    = "admin@triage.local"
  PASSWORD = "password123"

  BEFORE_LOGIN = [
    { file: "01-sign-in", path: "/users/sign_in" }
  ].freeze

  AFTER_LOGIN = [
    { file: "02-tickets",        path: "/tickets" },
    { file: "03-ticket-show",    path: "/tickets/1" },
    { file: "04-ticket-new",     path: "/tickets/new" },
    { file: "05-team",           path: "/users" },
    { file: "06-customers",      path: "/customers" },
    { file: "07-ticket-types",   path: "/ticket_types" },
    { file: "08-invoices",       path: "/invoices" },
    { file: "09-settings",       path: "/settings" },
    { file: "10-settings-ai",    path: "/settings/ai" },
    { file: "11-knowledge-base", path: "/settings/knowledge_articles" },
    { file: "12-price-lists",    path: "/settings/price_lists" },
    { file: "13-notifications",  path: "/notifications" },
    { file: "14-languages",      path: "/settings/languages" }
  ].freeze

  desc "Take Triage README screenshots"
  task all: :environment do
    require "selenium-webdriver"
    require "fileutils"
    FileUtils.mkdir_p(SCREENS_DIR)

    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless=new")
    options.add_argument("--disable-gpu")
    options.add_argument("--hide-scrollbars")
    options.add_argument("--force-device-scale-factor=1")
    options.add_argument("--window-size=#{WIDTH},#{HEIGHT}")
    driver = Selenium::WebDriver.for(:chrome, options: options)
    driver.manage.window.resize_to(WIDTH, HEIGHT)

    take_shots(driver, BEFORE_LOGIN)

    driver.navigate.to("#{APP_URL}/users/sign_in")
    sleep 1
    driver.find_element(id: "user_email").send_keys(EMAIL)
    driver.find_element(id: "user_password").send_keys(PASSWORD)
    driver.find_element(css: "input[type='submit']").click
    sleep 2

    take_shots(driver, AFTER_LOGIN)
  ensure
    driver&.quit
  end

  def take_shots(driver, shots)
    shots.each do |shot|
      url  = "#{APP_URL}#{shot[:path]}"
      file = SCREENS_DIR.join("#{shot[:file]}.png")
      puts "→ #{shot[:file]}  #{url}"
      driver.navigate.to(url)
      sleep WAIT
      driver.save_screenshot(file.to_s)
      puts "  ✓ #{file.basename}"
    rescue StandardError => e
      puts "  ✗ #{e.class}: #{e.message.first(120)}"
    end
  end
end

desc "Take Triage README screenshots"
task screenshots: "screenshots:all"
