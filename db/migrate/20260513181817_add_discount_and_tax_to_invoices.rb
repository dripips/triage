class AddDiscountAndTaxToInvoices < ActiveRecord::Migration[8.1]
  def change
    add_column :invoices, :discount_percent, :decimal, precision: 5, scale: 2, null: false, default: 0
    add_column :invoices, :tax_percent,      :decimal, precision: 5, scale: 2, null: false, default: 0
    add_column :invoices, :discount_cents,   :integer, null: false, default: 0
  end
end
