class NotificationDelivery
  def self.deliver(notification)
    new(notification).deliver_all
  end

  def initialize(notification)
    @notification = notification
    @company = notification.recipient.respond_to?(:company) ? notification.recipient.company : nil
  end

  def deliver_all
    deliver_email if email_enabled?
    deliver_telegram if telegram_enabled?
    deliver_slack if slack_enabled?
  end

  private

  def settings(category)
    return nil unless @company
    AppSetting.fetch(company: @company, category: category)
  end

  def notification_settings
    @notification_settings ||= settings("notifications")
  end

  def email_enabled?
    return false unless notification_settings
    case @notification.action
    when "ticket_created"      then notification_settings.get("email_on_new_ticket") != "0"
    when "comment_added", "message_received" then notification_settings.get("email_on_comment") != "0"
    when "ticket_transitioned" then notification_settings.get("email_on_transition") == "1"
    else false
    end
  end

  def telegram_enabled?
    s = settings("notifications")
    s&.get("telegram_enabled") == "1" && s&.get("telegram_bot_token").present?
  end

  def slack_enabled?
    s = settings("notifications")
    s&.get("slack_enabled") == "1" && s&.get("slack_webhook_url").present?
  end

  def deliver_email
    NotificationMailer.notify(@notification).deliver_later
  rescue => e
    Rails.logger.error("[NotificationDelivery] email failed: #{e.message}")
  end

  def deliver_telegram
    s = settings("notifications")
    token = s.get("telegram_bot_token")
    chat_id = s.get("telegram_chat_id")
    return unless token.present? && chat_id.present?

    conn = Faraday.new(url: "https://api.telegram.org")
    conn.post("/bot#{token}/sendMessage") do |req|
      req.headers["Content-Type"] = "application/json"
      req.body = { chat_id: chat_id, text: telegram_text, parse_mode: "HTML" }.to_json
    end
  rescue => e
    Rails.logger.error("[NotificationDelivery] telegram failed: #{e.message}")
  end

  def deliver_slack
    s = settings("notifications")
    url = s.get("slack_webhook_url")
    return unless url.present?

    Faraday.post(url) do |req|
      req.headers["Content-Type"] = "application/json"
      req.body = { text: slack_text }.to_json
    end
  rescue => e
    Rails.logger.error("[NotificationDelivery] slack failed: #{e.message}")
  end

  def telegram_text
    "<b>#{@notification.action.humanize}</b>\n#{@notification.message}"
  end

  def slack_text
    "*#{@notification.action.humanize}*\n#{@notification.message}"
  end
end
