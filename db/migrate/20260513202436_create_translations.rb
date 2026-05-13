class CreateTranslations < ActiveRecord::Migration[8.1]
  def change
    create_table :translations do |t|
      t.references :company, null: false, foreign_key: true
      t.string :locale, null: false
      t.string :key,    null: false
      t.text   :value

      t.timestamps
    end
    add_index :translations, [ :company_id, :locale, :key ], unique: true
  end
end
