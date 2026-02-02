class AddDeviseToUsers < ActiveRecord::Migration[8.1]
  def change
    # Rename password_digest to encrypted_password for Devise
    rename_column :users, :password_digest, :encrypted_password

    # Recoverable
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime

    # Rememberable
    add_column :users, :remember_created_at, :datetime

    # Trackable
    add_column :users, :sign_in_count, :integer, default: 0, null: false
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string

    # Lockable
    add_column :users, :failed_attempts, :integer, default: 0, null: false
    add_column :users, :unlock_token, :string
    add_column :users, :locked_at, :datetime

    # Add indexes
    add_index :users, :reset_password_token, unique: true
    add_index :users, :unlock_token, unique: true
  end
end

