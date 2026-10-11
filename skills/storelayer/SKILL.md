---
name: storelayer
license: Apache-2.0
description: >
  Build loyalty programs on Storelayer: purchase-reward rules, wallets (points,
  stamps, credits), basket promotions and coupons, discount scripts, referrals,
  custom lookup tables, and event/workflow debugging. Use when creating,
  changing, integrating, testing, or debugging any Storelayer behavior, or when
  designing a loyalty or discount feature for an application. Read the live
  docs and API reference for current concepts and contracts.
---

# Build with Storelayer

Storelayer holds the state and execution behind customer loyalty. Your application
sends **events** and **carts**; Storelayer evaluates **rules**, records **wallet**
movements, computes **promotion** discounts, and tracks **referrals**. A project owns
its configuration and customer data; customers are external user IDs your application
defines. Your code owns the business workflow; Storelayer owns the loyalty state.

## Read the live docs

**The live docs are the source of truth. Read them as part of the task.** This skill
gives direction and the traps that cost the most time; the docs carry concepts and
worked workflows, and the API reference carries endpoint contracts.

- Start with the [documentation index](https://docs.storelayer.io/llms.txt). Fetch
  only the pages the task needs.
- Every docs page has a Markdown version: append `.md` to the path, e.g.
  [wallet concepts](https://docs.storelayer.io/concepts/wallets.md). Convert
  extensionless links to `.md` when useful.
- Endpoint paths, auth, request bodies, and responses live in the
  [API reference](https://api.storelayer.io/docs) and its
  [OpenAPI document](https://api.storelayer.io/openapi.json). Select only the paths
  you need rather than loading the whole spec. Do not copy payload shapes from memory
  or from this skill.
- If a guide and the API reference disagree, follow the API reference for request
  structure and report the discrepancy.
- If live access is unavailable, say so, rely on installed API types or user-provided
  docs, and avoid inventing version-dependent details.

| Task | Start here |
| --- | --- |
| Orient, first read-only call | [Introduction](https://docs.storelayer.io/getting-started/introduction.md), [Quick start](https://docs.storelayer.io/getting-started/quick-start.md) |
| Credentials, project access | [Authentication](https://docs.storelayer.io/getting-started/authentication.md), [Projects](https://docs.storelayer.io/concepts/projects.md) |
| Find the right endpoint | [Using the API reference](https://docs.storelayer.io/api/overview.md) |
| Customer identity and profiles | [Customers](https://docs.storelayer.io/concepts/customers.md), [Customer data](https://docs.storelayer.io/api/customers.md) |
| Award, spend, or correct balances | [Wallets](https://docs.storelayer.io/concepts/wallets.md), [Working with wallets](https://docs.storelayer.io/api/wallets.md) |
| Reward purchases or signups | [Loyalty events](https://docs.storelayer.io/concepts/loyalty-events.md), [Loyalty program guide](https://docs.storelayer.io/guides/loyalty-program.md), [Sending events](https://docs.storelayer.io/api/events.md) |
| Rule conditions, resources, expressions | [Conditions and resources](https://docs.storelayer.io/guides/conditions.md) |
| Basket discounts, coupons, limits | [Promotions](https://docs.storelayer.io/concepts/promotions.md), [Creating promotions](https://docs.storelayer.io/guides/creating-promotions.md), [Checkout integration](https://docs.storelayer.io/api/promotions.md) |
| Custom discount logic | [Discount scripts](https://docs.storelayer.io/guides/discount-scripts.md) |
| Referral programs | [Referrals](https://docs.storelayer.io/concepts/referrals.md), [Referral programs guide](https://docs.storelayer.io/guides/referral-programs.md), [Referral integration](https://docs.storelayer.io/api/referrals.md) |
| Tiers, catalogs, blocklists | [Custom tables](https://docs.storelayer.io/guides/custom-storage.md), [Catalog data](https://docs.storelayer.io/api/catalog.md) |
| Store-specific behavior | [Store and facility data](https://docs.storelayer.io/api/stores.md) |
| Call external services from rules | [HTTP integrations](https://docs.storelayer.io/guides/webhooks.md) |
| A reward or discount did not happen | [Debugging rules](https://docs.storelayer.io/guides/debugging.md), [Workflows](https://docs.storelayer.io/guides/workflows.md) |
| Server integration code | [REST](https://docs.storelayer.io/sdks/rest.md), [JavaScript](https://docs.storelayer.io/sdks/javascript.md) |

## Pick the primitive

Start from the outcome the customer sees, then choose the smallest primitive:

- **Rule** (event → conditions → action): recurring rewards such as points for a
  purchase, a welcome bonus, or a tier multiplier.
- **Wallet operation**: a one-off award, spend, or correction. Award, spend, and
  set-to-absolute-balance are different operations; match the business request.
- **Promotion**: a discount on a basket. Prefer a `standard` or `buyget` application
  method; use `custom_script` only when they cannot express the offer.
- **Referral**: attribution (code, validate, apply) is separate from the reward, which
  follows a qualifying business event.
- **Custom table**: maintained lookup data (tier thresholds, eligible SKUs) that rules
  and promotions bind as a resource.

Preserve the user's stack and scope. Reach for an existing rule or promotion before
creating a new one that duplicates it.

## Work the conversation

1. **Pin the outcome in concrete terms**: "A purchase of at least $50 earns 100 points,
   once per order." Ask only what is missing: project, trigger event, thresholds and
   units, reward asset type, duplicate and refund policy.
2. **Inspect before changing**: read project config, existing rules, resources, and the
   customer's current state. Use a test project and test customer for anything that
   changes balances or consumes usage.
3. **Show the plan** (trigger, conditions, action, limits) and get confirmation before
   creating or activating anything.
4. **Create in draft or test form**, then verify against real state (see below).

## Traps that cost the most time

Confirm each against the current docs and API reference; these are reminders, not
contracts.

- **Money is integer minor units** (cents). `unitPrice: 2500` is $25.00; `25` is
  $0.25. This holds for cart prices, shipping and tax totals, fixed discounts, and
  discount-script amounts. State the unit when you write a threshold.
- **Cart and event fields are camelCase** (`unitPrice`, `productId`, `currencyCode`,
  `userId`). Ingestion rejects unknown fields rather than stripping them.
- **Expressions read named resources**: `{{ $('resource').field }}`. An event's
  top-level `type` is different from fields inside `payload`; use the payload path your
  event actually has. Do not use bare dot-notation such as `cart.total` as a
  `leftValue`.
- **Do not assume resources are auto-created.** Inspect and bind the resources a rule
  or promotion needs, and explicitly configure custom-table, HTTP, and database
  resources. A missing resource is different from a false condition.
- **Discount scripts use a different item shape.** The incoming cart has `id`,
  `unitPrice`, `quantity`; inside the script, normalized items expose `itemId` and
  `price` (already the line total). Read `price`, return `{ items: [{ id, amount }] }`
  with real item IDs, and never a bare array or `NaN`; the failure shows as
  `computation_no_discount`.
- **Preview is not checkout.** `dryRun: true` previews and consumes nothing.
  `dryRun: false` records usage and can spend coupons, budget, and wallet assets; it
  needs `cart.userId` and a nonempty `transactionId`.
- **Accepted is not applied.** Event ingestion queues work. Follow the workflow, then
  read the wallet or ledger. The same event ingested twice can award twice, so
  deduplicate at your event boundary; an order ID in the payload does not do it.
- **A passing condition test proves one comparison**, not that the action will succeed.
- **A customer ID is not a credential.** Keep project keys on the backend and
  authorize the customer in your backend before forwarding a request.

## Verify the outcome

Do not stop at a 200 response. Record the starting state, run one qualifying example,
wait for processing, then inspect the ledger, usage record, or referral record. Also run
a non-qualifying example and the exact boundary (e.g. 4999, 5000, 5001). Report which
of these you actually verified: accepted, rule matched, action succeeded, balance
changed. After an uncertain write, inspect existing state before retrying.

## Credentials and tools

Live operations need a project API key, normally in `STORE_LAYER_API_KEY`. Without one,
help design the integration and say what remains unverified. Never put keys in browser
code, repositories, or transcripts.

When Storelayer MCP tools are connected, they are a convenient way to perform the same
operations. The docs and API reference still define the behavior.

