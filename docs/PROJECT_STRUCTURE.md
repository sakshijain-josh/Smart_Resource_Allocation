# Project Structure

## Directory Organization

```
resource_allocator/
├── app/
│   ├── controllers/
│   │   ├── api/
│   │   │   └── v1/
│   │   │       ├── auth_controller.rb         # Authentication endpoints
│   │   │       ├── users_controller.rb        # User management (admin)
│   │   │       ├── resources_controller.rb    # Resource management
│   │   │       ├── bookings_controller.rb     # Booking management
│   │   │       └── holidays_controller.rb     # Holiday management
│   │   ├── concerns/
│   │   │   └── authenticatable.rb            # JWT auth concern
│   │   └── application_controller.rb
│   │
│   ├── models/
│   │   ├── user.rb                           # User model with auth
│   │   ├── resource.rb                       # Resource model
│   │   ├── booking.rb                        # Booking model
│   │   ├── holiday.rb                        # Holiday model
│   │   ├── notification.rb                   # Notification model
│   │   ├── audit_log.rb                      # Audit log model
│   │   └── application_record.rb
│   │
│   ├── services/
│   │   └── json_web_token.rb                 # JWT encoding/decoding
│   │
│   ├── jobs/
│   │   ├── booking_reminder_job.rb           # 15-min reminder
│   │   ├── auto_release_job.rb               # Auto-release unchecked
│   │   └── pending_expiry_job.rb             # Expire old pending requests
│   │
│   └── mailers/
│       └── notification_mailer.rb            # Email notifications
│
├── config/
│   ├── routes.rb                             # API routes
│   ├── database.yml                          # DB configuration
│   ├── initializers/
│   │   └── cors.rb                           # CORS configuration
│   └── environments/
│       ├── development.rb
│       ├── production.rb
│       └── test.rb
│
├── db/
│   ├── migrate/                              # Migration files
│   ├── schema.rb                             # Current schema
│   └── seeds.rb                              # Seed data
│
├── docs/                                     # 📁 Documentation
│   ├── PROJECT_OVERVIEW.md                   # Project description
│   ├── DATABASE_SCHEMA.md                    # Schema documentation
│   ├── AUTHENTICATION.md                     # Auth flow and API
│   └── PROJECT_STRUCTURE.md                  # This file
│
├── test/
│   ├── models/                               # Model tests
│   ├── controllers/                          # Controller tests
│   ├── integration/                          # Integration tests
│   └── fixtures/                             # Test data
│
├── Gemfile                                   # Dependencies
├── Rakefile                                  # Rake tasks
└── README.md                                 # Quick start guide
```

## Key Files and Their Purpose

### Authentication & Authorization

- **`app/services/json_web_token.rb`**: JWT token generation and verification
- **`app/controllers/concerns/authenticatable.rb`**: Reusable authentication logic
- **`app/controllers/api/v1/auth_controller.rb`**: Login and current user endpoints
- **`app/controllers/api/v1/users_controller.rb`**: Admin-only user management

### Core Business Logic

- **`app/models/user.rb`**: User accounts (admin/employee)
- **`app/models/resource.rb`**: Bookable resources (rooms, desks, etc.)
- **`app/models/booking.rb`**: Booking lifecycle (pending → approved → checked_in)
- **`app/models/holiday.rb`**: Blocked dates
- **`app/models/notification.rb`**: User notifications (email + in-app)
- **`app/models/audit_log.rb`**: Immutable audit trail

### Background Jobs (Sidekiq)

- **`app/jobs/booking_reminder_job.rb`**: Send reminder 15 minutes before booking
- **`app/jobs/auto_release_job.rb`**: Release bookings if user doesn't check-in
- **`app/jobs/pending_expiry_job.rb`**: Expire old pending requests

### Configuration

- **`config/routes.rb`**: API endpoint definitions
- **`config/initializers/cors.rb`**: Cross-origin configuration for frontend
- **`db/seeds.rb`**: Initial admin user and sample data

### Documentation

- **`docs/PROJECT_OVERVIEW.md`**: High-level project description
- **`docs/DATABASE_SCHEMA.md`**: Table structure and relationships
- **`docs/AUTHENTICATION.md`**: Auth flow, JWT details, API endpoints
- **`docs/PROJECT_STRUCTURE.md`**: This file

## API Endpoint Structure

```
/api/v1/
├── auth/
│   ├── POST   /login              # Login (returns JWT)
│   └── GET    /me                 # Current user info
│
├── users/                         # Admin only
│   ├── GET    /                   # List all users
│   ├── POST   /                   # Create user
│   ├── GET    /:id                # Get user
│   ├── PATCH  /:id                # Update user
│   └── DELETE /:id                # Delete user
│
├── resources/                     # Admin: CRUD, Employee: read only
│   ├── GET    /                   # List resources
│   ├── POST   /                   # Create resource
│   ├── GET    /:id                # Get resource
│   ├── PATCH  /:id                # Update resource
│   └── DELETE /:id                # Delete resource
│
├── bookings/
│   ├── GET    /                   # List bookings (filtered by role)
│   ├── POST   /                   # Create booking request
│   ├── GET    /:id                # Get booking details
│   ├── PATCH  /:id/approve        # Admin: approve booking
│   ├── PATCH  /:id/reject         # Admin: reject booking
│   ├── PATCH  /:id/check_in       # Employee: check-in
│   └── DELETE /:id                # Employee: cancel booking
│
└── holidays/                      # Admin only
    ├── GET    /                   # List holidays
    ├── POST   /                   # Create holiday
    └── DELETE /:id                # Delete holiday
```

## Database Schema Overview

```
┌─────────────┐
│   Users     │
│  (id: uuid) │──┐
└─────────────┘  │
                 │ belongs_to
┌─────────────┐  │  ┌──────────────┐
│  Resources  │  │  │   Bookings   │
│  (id: uuid) │──┼──│   (id: uuid) │
└─────────────┘  │  └──────────────┘
                 │         │
┌─────────────┐  │         │ has_many
│  Holidays   │  │         ├─────────────┐
│  (id: uuid) │  │         │             │
└─────────────┘  │  ┌──────▼───────┐  ┌──▼──────────┐
                 │  │Notifications │  │ Audit Logs  │
                 │  │  (id: uuid)  │  │ (id: uuid)  │
                 │  └──────────────┘  └─────────────┘
                 │
                 └─ performed_by (FK)
```

## Technology Stack

- **Backend Framework**: Ruby on Rails 8.1 (API mode)
- **Database**: PostgreSQL with UUID primary keys
- **Authentication**: JWT (JSON Web Tokens)
- **Password Hashing**: Bcrypt
- **Background Jobs**: Sidekiq (with Solid Queue)
- **Caching**: Solid Cache
- **Testing**: Minitest (Rails default)
- **CORS**: rack-cors

## Development Workflow

1. **Setup**:

   ```bash
   bundle install
   bin/rails db:create db:migrate db:seed
   ```

2. **Run server**:

   ```bash
   bin/rails server
   ```

3. **Run tests**:

   ```bash
   bin/rails test
   ```

4. **Run background jobs**:
   ```bash
   bin/jobs
   ```

## Next Steps

- [ ] Implement authentication (see `implementation_plan.md`)
- [ ] Build resource management controllers
- [ ] Build booking management with approval workflow
- [ ] Implement background jobs for reminders and auto-release
- [ ] Add email notifications
- [ ] Build frontend application
