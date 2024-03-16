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

ActiveRecord::Schema[7.1].define(version: 2024_03_16_102900) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "state_code", ["deposited", "withdrawn", "summarized", "sent"]

  create_table "account_states", force: :cascade do |t|
    t.string "title", null: false
    t.enum "code", null: false, enum_type: "state_code"
  end

  create_table "billing_events", force: :cascade do |t|
    t.uuid "public_uid", default: -> { "gen_random_uuid()" }, null: false
    t.integer "state_id", null: false
    t.integer "user_id", null: false
    t.integer "task_id"
    t.float "cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.uuid "public_uid", null: false
    t.integer "user_public_uid", null: false
    t.string "state", null: false
    t.string "title"
    t.float "assign_cost"
    t.float "solving_cost"
    t.string "jira_id"
    t.index ["public_uid"], name: "tasks_public_id_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.uuid "public_uid"
    t.string "email", null: false
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "users_email_key", unique: true
    t.index ["public_uid"], name: "users_public_uid_key", unique: true
  end

  add_foreign_key "billing_events", "account_states", column: "state_id", name: "events_states_fkey"
  add_foreign_key "billing_events", "tasks", name: "event_task_fkey"
  add_foreign_key "billing_events", "users", name: "event_users_fkey"
  add_foreign_key "sessions", "users", name: "sessions_user_fkey"
end
