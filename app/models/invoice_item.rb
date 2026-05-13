class InvoiceItem < ApplicationRecord
  belongs_to :invoice

  validates :name, presence: true
  validates :quantity, numericality: { greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }

  before_save :compute_total

  def unit_price  = unit_price_cents / 100.0
  def total       = total_cents / 100.0

  def effective_price_cents
    base = (quantity.to_d * unit_price_cents).to_i
    after_discount = base - (base * discount_percent.to_d / 100).to_i
    after_discount + (after_discount * surcharge_percent.to_d / 100).to_i
  end

  private

  def compute_total
    self.total_cents = effective_price_cents
  end
end
