require "bcrypt"

class User < ApplicationRecord
  include Discard::Model

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :company, optional: true
  has_many :api_tokens, dependent: :destroy
  has_many :in_app_notifications, as: :recipient, dependent: :destroy

  # kind: 0 = staff (helpdesk-команда), 1 = customer (внешний клиент).
  enum :kind, { staff: 0, customer: 1 }, prefix: :kind, default: :staff

  # Роли — agent / supervisor / admin / superadmin. Заполняется только
  # для staff; у customer'ов role NULL.
  enum :role, { agent: 0, supervisor: 1, admin: 2, superadmin: 3 }

  validates :role, presence: true, if: -> { kind_staff? }
  validates :name, presence: true

  scope :staff_users,    -> { where(kind: kinds[:staff]) }
  scope :customer_users, -> { where(kind: kinds[:customer]) }

  def display_name
    name.presence || email.split("@").first.humanize
  end

  def role_label
    if kind_customer?
      I18n.t("roles.customer", default: "Клиент")
    else
      I18n.t("roles.#{role}", default: role.to_s.humanize)
    end
  end

  # Шорткаты для UI/policies — `current_user.staff?` / `.customer?`.
  def staff?;       kind_staff?;          end
  def customer?;    kind_customer?;       end
  def admin?;       kind_staff? && (role == "admin");      end
  def superadmin?;  kind_staff? && (role == "superadmin"); end

  # Soft-delete: discarded юзеры не могут логиниться
  def active_for_authentication?
    super && discarded_at.nil?
  end

  def inactive_message
    discarded_at ? :locked : super
  end
end
