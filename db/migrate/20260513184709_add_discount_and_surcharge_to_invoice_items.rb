class AddDiscountAndSurchargeToInvoiceItems < ActiveRecord::Migration[8.1]
  def change
    add_column :invoice_items, :discount_percent,   :decimal, precision: 5, scale: 2, null: false, default: 0
    add_column :invoice_items, :surcharge_percent,  :decimal, precision: 5, scale: 2, null: false, default: 0
  end
end
