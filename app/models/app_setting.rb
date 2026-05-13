class AppSetting < ApplicationRecord
  belongs_to :company

  CATEGORIES = %w[general ai notifications sso api price_lists].freeze

  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :category, uniqueness: { scope: :company_id }

  def self.fetch(company:, category:)
    find_or_initialize_by(company: company, category: category.to_s).tap do |s|
      s.data ||= {}
    end
  end

  def get(key)
    data[key.to_s]
  end

  def set(key, value)
    data[key.to_s] = value
  end

  def set!(key, value)
    set(key, value)
    save!
  end

  def merge!(hash)
    self.data = data.merge(hash.transform_keys(&:to_s))
    save!
  end
end
