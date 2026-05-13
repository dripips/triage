class InvoiceItem < ApplicationRecord
  belongs_to :invoice

  validates :name, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }

  before_save :compute_total

  def unit_price
    unit_price_cents / 100.0
  end

  def total
    total_cents / 100.0
  end

  private

  def compute_total
    self.total_cents = (quantity * unit_price_cents).to_i
  end
end
