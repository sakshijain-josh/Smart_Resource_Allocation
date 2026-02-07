class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :resource, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.integer :status
      t.boolean :allow_smaller_capacity
      t.text :admin_note
      t.datetime :request_created_at
      t.datetime :request_expires_at
      t.datetime :approved_at
      t.datetime :checked_in_at
      t.datetime :cancelled_at
      t.datetime :auto_released_at

      t.timestamps
    end

    add_index :bookings, :status
    add_index :bookings, [ :user_id, :start_time ]
    add_index :bookings, [ :resource_id, :start_time, :end_time ]
  end
end
