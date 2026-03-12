# MCP Tools Reference

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

| Tool                             | Type  | Description                      |
| -------------------------------- | ----- | -------------------------------- |
| `promotions_list`                | read  | List promotions with filters     |
| `promotions_get_active`          | read  | Get all active promotions        |
| `promotions_list_coupons`        | read  | List coupons for a promotion     |
| `promotions_list_usage`          | read  | List usage/redemption records    |
| `promotions_get_stats`           | read  | Stats for a specific promotion   |
| `promotions_get_aggregate_stats` | read  | Global promotion stats           |
| `promotions_create`              | write | Create a promotion               |
| `promotions_update`              | write | Update a promotion               |
| `promotions_remove`              | write | Delete a promotion               |
| `promotions_duplicate`           | write | Clone a promotion as draft       |
| `promotions_create_coupon`       | write | Create a coupon                  |
| `promotions_bulk_create_coupons` | write | Bulk create 1-1000 coupons       |
| `promotions_evaluate_cart`       | write | Evaluate cart against promotions |

## Wallet (all require `userId`)

| Tool                       | Type  | Description                     |
| -------------------------- | ----- | ------------------------------- |
| `wallet_get_balance`       | read  | Get balance for all asset types |
| `wallet_list_transactions` | read  | Transaction history             |
| `wallet_credit`            | write | Add assets (points, tokens)     |
| `wallet_debit`             | write | Spend assets (FEFO order)       |

## Rules / Project

| Tool                        | Type  | Description                         |
| --------------------------- | ----- | ----------------------------------- |
| `project_get_config`        | read  | Project configuration               |
| `project_list_rules`        | read  | List loyalty rules                  |
| `project_get_rule`          | read  | Get a single rule                   |
| `project_list_integrations` | read  | List integrations                   |
| `project_list_resources`    | read  | List resource definitions           |
| `project_add_rule`          | write | Create a rule                       |
| `project_update_rule`       | write | Update a rule                       |
| `project_remove_rule`       | write | Delete a rule                       |
| `project_test_conditions`   | write | Test conditions against sample data |

## Events

| Tool               | Type | Description              |
| ------------------ | ---- | ------------------------ |
| `events_get`       | read | Get event by ID          |
| `events_list`      | read | List events with filters |
| `events_get_stats` | read | Event stats              |

## Referral

| Tool                       | Type  | Description             |
| -------------------------- | ----- | ----------------------- |
| `referral_get_config`      | read  | Referral program config |
| `referral_list_codes`      | read  | List referral codes     |
| `referral_validate_code`   | read  | Check if code is valid  |
| `referral_get_stats`       | read  | Aggregate stats         |
| `referral_get_leaderboard` | read  | Top referrers           |
| `referral_create_code`     | write | Create a referral code  |
| `referral_apply_code`      | write | Apply code for referee  |
| `referral_deactivate_code` | write | Deactivate a code       |

## External Users

| Tool                         | Type  | Description                  |
| ---------------------------- | ----- | ---------------------------- |
| `external_users_get_user`    | read  | Get user by ID               |
| `external_users_list_users`  | read  | List users                   |
| `external_users_lookup_user` | read  | Smart lookup (ID then email) |
| `external_users_register`    | write | Register a user              |
| `external_users_update`      | write | Update a user                |

## Skill & Feedback

| Tool                       | Type  | Description                  |
| -------------------------- | ----- | ---------------------------- |
| `skill_get_content`        | read  | Get this skill guide content |
| `skill_list_feedback`      | read  | List feedback entries        |
| `skill_get_feedback_stats` | read  | Feedback analytics           |
| `skill_update_content`     | write | Update skill guide           |
| `skill_submit_feedback`    | write | Report tool usage outcome    |

## Tool Naming Convention

MCP tools use underscores: `domain_operation` (e.g., `wallet_credit`)
Internal registry uses dots: `domain.operation` (e.g., `wallet.credit`)

The MCP server automatically converts between formats.
