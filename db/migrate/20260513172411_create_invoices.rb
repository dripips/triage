class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.references :company, null: false, foreign_key: true
      t.references :ticket,  null: true,  foreign_key: true
      t.references :user,    null: false, foreign_key: true
      t.string   :number,        null: false
      t.integer  :status,        null: false, default: 0
      t.integer  :subtotal_cents, null: false, default: 0
      t.integer  :tax_cents,     null: false, default: 0
      t.integer  :total_cents,   null: false, default: 0
      t.string   :currency,      null: false, default: "RUB"
      t.text     :notes
      t.datetime :paid_at
      t.datetime :due_at
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :invoices, [ :company_id, :number ], unique: true
    add_index :invoices, :discarded_at
    add_index :invoices, :status
  end
end
