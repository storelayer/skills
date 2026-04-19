# MCP Tools Reference

> **⚠️ Canonical source:** the authoritative tool table is in `SKILL.md` → *Available Tool Domains (84 tools)*. This file may include removed entries or miss newer ones.

Complete list of tools available via the Storelayer MCP server.

## Connection

```json
{
  "mcpServers": {
    "storelayer": {
      "command": "npx",
      "args": ["@storelayer/mcp-server"],
      "env": {
        "STORE_LAYER_API_URL": "https://api.storelayer.io",
        "STORE_LAYER_API_KEY": "your-api-key",
        "STORE_LAYER_PROJECT_ID": "your-project-id"
      }
    }
  }
}
```

## Promotions

| Tool                             | Type  | Description                                          |
| -------------------------------- | ----- | ---------------------------------------------------- |
| `promotions_get`                 | read  | Get a single promotion by ID                         |
| `promotions_list`                | read  | List promotions with filters                         |
| `promotions_get_active`          | read  | Get all active promotions                            |
| `promotions_get_coupon`          | read  | Get a single coupon by ID                            |
| `promotions_lookup_coupon`       | read  | Look up coupon by code string                        |
| `promotions_list_coupons`        | read  | List coupons for a promotion                         |
| `promotions_list_usage`          | read  | List usage/redemption records                        |
| `promotions_get_stats`           | read  | Stats for a specific promotion                       |
| `promotions_get_aggregate_stats` | read  | Global promotion stats                               |
| `promotions_create`              | write | Create a promotion (supports simple-mode conditions) |
| `promotions_update`              | write | Update a promotion (supports simple-mode conditions) |
| `promotions_remove`              | write | Delete a promotion                                   |
| `promotions_duplicate`           | write | Clone a promotion as draft                           |
| `promotions_create_coupon`       | write | Create a coupon                                      |
| `promotions_bulk_create_coupons` | write | Bulk create 1-1000 coupons                           |
| `promotions_update_coupon`       | write | Update an existing coupon                            |
| `promotions_remove_coupon`       | write | Delete a coupon                                      |
| `promotions_evaluate_cart`       | read  | Evaluate cart against promotions                     |

## Wallet (all require `userId`)

| Tool                       | Type  | Description                     |
| -------------------------- | ----- | ------------------------------- |
| `wallet_get_balance`       | read  | Get balance for all asset types |
| `wallet_list_transactions` | read  | Transaction history             |
| `wallet_credit`            | write | Add assets (points, tokens)     |
| `wallet_debit`             | write | Spend assets (FEFO order)       |
| `wallet_adjust`            | write | Set absolute balance            |

## Rules / Project

| Tool                         | Type  | Description                                                  |
| ---------------------------- | ----- | ------------------------------------------------------------ |
| `project_get_config`         | read  | Project configuration                                        |
| `project_list_rules`         | read  | List loyalty rules                                           |
| `project_get_rule`           | read  | Get a single rule                                            |
| `project_list_integrations`  | read  | List integrations                                            |
| `project_list_resources`     | read  | List resource definitions                                    |
| `project_get_summary`        | read  | Aggregate project overview (config, users, events, rules)    |
| `project_get_integration`    | read  | Get a single integration by ID                               |
| `project_add_rule`           | write | Create a rule                                                |
| `project_update_rule`        | write | Update a rule                                                |
| `project_remove_rule`        | write | Delete a rule                                                |
| `project_test_conditions`    | write | Test conditions against sample data                          |
| `project_test_rule`          | read  | Test a saved rule by ID against sample data                  |
| `project_update_config`      | write | Update project config (currency, timezone, settings)         |
| `project_add_integration`    | write | Create an integration (http, telegram, slack, postgres, ses) |
| `project_update_integration` | write | Update an existing integration                               |
| `project_remove_integration` | write | Delete an integration                                        |

## Events

| Tool               | Type  | Description                                    |
| ------------------ | ----- | ---------------------------------------------- |
| `events_ingest`    | write | Ingest event (triggers rules & wallet actions) |
| `events_get`       | read  | Get event by ID                                |
| `events_list`      | read  | List events with filters                       |
| `events_get_stats` | read  | Event stats                                    |

## Referral

| Tool                            | Type  | Description                                     |
| ------------------------------- | ----- | ----------------------------------------------- |
| `referral_get_config`           | read  | Referral program config                         |
| `referral_list_codes`           | read  | List referral codes                             |
| `referral_get_code_by_referrer` | read  | Look up code by referrer ID                     |
| `referral_validate_code`        | read  | Check if code is valid                          |
| `referral_list_referrals`       | read  | List referral records                           |
| `referral_list_events`          | read  | List referral audit events                      |
| `referral_get_stats`            | read  | Aggregate stats                                 |
| `referral_get_leaderboard`      | read  | Top referrers                                   |
| `referral_create_code`          | write | Create a referral code                          |
| `referral_apply_code`           | write | Apply code for referee                          |
| `referral_deactivate_code`      | write | Deactivate a code                               |
| `referral_update_config`        | write | Update referral config (format, length, expiry) |

## External Users

| Tool                         | Type  | Description                      |
| ---------------------------- | ----- | -------------------------------- |
| `external_users_get_user`    | read  | Get user by ID                   |
| `external_users_list_users`  | read  | List users                       |
| `external_users_lookup_user` | read  | Smart lookup (ID then email)     |
| `external_users_search`      | read  | Fuzzy search by name/email/phone |
| `external_users_register`    | write | Register a user                  |
| `external_users_update`      | write | Update a user                    |
| `external_users_remove`      | write | Remove a user                    |

## Resources

| Tool                | Type  | Description                                         |
| ------------------- | ----- | --------------------------------------------------- |
| `resources_list`    | read  | List all resource definitions                       |
| `resources_get`     | read  | Get a single resource by ID                         |
| `resources_resolve` | read  | Execute resources (HTTP, DB, internal) with context |
| `resources_add`     | write | Create a resource definition                        |
| `resources_update`  | write | Update a resource definition                        |
| `resources_remove`  | write | Delete a resource definition                        |

## Support

| Tool                    | Type  | Description             |
| ----------------------- | ----- | ----------------------- |
| `support_list_tickets`  | read  | List support tickets    |
| `support_get_ticket`    | read  | Get a single ticket     |
| `support_get_stats`     | read  | Ticket stats by status  |
| `support_create_ticket` | write | Create a support ticket |
| `support_update_ticket` | write | Update a ticket         |
| `support_close_ticket`  | write | Close a ticket          |

## Surveys

| Tool                      | Type  | Description                 |
| ------------------------- | ----- | --------------------------- |
| `surveys_list`            | read  | List surveys                |
| `surveys_get`             | read  | Get a single survey         |
| `surveys_get_stats`       | read  | Survey response stats       |
| `surveys_list_responses`  | read  | List responses for a survey |
| `surveys_create`          | write | Create a survey             |
| `surveys_submit_response` | write | Submit a survey response    |

## Stores

| Tool                     | Type  | Description           |
| ------------------------ | ----- | --------------------- |
| `stores_list`            | read  | List stores           |
| `stores_get`             | read  | Get a single store    |
| `stores_list_facilities` | read  | List facilities       |
| `stores_get_facility`    | read  | Get a single facility |
| `stores_create`          | write | Create a store        |
| `stores_update`          | write | Update a store        |
| `stores_remove`          | write | Delete a store        |
| `stores_create_facility` | write | Create a facility     |
| `stores_update_facility` | write | Update a facility     |
| `stores_remove_facility` | write | Delete a facility     |

## Workflows

| Tool                  | Type  | Description                     |
| --------------------- | ----- | ------------------------------- |
| `workflows_list`      | read  | List workflow executions        |
| `workflows_get`       | read  | Get a single workflow execution |
| `workflows_get_stats` | read  | Workflow execution stats        |
| `workflows_retry`     | write | Retry a failed workflow         |

## User Workflows

| Tool                       | Type | Description                  |
| -------------------------- | ---- | ---------------------------- |
| `user_workflows_list`      | read | List workflows for a user    |
| `user_workflows_get`       | read | Get a specific user workflow |
| `user_workflows_get_stats` | read | Stats for a user's workflows |

## Feedback

| Tool                 | Type  | Description           |
| -------------------- | ----- | --------------------- |
| `feedback_list`      | read  | List feedback entries |
| `feedback_get_stats` | read  | Feedback analytics    |
| `feedback_submit`    | write | Submit feedback       |

## Agent

| Tool                  | Type  | Description                            |
| --------------------- | ----- | -------------------------------------- |
| `agent_memory_store`  | write | Save observation to persistent memory  |
| `agent_memory_search` | read  | Search persistent memory               |
| `agent_memory_list`   | read  | List recent memories                   |
| `agent_load_skill`    | read  | Load a domain knowledge skill document |
| `agent_list_tools`    | read  | List all available registry tools      |

## Tool Naming Convention

MCP tools use underscores: `domain_operation` (e.g., `wallet_credit`)
Internal registry uses dots: `domain.operation` (e.g., `wallet.credit`)

The MCP server automatically converts between formats.
