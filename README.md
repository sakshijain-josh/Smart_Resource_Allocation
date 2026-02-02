# Smart Office Resource Management System

A controlled-access web platform for managing shared office resources through an admin-governed booking workflow. This system enforces conflict-free scheduling, approval-based allocation, and utilization tracking.

## 🔑 Key Features

- **Admin-Only User Provisioning**: No public signup - all accounts are created by administrators
- **JWT Authentication**: Secure, stateless token-based authentication
- **Role-Based Access Control**: Admin and Employee roles with different permissions
- **Resource Management**: Flexible JSONB-based resource attributes
- **Approval Workflow**: First-come-first-served booking queue with admin approval
- **Smart Conflict Resolution**: Auto-reject conflicting bookings when one is approved
- **Check-in Enforcement**: 15-minute grace period with auto-release
- **Audit Trail**: Immutable logs of all state changes
- **Notifications**: Email + in-app notifications for booking updates

## 📁 Documentation

Comprehensive documentation is available in the [`/docs`](./docs) folder:

- **[Project Overview](./docs/PROJECT_OVERVIEW.md)** - System description and business rules
- **[Authentication](./docs/AUTHENTICATION.md)** - Auth flow, JWT details, API endpoints
- **[Database Schema](./docs/DATABASE_SCHEMA.md)** - Table structure and relationships
- **[Project Structure](./docs/PROJECT_STRUCTURE.md)** - Directory organization and file purposes

## 🚀 Quick Start

### Prerequisites

- Ruby 3.3+ (check `.ruby-version`)
- PostgreSQL 14+
- Bundler

### Installation

```bash
# Install dependencies
bundle install

# Setup database
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed  # Creates default admin user

# Start server
bin/rails server
```

The API will be available at `http://localhost:3000`

### Default Admin Credentials

After running `db:seed`:

- **Email**: `admin@company.com`
- **Password**: `admin123`

⚠️ **Change these credentials in production!**

## 🧪 Testing

```bash
# Run all tests
bin/rails test

# Run specific test file
bin/rails test test/models/user_test.rb

# Run with coverage (if configured)
COVERAGE=true bin/rails test
```

## 📡 API Overview

### Authentication

```bash
# Login (returns JWT token)
POST /api/v1/auth/login

# Get current user
GET /api/v1/auth/me
```

### User Management (Admin Only)

```bash
POST   /api/v1/users      # Create user
GET    /api/v1/users      # List users
GET    /api/v1/users/:id  # Get user
PATCH  /api/v1/users/:id  # Update user
DELETE /api/v1/users/:id  # Delete user
```

See [Authentication Documentation](./docs/AUTHENTICATION.md) for detailed API usage and examples.

## 🏗️ Technology Stack

- **Backend**: Ruby on Rails 8.1 (API mode)
- **Database**: PostgreSQL with UUID primary keys
- **Authentication**: JWT + Bcrypt
- **Background Jobs**: Sidekiq (with Solid Queue)
- **Testing**: Minitest

## 🗓️ Development Roadmap

### Phase 1: Authentication ✅ _(Planned)_

- [x] Documentation structure
- [ ] JWT service implementation
- [ ] Auth controllers and user management
- [ ] Role-based authorization
- [ ] Comprehensive testing

### Phase 2: Resource Management _(Planned)_

- [ ] Resource CRUD operations
- [ ] Resource search and filtering
- [ ] Resource availability checks

### Phase 3: Booking System _(Planned)_

- [ ] Booking request creation
- [ ] Approval workflow
- [ ] Conflict detection and resolution
- [ ] Check-in functionality

### Phase 4: Automation _(Planned)_

- [ ] Booking reminders (15 min before)
- [ ] Auto-release unchecked bookings
- [ ] Pending request expiry

### Phase 5: Notifications _(Planned)_

- [ ] Email notifications
- [ ] In-app notifications
- [ ] Notification preferences

## 📊 System Constraints

- **Office Hours**: Mon-Fri, 9am-6pm only
- **Time Slots**: 30-minute granularity
- **No Recurring Bookings**: Each booking is a single instance
- **No Self-Registration**: Admin creates all accounts
- **No Checkout Tracking**: Only check-in is tracked

## 🔒 Security Considerations

1. **No Public Signup**: Prevents fake accounts and maintains audit integrity
2. **JWT Expiration**: Tokens expire after 24 hours
3. **Password Hashing**: Bcrypt with default cost factor
4. **Role-Based Authorization**: Strict admin/employee separation
5. **HTTPS Required**: All production traffic must use HTTPS
6. **Audit Logs**: Immutable trail of all administrative actions

## 🤝 Contributing

This is an internal enterprise system. Please follow the existing code style and ensure all tests pass before submitting changes.

## 📝 License

Internal use only - not for public distribution.

## 🆘 Support

For issues or questions, please refer to the documentation in the `/docs` folder or contact the development team.
