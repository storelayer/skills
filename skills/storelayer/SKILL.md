---
name: storelayer
description: Build loyalty programs, promotions, wallets, referrals, and customer engagement on the Storelayer commerce platform. Use when the user asks to create loyalty rules, promotions, discount codes, referral programs, earn/spend points, manage customers, or integrate events.
license: Apache-2.0
---

# Storelayer — Loyalty & Commerce Platform

You have access to the **Storelayer** platform. This skill makes you an expert at building loyalty programs, promotions, and customer engagement systems.

## Quick Decision Tree

```
What does the user want?
├─ Earn/spend points or tokens       → Wallet (references/wallet.md)
├─ Discounts, BOGO, % off            → Promotions (references/promotions.md)
├─ Coupon codes                       → Promotions + Coupons (references/promotions.md)
├─ Refer-a-friend programs            → Referral (references/referral.md)
├─ Track customer events              → Events & Rules (references/events.md)
├─ Manage customer profiles           → External Users (references/external-users.md)
├─ Automate multi-step flows          → Workflows (references/architecture.md)
├─ Understand the platform            → Architecture (references/architecture.md)
├─ Write discount scripts             → Script Reference (references/discount-scripts.md)
├─ Set up event ingestion             → Integration Agent (agents/integration-dev.md)
├─ Debug why something isn't working  → Debug Tool (tools/debug-rules.md)
└─ Set up a new project from scratch  → Setup Tool (tools/setup-project.md)
```

## Pipeline: How to Build Loyalty Programs

**Always follow this pipeline.** Do not skip steps.

### Step 1: Discover Current State

Before creating anything, understand what exists:

```
1. project_get_config          → currency, timezone, cart format
2. project_list_rules          → existing loyalty rules
3. promotions_get_active       → active promotions
4. events_get_stats            → event flow (what types come in)
5. wallet_get_balance (userId) → existing asset types in use
```

### Step 2: Design the Program

Map the user's intent to domains:

| User wants...                | Domains involved                | Reference                     |
| ---------------------------- | ------------------------------- | ----------------------------- |
| "Earn points on purchase"    | Rules + Wallet                  | events.md + wallet.md         |
| "10% off orders over $50"    | Promotions                      | promotions.md                 |
| "Buy 2 get 1 free"           | Promotions (script)             | discount-scripts.md           |
| "Refer a friend, get $10"    | Referral + Wallet               | referral.md + wallet.md       |
| "Double points this weekend" | Rules (with date conditions)    | events.md + conditions.md     |
| "Coupon code for 20% off"    | Promotions + Coupons            | promotions.md                 |
| "VIP tier discounts"         | Promotions (conditions on user) | promotions.md + conditions.md |

**Propose the full plan before creating anything.** Show the user what you'll create.

### Step 3: Build & Test Incrementally

- For **rules**: draft conditions → test with `project_test_conditions` → create rule
- For **promotions**: create as `draft` → test with `promotions_evaluate_cart` → activate
- For **coupons**: create coupon → test cart with coupon code → verify

### Step 4: Verify End-to-End

After building, **test the full pipeline** by ingesting a real event:

```json
// 1. Ingest a test event
events_ingest({
  "type": "purchase",
  "userId": "test-user-1",
  "payload": { "amount": 49.99, "orderId": "test-001" }
})

// 2. Verify the event was processed
events_list({ "type": "purchase", "processed": true })

// 3. Check wallet for expected credits
wallet_get_balance({ "userId": "test-user-1" })

// 4. Check workflow execution details
user_workflows_list({ "userId": "test-user-1" })
```

- For rules: `events_ingest` → rule match → action execution → `wallet_get_balance`
- For promotions: cart → conditions → script → discounts via `promotions_evaluate_cart`
- Summarize what was built and how pieces connect

## Recipes

### Points-for-Purchase (Earn 1 point per dollar)

**Domains:** Rules + Wallet + Events → See `references/wallet.md` and `references/events.md`

```json
// Step 1: Create the earning rule
project_add_rule({
  "name": "1 Point Per Dollar",
  "conditions": {
    "conditions": [
      { "leftValue": "{{ $('event').type }}", "operator": "equals", "rightValue": "purchase", "rightType": "string" }
    ],
    "combinator": "AND"
  },
  "actions": [
    {
      "type": "reward",
      "config": {
        "assetType": "points",
        "amount": "{{ $('event').payload.amount }}",
        "description": "Purchase reward: {{ $('event').payload.amount }} points"
      }
    }
  ],
  "resources": { "event": { "type": "purchase" } }
})

// Step 2: Test with a real event
events_ingest({
  "type": "purchase",
  "userId": "test-user-1",
  "payload": { "amount": 49.99, "orderId": "test-001" }
})

// Step 3: Verify points were awarded
wallet_get_balance({ "userId": "test-user-1" })
```

### Percentage Discount (10% off everything)

**Domains:** Promotions → See `references/promotions.md`

```json
promotions_create({
  "name": "10% Off Everything",
  "status": "draft",
  "conditions": { "conditions": [], "combinator": "AND" },
  "itemsDiscountComputation": {
    "script": "const items = $('cart').items;\nreturn items.map(item => ({ id: item.id, amount: item.price * 0.10 }));",
    "language": "javascript"
  }
})
```

### Coupon Code (20% off with code SAVE20)

**Domains:** Promotions + Coupons → See `references/promotions.md`

```json
// Step 1: Create promotion with requiresCoupon
promotions_create({
  "name": "20% Off with Code",
  "status": "active",
  "requiresCoupon": true,
  "conditions": { "conditions": [], "combinator": "AND" },
  "itemsDiscountComputation": {
    "script": "return $('cart').items.map(item => ({ id: item.id, amount: item.price * 0.20 }));",
    "language": "javascript"
  }
})

// Step 2: Create the coupon
promotions_create_coupon({ "promotionId": "promo_xxx", "code": "SAVE20", "maxUses": 1000 })
```

### Referral Program (Both get 500 points)

**Domains:** Referral + Rules + Wallet + Events → See `references/referral.md`

```json
// Step 1: Create referral code
referral_create_code({ "referrerId": "user-123" })

// Step 2: Rule to reward on completed referral
project_add_rule({
  "name": "Referral Reward",
  "conditions": {
    "conditions": [
      { "leftValue": "{{ $('event').type }}", "operator": "equals", "rightValue": "referral.completed", "rightType": "string" }
    ],
    "combinator": "AND"
  },
  "actions": [
    { "type": "reward", "config": { "assetType": "points", "amount": 500, "description": "Referral reward" } }
  ],
  "resources": { "event": { "type": "referral.completed" } }
})

// Step 3: Test — simulate referral completion
events_ingest({
  "type": "referral.completed",
  "userId": "user-123",
  "payload": { "referrerId": "user-123", "refereeId": "user-456" }
})

// Step 4: Verify
wallet_get_balance({ "userId": "user-123" })
```

## Common Mistakes

1. **Script returns empty array** — Field name mismatch. Check actual cart item fields. Always test with `promotions_evaluate_cart` first.
2. **Promotion not applying** — Check `notApplied` array in evaluate response for exact failure reasons.
3. **Rule not firing** — Event type in conditions must match what's being ingested. Use `events_list` to check.
4. **Forgot to activate** — Promotions created in `draft` won't apply. Update status to `active`.
5. **Coupon not working** — Promotion needs `requiresCoupon: true` AND coupon must be in `couponCodes` array.
6. **Stacking conflicts** — `exclusive` blocks everything else. Use `stackable` to combine. Use `exclusive_group` for best-of-group.
7. **Missing event resource** — Rules require `resources: { event: { type: "..." } }` to match events.

## Feedback

After building a loyalty program, report the outcome to improve this skill:

```json
skill_submit_feedback({
  "toolName": "promotions.create",
  "action": "created",
  "context": "Building a BOGO promotion",
  "outcome": "success",
  "details": "Worked on first try"
})
```
