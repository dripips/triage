class ConversationMessage < ApplicationRecord
  belongs_to :ticket
  belongs_to :author, polymorphic: true, optional: true
  has_many_attached :files

  enum :message_type, { text: 0, system: 1, ai_suggestion: 2, file_attachment: 3 }

  validates :body, presence: true, unless: -> { files.attached? }

  scope :chronological, -> { order(:created_at) }
  scope :public_only,   -> { where(internal: false) }
  scope :for_customer,  -> { public_only.where.not(message_type: :ai_suggestion) }
  scope :unread_by,     ->(user) { where.not("read_by ? :uid", uid: user.id.to_s) }

  after_create_commit :broadcast_to_ticket

  def read_by?(user)
    read_by.key?(user.id.to_s)
  end

  def mark_read_by!(user)
    return if read_by?(user)
    self.read_by = read_by.merge(user.id.to_s => Time.current.iso8601)
    save!
  end

  def read_at_by(user)
    ts = read_by[user.id.to_s]
    ts ? Time.parse(ts) : nil
  end

  def self.mark_all_read!(ticket, user)
    where(ticket: ticket).unread_by(user).find_each { |m| m.mark_read_by!(user) }
  end

  def self.post_system_event!(ticket:, body:, actor: nil)
    create!(
      ticket: ticket,
      author: actor,
      body: body,
      message_type: :system,
      internal: false
    )
  end

  private

  def broadcast_to_ticket
    broadcast_append_to(
      "ticket_#{ticket_id}_chat",
      target: "chat-messages",
      partial: "conversation_messages/conversation_message",
      locals: { conversation_message: self }
    )
  end
end
