class CreateAppSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :app_settings do |t|
      t.references :company, null: false, foreign_key: true
      t.string :category, null: false
      t.jsonb :data, null: false, default: {}

      t.timestamps
    end
    add_index :app_settings, [ :company_id, :category ], unique: true
  end
end
