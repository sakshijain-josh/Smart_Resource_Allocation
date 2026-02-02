# Feature: Create Resource

This document outlines the implementation plan for the Resource management feature, enabling Admins to create and manage bookable resources.

## Objectives

- Implement CRUD operations for Resources.
- Ensure only Admins can Create/Update/Delete resources.
- Employees can only List and View resources.

## Implementation Steps

### 1. Database Model

The `Resource` model should include:

- `name`: (String) e.g., "Conference Room A", "Desk 42".
- `resource_type`: (String) e.g., "room", "desk", "laptop".
- `description`: (Text) Optional details.
- `location`: (String) Floor, wing, or building.
- `metadata`: (JSONB) For type-specific attributes (e.g., seating capacity for rooms).

### 2. Controller Implementation

`Api::V1::ResourcesController` will handle requests:

- `GET /api/v1/resources`: List all resources.
- `GET /api/v1/resources/:id`: Show specific resource.
- `POST /api/v1/resources`: Create new resource (Admin only).
- `PATCH /api/v1/resources/:id`: Update resource (Admin only).
- `DELETE /api/v1/resources/:id`: Delete resource (Admin only).

### 3. Authorization (CanCanCan)

Update `app/models/ability.rb`:

```ruby
def initialize(user)
  user ||= User.new
  if user.admin?
    can :manage, Resource
  else
    can :read, Resource
  end
end
```

### 4. Validation Rules

- Name: Required, Unique.
- Resource Type: Required, must be in allowed list.

## API Specification (Swagger)

The following endpoint should be added/verified in `docs/swagger.yaml`:

### POST /api/v1/resources

**Request Body**:

```json
{
  "resource": {
    "name": "Meeting Room 1",
    "resource_type": "room",
    "location": "3rd Floor, East Wing",
    "metadata": {
      "capacity": 10,
      "projector": true
    }
  }
}
```

**Response (201 Created)**:

```json
{
  "id": "uuid",
  "name": "Meeting Room 1",
  "resource_type": "room",
  "location": "3rd Floor, East Wing",
  "metadata": {
    "capacity": 10,
    "projector": true
  },
  "created_at": "...",
  "updated_at": "..."
}
```

## Testing Plan

- [ ] Admin can create resource with valid data.
- [ ] Admin cannot create resource with duplicate name.
- [ ] Employee receives `403 Forbidden` when attempting to create resource.
- [ ] List endpoint returns all available resources.
