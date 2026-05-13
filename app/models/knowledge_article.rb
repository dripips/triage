class KnowledgeArticle < ApplicationRecord
  include Discard::Model

  belongs_to :company
  belongs_to :ticket_type, optional: true

  validates :title, presence: true

  scope :published,    -> { where(published: true) }
  scope :by_position,  -> { order(:position, :title) }
  scope :for_type,     ->(tt) { where(ticket_type: [ tt, nil ]) }
end
