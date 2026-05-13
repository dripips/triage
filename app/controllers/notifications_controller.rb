class NotificationsController < ApplicationController
  def index
    @notifications = current_user.in_app_notifications.recent.limit(50)
  end

  def mark_read
    current_user.in_app_notifications.unread.update_all(read_at: Time.current)
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.replace("notifications-badge", partial: "shared/notifications_badge")
      }
      format.html { redirect_to notifications_path }
    end
  end
end
