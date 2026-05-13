# Тип тикета определяет:
#   • workflow (states/transitions) — отличается для bug / complaint / IT-request
#   • custom fields schema — поля специфичные для типа (OS для IT, severity для bug)
#   • default priority + цвет для UI
#
# Workflow хранится в jsonb как:
#   {
#     "initial_state": "new",
#     "states": ["new", "triage", "in_progress", "resolved", "closed"],
#     "transitions": {
#       "triage":  { "from": ["new"], "to": "triage" },
#       "start":   { "from": ["triage"], "to": "in_progress" },
#       "resolve": { "from": ["in_progress"], "to": "resolved" },
#       "close":   { "from": ["resolved"], "to": "closed" }
#     }
#   }
class TicketType < ApplicationRecord
  include Discard::Model

  belongs_to :company
  has_many   :tickets, dependent: :restrict_with_error

  validates :key,
            presence: true,
            format: { with: /\A[a-z][a-z0-9_]*\z/ },
            length: { maximum: 50 }
  validates :name,             presence: true, length: { maximum: 120 }
  validates :default_priority, inclusion: { in: 0..3 }
  validates :color,            format: { with: /\A#[0-9A-Fa-f]{6}\z/ }

  scope :active_types, -> { where(active: true) }

  def initial_state
    workflow["initial_state"] || "new"
  end

  def states
    Array(workflow["states"]).map(&:to_s)
  end

  def transitions
    workflow["transitions"] || {}
  end

  def custom_field_keys
    Array(custom_fields_schema).map { |f| f["key"] }
  end
end
