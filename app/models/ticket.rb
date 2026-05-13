class Ticket < ApplicationRecord
  include Discard::Model

  PRIORITIES = { low: 0, normal: 1, high: 2, urgent: 3 }.freeze
  enum :priority, PRIORITIES

  belongs_to :company
  belongs_to :ticket_type
  belongs_to :reporter, polymorphic: true, optional: true
  belongs_to :assignee, class_name: "User", optional: true
  has_many   :comments, class_name: "TicketComment", dependent: :destroy
  has_many   :conversation_messages, dependent: :destroy
  has_many   :invoices, dependent: :nullify

  validates :subject, presence: true, length: { maximum: 280 }
  validates :status,  presence: true

  scope :open,   -> { where(closed_at: nil) }
  scope :closed, -> { where.not(closed_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  before_validation :set_initial_status,   on: :create
  before_validation :set_default_priority, on: :create

  def can_transition?(event_name)
    event = ticket_type.transitions[event_name.to_s]
    return false unless event
    Array(event["from"]).map(&:to_s).include?(status.to_s)
  end

  def transition!(event_name, actor: nil)
    raise ArgumentError, "invalid transition #{event_name} from #{status}" unless can_transition?(event_name)

    event = ticket_type.transitions[event_name.to_s]
    old_status = status
    new_status = event["to"].to_s

    transaction do
      update!(
        status:    new_status,
        closed_at: (terminal_state?(new_status) ? Time.current : closed_at)
      )

      body = I18n.t(
        "ticket_system.transition",
        actor: actor&.display_name || I18n.t("system_user", default: "Система"),
        from: I18n.t("ticket_states.#{old_status}", default: old_status.humanize),
        to: I18n.t("ticket_states.#{new_status}", default: new_status.humanize),
        default: "%{actor} изменил статус: %{from} → %{to}"
      )

      comments.create!(author: actor, body: body, internal: true)

      if actor && assignee && assignee != actor
        notify!(assignee, actor: actor, action: "ticket_transitioned",
                message: "#{actor.display_name}: #{I18n.t("ticket_states.#{old_status}")} → #{I18n.t("ticket_states.#{new_status}")}")
      end
    end
  end

  def assign_to!(new_assignee, actor: nil)
    old_assignee = assignee
    transaction do
      update!(assignee: new_assignee)

      body = if new_assignee == actor
        I18n.t("ticket_system.self_assign",
               actor: actor&.display_name,
               default: "%{actor} взял тикет в работу")
      else
        I18n.t("ticket_system.assigned",
               actor: actor&.display_name || I18n.t("system_user", default: "Система"),
               assignee: new_assignee.display_name,
               default: "%{actor} назначил на %{assignee}")
      end

      comments.create!(author: actor, body: body, internal: true)

      if new_assignee != actor
        notify!(new_assignee, actor: actor, action: "ticket_assigned",
                message: I18n.t("ticket_system.assigned_notification",
                                ticket: "##{id} #{subject.truncate(40)}",
                                default: "Вам назначен тикет %{ticket}"))
      end
    end
  end

  def open?  = closed_at.nil?
  def closed? = closed_at.present?

  private

  def set_initial_status
    self.status ||= ticket_type&.initial_state
  end

  def set_default_priority
    self.priority ||= ticket_type&.default_priority
  end

  def terminal_state?(state)
    %w[closed resolved cancelled done].include?(state.to_s)
  end

  def notify!(recipient, actor:, action:, message:)
    InAppNotification.create!(
      recipient: recipient,
      actor: actor,
      action: action,
      notifiable: self,
      message: message,
      url: "/tickets/#{id}"
    )
  end
end
