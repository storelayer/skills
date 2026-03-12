# Storelayer Skills

Centralized AI skill packages for the [Storelayer](https://storelayer.io) loyalty & commerce platform.

## What is this?

Skills are structured knowledge packages that AI coding agents (Claude Code, Codex, etc.) can load to become experts at building on the Storelayer platform. Instead of scattered documentation, skills provide:

- **Decision trees** for choosing the right approach
- **Reference docs** for each domain (wallet, promotions, referrals, etc.)
- **Agent definitions** for specialized tasks
- **Tools** for common operations
- **Recipes** for proven patterns

## Usage

### Claude Code

Add to your project's `.claude/settings.json`:

```json
{
  "skills": ["path/to/storelayer-skills/skills/storelayer"]
}
```

Or reference the MCP server:

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

### OpenAI Codex / Other Agents

The skill follows the [Agent Skills Standard](https://agentskills.io) format and can be loaded by any compatible agent.

## Structure

```
skills/storelayer/
  SKILL.md              # Main skill entry point (decision trees, pipeline, recipes)
  agents/
    loyalty-builder.md  # Specialized agent for building loyalty programs
    promo-engineer.md   # Specialized agent for promotion engineering
    integration-dev.md  # Agent for event ingestion & webhook setup
  references/
    architecture.md     # Platform architecture & patterns
    wallet.md           # Wallet/ledger system reference
    promotions.md       # Promotion engine reference
    referral.md         # Referral system reference
    events.md           # Event tracking & rules reference
    external-users.md   # Customer management reference
    discount-scripts.md # Discount computation scripting guide
    conditions.md       # Condition engine reference
    mcp-tools.md        # MCP tool reference (all available tools)
  tools/
    setup-project.md    # Project setup checklist
    test-promotion.md   # Promotion testing workflow
    debug-rules.md      # Rule debugging workflow
  assets/
    storelayer-icon.svg # Brand icon
```

## Contributing

1. Fork this repo
2. Edit or add skill files
3. Test with your agent of choice
4. Submit a PR

## License

Apache-2.0
