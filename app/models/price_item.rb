class PriceItem < ApplicationRecord
  belongs_to :price_list

  validates :name, presence: true
  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }

  scope :active_items, -> { where(active: true) }
  scope :by_position,  -> { order(:position, :name) }

  def amount
    amount_cents / 100.0
  end

  def formatted_price
    "#{amount} #{currency}"
  end
end
