class TicketComment < ApplicationRecord
  include Discard::Model

  belongs_to :ticket
  belongs_to :author, polymorphic: true, optional: true

  validates :body, presence: true, length: { maximum: 10_000 }

  scope :visible_to_reporter, -> { where(internal: false) }
  scope :chronological,       -> { order(:created_at) }
end
