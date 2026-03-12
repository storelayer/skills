# Events & Rules System

Events are the backbone of Storelayer's automation. External systems send events (purchases, signups, etc.), and rules define what happens when events match conditions.

## Key Concepts

- **Event**: A timestamped action with `type`, `userId`, and `payload`
- **Rule**: Condition set + actions that execute when a matching event arrives
- **Event Queue**: Events are processed via Cloudflare Queues (batch 10, timeout 5s)
- **DO Scope**: Events stored in `${projectId}_${userId}`, Rules in `${projectId}`

## MCP Tools — Events

| Tool               | Type  | Description                                    |
| ------------------ | ----- | ---------------------------------------------- |
| `events_ingest`    | write | Ingest event (triggers rules & wallet actions) |
| `events_get`       | read  | Get event by ID                                |
| `events_list`      | read  | List events with filters                       |
| `events_get_stats` | read  | Event stats by type                            |

## MCP Tools — Rules

| Tool                      | Type  | Description                         |
| ------------------------- | ----- | ----------------------------------- |
| `project_get_config`      | read  | Project configuration               |
| `project_list_rules`      | read  | List all loyalty rules              |
| `project_get_rule`        | read  | Get a single rule by ID             |
| `project_add_rule`        | write | Create a rule                       |
| `project_update_rule`     | write | Update a rule                       |
| `project_remove_rule`     | write | Delete a rule                       |
| `project_test_conditions` | write | Test conditions against sample data |

## Event Ingestion

### Via MCP Tool (recommended for agents)

```json
events_ingest({
  "type": "purchase",
  "userId": "customer-123",
  "payload": {
    "amount": 49.99,
    "orderId": "order-789",
    "items": [{ "id": "item-1", "name": "Latte", "price": 4.99 }]
  }
})
```

Returns `{ id: "evt_xxx", status: "accepted" }`. The event is stored, queued for rule evaluation, and tracked in the user's workflow history.

### Via REST API (for external integrations)

```
POST /projects/{projectId}/ingest/events
Headers: X-API-Key: <key>

{
  "type": "purchase",
  "userId": "customer-123",
  "payload": {
    "amount": 49.99,
    "orderId": "order-789",
    "items": [...]
  }
}
```

## Creating Rules

A rule has: name, conditions (when to fire), actions (what to do), and resources (what events to match + what data to fetch).

```json
project_add_rule({
  "name": "1 Point Per Dollar on Purchase",
  "conditions": {
    "conditions": [
      {
        "leftValue": "{{ $('event').type }}",
        "operator": "equals",
        "rightValue": "purchase",
        "rightType": "string"
      },
      {
        "leftValue": "{{ $('event').payload.amount }}",
        "operator": "gt",
        "rightValue": 0,
        "rightType": "number"
      }
    ],
    "combinator": "AND"
  },
  "actions": [
    {
      "type": "reward",
      "config": {
        "assetType": "points",
        "amount": "{{ $('event').payload.amount }}",
        "description": "Purchase reward for order {{ $('event').payload.orderId }}"
      }
    }
  ],
  "resources": {
    "event": { "type": "purchase" }
  }
})
```

### Rule Fields

| Field        | Required | Description                            |
| ------------ | -------- | -------------------------------------- |
| `name`       | Yes      | Human-readable name                    |
| `conditions` | Yes      | Condition set (see `conditions.md`)    |
| `actions`    | Yes      | Array of actions to execute            |
| `resources`  | Yes      | Must include `event.type` for matching |

### Action Types

| Type                | Config Fields                                          | Description                        |
| ------------------- | ------------------------------------------------------ | ---------------------------------- |
| `reward`            | `assetType`, `amount`, `description`, `expirationDate` | Credit wallet (earn points/tokens) |
| `redemption`        | `assetType`, `amount`, `description`                   | Debit wallet (spend points/tokens) |
| `integration`       | `integrationId`, `payloadTemplate`                     | Trigger an external integration    |
| `notify`            | `title`, `message`                                     | Send a notification                |
| `tag`               | `tag`                                                  | Tag the user                       |
| `apply_referral`    | `code`, `refereeId`, `metadata`                        | Apply a referral code              |
| `complete_referral` | `refereeId`                                            | Mark a referral as completed       |
| `mark_code_used`    | `code`, `refereeId`                                    | Mark a referral code as used       |
| `custom`            | `key`                                                  | Custom action (extensible)         |

### Template Expressions in Actions

Actions support `{{ }}` template expressions with the `$()` function:

- `{{ $('event').type }}` — Event type
- `{{ $('event').payload.amount }}` — Nested payload values
- `{{ $('event').userId }}` — User who triggered the event
- `{{ $('user').email }}` — User profile fields (requires `user` resource)
- `{{ $('wallet').points.balance }}` — Wallet balance (requires `wallet` resource)

## Using Wallet Data in Rules

To access wallet balances in rule conditions, add an internal resource with entity `wallet`:

```json
project_add_rule({
  "name": "Free Coffee on Every 4th Purchase",
  "conditions": {
    "conditions": [
      {
        "leftValue": "{{ $('event').type }}",
        "operator": "equals",
        "rightValue": "purchase",
        "rightType": "string"
      },
      {
        "leftValue": "{{ $('wallet').coffee_stamps.balance % 4 }}",
        "operator": "equals",
        "rightValue": 0,
        "rightType": "number"
      }
    ],
    "combinator": "AND"
  },
  "actions": [
    {
      "type": "reward",
      "config": {
        "assetType": "free_coffee",
        "amount": 1,
        "description": "Free coffee reward!"
      }
    }
  ],
  "resources": {
    "event": { "type": "purchase" },
    "wallet": { "type": "internal", "entity": "wallet" }
  }
})
```

> **Important:** The `wallet` resource must be declared in `resources` for `$('wallet')` to resolve. Without it, wallet data is not fetched and expressions return `undefined`/`NaN`.

## Testing Rules

Always test conditions before creating rules:

```json
project_test_conditions({
  "conditions": {
    "conditions": [
      { "leftValue": "{{ $('event').type }}", "operator": "equals", "rightValue": "purchase", "rightType": "string" }
    ],
    "combinator": "AND"
  },
  "context": {
    "event": { "type": "purchase", "payload": { "amount": 49.99 } }
  }
})
```

Returns `{ match: true/false, details: [...] }` — shows which conditions passed/failed.

## Common Event Types

| Event Type           | Typical Payload Fields           |
| -------------------- | -------------------------------- |
| `purchase`           | amount, currency, items, orderId |
| `signup`             | source, referralCode             |
| `referral.completed` | referrerId, refereeId            |
| `page_view`          | url, duration                    |
| `product_view`       | productId, category              |
| `cart_abandoned`     | cartId, items, total             |
| `review_submitted`   | productId, rating                |

## Gotchas

- **Missing `resources`** — Rules MUST have `resources: { event: { type: "..." } }` to match events. This is the #1 cause of rules not firing.
- **Missing internal resources** — To use `$('wallet')` or `$('user')` in conditions, you must declare the corresponding internal resource in `resources`. Without it, the data is not fetched.
- **Template syntax** — Use `{{ $('resource').field }}` syntax for accessing resource data in conditions and actions
- **Condition testing** — Always test with `project_test_conditions` before deploying. The `context` must include the full data shape for all referenced resources.
- **Queue processing** — Events are batched (10 events, 5s timeout). There's a small delay between ingestion and rule execution.
