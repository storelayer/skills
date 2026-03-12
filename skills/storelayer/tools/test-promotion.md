# Test Promotion Tool

Workflow for testing promotions before activation.

## Steps

### 1. List Current Promotions

```json
promotions_list()
```

Identify the promotion to test by ID.

### 2. Prepare Test Cart

Create a realistic cart that should trigger the promotion:

```json
{
  "cart": {
    "items": [
      { "id": "item-1", "price": 50.0, "quantity": 1, "category": "clothing" },
      {
        "id": "item-2",
        "price": 25.0,
        "quantity": 2,
        "category": "accessories"
      }
    ]
  }
}
```

### 3. Evaluate

```json
promotions_evaluate_cart({
  "cart": {
    "items": [
      { "id": "item-1", "price": 50.00, "quantity": 1, "category": "clothing" },
      { "id": "item-2", "price": 25.00, "quantity": 2, "category": "accessories" }
    ]
  },
  "couponCodes": []
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
