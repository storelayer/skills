# Condition Engine Reference

Conditions are used in both **rules** (event matching) and **promotions** (cart matching).

## Condition Structure

```json
{
  "conditions": [
    {
      "leftValue": "{{ event.type }}",
      "operator": "equals",
      "rightValue": "purchase",
      "rightType": "string"
    }
  ],
  "combinator": "AND"
}
```

### Fields

| Field        | Description                                     |
| ------------ | ----------------------------------------------- |
| `leftValue`  | Template expression or literal to evaluate      |
| `operator`   | Comparison operator                             |
| `rightValue` | Value to compare against                        |
| `rightType`  | Type hint: `string`, `number`, `boolean`        |
| `combinator` | `AND` (all must match) or `OR` (any must match) |

## Operators

| Operator      | Description             | Example                          |
| ------------- | ----------------------- | -------------------------------- |
| `equals`      | Exact match             | `event.type` equals `purchase`   |
| `notEquals`   | Not equal               | `event.type` notEquals `refund`  |
| `gt`          | Greater than            | `cart.total` gt `50`             |
| `gte`         | Greater than or equal   | `cart.total` gte `100`           |
| `lt`          | Less than               | `cart.itemCount` lt `10`         |
| `lte`         | Less than or equal      | `event.payload.amount` lte `500` |
| `contains`    | String contains         | `user.email` contains `@corp`    |
| `notContains` | String doesn't contain  | `event.type` notContains `test`  |
| `startsWith`  | String starts with      | `event.type` startsWith `order`  |
| `endsWith`    | String ends with        | `user.email` endsWith `.com`     |
| `exists`      | Field is not null/undef | `event.payload.coupon` exists    |
| `notExists`   | Field is null/undefined | `user.tier` notExists            |
| `regex`       | Regex match             | `event.type` regex `^order\.`    |
| `before`      | Date before             | `event.timestamp` before `date`  |
| `after`       | Date after              | `event.timestamp` after `date`   |
| `isEmpty`     | Empty string/array      | `cart.items` isEmpty             |
| `isNotEmpty`  | Non-empty               | `cart.items` isNotEmpty          |
| `hasKey`      | Object has key          | `event.payload` hasKey `amount`  |

## Template Expressions (Rules)

Rules use `{{ }}` template syntax to reference event data:

| Expression                   | Resolves To            |
| ---------------------------- | ---------------------- |
| `{{ event.type }}`           | Event type string      |
| `{{ event.payload.amount }}` | Nested payload field   |
| `{{ event.userId }}`         | User ID from event     |
| `{{ user.email }}`           | User profile email     |
| `{{ user.name }}`            | User profile name      |
| `{{ history.amount }}`       | Historical aggregation |

## Condition Fields (Promotions)

Promotions use dot-notation paths into the cart:

| Field                    | Description           |
| ------------------------ | --------------------- |
| `cart.total`             | Cart total amount     |
| `cart.itemCount`         | Total item count      |
| `cart.uniqueItemCount`   | Unique item count     |
| `cart.items[0].price`    | First item's price    |
| `cart.items[0].category` | First item's category |

## Nested/Grouped Conditions

Conditions can be nested for complex logic:

```json
{
  "conditions": [
    {
      "leftValue": "{{ event.type }}",
      "operator": "equals",
      "rightValue": "purchase",
      "rightType": "string"
    },
    {
      "conditions": [
        {
          "leftValue": "{{ event.payload.amount }}",
          "operator": "gte",
          "rightValue": 100,
          "rightType": "number"
        },
        {
          "leftValue": "{{ user.tier }}",
          "operator": "equals",
          "rightValue": "vip",
          "rightType": "string"
        }
      ],
      "combinator": "OR"
    }
  ],
  "combinator": "AND"
}
```

This matches: `purchase AND (amount >= 100 OR user is VIP)`

## Testing

Always test conditions before deploying:

```json
project_test_conditions({
  "conditions": { ... },
  "context": {
    "event": { "type": "purchase", "payload": { "amount": 75 } },
    "user": { "tier": "gold", "email": "alice@example.com" }
  }
})
```

Response shows which individual conditions passed or failed.
