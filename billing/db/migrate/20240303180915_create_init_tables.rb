class CreateInitTables < ActiveRecord::Migration[7.1]
  enable_extension 'pgcrypto'

  def change
    create_table :users do |t|
      t.uuid     :public_uid
      t.string   :email, null: false
      t.boolean  :admin, default: false

      t.timestamps
    end
    add_index :users, :email,      unique: true, name: :users_email_key
    add_index :users, :public_uid, unique: true, name: :users_public_uid_key

    create_table :sessions, id: :uuid do |t|
      t.integer  :user_id,      null: false
      t.string   :refresh_token
      t.integer  :expires_in

      t.timestamps
    end
    add_foreign_key :sessions, :users, column: :user_id, name: :sessions_user_fkey

    create_table :tasks do |t|
      t.uuid    :public_uid,      null: false
      t.uuid    :user_public_uid, null: false
      t.string  :state,           null: false
      t.string  :title
      t.float   :assign_cost
      t.float   :solving_cost

      t.timestamps
    end
    add_index :tasks, :public_uid, unique: true, name: :tasks_public_id_key

    create_enum  :state_code, %i[deposited withdrawn summarized sent]
    create_table :account_states do |t|
      t.string   :title,                        null: false
      t.enum     :code, enum_type: :state_code, null: false
    end
    
    create_table :billing_events do |t|
      t.uuid     :public_uid,   null: false, default: 'gen_random_uuid()'
      t.integer  :state_id,     null: false
      t.integer  :user_id,      null: false
      t.integer  :task_id
      t.float    :cost

      t.timestamps
    end
    add_foreign_key :billing_events, :users, column: :user_id, name: :event_users_fkey
    add_foreign_key :billing_events, :account_states, column: :state_id, name: :events_states_fkey
    add_foreign_key :billing_events, :tasks, column: :task_id, name: :event_task_fkey
  end
end
