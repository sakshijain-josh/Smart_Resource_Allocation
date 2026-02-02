# Authentication & Authorization Documentation

## Overview

The Smart Office Resource Management System uses **Devise** for authentication with JWT token support and **CanCanCan** for role-based authorization.

## Key Principles

### No Public Self-Registration

- **CRITICAL**: There is NO public signup endpoint
- Only admins can create user accounts
- This ensures identity integrity and audit reliability
- Prevents fake accounts and maintains audit validity

### User Roles

- **Admin**: Full system access, user management, booking approval
- **Employee**: Login, request bookings, check-in, view bookings

## Authentication Stack

### Devise

- Industry-standard authentication solution for Rails
- Handles password encryption, session management, and user lifecycle
- Modular design with customizable strategies
- Built-in security features and validations

### Devise-JWT

- Extension for Devise that provides JWT token authentication
- Stateless authentication for API endpoints
- Token generation, validation, and revocation
- Custom strategies for token storage and blacklisting

### CanCanCan

- Authorization library for Rails
- Centralized permission management through Ability class
- Role-based and resource-based access control
- Clean, declarative syntax for defining permissions

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
    "email": "employee@company.com",
    "password": "securepassword"
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
    "name": "John Doe",
    "email": "john@company.com",
    "role": "employee"
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

#### Get Current User

```http
GET /api/v1/auth/me
Authorization: Bearer <token>
```

**Success Response (200 OK):**

```json
{
  "id": "uuid",
  "employee_id": "EMP001",
  "name": "John Doe",
  "email": "john@company.com",
  "role": "employee"
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

#### List Users

```http
GET /api/v1/users
Authorization: Bearer <admin-token>
```

#### Get User

```http
GET /api/v1/users/:id
Authorization: Bearer <admin-token>
```

#### Update User

```http
PATCH /api/v1/users/:id
Authorization: Bearer <admin-token>
Content-Type: application/json

{
  "user": {
    "name": "Jane Smith Updated",
    "email": "jane.new@company.com"
  }
}
```

## JWT Token Structure

### Payload (Devise-JWT)

```json
{
  "sub": "user-uuid",
  "scp": "user",
  "iat": 1738497600,
  "exp": 1738584000,
  "jti": "unique-token-id"
}
```

### Expiration

- Tokens expire after **24 hours**
- Refresh token mechanism can be enabled (optional)
- Expired tokens return 401 Unauthorized
- JTI (JWT ID) used for token revocation

## Security Measures

1. **Password Encryption**: Devise uses Bcrypt with configurable cost factor
2. **Token Signing**: Devise-JWT uses HS256 algorithm with secret key from credentials
3. **Token Revocation**: JWT blacklisting using JTI (JWT ID) stored in database
4. **HTTPS Required**: All auth endpoints must use HTTPS in production
5. **CORS Configuration**: Whitelist specific frontend origins
6. **Input Validation**: Devise built-in validations for email format and password strength
7. **Rate Limiting**: Can integrate with Rack::Attack for brute force protection
8. **Password Complexity**: Configurable in Devise initializer (min 8 chars recommended)
9. **Account Lockout**: Devise :lockable module for failed login attempts
10. **Email Confirmation**: Devise :confirmable module (optional for new users)

## Error Codes

| Code | Meaning               | Scenario                                             |
| ---- | --------------------- | ---------------------------------------------------- |
| 200  | OK                    | Successful authentication                            |
| 201  | Created               | User successfully created                            |
| 401  | Unauthorized          | Invalid credentials or missing/expired token         |
| 403  | Forbidden             | Valid token but insufficient permissions (CanCanCan) |
| 422  | Unprocessable Entity  | Validation errors (duplicate email, etc.)            |
| 500  | Internal Server Error | Server-side error                                    |

## Implementation Details

### Gems Required

```ruby
# Gemfile
gem 'devise'
gem 'devise-jwt'
gem 'cancancan'
```

### User Model

Location: `app/models/user.rb`

**Features:**

```ruby
class User < ApplicationRecord
  # Devise modules
  devise :database_authenticatable,
         :jwt_authenticatable,
         :validatable,
         :lockable,
         :timeoutable,
         jwt_revocation_strategy: JwtDenylist

  # Role enum
  enum role: { employee: 0, admin: 1 }

  # Validations
  validates :employee_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  # Helper methods
  def admin?
    role == 'admin'
  end

  def employee?
    role == 'employee'
  end
end
```

### Ability Class (CanCanCan)

Location: `app/models/ability.rb`

**Permissions:**

```ruby
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.admin?
      # Admins can manage everything
      can :manage, :all
    elsif user.employee?
      # Employees can manage their own bookings
      can :read, Booking
      can :create, Booking
      can :update, Booking, user_id: user.id
      can :destroy, Booking, user_id: user.id, status: 'pending'

      # Employees can read resources
      can :read, Resource

      # Employees can check-in to their own bookings
      can :check_in, Booking, user_id: user.id

      # Employees can read their own user profile
      can :read, User, id: user.id
      can :update, User, id: user.id
    end

    # Define abilities for other roles or specific scenarios
  end
end
```

### Controllers with CanCanCan

**Application Controller:**

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: 'Access denied' }, status: :forbidden
  end
end
```

**Resource Controller Example:**

```ruby
# app/controllers/api/v1/bookings_controller.rb
class Api::V1::BookingsController < ApplicationController
  load_and_authorize_resource

  def index
    # @bookings is automatically loaded based on current user's abilities
    render json: @bookings
  end

  def create
    # @booking is automatically authorized
    if @booking.save
      render json: @booking, status: :created
    else
      render json: { errors: @booking.errors }, status: :unprocessable_entity
    end
  end
end
```

### Devise-JWT Configuration

Location: `config/initializers/devise.rb`

```ruby
Devise.setup do |config|
  # JWT configuration
  config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.devise_jwt_secret_key
    jwt.dispatch_requests = [
      ['POST', %r{^/api/v1/auth/login$}]
    ]
    jwt.revocation_requests = [
      ['DELETE', %r{^/api/v1/auth/logout$}]
    ]
    jwt.expiration_time = 24.hours.to_i
  end

  # Password complexity
  config.password_length = 8..128

  # Lockable module
  config.lock_strategy = :failed_attempts
  config.unlock_strategy = :time
  config.maximum_attempts = 5
  config.unlock_in = 1.hour
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

**Migration:**

```ruby
create_table :jwt_denylist do |t|
  t.string :jti, null: false
  t.datetime :exp, null: false
  t.timestamps
end

add_index :jwt_denylist, :jti
```

## Testing Authentication

### Using cURL

```bash
# Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"admin@company.com","password":"admin123"}}'

# Logout
curl -X DELETE http://localhost:3000/api/v1/auth/logout \
  -H "Authorization: Bearer <your-token>"

# Get current user
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer <your-token>"

# Create user (admin only)
curl -X POST http://localhost:3000/api/v1/users \
  -H "Authorization: Bearer <admin-token>" \
  -H "Content-Type: application/json" \
  -d '{"user":{"employee_id":"EMP002","name":"Test User","email":"test@company.com","password":"password123","role":"employee"}}'
```

## Authorization Examples

### Check Abilities in Controllers

```ruby
# Check if user can perform action
if can? :create, Booking
  # Allow action
end

# Authorize specific action
authorize! :update, @booking

# Load and authorize resources automatically
load_and_authorize_resource
```

### Check Abilities in Views/Serializers

```ruby
if can? :update, booking
  # Show edit button
end
```

## CanCanCan Error Handling

```ruby
# app/controllers/application_controller.rb
rescue_from CanCan::AccessDenied do |exception|
  render json: {
    error: 'Access denied',
    message: exception.message
  }, status: :forbidden
end
```

## Future Enhancements

1. **Refresh Tokens**: Implement refresh token mechanism with Devise-JWT
2. **Password Reset**: Enable Devise :recoverable module with email support
3. **Email Confirmation**: Enable Devise :confirmable for new user verification
4. **2FA**: Implement two-factor authentication with devise-two-factor gem
5. **Session Management**: Track active sessions with Devise :trackable
6. **Advanced Abilities**: Add more granular permissions with CanCanCan
7. **OAuth Integration**: Add social login with devise-omniauth
8. **Account Lockout**: Fine-tune Devise :lockable settings
