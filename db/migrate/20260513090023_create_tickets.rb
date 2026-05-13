class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.references :company,     null: false, foreign_key: true, index: true
      t.references :ticket_type, null: false, foreign_key: true, index: true
      # Reporter — polymorphic (User для staff, или ExternalContact / Guest для anonymous)
      t.references :reporter,    polymorphic: true, null: true, index: true
      # Assignee — User (staff). Nullable пока никто не назначен.
      t.references :assignee, foreign_key: { to_table: :users }, index: true

      t.integer  :priority,    null: false, default: 1               # 0..3
      t.string   :status,      null: false                            # AASM state per ticket-type
      t.string   :subject,     null: false, limit: 280
      t.text     :description
      t.jsonb    :custom_fields, null: false, default: {}
      t.jsonb    :metadata,      null: false, default: {}

      t.datetime :closed_at
      t.datetime :due_at
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :tickets, :created_at
    add_index :tickets, [ :company_id, :status ]
  end
end
