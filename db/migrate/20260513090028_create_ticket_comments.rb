class CreateTicketComments < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_comments do |t|
      t.references :ticket, null: false, foreign_key: true, index: true
      # Author polymorphic (User для staff, или ExternalContact). Null
      # если system-message (например, AASM-transition сохранил состояние).
      t.references :author, polymorphic: true, null: true, index: true

      t.text     :body,        null: false
      # Internal — виден только staff, не репортеру (приватные заметки
      # agent → supervisor).
      t.boolean  :internal,    null: false, default: false
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :ticket_comments, [ :ticket_id, :created_at ]
  end
end
