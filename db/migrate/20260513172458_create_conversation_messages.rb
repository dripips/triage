class CreateConversationMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :conversation_messages do |t|
      t.references :ticket,  null: false, foreign_key: true
      t.references :author,  polymorphic: true, null: true
      t.text     :body,         null: false
      t.integer  :message_type, null: false, default: 0
      t.boolean  :internal,     null: false, default: false

      t.timestamps
    end
    add_index :conversation_messages, [ :ticket_id, :created_at ]
  end
end
