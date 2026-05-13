class AddExternalAuthToUsers < ActiveRecord::Migration[8.1]
  def change
    # External SSO mapping: при первом SSO-логине создаём User c external_id
    # из claims; при последующих — обновляем email/name из токена.
    # external_provider — на будущее (OIDC / OAuth / SAML), пока всегда "jwt".
    add_column :users, :external_id,       :string
    add_column :users, :external_provider, :string, default: "jwt"
    add_index  :users, [ :external_provider, :external_id ], unique: true,
                                                              where: "external_id IS NOT NULL"
  end
end
