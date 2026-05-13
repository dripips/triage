class AddSsoToCompanies < ActiveRecord::Migration[8.1]
  def change
    # External SSO settings per tenant. Если у клиента есть своя система
    # auth (например, customer portal на их сайте) — он сможет логинить
    # юзеров в Triage через JWT-токен подписанный shared secret.
    add_column :companies, :sso_enabled,       :boolean, default: false, null: false
    add_column :companies, :sso_secret,        :string                                  # HMAC shared secret (HS256)
    add_column :companies, :sso_user_id_claim, :string,  default: "sub"                  # JWT-claim с external user_id
    add_column :companies, :sso_email_claim,   :string,  default: "email"
    add_column :companies, :sso_name_claim,    :string,  default: "name"
  end
end
