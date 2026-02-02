# Authentication & Authorization Documentation

## Overview

The Smart Office Resource Management System uses **Devise** for authentication with JWT token support and **CanCanCan** for role-based authorization.

## Key Principles

### No Public Self-Registration

- **CRITICAL**: There is NO public signup endpoint.
- Only admins can create user accounts.
- This ensures identity integrity and audit reliability.
- Prevents fake accounts and maintains audit validity.

### User Roles

- **Admin**: Full system access, user management, resource creation, and booking approval.
- **Employee**: Can login, view resources, request bookings, and manage their own profile/bookings.

## Authentication Stack

### Devise

- Industry-standard authentication solution for Rails.
- Handles password encryption and user lifecycle.
- Modular design with customizable strategies.

### Devise-JWT

- Extension for Devise that provides JWT token authentication for API-only apps.
- Stateless authentication using a **JWT Denylist** for revocation.
- Tokens expire after 24 hours.

### CanCanCan

- Authorization library for Rails.
- Centralized permission management through the `Ability` class.
- Role-based and resource-based access control.

## Authentication Flow

### 1. Login Flow

```
Employee/Admin → POST /api/v1/auth/login
                  ├─ email: string
                  └─ password: string
                ↓
    Devise validates credentials
                ↓
         JWT Token Generated (Devise-JWT)
                ↓
    Response: { token, user, expires_at }
                ↓
      Client stores JWT token
                ↓
   Subsequent requests include:
   Authorization: Bearer <token>
```

### 2. Request Authentication

```
Client Request → Authorization Header
                ↓
      Devise-JWT Token Verification
                ↓
        ┌─────────────┐
        │ Valid?      │
        └─────────────┘
         /           \
       Yes           No
        ↓             ↓
  Set current_user  401 Unauthorized
        ↓
  CanCanCan authorization check
        ↓
  Process request
```

### 3. CanCanCan Authorization Flow

```
Controller Action
        ↓
  load_and_authorize_resource
        ↓
  CanCanCan checks Ability class
        ↓
    ┌───────────────────┐
    │ User has ability? │
    └───────────────────┘
     /                  \
   Yes                  No
    ↓                    ↓
  Allow           403 Forbidden (CanCan::AccessDenied)
```

## API Endpoints

### Authentication Endpoints

#### Login

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "user": {
    "email": "admin@josh.com",
    "password": "password123"
  }
}
```

**Success Response (200 OK):**

```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": "uuid",
    "employee_id": "EMP001",
    "name": "Admin",
    "email": "admin@josh.com",
    "role": "admin"
  },
  "expires_at": "2026-02-03T12:00:00Z"
}
```

**Error Response (401 Unauthorized):**

```json
{
  "error": "Invalid email or password"
}
```

#### Logout

```http
DELETE /api/v1/auth/logout
Authorization: Bearer <token>
```

**Success Response (200 OK):**

```json
{
  "message": "Logged out successfully"
}
```

#### Get Current User (Profile)

```http
GET /api/v1/auth/me
Authorization: Bearer <token>
```

**Success Response (200 OK):**

```json
{
  "id": "uuid",
  "employee_id": "EMP001",
  "name": "Admin",
  "email": "admin@josh.com",
  "role": "admin"
}
```

### User Management Endpoints (Admin Only)

#### Create User

```http
POST /api/v1/users
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "user": {
    "employee_id": "EMP002",
    "name": "Jane Smith",
    "email": "jane@company.com",
    "password": "temporarypassword",
    "role": "employee"
  }
}
```

**Success Response (201 Created):**

```json
{
  "message": "User created successfully",
  "user": {
    "id": "uuid",
    "employee_id": "EMP002",
    "name": "Jane Smith",
    "email": "jane@company.com",
    "role": "employee"
  }
}
```

## Security Measures

1. **Password Encryption**: Devise uses Bcrypt for secure password hashing.
2. **Token Signing**: Devise-JWT uses HS256 algorithm with a secret key.
3. **Token Revocation**: Uses a database-backed **JWT Denylist** to invalidate tokens upon logout.
4. **Manual Helpers**: Custom `current_user` and `authenticate_user!` in `ApplicationController` for robust API authentication.
5. **CORS Configuration**: Handles cross-origin requests from the frontend.

## Error Codes

| Code | Meaning              | Scenario                                             |
| ---- | -------------------- | ---------------------------------------------------- |
| 200  | OK                   | Successful authentication                            |
| 201  | Created              | User successfully created                            |
| 401  | Unauthorized         | Invalid credentials or missing/expired token         |
| 403  | Forbidden            | Valid token but insufficient permissions (CanCanCan) |
| 404  | Not Found            | Resource not found                                   |
| 422  | Unprocessable Entity | Validation errors (duplicate email, etc.)            |

## Implementation Details

### User Model

Location: `app/models/user.rb`

```ruby
class User < ApplicationRecord
  devise :database_authenticatable,
         :jwt_authenticatable,
         :validatable,
         jwt_revocation_strategy: JwtDenylist

  validates :employee_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
```

### Ability Class (CanCanCan)

Location: `app/models/ability.rb`

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    if user.admin?
      can :manage, :all
    elsif user.employee?
      can :read, Booking
      can :create, Booking
      can :update, Booking, user_id: user.id, status: 'pending'
      can :destroy, Booking, user_id: user.id, status: ['pending', 'approved']

      can :read, Resource
      can :read, User, id: user.id
      can :update, User, id: user.id
    end
  end
end
```

### Application Controller

Location: `app/controllers/application_controller.rb`

```ruby
class ApplicationController < ActionController::API
  before_action :authenticate_user!

  def current_user
    @current_user ||= warden.authenticate(:jwt, scope: :api_v1_user)
  end

  def authenticate_user!
    render json: { error: 'Unauthorized' }, status: :unauthorized unless current_user
  end

  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: 'Access denied', message: exception.message }, status: :forbidden
  end
end
```

### JWT Denylist Model

Location: `app/models/jwt_denylist.rb`

```ruby
class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist
  self.table_name = 'jwt_denylist'
end
```

## Testing Authentication

### Using cURL

```bash
# Login (Admin)
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"admin@josh.com","password":"password123"}}'

# Get current profile
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer <token>"

# Create user (Admin Only)
curl -X POST http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer <admin-token>" \
  -H "Content-Type: application/json" \
  -d '{"user":{"employee_id":"EMP002","name":"Test","email":"test@test.com","password":"password123","role":"employee"}}'
```
