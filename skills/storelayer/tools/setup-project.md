# Setup Project Tool

Step-by-step checklist for setting up a new Storelayer loyalty project from scratch.

## Prerequisites

- Storelayer MCP server connected
- API key and project ID configured

## Checklist

### 1. Verify Connection

```json
project_get_config()
```

If this fails, check MCP server configuration:

- `STORE_LAYER_API_URL` — API endpoint
- `STORE_LAYER_API_KEY` — Valid API key
- `STORE_LAYER_PROJECT_ID` — Project ID

### 2. Register Test Users

```json
external_users_register({
  "userId": "test-user-1",
  "email": "test@example.com",
  "name": "Test User"
})
```

### 3. Define Your First Event Rule

Decide what events your system will send and create a matching rule:

```json
project_add_rule({
  "name": "Welcome Bonus",
  "conditions": {
    "conditions": [
      { "leftValue": "{{ event.type }}", "operator": "equals", "rightValue": "signup", "rightType": "string" }
    ],
    "combinator": "AND"
  },
  "actions": [
    {
      "type": "reward",
      "config": { "assetType": "points", "amount": 100, "description": "Welcome bonus!" }
    }
  ],
  "resources": { "event": { "type": "signup" } }
})
```

### 4. Test the Rule

```json
project_test_conditions({
  "conditions": {
    "conditions": [
      { "leftValue": "{{ event.type }}", "operator": "equals", "rightValue": "signup", "rightType": "string" }
    ],
    "combinator": "AND"
  },
  "context": { "event": { "type": "signup" } }
})
```

### 5. Verify Wallet

```json
wallet_get_balance({ "userId": "test-user-1" })
```

### 6. Create a Test Promotion (Optional)

```json
promotions_create({
  "name": "Launch Discount 10%",
  "status": "draft",
  "conditions": { "conditions": [], "combinator": "AND" },
  "itemsDiscountComputation": {
    "script": "return $('cart').items.map(i => ({ id: i.id, amount: i.price * 0.10 }));",
    "language": "javascript"
  }
})
```

### 7. Summary

After setup, confirm:

- [ ] Project config loads successfully
- [ ] Test user registered
- [ ] At least one event rule created and tested
- [ ] Wallet operations working
- [ ] (Optional) Promotion created and tested
