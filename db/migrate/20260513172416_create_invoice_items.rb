class CreateInvoiceItems < ActiveRecord::Migration[8.1]
  def change
    create_table :invoice_items do |t|
      t.references :invoice, null: false, foreign_key: true
      t.string   :name,            null: false
      t.text     :description
      t.decimal  :quantity,         null: false, default: 1, precision: 10, scale: 2
      t.integer  :unit_price_cents, null: false, default: 0
      t.integer  :total_cents,      null: false, default: 0
      t.integer  :position,         null: false, default: 0

      t.timestamps
    end
  end
end
