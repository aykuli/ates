# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.1]
  enable_extension 'pgcrypto'

  def change
    create_table :users do |t|
      t.string  :email,              null: false, default: ''
      t.string  :encrypted_password, null: false, default: ''
      t.uuid    :public_uid,         null: false, default: 'gen_random_uuid()'
      t.boolean :admin,                           default: false


      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :users, :email, unique: true
  end
end
