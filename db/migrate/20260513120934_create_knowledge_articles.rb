class CreateKnowledgeArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :knowledge_articles do |t|
      t.references :company,     null: false, foreign_key: true
      t.references :ticket_type, null: true,  foreign_key: true
      t.string   :title,      null: false
      t.text     :body,       null: false, default: ""
      t.boolean  :published,  null: false, default: false
      t.integer  :position,   null: false, default: 0
      t.datetime :discarded_at

      t.timestamps
    end
    add_index :knowledge_articles, [ :company_id, :published ]
    add_index :knowledge_articles, :discarded_at
  end
end
