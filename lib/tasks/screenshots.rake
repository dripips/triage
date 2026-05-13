# Скриншоты для README. Запускать при сервере на :4500.
#   bin/rails screenshots

namespace :screenshots do
  WIDTH  = 1440
  HEIGHT = 900
  WAIT   = 2.0
  SCREENS_DIR = Rails.root.join("docs", "screenshots")
  APP_URL  = ENV["APP_URL"].presence || "http://localhost:4500"
  EMAIL    = "agent@triage.local"
  PASSWORD = "password123"

  SHOTS = [
    { file: "01-tickets",        path: "/tickets" },
    { file: "02-ticket-show",    path: "/tickets/1" },
    { file: "03-ticket-new",     path: "/tickets/new" },
    { file: "04-sign-in",        path: "/users/sign_in", skip_login: true }
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

    # Login first (use auth-required shots)
    driver.navigate.to("#{APP_URL}/users/sign_in")
    sleep 1
    driver.find_element(id: "user_email").send_keys(EMAIL)
    driver.find_element(id: "user_password").send_keys(PASSWORD)
    driver.find_element(css: "input[type='submit']").click
    sleep 1.5

    SHOTS.each do |shot|
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
  ensure
    driver&.quit
  end
end

desc "Take Triage README screenshots — alias for screenshots:all"
task screenshots: "screenshots:all"
