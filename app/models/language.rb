class Language < ApplicationRecord
  include Discard::Model

  belongs_to :company

  enum :direction, { ltr: 0, rtl: 1 }

  validates :code, presence: true, format: { with: /\A[a-z]{2}(-[A-Z]{2})?\z/ },
                   uniqueness: { scope: :company_id }
  validates :native_name, presence: true

  scope :enabled, -> { kept.where(enabled: true).order(:position, :native_name) }
  scope :ordered, -> { kept.order(:position, :native_name) }

  def self.default_for(company)
    where(company: company).enabled.find_by(is_default: true) ||
      where(company: company).enabled.first
  end

  def self.available_codes(company)
    where(company: company).enabled.pluck(:code)
  end

  def default?
    is_default
  end
end
