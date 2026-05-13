class Company < ApplicationRecord
  include Discard::Model

  has_many :users, dependent: :destroy

  validates :name, presence: true, length: { maximum: 120 }
  validates :subdomain,
            uniqueness: { allow_nil: true },
            format: { with: /\A[a-z0-9-]{1,50}\z/, allow_nil: true }
end
