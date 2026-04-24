# Test Promotion Tool

Workflow for testing promotions before activation.

## Steps

### 1. List Current Promotions

```json
promotions_list()
```

Identify the promotion to test by ID.

### 2. Prepare Test Cart

Create a realistic cart that should trigger the promotion. All prices in **cents** (integer), use `unitPrice` not `price`:

```json
{
  "cart": {
    "currencyCode": "USD",
    "items": [
      { "id": "item-1", "unitPrice": 5000, "quantity": 1, "category": "clothing" },
      { "id": "item-2", "unitPrice": 2500, "quantity": 2, "category": "accessories" }
    ]
  }
}
```

### 3. Evaluate

```json
promotions_evaluate_cart({
  "cart": {
    "currencyCode": "USD",
    "items": [
      { "id": "item-1", "unitPrice": 5000, "quantity": 1, "category": "clothing" },
      { "id": "item-2", "unitPrice": 2500, "quantity": 2, "category": "accessories" }
    ]
  },
  "couponCodes": [],
  "dryRun": true
})
```

### 4. Analyze Response

Check these fields:

- **`applied`**: Promotions that fired — verify discount amounts
- **`notApplied`**: Promotions that didn't — check `reason` for debugging
- **`summary.totalDiscount`**: Total discount — sanity check the math

### 5. Edge Cases to Test

| Scenario            | Cart Modification                |
| ------------------- | -------------------------------- |
| Empty cart          | `{ "items": [] }`                |
| Single item         | One item only                    |
| Below condition min | Cart total below threshold       |
| Above condition min | Cart total above threshold       |
| With coupon         | Add to `couponCodes` array       |
| Without coupon      | Empty `couponCodes`              |
| Multiple categories | Mix of matching and non-matching |
| Large cart          | 10+ items                        |

### 6. Activate

Once all tests pass:

```json
promotions_update({ "promotionId": "promo_xxx", "status": "active" })
```

### 7. Verify Active

```json
promotions_get_active()
```

Confirm the promotion appears in the active list.
