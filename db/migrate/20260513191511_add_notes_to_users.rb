class AddNotesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :staff_notes, :text
  end
end
