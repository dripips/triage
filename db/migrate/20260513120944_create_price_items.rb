class CreatePriceItems < ActiveRecord::Migration[8.1]
  def change
    create_table :price_items do |t|
      t.references :price_list, null: false, foreign_key: true
      t.string   :name,         null: false
      t.text     :description
      t.integer  :amount_cents, null: false, default: 0
      t.string   :currency,     null: false, default: "RUB"
      t.integer  :position,     null: false, default: 0
      t.boolean  :active,       null: false, default: true

      t.timestamps
    end
    add_index :price_items, [ :price_list_id, :position ]
  end
end
