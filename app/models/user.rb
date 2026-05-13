require "bcrypt"

class User < ApplicationRecord
  include Discard::Model

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :company, optional: true
  has_many :api_tokens, dependent: :destroy

  # Роли — agent / supervisor / admin / superadmin. Customer'ы (external)
  # пишут тикеты без auth через web-form / email, для них User не нужен.
  enum :role, { agent: 0, supervisor: 1, admin: 2, superadmin: 3 }

  validates :role, presence: true

  scope :staff, -> { where.not(role: nil) }

  def display_name
    email.split("@").first.humanize
  end

  def full_role_name
    I18n.t("roles.#{role}", default: role.humanize)
  end

  # Soft-delete: discarded юзеры не могут логиниться
  def active_for_authentication?
    super && discarded_at.nil?
  end

  def inactive_message
    discarded_at ? :locked : super
  end
end
