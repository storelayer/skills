# Storelayer Architecture

## Overview

Storelayer is a multi-tenant loyalty & commerce platform built on Cloudflare Workers with Durable Objects. Each project (tenant) gets isolated state via DO instances keyed by `${projectId}` or `${projectId}_${userId}`.

## Runtime Stack

- **Edge Runtime:** Cloudflare Workers (V8 isolates)
- **State:** Durable Objects with SQLite storage
- **Database:** D1 (SQLite) for relational data (users, projects, memberships)
- **Cache:** KV namespace (shared)
- **Queue:** Cloudflare Queues for async event processing
- **Storage:** R2 for assets and tenant worker bundles
- **Multi-tenant Isolation:** Workers for Platforms (per-project worker dispatch)
- **Functional Core:** Effect-TS for all async business logic

## Request Flow

```
Client Request
  ↓
Cloudflare Workers (Hono 4.7 + OpenAPI)
  ↓
Middleware Stack:
  Logger → CORS → Auth (API Key or JWT) → Project Membership → Dev Gate
  ↓
Route Handler (Effect.gen)
  ↓
DO Client Factory → Durable Object RPC (Effect-based)
  ↓
DO Storage (SQLite + KV)
```

## Authentication

Two auth paths:

1. **JWT** (Dashboard users): Bearer token → verifyJWT → user context
2. **API Key** (External integrations): X-API-Key header → KV lookup → projectId

## Durable Object Architecture

Every domain (wallet, promotions, referral, etc.) is a Durable Object package:

```
packages/[domain]/src/
├── index.ts              # Public exports
├── durable-object/       # DO class (createDurableEffect)
├── business/             # Business logic, types, services
└── client/               # RPC client factory
```

DO instances are created via `createDurableEffect()` from `@storelayer/durable-core`:

```typescript
const { DurableObject, Client } = createDurableEffect({
  name: "WalletStorage",
  methods: {
    earn: {
      execute: (input) =>
        Effect.gen(function* () {
          const storage = yield* StorageAdapter;
          // business logic
        }),
    },
  },
});
```

**DO ID Scoping:**

- User-scoped: `${projectId}_${userId}` (wallet, loyalty-events)
- Project-scoped: `${projectId}` (promotions, external-users, project config)

## WebSocket Real-Time Updates

Durable Objects support WebSocket Hibernation API for real-time client communication. The workflow execution DO uses this for live workflow monitoring:

```
Dashboard (WebSocket client)
  ↓
API: GET /projects/:projectId/workflows/ws?token=JWT&workflowId=...
  ↓
Middleware: auth accepts ?token= query param for WebSocket upgrade requests
  ↓
Workflow Execution DO (WebSocket Hibernation API)
  ├── acceptWebSocket(server, tags)     — tag: "workflow:{id}" + "all"
  ├── webSocketMessage / Close / Error  — lifecycle handlers
  └── broadcast after mutations         — step:added, workflow:status, etc.
```

**Server → Client events:** `snapshot`, `workflow:created`, `workflow:status`, `step:added`, `step:updated`, `rules:added`, `action:added`, `action:updated`, `pong`

**Client → Server:** `ping`, `subscribe` (with optional `workflowId` filter)

Connections without a `workflowId` receive events for all workflows in the project (used by the list page). Connections with a `workflowId` receive only events for that workflow.

## Expression Engine (`@storelayer/expressions`)

A dedicated package for safe expression evaluation using AST parsing (jsep). No `eval()` or `new Function()`.

**Enforced syntax:** All expressions MUST be wrapped in `{{ }}`. Bare strings like `event.type` or `$('event').type` are returned as-is (not evaluated).

**Scope available inside `{{ }}`:**

- `$('resourceKey')` — access context resources (the only way)
- `$now` — current ISO timestamp, `$today` — current date (YYYY-MM-DD)
- Standard globals: `Math`, `JSON`, `String`, `Number`, `Boolean`, `Array`, `Object`, `Date`
- Utility functions: `parseInt`, `parseFloat`, `isNaN`, `isFinite`
- Supports: member access, method calls, binary/logical/unary/ternary operators, array expressions, arrow functions (`item => item.name`)

## Response Format

```typescript
// Success
{ success: true, data: T }

// Error
{ success: false, error: { code: number | string, message: string } }
```

## Domain Map

| Domain         | DO Scope       | Key Operations                                                     |
| -------------- | -------------- | ------------------------------------------------------------------ |
| Wallet         | user-scoped    | earn, spend, balance, transactions                                 |
| Promotions     | project-scoped | create, evaluate cart, coupons, stacking                           |
| External Users | project-scoped | register, lookup, list, update                                     |
| Events         | user-scoped    | track, list, stats                                                 |
| Rules/Project  | project-scoped | add/update/remove rules, config                                    |
| Referral       | project-scoped | create codes, apply, leaderboard                                   |
| Workflows      | project-scoped | multi-step automation, WebSocket live updates, R2 context archival |
| Catalog        | project-scoped | products, categories                                               |
| Stores         | project-scoped | store locations                                                    |
| Support        | project-scoped | support tickets                                                    |
| Surveys        | project-scoped | customer surveys                                                   |

## Workers for Platforms (Tenant Workers)

Each project can have a dedicated tenant worker for isolated compute:

```
API → DISPATCHER.get(projectId) → Tenant Worker
                                   ├── POST /evaluate-promos
                                   ├── POST /process-event
                                   └── POST /promotions-rpc
```

Tenant workers are rate-limited by plan:

- Free: 10ms CPU, 50 subrequests
- Starter: 30ms CPU, 100 subrequests
- Pro: 50ms CPU, 500 subrequests
- Enterprise: 200ms CPU, 1000 subrequests

## MCP Integration

The platform exposes a Resource Registry that powers the MCP server:

```
MCP Client (Claude) → MCP Server → API /internal-tools → Resource Registry → DO Clients
```

Tools are registered per domain (e.g., `wallet.earn`, `promotions.create`) and exposed as MCP tools with auto-generated schemas.

## Infrastructure Bindings

| Binding      | Type         | Name/ID               |
| ------------ | ------------ | --------------------- |
| DB           | D1           | storelayer-db         |
| KV           | KV Namespace | shared cache          |
| EVENTS_QUEUE | Queue        | storelayer-events     |
| BUNDLES      | R2           | storelayer-bundles    |
| ASSETS       | R2           | storelayer-assets     |
| DISPATCHER   | WfP          | storelayer-production |
