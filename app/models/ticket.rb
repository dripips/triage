class Ticket < ApplicationRecord
  include Discard::Model

  PRIORITIES = { low: 0, normal: 1, high: 2, urgent: 3 }.freeze
  enum :priority, PRIORITIES

  belongs_to :company
  belongs_to :ticket_type
  belongs_to :reporter, polymorphic: true, optional: true
  belongs_to :assignee, class_name: "User", optional: true
  has_many   :comments, class_name: "TicketComment", dependent: :destroy

  validates :subject, presence: true, length: { maximum: 280 }
  validates :status,  presence: true

  scope :open,   -> { where.not(closed_at: nil) }
  scope :closed, -> { where.not(closed_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  before_validation :set_initial_status,    on: :create
  before_validation :set_default_priority,  on: :create

  # AASM-стейт-машина инициализируется из ticket_type.workflow (jsonb).
  # Простой transition без gem'а AASM — потому что states/transitions
  # каждого тикета зависят от его типа, а AASM требует static class config.
  #
  # Использование:
  #   ticket.can_transition?("triage")  → true / false
  #   ticket.transition!("triage", actor: user, comment: "...")
  #
  # При valid transition'е:
  #   • меняется status
  #   • если status в "closed-states" — closed_at = now
  #   • создаётся system-comment в ленте
  def can_transition?(event_name)
    event = ticket_type.transitions[event_name.to_s]
    return false unless event
    Array(event["from"]).map(&:to_s).include?(status.to_s)
  end

  def transition!(event_name, actor: nil, comment: nil)
    raise ArgumentError, "invalid transition #{event_name} from #{status}" unless can_transition?(event_name)

    event = ticket_type.transitions[event_name.to_s]
    new_status = event["to"].to_s

    transaction do
      update!(
        status:    new_status,
        closed_at: (terminal_state?(new_status) ? Time.current : closed_at)
      )

      comments.create!(
        author: actor,
        body:   build_transition_body(event_name, new_status, comment),
        internal: true
      )
    end
  end

  def open?
    closed_at.nil?
  end

  def closed?
    closed_at.present?
  end

  private

  def set_initial_status
    self.status ||= ticket_type&.initial_state
  end

  def set_default_priority
    self.priority ||= ticket_type&.default_priority
  end

  def terminal_state?(state)
    %w[closed resolved cancelled].include?(state.to_s)
  end

  def build_transition_body(event_name, new_status, user_comment)
    base = "Status: #{status} → #{new_status} (#{event_name})"
    user_comment.present? ? "#{base}\n\n#{user_comment}" : base
  end
end
