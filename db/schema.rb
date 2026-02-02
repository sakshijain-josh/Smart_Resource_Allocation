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

ActiveRecord::Schema[8.1].define(version: 2026_02_02_084814) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action", null: false
    t.uuid "booking_id"
    t.datetime "created_at", null: false
    t.text "message"
    t.integer "new_status"
    t.integer "old_status"
    t.uuid "performed_by"
    t.uuid "resource_id"
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_audit_logs_on_booking_id"
    t.index ["resource_id"], name: "index_audit_logs_on_resource_id"
  end

  create_table "bookings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "admin_note"
    t.boolean "allow_smaller_capacity"
    t.datetime "approved_at"
    t.datetime "auto_released_at"
    t.datetime "cancelled_at"
    t.datetime "checked_in_at"
    t.datetime "created_at", null: false
    t.datetime "end_time"
    t.datetime "request_created_at"
    t.datetime "request_expires_at"
    t.uuid "resource_id", null: false
    t.datetime "start_time"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["resource_id", "start_time", "end_time"], name: "index_bookings_on_resource_id_and_start_time_and_end_time"
    t.index ["resource_id"], name: "index_bookings_on_resource_id"
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["user_id", "start_time"], name: "index_bookings_on_user_id_and_start_time"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "holidays", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "holiday_date"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "jwt_denylists", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "exp", null: false
    t.string "jti", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti", unique: true
  end

  create_table "notifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "booking_id"
    t.string "channel", null: false
    t.datetime "created_at", null: false
    t.boolean "is_read", default: false, null: false
    t.string "notification_type", null: false
    t.datetime "sent_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["booking_id"], name: "index_notifications_on_booking_id"
    t.index ["user_id", "is_read"], name: "index_notifications_on_user_id_and_is_read"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "resources", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_active"
    t.string "name"
    t.jsonb "properties"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["properties"], name: "index_resources_on_properties", using: :gin
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email", null: false
    t.string "employee_id", null: false
    t.string "encrypted_password", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "employee", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["employee_id"], name: "index_users_on_employee_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "audit_logs", "bookings"
  add_foreign_key "audit_logs", "resources"
  add_foreign_key "audit_logs", "users", column: "performed_by"
  add_foreign_key "bookings", "resources"
  add_foreign_key "bookings", "users"
  add_foreign_key "notifications", "bookings"
  add_foreign_key "notifications", "users"
end
