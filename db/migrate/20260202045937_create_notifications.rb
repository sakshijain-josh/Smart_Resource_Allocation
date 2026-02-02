class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications, id: :uuid do |t|
      t.references :user, type: :uuid, foreign_key: true
      t.references :booking, type: :uuid, foreign_key: true

      t.string :notification_type, null: false
      t.string :channel, null: false
      t.boolean :is_read, null: false, default: false
      t.datetime :sent_at, null: false

      t.timestamps
    end

    add_index :notifications, [:user_id, :is_read]
  end
end
