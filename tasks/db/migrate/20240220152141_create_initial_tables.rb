# frozen_string_literal: true

class CreateInitialTables < ActiveRecord::Migration[7.1]
  enable_extension 'pgcrypto'

  def change
    create_table :users do |t|
      t.uuid    :public_uid,  null: false
      t.string  :email,       null: false
      t.boolean :admin,       default: false

      t.timestamps
    end
    add_index :users, :email, unique: true, name: :users_email_key

    create_table :sessions, id: :uuid do |t|
      t.integer  :user_id,      null: false
      t.string   :refresh_token
      t.integer  :expires_in

      t.timestamps
    end
    add_foreign_key :sessions, :users, column: :user_id, name: :sessions_user_fkey

    create_table :tasks do |t|
      t.string  :title,      null: false
      t.uuid    :public_uid, null: false, default: 'gen_random_uuid()'

      t.timestamps
    end

    create_enum :state_code, %i[created assigned reassigned done]
    create_table :states do |t|
      t.string  :title, null: false
      t.enum    :code,  enum_type: :state_code, default: :created
    end

    create_table :events do |t|
      t.integer :task_id,     null: false
      t.integer :state_id,    null: false
      t.integer :user_id,     null: false
      t.integer :assignee_id, default: nil

      t.timestamps
    end
    add_foreign_key :events, :tasks,  column: :task_id,     name: :events_tasks_fkey
    add_foreign_key :events, :states, column: :state_id,    name: :events_states_fkey
    add_foreign_key :events, :users,  column: :user_id,     name: :event_users_fkey
    add_foreign_key :events, :users,  column: :assignee_id, name: :event_assignee_fkey
  end
end
