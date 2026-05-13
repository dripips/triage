class PriceList < ApplicationRecord
  include Discard::Model

  belongs_to :company
  has_many :price_items, dependent: :destroy

  validates :name, presence: true

  scope :active_lists, -> { where(active: true) }
end
