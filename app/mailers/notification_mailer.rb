class NotificationMailer < ApplicationMailer
  def notify(notification)
    @notification = notification
    @recipient = notification.recipient
    return unless @recipient.respond_to?(:email) && @recipient.email.present?

    mail(
      to: @recipient.email,
      subject: "[Triage] #{notification.action.humanize}: #{notification.message.to_s.truncate(80)}"
    )
  end
end
