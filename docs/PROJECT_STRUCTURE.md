# Project Structure

## Directory Organization

```
resource_allocator/
├── app/
│   ├── controllers/
│   │   ├── api/
│   │   │   └── v1/
│   │   │       ├── sessions_controller.rb      # Login (Devise JWT)
│   │   │       ├── registrations_controller.rb # Profile (/auth/me)
│   │   │       ├── users_controller.rb        # User management (admin)
│   │   │       ├── resources_controller.rb    # Resource management
│   │   │       ├── bookings_controller.rb     # Booking management
│   │   │       └── holidays_controller.rb     # Holiday management
│   │   └── application_controller.rb         # Manual auth helpers (warden)
│   │
│   ├── models/
│   │   ├── user.rb                           # User model (Devise JWT)
│   │   ├── jwt_denylist.rb                   # JWT Revocation strategy
│   │   ├── resource.rb                       # Resource model
│   │   ├── booking.rb                        # Booking model
│   │   ├── holiday.rb                        # Holiday model
│   │   ├── notification.rb                   # Notification model
│   │   ├── audit_log.rb                      # Audit log model
│   │   └── application_record.rb
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
│   │   ├── cors.rb                           # CORS configuration
│   │   └── devise.rb                         # Devise configuration
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
│   ├── PROJECT_STRUCTURE.md                  # This file
│   ├── swagger.yaml                          # OpenAPI Specification
│   └── create_resource.md                    # Resource Implementation Guide
│
├── test/
│   ├── models/                               # Model tests
│   ├── controllers/                          # Controller tests
│   ├── integration/                          # Integration tests
│   ├── fixtures/                             # Test data
│   └── test_helper.rb
│
├── Gemfile                                   # Dependencies
├── Rakefile                                  # Rake tasks
└── README.md                                 # Quick start guide
```

## Key Files and Their Purpose

### Authentication & Authorization

- **`app/models/user.rb`**: Devise configuration for `database_authenticatable` and `jwt_authenticatable`.
- **`app/models/jwt_denylist.rb`**: Stores revoked tokens to prevent replay attacks.
- **`app/controllers/application_controller.rb`**: Defines manual `current_user` and `authenticate_user!` helpers using Warden directly for robust API-only authentication.
- **`app/controllers/api/v1/sessions_controller.rb`**: Custom login logic that returns JWT in the `token` response body.
- **`app/controllers/api/v1/registrations_controller.rb`**: Handles current user profile retrieval (`/auth/me`).
- **`app/controllers/api/v1/users_controller.rb`**: Admin-only user registration endpoint.

### Core Business Logic

- **`app/models/user.rb`**: User accounts (admin/employee). Roles are string-based (`admin`, `employee`).
- **`app/models/resource.rb`**: Bookable resources (rooms, desks, etc.).
- **`app/models/booking.rb`**: Booking lifecycle (pending → approved → checked_in). Supports Rails 8 enum syntax.
- **`app/models/holiday.rb`**: Blocked dates.
- **`app/models/notification.rb`**: User notifications (email + in-app).
- **`app/models/audit_log.rb`**: Immutable audit trail.

### Background Jobs (Sidekiq / Solid Queue)

- **`app/jobs/booking_reminder_job.rb`**: Send reminder 15 minutes before booking.
- **`app/jobs/auto_release_job.rb`**: Release bookings if user doesn't check-in.
- **`app/jobs/pending_expiry_job.rb`**: Expire old pending requests.

### Configuration

- **`config/routes.rb`**: API endpoint definitions. Namespaced under `/api/v1/`.
- **`config/initializers/cors.rb`**: Cross-origin configuration for frontend (allows all origins in dev).
- **`db/seeds.rb`**: Initial admin user (`admin@josh.com`) and sample data.

### Documentation

- **`docs/PROJECT_OVERVIEW.md`**: High-level project description.
- **`docs/DATABASE_SCHEMA.md`**: Table structure and relationships.
- **`docs/AUTHENTICATION.md`**: Auth flow, JWT details, API endpoints.
- **`docs/PROJECT_STRUCTURE.md`**: This file.
- **`docs/swagger.yaml`**: Full OpenAPI 3.0.3 Specification.

## API Endpoint Structure

```
/api/v1/
├── auth/
│   ├── POST   /login              # Login (returns JWT)
│   └── GET    /me                 # Current user info (Registrations#show)
│
├── users/                         # Admin only
│   ├── POST   /                   # Register new user
│   ├── GET    /                   # List all users (pending)
│   └── DELETE /:id                # Delete user (pending)
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

## Technology Stack

- **Backend Framework**: Ruby on Rails 8.1 (API mode)
- **Database**: PostgreSQL with UUID primary keys
- **Authentication**: Devise + Devise-JWT
- **Revocation**: JWT Denylist (Database-backed)
- **Authorization**: CanCanCan
- **Documentation**: Swagger (OpenAPI 3.0.3)
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

## Next Steps

- [x] Implement authentication (Devise JWT)
- [x] Implement admin-only user registration
- [x] Generate Swagger documentation
- [ ] Build resource management controllers (Current Task)
- [ ] Build booking management with approval workflow
- [ ] Implement background jobs for reminders and auto-release
- [ ] Add email notifications
- [ ] Build frontend application
