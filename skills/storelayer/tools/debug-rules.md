# Debug Rules Tool

Systematic workflow for diagnosing why rules aren't firing or producing unexpected results.

## Symptom: Rule Not Firing

### Step 1: Verify the Rule Exists

```json
project_list_rules()
```

Find your rule. If missing, it was never created.

### Step 2: Check Event Flow

```json
events_list()
events_get_stats()
```

Verify events of the expected type are arriving. If no events, ingest one to test:

```json
events_ingest({
  "type": "purchase",
  "userId": "test-user-1",
  "payload": { "amount": 49.99 }
})
```

### Step 3: Check `resources` Field

The #1 cause of rules not firing. The rule MUST have:

```json
"resources": { "event": { "type": "purchase" } }
```

If `resources` is missing or the event type doesn't match, the rule is never evaluated.

### Step 4: Test Conditions

```json
project_test_conditions({
  "conditions": { ... },  // Copy from the rule
  "context": {
    "event": {
      "type": "purchase",
      "payload": { "amount": 49.99 }
    }
  }
})
```

The response shows which conditions passed/failed. Common issues:

- Template expression typo (`{{ $('event').pyaload.amount }}` instead of `{{ $('event').payload.amount }}`)
- Wrong operator (using `equals` with a number instead of `gte`)
- Wrong `rightType` (string vs number mismatch)

### Step 5: Check Action Config

If conditions pass but no wallet credit:

- Verify `assetType` is a valid string
- Verify `amount` resolves to a positive number
- Check `{{ }}` template expressions in action config

## Symptom: Wrong Amount

### Check Template Resolution

If the rule uses `"amount": "{{ $('event').payload.amount }}"`:

- Verify the event payload actually has an `amount` field
- Verify it's a number, not a string
- Test with `project_test_conditions` using the exact event shape

### Check for Duplicate Rules

```json
project_list_rules()
```

Multiple rules matching the same event type will ALL fire. Check for duplicates.

## Symptom: Promotion Not Applying

### Step 1: Check Status

```json
promotions_get_active()
```

Is the promotion `active`? Draft promotions don't apply.

### Step 2: Evaluate and Check `notApplied`

```json
promotions_evaluate_cart({ "cart": { "items": [...] } })
```

The `notApplied` array contains the exact reason:

- `condition_failed` — which condition failed and why
- `coupon_required` — promotion needs a coupon code
- `usage_exceeded` — max usage reached
- `validity_expired` — outside validFrom/validTo window

### Step 3: Check Cart Field Names

The discount script references specific fields (e.g., `i.category`). If your cart items use `i.type` instead, the script fails silently (returns empty array).

### Step 4: Test Script Isolation

Create a minimal promotion with no conditions to test the script alone:

```json
promotions_create({
  "name": "Debug Test",
  "status": "active",
  "conditions": { "conditions": [], "combinator": "AND" },
  "itemsDiscountComputation": {
    "script": "return $('cart').items.map(i => ({ id: i.id, amount: 1 }));",
    "language": "javascript"
  }
})
```

If this applies (gives $1 off each item), the issue is in your script logic, not conditions.

## Quick Checklist

- [ ] Rule exists in `project_list_rules()`
- [ ] Events arriving in `events_list()`
- [ ] Rule has `resources: { event: { type: "..." } }`
- [ ] Event type in resources matches actual event type
- [ ] Conditions pass in `project_test_conditions()`
- [ ] Template expressions use correct field paths
- [ ] For promotions: status is `active`
- [ ] For coupons: `requiresCoupon: true` AND code in `couponCodes`
