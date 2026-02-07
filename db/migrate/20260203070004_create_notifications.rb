class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, foreign_key: true
      t.references :booking, foreign_key: true
      t.string :notification_type, null: false
      t.string :channel, null: false
      t.datetime :sent_at, null: false
      t.boolean :is_read, null: false, default: false

      t.timestamps
    end

    add_index :notifications, [ :user_id, :is_read ]
  end
end
