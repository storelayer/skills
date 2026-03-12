# External Users (Customer Management)

External users are the end-customers of your loyalty program. They're managed via a project-scoped Durable Object.

## Key Concepts

- **DO Scope**: `${projectId}` — all users for a project in one DO
- **User ID**: Client-provided or auto-generated identifier
- **Lookup**: Can find users by ID or email

## MCP Tools

| Tool                         | Type  | Description                  |
| ---------------------------- | ----- | ---------------------------- |
| `external_users_get_user`    | read  | Get user by ID               |
| `external_users_list_users`  | read  | List users (paginated)       |
| `external_users_lookup_user` | read  | Smart lookup (ID then email) |
| `external_users_register`    | write | Register a new user          |
| `external_users_update`      | write | Update user fields           |

## User Fields

| Field       | Required (register) | Type   | Description               |
| ----------- | ------------------- | ------ | ------------------------- |
| `userId`    | Yes                 | string | Unique user ID            |
| `firstName` | Yes                 | string | First name                |
| `lastName`  | Yes                 | string | Last name                 |
| `email`     | No                  | string | User email                |
| `phone`     | No                  | string | Phone number              |
| `birthday`  | No                  | string | Birthday (ISO date)       |
| `gender`    | No                  | string | Gender                    |
| `metadata`  | No                  | object | Custom key-value metadata |

## Registering a User

```json
external_users_register({
  "userId": "customer-123",
  "firstName": "Alice",
  "lastName": "Smith",
  "email": "alice@example.com",
  "metadata": {
    "tier": "gold",
    "signupSource": "web"
  }
})
```

## Lookup

```json
// By ID
external_users_get_user({ "userId": "customer-123" })

// Smart lookup (tries ID first, then email)
external_users_lookup_user({ "lookupValue": "customer-123", "lookupFallbacks": ["alice@example.com"] })
```

## Listing Users

```json
external_users_list_users({ "limit": 50, "offset": 0 })
```

## Updating a User

```json
external_users_update({
  "userId": "customer-123",
  "lastName": "Johnson",
  "metadata": { "tier": "platinum" }
})
```

## Common Patterns

### User-Scoped Operations

When calling wallet, events, or other user-scoped tools, you need the `userId`. Use `external_users_lookup_user` to find it from an email or identifier.

### Metadata

Store arbitrary key-value data in `metadata`. Useful for tier status, preferences, custom attributes.

### Bulk Registration

Use `external_users_register` in a loop for batch imports. Each call is idempotent if the same userId is used.

## Gotchas

- User IDs are strings, not numbers
- `firstName` and `lastName` are **required** when registering — omitting them causes a NOT NULL constraint error
- `external_users_lookup_user` tries ID first, then email — use it when unsure
- Metadata is merged on update, not replaced (send only changed fields)
