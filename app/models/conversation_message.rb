class ConversationMessage < ApplicationRecord
  belongs_to :ticket
  belongs_to :author, polymorphic: true, optional: true

  # 0=text, 1=system (transition/assignment), 2=ai_suggestion, 3=file
  enum :message_type, { text: 0, system: 1, ai_suggestion: 2, file_attachment: 3 }

  validates :body, presence: true

  scope :chronological, -> { order(:created_at) }
  scope :public_only,   -> { where(internal: false) }
  scope :for_customer,  -> { public_only.where.not(message_type: :ai_suggestion) }

  after_create_commit :broadcast_to_ticket

  private

  def broadcast_to_ticket
    broadcast_append_to(
      "ticket_#{ticket_id}_chat",
      target: "chat-messages",
      partial: "conversation_messages/message",
      locals: { message: self }
    )
  end
end
