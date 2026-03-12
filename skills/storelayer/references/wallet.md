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

| Tool            | Description                     | Requires userId |
| --------------- | ------------------------------- | --------------- |
| `wallet_credit` | Add assets (earn points/tokens) | Yes             |
| `wallet_debit`  | Spend assets (FEFO order)       | Yes             |

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

## Checking Balance

```json
wallet_get_balance({ "userId": "customer-123" })
```

Response includes balance per asset type:

```json
{
  "balances": {
    "points": { "available": 450, "pending": 0, "total": 450 }
  }
}
```

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
