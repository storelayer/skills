# Storelayer Skills

Skills for building loyalty programs, promotions, wallets, referrals, and customer engagement on [Storelayer](https://storelayer.io).

## Install

### Via skills.sh CLI (recommended)

```bash
npx skills add storelayer/skills
```

Install for specific agents:

```bash
npx skills add storelayer/skills -a claude-code -a cursor -a pi
```

### Via Claude Code plugin marketplace

```
/plugin marketplace add storelayer/skills
/plugin install storelayer@storelayer
```

### From local .skill file

```bash
npx skills add ./dist/storelayer.skill
```

## Skills

- `storelayer` — main skill. Triggers on loyalty rules, promotions, discount codes, referrals, points, customer events, wallet operations.

## Source of truth

Maintain the skill directly in [`skills/storelayer/SKILL.md`](skills/storelayer/SKILL.md).
This repository is canonical; do not overwrite the skill from `pi-storelayer`.

The skill reads [live Markdown documentation](https://docs.storelayer.io/llms.txt)
for concepts and workflows, then uses the existing [API reference](https://api.storelayer.io/docs)
and [OpenAPI contract](https://api.storelayer.io/openapi.json) for endpoint details.
For live project operations, supply `STORE_LAYER_API_KEY` in the agent's environment.

The skill carries decision guidance; concepts and cookbooks live in the docs site.
Endpoint specifications stay in the existing API reference. Update guides when a contract change affects their workflows.
Domain references and cookbooks live on the docs site so installed skills do not carry stale copies.

## Layout

```
.claude-plugin/        # Claude Code marketplace metadata
skills/storelayer/
  SKILL.md            # canonical skill, live docs and HTTP workflow
  agents/claude.yaml  # display metadata
  assets/             # skill icon
scripts/
  package_skill.sh    # package into .skill zip for distribution
```

## Package for distribution

```bash
./scripts/package_skill.sh           # outputs dist/storelayer.skill
./scripts/package_skill.sh ./build   # custom output dir
```

## Update

Edit `skills/storelayer/**`, commit, push. Users run:

```bash
npx skills update storelayer
```

## License

Apache-2.0
