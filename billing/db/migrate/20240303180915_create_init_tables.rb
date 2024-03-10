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
      t.uuid    :public_uid
      t.integer :assignee_id
      t.string  :title
    end
    add_index :tasks, :public_uid, unique: true, name: :tasks_public_id_key

    create_table :task_costs do |t|
      t.uuid   :task_id
      t.float  :assign_cost,   null: false
      t.float  :solving_cost,  null: false
    end
    add_index :task_costs, :task_id, unique: true, name: :task_cost_task_id_key

    create_enum  :state_code, %i[earned deducted summarized]
    create_table :states do |t|
      t.string   :title,                        null: false
      t.enum     :code, enum_type: :state_code, null: false
    end
    
    create_table :events do |t|
      t.uuid     :public_uid,   null: false, default: 'gen_random_uuid()'
      t.integer  :state_id,     null: false
      t.integer  :user_id,      null: false
      t.integer  :task_cost_id
      t.float    :cost

      t.timestamps
    end
    add_foreign_key :events, :users,      column: :user_id,       name: :event_users_fkey
    add_foreign_key :events, :states,     column: :state_id,      name: :events_states_fkey
    add_foreign_key :events, :task_costs, column: :task_cost_id,  name: :event_task_costs_fkey
  end
end
