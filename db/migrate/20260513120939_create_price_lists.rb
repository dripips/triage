class CreatePriceLists < ActiveRecord::Migration[8.1]
  def change
    create_table :price_lists do |t|
      t.references :company, null: false, foreign_key: true
      t.string   :name,     null: false
      t.boolean  :active,   null: false, default: true
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :price_lists, :discarded_at
  end
end
