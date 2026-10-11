---
name: storelayer
description: Build and operate Storelayer loyalty programs through its HTTP API. Use for purchase rewards, points and stamps, wallet adjustments, promotions and coupons, referral programs, customer events, custom lookup tables, or diagnosing missing rewards. Read Markdown guides and the existing API reference before implementing or changing a program.
license: Apache-2.0
---

# Build with Storelayer

Storelayer provides the state and execution behind loyalty experiences: events trigger rules, wallets track assets, promotions compute discounts, and referrals track attribution. Your application owns customer authentication and the business event; Storelayer owns the configured program's execution and records.

Use the existing Storelayer API for application integrations. Preserve the user's application stack and requested scope.

## Read the current docs

Start at [the documentation index](https://docs.storelayer.io/llms.txt) and load only the pages needed for the task. Every documentation page has a Markdown URL: replace a trailing slash with `.md`. Resolve site-relative links against `https://docs.storelayer.io`.

This skill provides decision guidance. Markdown docs explain concepts and workflows. The [existing API reference](https://api.storelayer.io/docs) owns endpoint methods, paths, authentication, request bodies, response schemas, and examples. Its [OpenAPI document](https://api.storelayer.io/openapi.json) is the machine-readable contract. Read the relevant endpoint before writing an integration; keep endpoint specifications in the API reference rather than duplicating them here.

| Task | Start here |
| --- | --- |
| First connection and API contracts | [Quick start](https://docs.storelayer.io/getting-started/quick-start.md), [using the API reference](https://docs.storelayer.io/api/overview.md), [authentication](https://docs.storelayer.io/getting-started/authentication.md) |
| Purchase, signup, or milestone rewards | [Loyalty program cookbook](https://docs.storelayer.io/guides/loyalty-program.md), [conditions and resources](https://docs.storelayer.io/guides/conditions.md) |
| Points, stamps, credits, or corrections | [Wallet concepts](https://docs.storelayer.io/concepts/wallets.md), [wallet operations](https://docs.storelayer.io/api/wallets.md) |
| Discounts, coupons, stacking, or redemption | [Promotion cookbook](https://docs.storelayer.io/guides/creating-promotions.md), [promotion concepts](https://docs.storelayer.io/concepts/promotions.md) |
| A discount that needs code | [Discount scripts](https://docs.storelayer.io/guides/discount-scripts.md) |
| Referrer/referee attribution and rewards | [Referral programs](https://docs.storelayer.io/guides/referral-programs.md) |
| Customer identity and profile changes | [Customers](https://docs.storelayer.io/api/customers.md) |
| Tiers, exclusions, or configurable lookups | [Custom tables](https://docs.storelayer.io/guides/custom-storage.md) |
| Missing rewards or failed processing | [Debugging](https://docs.storelayer.io/guides/debugging.md), [workflows](https://docs.storelayer.io/guides/workflows.md) |
| Application integration | [JavaScript](https://docs.storelayer.io/sdks/javascript.md), [events](https://docs.storelayer.io/api/events.md), [HTTP integrations](https://docs.storelayer.io/guides/webhooks.md) |

If Markdown is unavailable, try the normal HTML page. If live docs are unavailable, use the current repository's routes, schemas, and installed types, state the limitation, and avoid inventing an API. If a guide disagrees with the API reference, use the current endpoint contract for request structure and report the discrepancy.

## Choose the program's shape

Start from the observable outcome: what happens to the customer's balance, basket, profile, or referral record? Resolve only missing details that change that outcome: event trigger, eligibility, amount and units, customer identity, timing, caps, and intended environment.

- **Repeatable rewards:** ingest a business event and configure a rule. Inspect existing rules first so a new rule does not award the same benefit twice.
- **Checkout discounts:** use a promotion. Prefer standard or buy/get methods when they express the offer; use a script for calculations that need it.
- **Manual adjustments:** use wallet operations. Earn adds an amount, spend subtracts an amount, and modify sets an absolute balance. Do not confuse these intents.
- **Referrals:** separate attribution from qualification and rewards. A valid or applied code does not prove that either party received points.
- **Data-driven eligibility:** reuse a resource or custom table for maintained lookup data. Do not encode a changing tier or eligibility catalog in a long expression.

For a concrete request, implement the relevant shape. Brainstorming is useful when requested, not a prerequisite to execution. Carry out already-authorized work without a redundant confirmation loop. Ask only when an unresolved decision affects customer value, identity, destructive scope, or whether a live benefit should be enabled.

## Implement through the API reference

Open the [API reference](https://api.storelayer.io/docs) and choose the section matching the task: External Users for profiles, Wallet for balances and transactions, Events and Rules for rewards, Promotions for checkout, Referrals for attribution, Storage for lookup tables, and Workflows for execution history.

For programmatic inspection, fetch [OpenAPI](https://api.storelayer.io/openapi.json) and select the relevant paths and referenced schemas. Keep reads targeted rather than loading the entire specification into context.

Before constructing a request, inspect its method, path/query parameters, authentication requirements, body, and responses. Follow schema references. Use the API reference's language example or the application's existing client pattern. Do not invent endpoints or impose a generic request envelope on unrelated endpoints.

Keep environment, project identity, and credentials consistent. Credentials belong in a server-side environment or secret manager, never in generated source, browser bundles, or transcripts. Use only the authentication method documented for the selected endpoint.

Read the HTTP status and documented response, including the business outcome. A request can succeed while a basket qualifies for no discount. Distinguish validation failures, access failures, network uncertainty, and a valid negative business result. Correct the cause before retrying.

## Preserve the business invariants

**Identity and scope.** Reuse the application's stable external user ID across events, wallets, referrals, and checkout. Verify the intended project and affected customer. A project API key must stay on the backend, which authorizes customer access itself.

**Units.** Cart prices and discounts use integer minor currency units; USD 25.00 is 2500. Wallet assets have their own units. Arbitrary event payloads follow the application's resource schema, so establish whether `amount` means cents, dollars, points, or something else before building a threshold.

**Expressions and resources.** Use `{{ $('resource').field }}` with the actual resolved data shape. Inspect existing resources and configure the bindings the rule requires. Follow the selected API contract for creation behavior; do not assume missing resources are created automatically. Read the current conditions schema rather than assuming nested groups or operator aliases work everywhere.

**Preview versus commitment.** Set `dryRun: true` explicitly for promotion previews. Draft previews need the supported inactive-inclusion option. With `dryRun: false`, cart evaluation can record usage and spend assets; it requires a nonempty `transactionId` and `cart.userId`. Use the API reference to distinguish preview behavior from recorded checkout.

**Script contracts.** Inside discount scripts, normalized cart items use `itemId` and `price` for calculations, not input-cart `id`, `unitPrice`, or `quantity`. Use each supplied normalized price without multiplying quantity again. Return `{ items: [{ id, amount }], suggestion? }`; a bare array or `NaN` can produce `computation_no_discount`. Read the script guide before implementing redemptions.

**Asynchronous completion.** Event acceptance is not reward completion. Use the returned event identity to locate its execution through the documented workflow endpoints, wait with a bounded strategy, inspect outcomes, then read the affected state. A condition test checks matching; it does not execute or verify actions.

**Uncertain writes.** Use the selected endpoint's documented idempotency guarantees; do not infer them from another endpoint or a business tracking field. After a timeout, inspect ledger, workflow, or usage state before retrying. Re-ingesting an event or repeating a wallet award can duplicate effects. Use a bounded wait and report unresolved state instead of repeatedly issuing mutations.

## Verify the customer's outcome

Choose checks that can distinguish the intended behavior from a plausible bug:

- Reward thresholds: one qualifying event, one below the boundary, and the exact boundary. Check wallet deltas and ledger entries after processing.
- Promotions: qualifying and non-qualifying carts, coupon requirements, quantities, rounding, and interaction with existing campaigns. Inspect per-item amounts and rejection reasons.
- Referrals: attribution, qualifying event, and each intended recipient's ledger. Check the configured policy for repeated or disallowed applications.
- Lookup-backed rules: a matching row and a missing row, with explicit expected behavior for both.

Use a test project/customer for mutating examples. Read before updating existing resources and preserve unrelated configuration. Save a small redacted request/response artifact with relevant IDs and expected outcomes. Report what changed, what was verified, and what remains uncertain; do not claim a dry run proved a production side effect.
