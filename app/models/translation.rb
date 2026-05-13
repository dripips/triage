class Translation < ApplicationRecord
  belongs_to :company

  validates :locale, presence: true
  validates :key,    presence: true
  validates :key,    uniqueness: { scope: [ :company_id, :locale ] }

  scope :for_locale, ->(locale) { where(locale: locale.to_s) }
  scope :search,     ->(q) { where("key ILIKE :q OR value ILIKE :q", q: "%#{q}%") }
end
