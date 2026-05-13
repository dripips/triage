class CreateLanguages < ActiveRecord::Migration[8.1]
  def change
    create_table :languages do |t|
      t.references :company, null: false, foreign_key: true
      t.string  :code,        null: false
      t.string  :native_name, null: false
      t.string  :english_name
      t.string  :flag
      t.integer :direction,   null: false, default: 0
      t.boolean :enabled,     null: false, default: true
      t.boolean :is_default,  null: false, default: false
      t.integer :position,    null: false, default: 0
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :languages, [ :company_id, :code ], unique: true
    add_index :languages, :discarded_at
  end
end
