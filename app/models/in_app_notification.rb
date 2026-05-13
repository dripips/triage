class InAppNotification < ApplicationRecord
  belongs_to :recipient, polymorphic: true
  belongs_to :actor,     polymorphic: true, optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  ACTIONS = %w[
    ticket_created ticket_assigned ticket_transitioned
    comment_added message_received invoice_created
  ].freeze

  validates :action, presence: true

  scope :unread,  -> { where(read_at: nil) }
  scope :read,    -> { where.not(read_at: nil) }
  scope :recent,  -> { order(created_at: :desc) }

  def read?
    read_at.present?
  end

  def mark_read!
    update!(read_at: Time.current) unless read?
  end

  after_create_commit :broadcast_to_recipient

  private

  def broadcast_to_recipient
    broadcast_prepend_to(
      "notifications_#{recipient_type}_#{recipient_id}",
      target: "notifications-list",
      partial: "shared/notification_item",
      locals: { notification: self }
    )
  end
end
