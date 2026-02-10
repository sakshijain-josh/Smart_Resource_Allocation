-- PostgreSQL DDL generated from Rails schema.rb

-- Extensions
CREATE EXTENSION IF NOT EXISTS "plpgsql";

-- Tables

-- Table: users
CREATE TABLE "users" (
    "id" BIGSERIAL PRIMARY KEY,
    "email" VARCHAR(255) NOT NULL DEFAULT '',
    "employee_id" VARCHAR(255) NOT NULL,
    "encrypted_password" VARCHAR(255) NOT NULL DEFAULT '',
    "name" VARCHAR(255) NOT NULL,
    "role" VARCHAR(255) NOT NULL DEFAULT 'employee',
    "failed_attempts" INTEGER NOT NULL DEFAULT 0,
    "sign_in_count" INTEGER NOT NULL DEFAULT 0,
    "current_sign_in_at" TIMESTAMP(6) WITHOUT TIME ZONE,
    "last_sign_in_at" TIMESTAMP(6) WITHOUT TIME ZONE,
    "current_sign_in_ip" VARCHAR(255),
    "last_sign_in_ip" VARCHAR(255),
    "remember_created_at" TIMESTAMP(6) WITHOUT TIME ZONE,
    "reset_password_token" VARCHAR(255),
    "reset_password_sent_at" TIMESTAMP(6) WITHOUT TIME ZONE,
    "unlock_token" VARCHAR(255),
    "locked_at" TIMESTAMP(6) WITHOUT TIME ZONE,
    "created_at" TIMESTAMP(6) NOT NULL,
    "updated_at" TIMESTAMP(6) NOT NULL
);

CREATE UNIQUE INDEX "index_users_on_email" ON "users" ("email");
CREATE UNIQUE INDEX "index_users_on_employee_id" ON "users" ("employee_id");
CREATE UNIQUE INDEX "index_users_on_reset_password_token" ON "users" ("reset_password_token");
CREATE UNIQUE INDEX "index_users_on_unlock_token" ON "users" ("unlock_token");

-- Table: resources
CREATE TABLE "resources" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(255),
    "resource_type" VARCHAR(255),
    "description" TEXT,
    "location" VARCHAR(255),
    "is_active" BOOLEAN,
    "properties" JSONB,
    "created_at" TIMESTAMP(6) NOT NULL,
    "updated_at" TIMESTAMP(6) NOT NULL
);

CREATE INDEX "index_resources_on_properties" ON "resources" USING GIN ("properties");

-- Table: bookings
CREATE TABLE "bookings" (
    "id" BIGSERIAL PRIMARY KEY,
    "user_id" BIGINT NOT NULL,
    "resource_id" BIGINT NOT NULL,
    "start_time" TIMESTAMP(6) WITHOUT TIME ZONE,
    "end_time" TIMESTAMP(6) WITHOUT TIME ZONE,
    "status" INTEGER,
    "approved_at" TIMESTAMP(6) WITHOUT TIME ZONE,
    "cancelled_at" TIMESTAMP(6) WITHOUT TIME ZONE,
    "checked_in_at" TIMESTAMP(6) WITHOUT TIME ZONE,
    "auto_released_at" TIMESTAMP(6) WITHOUT TIME ZONE,
    "request_created_at" TIMESTAMP(6) WITHOUT TIME ZONE,
    "request_expires_at" TIMESTAMP(6) WITHOUT TIME ZONE,
    "admin_note" TEXT,
    "allow_smaller_capacity" BOOLEAN,
    "created_at" TIMESTAMP(6) NOT NULL,
    "updated_at" TIMESTAMP(6) NOT NULL,
    CONSTRAINT "fk_rails_ef057a1111" FOREIGN KEY ("user_id") REFERENCES "users" ("id"),
    CONSTRAINT "fk_rails_963b53c155" FOREIGN KEY ("resource_id") REFERENCES "resources" ("id")
);

CREATE INDEX "index_bookings_on_user_id" ON "bookings" ("user_id");
CREATE INDEX "index_bookings_on_resource_id" ON "bookings" ("resource_id");
CREATE INDEX "index_bookings_on_status" ON "bookings" ("status");
CREATE INDEX "index_bookings_on_resource_id_and_start_time_and_end_time" ON "bookings" ("resource_id", "start_time", "end_time");
CREATE INDEX "index_bookings_on_user_id_and_start_time" ON "bookings" ("user_id", "start_time");

-- Table: audit_logs
CREATE TABLE "audit_logs" (
    "id" BIGSERIAL PRIMARY KEY,
    "booking_id" BIGINT,
    "resource_id" BIGINT,
    "performed_by" BIGINT,
    "action" VARCHAR(255) NOT NULL,
    "old_status" INTEGER,
    "new_status" INTEGER,
    "message" TEXT,
    "created_at" TIMESTAMP(6) NOT NULL,
    "updated_at" TIMESTAMP(6) NOT NULL,
    CONSTRAINT "fk_rails_7424bd4157" FOREIGN KEY ("booking_id") REFERENCES "bookings" ("id"),
    CONSTRAINT "fk_rails_c1c1f7283d" FOREIGN KEY ("resource_id") REFERENCES "resources" ("id"),
    CONSTRAINT "fk_rails_performed_by" FOREIGN KEY ("performed_by") REFERENCES "users" ("id")
);

CREATE INDEX "index_audit_logs_on_booking_id" ON "audit_logs" ("booking_id");
CREATE INDEX "index_audit_logs_on_resource_id" ON "audit_logs" ("resource_id");

-- Table: notifications
CREATE TABLE "notifications" (
    "id" BIGSERIAL PRIMARY KEY,
    "user_id" BIGINT,
    "booking_id" BIGINT,
    "notification_type" VARCHAR(255) NOT NULL,
    "channel" VARCHAR(255) NOT NULL,
    "sent_at" TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    "is_read" BOOLEAN NOT NULL DEFAULT FALSE,
    "created_at" TIMESTAMP(6) NOT NULL,
    "updated_at" TIMESTAMP(6) NOT NULL,
    CONSTRAINT "fk_rails_b080c1070d" FOREIGN KEY ("user_id") REFERENCES "users" ("id"),
    CONSTRAINT "fk_rails_770e70f69a" FOREIGN KEY ("booking_id") REFERENCES "bookings" ("id")
);

CREATE INDEX "index_notifications_on_user_id" ON "notifications" ("user_id");
CREATE INDEX "index_notifications_on_booking_id" ON "notifications" ("booking_id");
CREATE INDEX "index_notifications_on_user_id_and_is_read" ON "notifications" ("user_id", "is_read");

-- Table: holidays
CREATE TABLE "holidays" (
    "id" BIGSERIAL PRIMARY KEY,
    "name" VARCHAR(255),
    "holiday_date" DATE,
    "created_at" TIMESTAMP(6) NOT NULL,
    "updated_at" TIMESTAMP(6) NOT NULL
);

-- Table: jwt_denylists
CREATE TABLE "jwt_denylists" (
    "id" BIGSERIAL PRIMARY KEY,
    "jti" VARCHAR(255) NOT NULL,
    "exp" TIMESTAMP(6) WITHOUT TIME ZONE NOT NULL,
    "created_at" TIMESTAMP(6) NOT NULL,
    "updated_at" TIMESTAMP(6) NOT NULL
);

CREATE UNIQUE INDEX "index_jwt_denylists_on_jti" ON "jwt_denylists" ("jti");
