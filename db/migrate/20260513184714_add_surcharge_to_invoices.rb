class AddSurchargeToInvoices < ActiveRecord::Migration[8.1]
  def change
    add_column :invoices, :surcharge_percent, :decimal, precision: 5, scale: 2, null: false, default: 0
    add_column :invoices, :surcharge_cents,   :integer, null: false, default: 0
    add_column :invoices, :surcharge_hidden,  :boolean, null: false, default: true
  end
end
