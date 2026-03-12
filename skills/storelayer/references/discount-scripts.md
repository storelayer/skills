# Discount Script Reference

Discount scripts are JavaScript code that runs inside promotion evaluation. They compute per-item discounts for a cart.

## Context API

```javascript
$("cart"); // Full cart object
$("cart").items; // Array of cart items
$("cart").total; // Cart total (number)
$("user"); // Current user object (if userId provided)
$("couponCodes"); // Array of applied coupon codes
```

### Cart Item Shape

```typescript
interface CartItem {
  id: string; // Unique item identifier (required)
  price: number; // Item price (required)
  quantity: number; // Quantity (required)
  category?: string; // Category for filtering
  tags?: string[]; // Tags for filtering
  [key: string]: any; // Any custom fields
}
```

## Return Format

Scripts MUST return: `Array<{ id: string, amount: number }>`

- `id`: Cart item ID to discount
- `amount`: Discount amount (positive number, not exceeding item price)

Return `[]` (empty array) to apply no discounts.

## Patterns

### Percentage Off All Items

```javascript
const RATE = 0.1; // 10%
return $("cart").items.map((i) => ({ id: i.id, amount: i.price * RATE }));
```

### Fixed Amount (Distributed Proportionally)

```javascript
const DISCOUNT = 5; // $5 off
const total = $("cart").items.reduce((s, i) => s + i.price, 0);
return $("cart").items.map((i) => ({
  id: i.id,
  amount: (i.price / total) * DISCOUNT,
}));
```

### Category-Specific Discount

```javascript
return $("cart")
  .items.filter((i) => i.category === "electronics")
  .map((i) => ({ id: i.id, amount: i.price * 0.15 }));
```

### BOGO (Cheapest Item Free)

```javascript
const items = $("cart").items;
if (items.length < 2) return [];
const sorted = [...items].sort((a, b) => a.price - b.price);
return [{ id: sorted[0].id, amount: sorted[0].price }];
```

### Buy N Get 1 Free (Same Category)

```javascript
const shoes = $("cart").items.filter((i) => i.category === "shoes");
if (shoes.length < 3) return [];
const sorted = [...shoes].sort((a, b) => a.price - b.price);
return [{ id: sorted[0].id, amount: sorted[0].price }];
```

### Tiered Discount

```javascript
const total = $("cart").items.reduce((s, i) => s + i.price, 0);
const rate = total >= 200 ? 0.2 : total >= 100 ? 0.15 : total >= 50 ? 0.1 : 0;
if (rate === 0) return [];
return $("cart").items.map((i) => ({ id: i.id, amount: i.price * rate }));
```

### Max Discount Cap

```javascript
const MAX_DISCOUNT = 50; // $50 cap
const rate = 0.2;
let remaining = MAX_DISCOUNT;
return $("cart").items.map((i) => {
  const discount = Math.min(i.price * rate, remaining);
  remaining -= discount;
  return { id: i.id, amount: discount };
});
```

### Tag-Based Discount

```javascript
return $("cart")
  .items.filter((i) => i.tags && i.tags.includes("clearance"))
  .map((i) => ({ id: i.id, amount: i.price * 0.3 }));
```

### User-Conditional Discount

```javascript
const user = $("user");
if (!user || user.tier !== "vip") return [];
return $("cart").items.map((i) => ({ id: i.id, amount: i.price * 0.1 }));
```

## Testing Scripts

Always test with `promotions_evaluate_cart`:

```json
promotions_evaluate_cart({
  "cart": {
    "items": [
      { "id": "item-1", "price": 25.00, "quantity": 1, "category": "shoes" },
      { "id": "item-2", "price": 15.00, "quantity": 2, "category": "accessories" }
    ]
  }
})
```

Check the response:

- `applied[].discounts` — per-item discount amounts
- `summary.totalDiscount` — total discount
- `notApplied[].reason` — why promotions didn't apply

## Gotchas

- Scripts run in a sandboxed V8 environment — no `fetch`, `setTimeout`, or Node.js APIs
- `$('cart').items` field names must match your actual cart data (e.g., `category` vs `type`)
- Return `[]` for no discounts, not `null` or `undefined`
- Discount amount should not exceed item price
- Scripts must be synchronous — no `async`/`await`
