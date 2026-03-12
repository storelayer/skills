# Condition Engine Reference

Conditions are used in both **rules** (event matching) and **promotions** (cart matching).

## Condition Structure

```json
{
  "conditions": [
    {
      "leftValue": "{{ $('event').type }}",
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

| Operator      | Description             | Example                                |
| ------------- | ----------------------- | -------------------------------------- |
| `equals`      | Exact match             | `$('event').type` equals `purchase`    |
| `notEquals`   | Not equal               | `$('event').type` notEquals `refund`   |
| `gt`          | Greater than            | `$('cart').total` gt `50`              |
| `gte`         | Greater than or equal   | `$('wallet').points.balance` gte `100` |
| `lt`          | Less than               | `$('cart').itemCount` lt `10`          |
| `lte`         | Less than or equal      | `$('event').payload.amount` lte `500`  |
| `contains`    | String contains         | `$('user').email` contains `@corp`     |
| `notContains` | String doesn't contain  | `$('event').type` notContains `test`   |
| `startsWith`  | String starts with      | `$('event').type` startsWith `order`   |
| `endsWith`    | String ends with        | `$('user').email` endsWith `.com`      |
| `exists`      | Field is not null/undef | `$('event').payload.coupon` exists     |
| `notExists`   | Field is null/undefined | `$('user').tier` notExists             |
| `regex`       | Regex match             | `$('event').type` regex `^order\.`     |
| `before`      | Date before             | `$('event').timestamp` before `date`   |
| `after`       | Date after              | `$('event').timestamp` after `date`    |
| `isEmpty`     | Empty string/array      | `$('cart').items` isEmpty              |
| `isNotEmpty`  | Non-empty               | `$('cart').items` isNotEmpty           |
| `hasKey`      | Object has key          | `$('event').payload` hasKey `amount`   |

## Template Expressions

Use `{{ }}` with the `$()` function to access resources by key:

### `$()` Function

The `$('key')` function returns the resource value registered under that key in the evaluation context. This is the recommended way to access any resource data in conditions.

### Event Data

| Expression                        | Resolves To          |
| --------------------------------- | -------------------- |
| `{{ $('event').type }}`           | Event type string    |
| `{{ $('event').payload.amount }}` | Nested payload field |
| `{{ $('event').userId }}`         | User ID from event   |

### User Data (requires `user` internal resource)

| Expression                  | Resolves To        |
| --------------------------- | ------------------ |
| `{{ $('user').email }}`     | User profile email |
| `{{ $('user').firstName }}` | User first name    |
| `{{ $('user').lastName }}`  | User last name     |
| `{{ $('user').phone }}`     | User phone number  |

### Wallet Data (requires `wallet` internal resource)

| Expression                                    | Resolves To                   |
| --------------------------------------------- | ----------------------------- |
| `{{ $('wallet').points.balance }}`            | Current points balance        |
| `{{ $('wallet').coffee_stamps.balance }}`     | Current coffee stamps balance |
| `{{ $('wallet').points.lifetimeEarned }}`     | Total points earned all time  |
| `{{ $('wallet').coffee_stamps.balance % 4 }}` | Modulo check for Nth purchase |

### Built-in Variables

| Expression     | Resolves To                      |
| -------------- | -------------------------------- |
| `{{ $now }}`   | Current ISO timestamp            |
| `{{ $today }}` | Current date string (YYYY-MM-DD) |

### Computed Expressions

Expressions support JavaScript operators and built-in functions:

```
{{ $('event').payload.amount * 2 }}              → arithmetic
{{ $('wallet').points.balance >= 100 }}          → comparison (returns boolean)
{{ $('event').payload.items.length }}             → array length
{{ Math.floor($('wallet').points.balance / 10) }} → Math functions
```

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
      "leftValue": "{{ $('event').type }}",
      "operator": "equals",
      "rightValue": "purchase",
      "rightType": "string"
    },
    {
      "conditions": [
        {
          "leftValue": "{{ $('event').payload.amount }}",
          "operator": "gte",
          "rightValue": 100,
          "rightType": "number"
        },
        {
          "leftValue": "{{ $('wallet').points.balance }}",
          "operator": "gte",
          "rightValue": 500,
          "rightType": "string"
        }
      ],
      "combinator": "OR"
    }
  ],
  "combinator": "AND"
}
```

This matches: `purchase AND (amount >= 100 OR wallet points >= 500)`

## Internal Resources for Conditions

To use wallet, user, or other data in rule conditions, you must create internal resources. The resource `key` determines how you access it via `$()`:

| Resource Key | Entity / Tool                  | Access Pattern                           |
| ------------ | ------------------------------ | ---------------------------------------- |
| `wallet`     | entity: `wallet`               | `{{ $('wallet').assetType.balance }}`    |
| `user`       | entity: `user`                 | `{{ $('user').email }}`                  |
| `history`    | entity: `history`              | `{{ $('history').items }}`               |
| custom key   | toolName: `wallet.get_balance` | `{{ $('customKey').assetType.balance }}` |

> **Important:** Without the corresponding internal resource configured, `$('wallet')` returns `undefined` and expressions using it resolve to `NaN` or `undefined`.

## Testing

Always test conditions before deploying:

```json
project_test_conditions({
  "conditions": { ... },
  "context": {
    "event": { "type": "purchase", "payload": { "amount": 75 } },
    "user": { "tier": "gold", "email": "alice@example.com" },
    "wallet": {
      "points": { "balance": 450, "lifetimeEarned": 1000 },
      "coffee_stamps": { "balance": 3, "lifetimeEarned": 3 }
    }
  }
})
```

Response shows which individual conditions passed or failed.
