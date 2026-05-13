class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string   :name,           null: false
      t.string   :code
      t.string   :subdomain
      t.string   :default_locale, default: "ru"
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :companies, :subdomain, unique: true, where: "subdomain IS NOT NULL"
    add_index :companies, :code,      unique: true, where: "code IS NOT NULL"
  end
end
