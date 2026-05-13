class CreateInAppNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :in_app_notifications do |t|
      t.references :recipient, polymorphic: true, null: false
      t.references :actor,     polymorphic: true, null: true
      t.string     :action,    null: false
      t.references :notifiable, polymorphic: true, null: true
      t.text       :message
      t.string     :url
      t.datetime   :read_at

      t.timestamps
    end
    add_index :in_app_notifications, [ :recipient_type, :recipient_id, :read_at ], name: "idx_notif_recipient_read"
  end
end
