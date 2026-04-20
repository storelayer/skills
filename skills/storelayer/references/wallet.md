# Wallet System

The wallet is a per-user ledger for tracking points, tokens, credits, and any custom asset type.

## Key Concepts

- **Asset Type**: Named unit (e.g., "points", "stamps", "credits"). Arbitrary string — you define them.
- **DO Scope**: `${projectId}_${userId}` — each user has their own wallet instance.
- **FEFO**: Spend uses First-Expire-First-Out ordering.
- **Expiration**: Earned assets can have an optional `expiresAt` timestamp.

## MCP Tools

### Read Operations

| Tool                       | Description                      | Requires userId |
| -------------------------- | -------------------------------- | --------------- |
| `wallet_get_balance`       | Get balance for all asset types  | Yes             |
| `wallet_list_transactions` | Transaction history with filters | Yes             |

### Write Operations

| Tool            | Description                              | Requires userId |
| --------------- | ---------------------------------------- | --------------- |
| `wallet_credit` | Add assets (earn points/tokens)          | Yes             |
| `wallet_debit`  | Spend assets (FEFO order)                | Yes             |
| `wallet_modify` | Set balance to an absolute target amount | Yes             |

## Earning (Credit)

```json
wallet_credit({
  "userId": "customer-123",
  "assetType": "points",
  "amount": 100,
  "description": "Purchase reward: Order #456",
  "expiresAt": "2027-03-13T00:00:00Z",
  "tags": ["purchase", "order-456"],
  "referenceId": "order-456"
})
```

**Fields:**

- `assetType` (required): String identifier for the asset
- `amount` (required): Positive number
- `description` (optional): Human-readable reason
- `expiresAt` (optional): ISO 8601 timestamp for expiration
- `tags` (optional): Array of strings for categorization
- `referenceId` (optional): External reference (for deduplication/tracking)

## Spending (Debit)

```json
wallet_debit({
  "userId": "customer-123",
  "assetType": "points",
  "amount": 50,
  "description": "Redeemed for $5 coupon"
})
```

Spending follows **FEFO** (First-Expire-First-Out) — assets expiring soonest are consumed first.

## Modify Balance (Set to Absolute Value)

```json
wallet_modify({
  "userId": "customer-123",
  "assetType": "points",
  "targetAmount": 60,
  "description": "Manual balance correction",
  "expiresAt": "2027-03-13T00:00:00Z"
})
```

Sets the wallet balance for an asset type to an absolute target. The engine
computes the delta against the current balance and records a single `adjust`
transaction:

- **target > current:** creates a new asset entry for the delta (honors
  `expiresAt` / `tags`).
- **target < current:** consumes existing entries FEFO (same ordering as spend).
- **target == current:** no-op; no transaction written.

Use this instead of chaining a redemption + reward when a rule needs to set
the balance to a specific number. In rule actions, use type `modify` with
config `{ assetType, targetAmount, userId?, description?, expiresIn?,
expiresInUnit?, tags? }`.

## Checking Balance

```json
wallet_get_balance({ "userId": "customer-123" })
```

Response returns each asset type with full balance details:

```json
{
  "points": {
    "assetType": "points",
    "balance": 450,
    "lifetimeEarned": 1000,
    "lifetimeSpent": 550,
    "lifetimeExpired": 0,
    "nextExpiration": "2027-06-01T00:00:00Z"
  },
  "coffee_stamps": {
    "assetType": "coffee_stamps",
    "balance": 3,
    "lifetimeEarned": 3,
    "lifetimeSpent": 0,
    "lifetimeExpired": 0,
    "nextExpiration": null
  }
}
```

**Fields per asset type:**

| Field             | Type           | Description                      |
| ----------------- | -------------- | -------------------------------- |
| `assetType`       | string         | Asset type identifier            |
| `balance`         | number         | Current available balance        |
| `lifetimeEarned`  | number         | Total earned across all time     |
| `lifetimeSpent`   | number         | Total spent across all time      |
| `lifetimeExpired` | number         | Total expired across all time    |
| `nextExpiration`  | string \| null | ISO date of next asset to expire |

## Using Wallet in Rule Conditions

When a wallet internal resource is configured (key: `wallet`, entity: `wallet`), the balance data is available in rule conditions using the `$()` function:

```
{{ $('wallet').points.balance }}           → current points balance
{{ $('wallet').coffee_stamps.balance }}     → current coffee stamps balance
{{ $('wallet').points.lifetimeEarned }}     → total points ever earned
{{ $('wallet').coffee_stamps.balance % 4 }} → modulo check (e.g. every 4th stamp)
```

**Example: Free coffee on every 4th purchase**

```json
{
  "leftValue": "{{ $('wallet').coffee_stamps.balance % 4 }}",
  "operator": "equals",
  "rightValue": 0,
  "rightType": "number"
}
```

> **Important:** You must create an internal resource with key `wallet` and entity `wallet` (or toolName `wallet.get_balance`) for wallet data to be available in rule conditions. Without this resource, `$('wallet')` returns `undefined`.

## Transaction History

```json
wallet_list_transactions({
  "userId": "customer-123",
  "assetType": "points",
  "limit": 20
})
```

## Common Patterns

### Points-for-Purchase (via Rules)

Create an event rule that credits the wallet on purchase events. See `events.md`.

### Manual Credit/Debit

Use `wallet_credit` / `wallet_debit` directly for admin operations, customer service adjustments, or one-off rewards.

### Multiple Asset Types

A single user can have multiple asset types (points + stamps + credits). Each tracks independently.

### Expiration

Set `expiresAt` on credits. Expired assets are automatically excluded from balance. The DO alarm handles cleanup.

## Gotchas

- Always specify `userId` — wallet is user-scoped
- `amount` must be positive for both credit and debit
- Debit will fail if insufficient balance
- `referenceId` is not enforced as unique — use it for tracking, not dedup
- In rule conditions, use `$('wallet').assetType.balance` syntax — the wallet resource must be configured for this to work
