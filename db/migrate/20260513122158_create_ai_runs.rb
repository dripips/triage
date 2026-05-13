class CreateAiRuns < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_runs do |t|
      t.references :company, null: false, foreign_key: true
      t.references :ticket,  null: true,  foreign_key: true
      t.references :user,    null: true,  foreign_key: true
      t.string  :kind,          null: false
      t.string  :model,         null: false
      t.integer :input_tokens,  null: false, default: 0
      t.integer :output_tokens, null: false, default: 0
      t.integer :total_tokens,  null: false, default: 0
      t.float   :cost_usd,     null: false, default: 0.0
      t.boolean :success,       null: false, default: true
      t.jsonb   :payload
      t.text    :error

      t.timestamps
    end
    add_index :ai_runs, [ :company_id, :created_at ]
    add_index :ai_runs, [ :company_id, :kind ]
  end
end
