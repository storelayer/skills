# Promotions System

> **⚠️ Stale schema warning:** examples below use the legacy `itemsDiscountComputation` field. The current API uses `applicationMethod` with `methodType: "standard" | "buyget" | "custom_script"`. See **Application Method Reference** in `SKILL.md` for the canonical schema. Concepts (stacking, coupons, limits) still apply; only the discount-computation shape changed.

The promotions engine handles discounts, coupons, cart-level pricing logic, and promotion stacking.

## Key Concepts

- **Promotion**: A discount rule with conditions, a computation script, and lifecycle (draft/active/archived)
- **DO Scope**: `${projectId}` — promotions are project-scoped
- **Discount Script**: JavaScript code that computes per-item discounts
- **Stacking**: Controls how multiple promotions interact (stackable, exclusive, exclusive_group)
- **Coupons**: Optional codes that gate promotion activation

## MCP Tools

### Read Operations

| Tool                             | Description                    |
| -------------------------------- | ------------------------------ |
| `promotions_list`                | List promotions with filters   |
| `promotions_get_active`          | Get all active promotions      |
| `promotions_list_coupons`        | List coupons for a promotion   |
| `promotions_list_usage`          | List usage/redemption records  |
| `promotions_get_stats`           | Stats for a specific promotion |
| `promotions_get_aggregate_stats` | Global promotion stats         |

### Write Operations

| Tool                             | Description                      |
| -------------------------------- | -------------------------------- |
| `promotions_create`              | Create a promotion               |
| `promotions_update`              | Update a promotion               |
| `promotions_remove`              | Delete a promotion               |
| `promotions_duplicate`           | Clone a promotion as draft       |
| `promotions_create_coupon`       | Create a coupon                  |
| `promotions_bulk_create_coupons` | Bulk create 1-1000 coupons       |
| `promotions_evaluate_cart`       | Evaluate cart against promotions |

## Creating a Promotion

```json
promotions_create({
  "name": "Summer Sale 15%",
  "status": "draft",
  "stackingMode": "stackable",
  "priority": 10,
  "validFrom": "2026-06-01T00:00:00Z",
  "validTo": "2026-08-31T23:59:59Z",
  "requiresCoupon": false,
  "conditions": {
    "conditions": [
      { "leftValue": "{{ $('cart').total }}", "operator": "gte", "rightValue": 2500, "rightType": "number" }
    ],
    "combinator": "AND"
  },
  "itemsDiscountComputation": {
    "script": "return $('cart').items.map(i => ({ id: i.id, amount: i.price * 0.15 }));",
    "language": "javascript"
  }
})
```

### Fields

| Field                      | Required | Description                                           |
| -------------------------- | -------- | ----------------------------------------------------- |
| `name`                     | Yes      | Promotion name                                        |
| `status`                   | Yes      | `draft`, `active`, or `archived`                      |
| `conditions`               | Yes      | Condition set (see `conditions.md`)                   |
| `itemsDiscountComputation` | Yes      | Script + language for discount calculation            |
| `stackingMode`             | No       | `stackable` (default), `exclusive`, `exclusive_group` |
| `priority`                 | No       | Higher = evaluated first (default: 0)                 |
| `validFrom` / `validTo`    | No       | ISO 8601 time window                                  |
| `requiresCoupon`           | No       | If true, only applies when coupon code is provided    |
| `maxUsage`                 | No       | Global usage limit                                    |

## Evaluating a Cart

```json
promotions_evaluate_cart({
  "cart": {
    "currencyCode": "USD",
    "items": [
      { "id": "item-1", "unitPrice": 2500, "quantity": 1, "category": "shoes" },
      { "id": "item-2", "unitPrice": 1500, "quantity": 2 }
    ]
  },
  "couponCodes": ["SAVE20"],
  "userId": "customer-123"
})
```

**Response includes:**

- `applied`: Array of promotions that applied with their discounts
- `notApplied`: Array of promotions that didn't apply with reasons
- `summary`: Total discount, per-item breakdown

## Stacking Modes

| Mode              | Behavior                                          |
| ----------------- | ------------------------------------------------- |
| `stackable`       | Combines with other stackable promotions          |
| `exclusive`       | Blocks all other promotions if it applies         |
| `exclusive_group` | Only the best promotion within same group applies |

**Evaluation order**: Higher `priority` first. Exclusive promotions short-circuit.

## Coupons

### Create a Coupon

```json
promotions_create_coupon({
  "promotionId": "promo_xxx",
  "code": "SAVE20",
  "maxUses": 1000,
  "maxUsesPerUser": 1
})
```

### Bulk Create

```json
promotions_bulk_create_coupons({
  "promotionId": "promo_xxx",
  "count": 100,
  "prefix": "SUMMER",
  "maxUsesPerCode": 1
})
```

## Lifecycle

1. Create as `draft` — won't apply to carts
2. Test with `promotions_evaluate_cart`
3. Update to `active` — goes live
4. Set `validFrom`/`validTo` for time-bound campaigns
5. Archive when done

## Gotchas

- **Draft promotions don't apply** — must be `active`
- **requiresCoupon** — promotion is invisible without coupon code in `couponCodes` array
- **Script field names** — must match actual cart item properties. Check with real cart data.
- **Stacking** — `exclusive` blocks everything. Use `stackable` for combinable discounts.
- **notApplied** — always check this array for debugging. It tells you exactly which conditions failed.
- **Condition leftValue must use expression syntax** — `{{ $('cart').total }}` works; bare `cart.total` is treated as a literal string and never resolves. See `conditions.md` for details.
- **Cart values are in cents** — `total`, `unitPrice`, `shippingTotal` are integers in cents. A $25 threshold = `rightValue: 2500`.
