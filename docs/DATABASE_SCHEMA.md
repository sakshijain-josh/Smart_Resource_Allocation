# Database Schema Documentation

## Overview

This document describes the database schema for the Smart Office Resource Management System.

## Tables

### Users

Stores employee and admin accounts (admin-provisioned only).

| Column          | Type      | Constraints                   | Description                 |
| --------------- | --------- | ----------------------------- | --------------------------- |
| id              | uuid      | Primary Key                   | Auto-generated UUID         |
| employee_id     | string    | NOT NULL, UNIQUE              | Company employee identifier |
| name            | string    | NOT NULL                      | Full name                   |
| email           | string    | NOT NULL, UNIQUE              | Email address               |
| password_digest | string    | NOT NULL                      | Bcrypt hashed password      |
| role            | string    | NOT NULL, default: 'employee' | Role: 'employee' or 'admin' |
| created_at      | timestamp | NOT NULL                      | Record creation time        |
| updated_at      | timestamp | NOT NULL                      | Last update time            |

**Indexes:**

- `index_users_on_employee_id` (unique)
- `index_users_on_email` (unique)

---

### Resources

Stores bookable office resources with flexible JSONB properties.

| Column     | Type      | Constraints | Description                                     |
| ---------- | --------- | ----------- | ----------------------------------------------- |
| id         | uuid      | Primary Key | Auto-generated UUID                             |
| name       | string    |             | Resource name                                   |
| type       | string    |             | Resource type (e.g., 'conference_room', 'desk') |
| properties | jsonb     |             | Flexible attributes (capacity, floor, features) |
| is_active  | boolean   |             | Active/inactive status                          |
| created_at | timestamp | NOT NULL    | Record creation time                            |
| updated_at | timestamp | NOT NULL    | Last update time                                |

**Indexes:**

- `index_resources_on_properties` (GIN index for JSONB queries)

---

### Bookings

Stores all booking requests and their lifecycle states.

| Column                 | Type      | Constraints              | Description                                                                        |
| ---------------------- | --------- | ------------------------ | ---------------------------------------------------------------------------------- |
| id                     | uuid      | Primary Key              | Auto-generated UUID                                                                |
| user_id                | uuid      | NOT NULL, FK → users     | Requesting employee                                                                |
| resource_id            | uuid      | NOT NULL, FK → resources | Requested resource                                                                 |
| start_time             | timestamp |                          | Booking start time                                                                 |
| end_time               | timestamp |                          | Booking end time                                                                   |
| status                 | integer   |                          | 0=pending, 1=approved, 2=rejected, 3=expired, 4=auto_released, 5=cancelled_by_user |
| allow_smaller_capacity | boolean   |                          | Allow alternative smaller resource                                                 |
| admin_note             | text      |                          | Admin message/reason                                                               |
| request_created_at     | timestamp |                          | When request was made                                                              |
| request_expires_at     | timestamp |                          | When pending request expires                                                       |
| approved_at            | timestamp |                          | When admin approved                                                                |
| checked_in_at          | timestamp |                          | When user checked in                                                               |
| cancelled_at           | timestamp |                          | When user cancelled                                                                |
| auto_released_at       | timestamp |                          | When system auto-released                                                          |
| created_at             | timestamp | NOT NULL                 | Record creation time                                                               |
| updated_at             | timestamp | NOT NULL                 | Last update time                                                                   |

**Indexes:**

- `index_bookings_on_user_id`
- `index_bookings_on_resource_id`
- `index_bookings_on_status`
- `index_bookings_on_user_id_and_start_time`
- `index_bookings_on_resource_id_and_start_time_and_end_time`

---

### Holidays

Stores blocked dates when no bookings are allowed.

| Column       | Type      | Constraints | Description          |
| ------------ | --------- | ----------- | -------------------- |
| id           | uuid      | Primary Key | Auto-generated UUID  |
| name         | string    |             | Holiday name         |
| holiday_date | date      |             | Date to block        |
| created_at   | timestamp | NOT NULL    | Record creation time |
| updated_at   | timestamp | NOT NULL    | Last update time     |

---

### Notifications

Stores user notifications for booking status changes.

| Column            | Type      | Constraints              | Description                  |
| ----------------- | --------- | ------------------------ | ---------------------------- |
| id                | uuid      | Primary Key              | Auto-generated UUID          |
| user_id           | uuid      | FK → users               | Recipient user               |
| booking_id        | uuid      | FK → bookings            | Related booking              |
| notification_type | string    | NOT NULL                 | Type of notification         |
| channel           | string    | NOT NULL                 | Channel: 'email' or 'in_app' |
| sent_at           | timestamp | NOT NULL                 | When notification was sent   |
| is_read           | boolean   | NOT NULL, default: false | Read status                  |
| created_at        | timestamp | NOT NULL                 | Record creation time         |
| updated_at        | timestamp | NOT NULL                 | Last update time             |

**Indexes:**

- `index_notifications_on_user_id`
- `index_notifications_on_booking_id`
- `index_notifications_on_user_id_and_is_read`

---

### Audit Logs

Immutable log of all state changes for compliance.

| Column       | Type      | Constraints    | Description                |
| ------------ | --------- | -------------- | -------------------------- |
| id           | uuid      | Primary Key    | Auto-generated UUID        |
| action       | string    | NOT NULL       | Action type                |
| performed_by | uuid      | FK → users     | Admin who performed action |
| booking_id   | uuid      | FK → bookings  | Related booking            |
| resource_id  | uuid      | FK → resources | Related resource           |
| old_status   | integer   |                | Previous booking status    |
| new_status   | integer   |                | New booking status         |
| message      | text      |                | Additional context/reason  |
| created_at   | timestamp | NOT NULL       | Record creation time       |
| updated_at   | timestamp | NOT NULL       | Last update time           |

**Indexes:**

- `index_audit_logs_on_booking_id`
- `index_audit_logs_on_resource_id`

---

## Relationships

```
users
  ├─ has_many :bookings
  ├─ has_many :notifications
  └─ has_many :audit_logs (as performed_by)

resources
  ├─ has_many :bookings
  └─ has_many :audit_logs

bookings
  ├─ belongs_to :user
  ├─ belongs_to :resource
  ├─ has_many :notifications
  └─ has_many :audit_logs

notifications
  ├─ belongs_to :user
  └─ belongs_to :booking

audit_logs
  ├─ belongs_to :user (performed_by)
  ├─ belongs_to :booking
  └─ belongs_to :resource
```

## Constraints & Business Rules

1. **No Self-Registration**: Users can only be created by admins
2. **Unique Identifiers**: employee_id and email must be unique
3. **Booking Time Slots**: 30-minute granularity, Mon-Fri 9am-6pm only
4. **No Overlapping Approved Bookings**: System prevents double-booking
5. **Immutable Audit Logs**: Never updated, only created
6. **Password Security**: Passwords stored as bcrypt hashes only
