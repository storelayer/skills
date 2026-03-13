# Referral System

The referral system manages refer-a-friend programs including code generation, application, tracking, and leaderboards.

## Key Concepts

- **DO Scope**: `${projectId}` — referral state is project-scoped
- **Referral Code**: Unique code tied to a referrer (user)
- **Application**: When a referee uses a referral code
- **Completion**: Triggered via event rules, which can then reward both parties

## MCP Tools

### Read Operations

| Tool                       | Description             |
| -------------------------- | ----------------------- |
| `referral_get_config`      | Referral program config |
| `referral_list_codes`      | List referral codes     |
| `referral_validate_code`   | Check if code is valid  |
| `referral_get_stats`       | Aggregate stats         |
| `referral_get_leaderboard` | Top referrers           |

### Write Operations

| Tool                       | Description            |
| -------------------------- | ---------------------- |
| `referral_create_code`     | Create a referral code |
| `referral_apply_code`      | Apply code for referee |
| `referral_deactivate_code` | Deactivate a code      |

## Typical Flow

### 1. Create Referral Code

```json
referral_create_code({ "referrerId": "user-123" })
// Returns: { code: "ABC123", referrerId: "user-123" }
```

### 2. Referee Applies Code

```json
referral_apply_code({ "code": "ABC123", "refereeId": "user-456" })
```

### 3. Reward Both Parties (via Rules)

Create event rules that trigger on `referral.completed`:

```json
project_add_rule({
  "name": "Referral Reward - Referrer",
  "conditions": {
    "conditions": [
      { "leftValue": "{{ $('event').type }}", "operator": "equals", "rightValue": "referral.completed", "rightType": "string" }
    ],
    "combinator": "AND"
  },
  "actions": [
    {
      "type": "reward",
      "config": {
        "assetType": "points",
        "amount": 500,
        "description": "Referral bonus - you referred a friend!"
      }
    }
  ],
  "resources": { "event": { "type": "referral.completed" } }
})
```

### 4. Track Performance

```json
referral_get_leaderboard()
// Returns top referrers by count

referral_get_stats()
// Returns aggregate: total codes, total applications, conversion rate
```

## Common Patterns

### Double-Sided Reward

Create two rules — one for referrer, one for referee — both triggered by `referral.completed`.

### Tiered Referral

Create multiple rules with different conditions (e.g., 5+ referrals = bonus multiplier).

### Limited Codes

Set usage limits on referral codes to prevent abuse.

## Gotchas

- Referral codes are per-project, not per-user-wallet
- The `referral.completed` event must be triggered (either automatically or via ingestion) for rules to fire
- Deactivated codes cannot be reactivated — create new ones instead
