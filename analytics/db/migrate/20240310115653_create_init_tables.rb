class CreateInitTables < ActiveRecord::Migration[7.1]
  enable_extension 'pgcrypto'

  def change
    create_table :users do |t|
      t.uuid    :public_uid,  null: false
      t.string  :email
      t.boolean :admin,       default: false

      t.timestamps
    end
    add_index :users, :public_uid,   unique: true, name: :users_uid_key

    create_table :sessions, id: :uuid do |t|
      t.integer  :user_id,      null: false
      t.string   :refresh_token
      t.integer  :expires_in

      t.timestamps
    end
    add_foreign_key :sessions, :users, column: :user_id, name: :sessions_user_fkey

    create_table :balances do |t|
      t.uuid     :user_id,  null: false
      t.float    :current
      t.datetime :time

      t.timestamps
    end

    create_table :done_tasks do |t|
      t.uuid   :public_uid,  null: false
      t.float :cost

      t.timestamps
    end
  end
end
