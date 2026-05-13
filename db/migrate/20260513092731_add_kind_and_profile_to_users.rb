class AddKindAndProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    # kind: 0 = staff (агент/админ helpdesk-команды), 1 = customer
    # (внешний клиент, пишет тикеты со стороны). У staff role обязательна;
    # customer-у role NULL.
    add_column :users, :kind, :integer, null: false, default: 0
    add_index  :users, :kind

    add_column :users, :name, :string unless column_exists?(:users, :name)
    unless column_exists?(:users, :locale)
      add_column :users, :locale, :string, default: "ru", null: false
    end

    change_column_null :users, :role, true
  end
end
