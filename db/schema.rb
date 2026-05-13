# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_13_092731) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "api_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.datetime "last_used_at"
    t.string "name", null: false
    t.string "token_digest", limit: 60, null: false
    t.string "token_prefix", limit: 8, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["token_digest"], name: "index_api_tokens_on_token_digest", unique: true
    t.index ["token_prefix"], name: "index_api_tokens_on_token_prefix"
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "code"
    t.datetime "created_at", null: false
    t.string "default_locale", default: "ru"
    t.datetime "discarded_at"
    t.string "name", null: false
    t.string "sso_email_claim", default: "email"
    t.boolean "sso_enabled", default: false, null: false
    t.string "sso_name_claim", default: "name"
    t.string "sso_secret"
    t.string "sso_user_id_claim", default: "sub"
    t.string "subdomain"
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_companies_on_code", unique: true, where: "(code IS NOT NULL)"
    t.index ["subdomain"], name: "index_companies_on_subdomain", unique: true, where: "(subdomain IS NOT NULL)"
  end

  create_table "ticket_comments", force: :cascade do |t|
    t.bigint "author_id"
    t.string "author_type"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.boolean "internal", default: false, null: false
    t.bigint "ticket_id", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_ticket_comments_on_author"
    t.index ["ticket_id", "created_at"], name: "index_ticket_comments_on_ticket_id_and_created_at"
    t.index ["ticket_id"], name: "index_ticket_comments_on_ticket_id"
  end

  create_table "ticket_types", force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "color", default: "#0A84FF", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "custom_fields_schema", default: [], null: false
    t.integer "default_priority", default: 1, null: false
    t.text "description"
    t.datetime "discarded_at"
    t.string "key", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.jsonb "workflow", default: {}, null: false
    t.index ["company_id", "key"], name: "index_ticket_types_on_company_id_and_key", unique: true
    t.index ["company_id"], name: "index_ticket_types_on_company_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.bigint "assignee_id"
    t.datetime "closed_at"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.jsonb "custom_fields", default: {}, null: false
    t.text "description"
    t.datetime "discarded_at"
    t.datetime "due_at"
    t.jsonb "metadata", default: {}, null: false
    t.integer "priority", default: 1, null: false
    t.bigint "reporter_id"
    t.string "reporter_type"
    t.string "status", null: false
    t.string "subject", limit: 280, null: false
    t.bigint "ticket_type_id", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_tickets_on_assignee_id"
    t.index ["company_id", "status"], name: "index_tickets_on_company_id_and_status"
    t.index ["company_id"], name: "index_tickets_on_company_id"
    t.index ["created_at"], name: "index_tickets_on_created_at"
    t.index ["reporter_type", "reporter_id"], name: "index_tickets_on_reporter"
    t.index ["ticket_type_id"], name: "index_tickets_on_ticket_type_id"
  end

  create_table "users", force: :cascade do |t|
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "discarded_at"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "external_id"
    t.string "external_provider", default: "jwt"
    t.integer "kind", default: 0, null: false
    t.string "locale"
    t.string "name"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role"
    t.string "time_zone"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["external_provider", "external_id"], name: "index_users_on_external_provider_and_external_id", unique: true, where: "(external_id IS NOT NULL)"
    t.index ["kind"], name: "index_users_on_kind"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "api_tokens", "users"
  add_foreign_key "ticket_comments", "tickets"
  add_foreign_key "ticket_types", "companies"
  add_foreign_key "tickets", "companies"
  add_foreign_key "tickets", "ticket_types"
  add_foreign_key "tickets", "users", column: "assignee_id"
  add_foreign_key "users", "companies"
end
