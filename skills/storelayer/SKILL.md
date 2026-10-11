---
name: storelayer
license: Apache-2.0
description: >
  Build loyalty and commerce features on Storelayer: event-driven reward rules,
  multi-asset wallets (points, stamps, credits), basket promotions, coupons and
  discount scripts, points redemption at checkout, referral programs, custom
  lookup tables, and HTTP integrations. Use when designing, building, integrating,
  testing, or debugging any Storelayer behavior, or when a product needs loyalty,
  rewards, or discount logic. Read the live docs for current contracts and recipes.
---

# Build with Storelayer

Storelayer is a project-scoped loyalty engine. Your backend sends **events**
(`purchase`, `user_registered`, …) and **carts**; Storelayer runs **rules** that move
**wallet** balances, computes **promotion** discounts per cart line, and tracks
**referrals**. Customers are external user IDs your application owns. Your code owns
the business workflow and the source of truth for orders and prices; Storelayer owns
loyalty state and the decision logic you configure in it.

## Read the live docs

**The live docs are the source of truth. Read them as part of the task.** This skill
gives direction and the traps that cost the most time; the docs carry verified
request bodies, recipes, and limits.

- Start with the [documentation index](https://docs.storelayer.io/llms.txt). Fetch only
  the pages the task needs.
- Every page has a Markdown version: append `.md`, e.g.
  [conditions and resources](https://docs.storelayer.io/guides/conditions.md).
- For exact request and response schemas, select paths from the
  [OpenAPI document](https://api.storelayer.io/openapi.json) with `jq` instead of loading
  it whole (it is large). The [API reference](https://api.storelayer.io/docs) is the
  browsable version.
- If a guide and OpenAPI disagree, trust the guide for behavior (it was verified against
  the engine) and OpenAPI for field names, then mention the discrepancy.
- If live access fails, say so and avoid inventing version-dependent details.

| Task | Start here; follow the relevant details |
| --- | --- |
| First calls, base URL, envelope, errors | [Quick start](https://docs.storelayer.io/getting-started/quick-start.md), [API overview](https://docs.storelayer.io/api/overview.md) |
| Keys, scoping, MCP setup | [Authentication](https://docs.storelayer.io/getting-started/authentication.md), [Agents](https://docs.storelayer.io/getting-started/agents.md) |
| Reward purchases, signups, visits | [Loyalty program recipe](https://docs.storelayer.io/guides/loyalty-program.md), [Loyalty events](https://docs.storelayer.io/concepts/loyalty-events.md), [Sending events](https://docs.storelayer.io/api/events.md) |
| Expressions, operators, resources | [Conditions and resources](https://docs.storelayer.io/guides/conditions.md) |
| Award, spend, set balances | [Wallets](https://docs.storelayer.io/concepts/wallets.md), [Wallet API](https://docs.storelayer.io/api/wallets.md) |
| Basket discounts and coupons | [Promotions](https://docs.storelayer.io/concepts/promotions.md), [Creating promotions](https://docs.storelayer.io/guides/creating-promotions.md), [Checkout integration](https://docs.storelayer.io/api/promotions.md) |
| Custom discount math, points redemption | [Discount scripts](https://docs.storelayer.io/guides/discount-scripts.md) |
| Referral programs | [Referrals](https://docs.storelayer.io/concepts/referrals.md), [Referral recipe](https://docs.storelayer.io/guides/referral-programs.md), [Referral API](https://docs.storelayer.io/api/referrals.md) |
| Customer profiles | [Customers](https://docs.storelayer.io/concepts/customers.md), [Customer API](https://docs.storelayer.io/api/customers.md) |
| Tier tables, eligible SKUs, blocklists | [Custom tables](https://docs.storelayer.io/guides/custom-storage.md) |
| Products, stores, location rules | [Catalog](https://docs.storelayer.io/api/catalog.md), [Stores](https://docs.storelayer.io/api/stores.md) |
| Call external services from rules | [HTTP integrations](https://docs.storelayer.io/guides/webhooks.md) |
| A reward or discount did not happen | [Debugging](https://docs.storelayer.io/guides/debugging.md), [Workflows](https://docs.storelayer.io/guides/workflows.md) |
| Project config, cloning, roles | [Projects](https://docs.storelayer.io/concepts/projects.md) |
| Server integration code | [REST](https://docs.storelayer.io/sdks/rest.md), [JavaScript](https://docs.storelayer.io/sdks/javascript.md) |

## Find the useful shape

Start from what the customer sees (a balance, a discount line, a referral bonus) and work
back to the smallest primitive. Keep order truth, prices, refunds policy, and
deduplication in the user's backend; put the loyalty decision in Storelayer.

- **Recurring reward → rule.** An event resource binds the rule to an event type,
  conditions gate it, actions run: `reward`, `redemption`, `modify`, `emit_event`,
  `update_user`, `custom_table`, `integration`, referral actions. Amounts can be
  expressions: `"{{ Math.floor($('event').payload.amount / 100) }}"` is points per dollar.
- **State-dependent reward → declare the state.** Tiers, balances, history, or table
  rows reach a rule only through resources the rule declares. For "10 stamps → free
  coffee", resources are resolved before actions run, so chain a second event with
  `emit_event` and check the balance there. Explore the stamp-card and tier patterns in
  the [loyalty program recipe](https://docs.storelayer.io/guides/loyalty-program.md).
- **Configuration that changes → custom table.** Tier thresholds or eligible SKUs in a
  table bound as a `custom_table` resource beat hard-coding values into many rules.
- **One-off balance change → wallet API.** `earn` adds, `spend` consumes
  (first-expiring-first-out, all-or-nothing), `modify` sets an absolute target. Pick by
  the business wording: "give 100" vs "correct to 100" are different operations.
- **Basket discount → promotion.** Prefer `standard` (percentage/fixed on items, order,
  or shipping, `each` vs `across` allocation) and `buyget`; use `custom_script` only for
  math they cannot express. Coupons, validity windows, usage caps, per-user limits,
  budgets, and `stackingMode` constrain it.
- **Pay with points → promotion + wallet resource.** The cart carries
  `redemptions: [{ type, amount }]`, a script converts them to item discounts and reports
  the `redemption` it used, and a recorded checkout spends the points. Follow the worked
  example in [discount scripts](https://docs.storelayer.io/guides/discount-scripts.md).
- **Referral → attribution plus a reward rule.** Codes, validation, and apply record who
  referred whom; the reward is a rule on the qualifying event (for example the referee's
  first purchase) that rewards both sides. Validation is not a reward.

For an open-ended request, propose the few shapes that fit and recommend one. For a
concrete request, pick the shape and build.

## Rules and expressions

- **Expressions read resources only through `$('key')`**, and only when the whole string
  is one `{{ … }}`. `{{ event.userId }}` is `undefined`; `"Order {{ … }}"` stays literal.
  JS-like operators, `??`, ternaries, `Math`, and arrow functions work; template literals
  and object literals do not. Errors evaluate to `undefined`, not an exception.
- **Event data lives under `payload`.** The rule context is
  `{ event: { type, userId, payload } }`, so use `$('event').payload.amount`, never
  `$('event').amount`.
- **Resources must exist and be declared.** Over REST, nothing is auto-created: register
  the resource (`POST /projects/{projectId}/resources`), then list it in the rule's
  `resources`. A rule needs an `event` resource; an undeclared resource is silently
  `undefined`. (The MCP `add_rule` tool can infer and create resources; REST cannot.)
- **A rule without an event-type binding runs for every event.**
- **Conditions are one flat group** (`combinator` AND/OR, no nesting). Numeric operators
  match only numbers: send `rightValue` as a JSON number or set `rightType: "number"`.
  When `rightValue` is itself an expression, omit `rightType`: live processing treats it
  as `NaN` even though `/rules/test` passes.
- **`/rules/test` resolves nothing.** Pass the context exactly as the rule will see it.
  Use `POST /projects/{projectId}/resources/resolve` to see what resources really return.
  `/rules/execute` and `/rules/execute-actions` perform real actions.

## Money, carts, and checkout

- **Money is integer minor units everywhere** (`unitPrice: 2500` is $25.00). Write
  thresholds as cents and say so: "$50 → 5000".
- A cart needs `items[]` (`id`, `quantity`, integer `unitPrice`) and `currencyCode`;
  fields are camelCase. The engine recomputes `subtotal`. **The catalog is not read during
  evaluation**, so any attribute a condition uses (category, brand) must be on the cart.
- **Preview with `dryRun: true`** (nothing consumed; `includeInactive` /
  `includeInactiveIds` let you preview drafts). **Record with `dryRun: false`**, which
  needs `cart.userId` and `transactionId`. Retrying the same `transactionId` with the same
  body is safe and returns `duplicate: true`; a different body gets 409.
- Inspect `notApplied` reasons (`conditions_not_met`, `coupon_required`,
  `excluded_by_stacking`, `computation_no_discount`, …) before changing a promotion.
- **Discount scripts see normalised per-unit items** with `itemId` and `price` (not
  `id`/`unitPrice`/`quantity`) and must return `{ items: [{ id, amount }] }`; a bare
  array or `NaN` amounts yield `computation_no_discount`. **Write scripts in plain
  JavaScript**: TypeScript is not compiled at evaluation and fails at checkout.
- Cancelling a usage releases caps and budget but does **not** refund redeemed points.

## Events, wallets, and delivery

- **Accepted is not applied.** `POST /ingest/events` returns `201 { id: "evt_…" }` before
  rules run. The workflow ID equals the event ID; poll
  `GET /projects/{projectId}/workflows/{id}` until it exists, then read `rules[]` and
  `actions[]`, then the wallet.
- Ingest keeps only `type`, `userId`, `payload`; other top-level fields are silently
  dropped.
- **Neither ingest nor wallet writes deduplicate.** Each call creates a new event or
  transaction; `referenceId` is not checked. After a timeout, look up the workflow or
  transactions before retrying, and deduplicate orders in the user's backend.
- A failing wallet action (for example `Insufficient balance`) fails the workflow, but
  actions that already ran stay applied.
- Wallet REST responses use `data.assets.<type>.balance`. Inside rules and promotions,
  `$('wallet').points.balance` and `$('wallet').balances.points` both work.

## Access and tools

- Base URL `https://api.storelayer.io`. Send `Authorization: Bearer <key>`; project keys
  look like `sk_…` and are bound to one project (another `projectId` → 403). `X-API-Key`
  is accepted only on ingest. Keep keys server-side and authorize the shopper in the
  backend: a `userId` is not a credential.
- Responses use `{ success, data }` / `{ success: false, error: { code, message } }`;
  schema validation failures return an issue array instead.
- Table DDL and raw SQL need the `storage:admin` scope, which API keys do not have today;
  use the dashboard.
- Live work needs a key in `STORE_LAYER_API_KEY`. The MCP server
  (`npx -y @storelayer/mcp-server`, env `STORE_LAYER_API_KEY`, optional
  `STORE_LAYER_API_URL`) exposes the same operations as tools; the project comes from the
  key.

## Work the change and verify it

1. **Pin the outcome in testable terms**: "a purchase of at least $50 (5000) earns 100
   points, once per order; refunds reverse it". Ask only for what is missing.
2. **Inspect first**: project config, existing rules, resources, promotions, and the test
   customer's balance. Prefer extending what exists over adding a duplicate.
3. **Show the plan** (resources, rule or promotion body, limits) and confirm before
   creating or activating. Use a test project or test customer for anything that moves
   value.
4. **Test conditions at the boundary** (4999 / 5000 / 5001) and preview carts with
   `dryRun: true`, including one non-qualifying case.
5. **Run once for real and read the state**: the workflow's rule and action results, the
   ledger entry, the promotion usage. Report which of these you actually verified
   (accepted, matched, action succeeded, balance changed) and what remains unverified.

When something fails, find the first divergence: event accepted → rule bound to the type
→ resources resolved → each condition's resolved values → action result → persisted
state. Do not re-send an event "to see if it works"; it may award twice.
