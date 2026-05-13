class CreateTicketTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_types do |t|
      t.references :company, null: false, foreign_key: true, index: true
      t.string   :key,                 null: false                    # "bug" / "complaint" / "it_request"
      t.string   :name,                null: false                    # localized display name
      t.text     :description
      t.jsonb    :workflow,            null: false, default: {}        # AASM states + transitions
      t.jsonb    :custom_fields_schema, null: false, default: []        # array of { key, label, type, required }
      t.integer  :default_priority,    null: false, default: 1         # 0..3 (low / normal / high / urgent)
      t.string   :color,               null: false, default: "#0A84FF"
      t.boolean  :active,              null: false, default: true
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :ticket_types, [ :company_id, :key ], unique: true
  end
end
