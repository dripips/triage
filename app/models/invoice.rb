class Invoice < ApplicationRecord
  include Discard::Model

  belongs_to :company
  belongs_to :ticket, optional: true
  belongs_to :user
  has_many :invoice_items, dependent: :destroy

  accepts_nested_attributes_for :invoice_items, allow_destroy: true, reject_if: :all_blank

  enum :status, { draft: 0, sent: 1, paid: 2, overdue: 3, cancelled: 4 }

  validates :number, presence: true, uniqueness: { scope: :company_id }
  validates :currency, presence: true

  before_validation :generate_number, on: :create

  scope :recent, -> { order(created_at: :desc) }

  def subtotal = subtotal_cents / 100.0
  def discount = discount_cents / 100.0
  def tax      = tax_cents / 100.0
  def total    = total_cents / 100.0

  def formatted_total
    "#{total} #{currency}"
  end

  def recalculate_totals
    items_sum = invoice_items.reject(&:marked_for_destruction?).sum { |i| (i.quantity.to_d * i.unit_price_cents.to_i).to_i }
    self.subtotal_cents = items_sum
    self.discount_cents = (items_sum * discount_percent.to_d / 100).to_i
    after_discount = items_sum - discount_cents
    self.tax_cents = (after_discount * tax_percent.to_d / 100).to_i
    self.total_cents = after_discount + tax_cents
  end

  private

  def generate_number
    return if number.present?
    prefix = Time.current.strftime("%Y%m")
    seq = (company&.invoices&.where("number LIKE ?", "INV-#{prefix}-%")&.count || 0) + 1
    self.number = "INV-#{prefix}-#{seq.to_s.rjust(4, '0')}"
  end
end
