class AddReadTrackingToConversationMessages < ActiveRecord::Migration[8.1]
  def change
    add_column :conversation_messages, :read_by, :jsonb, null: false, default: {}
  end
end
