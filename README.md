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

Content mirrors the upstream `storelayer-builder` skill at [`storelayer/pi-storelayer`](https://github.com/storelayer/pi-storelayer) — the canonical source. Sync with:

```bash
gh api repos/storelayer/pi-storelayer/contents/skills/storelayer-builder/SKILL.md --jq .content | base64 -d > skills/storelayer/SKILL.md
# then re-add the `name: storelayer` frontmatter field
```

## Layout

```
.claude-plugin/
  plugin.json         # plugin manifest
  marketplace.json    # marketplace manifest
skills/
  storelayer/
    SKILL.md          # main skill definition
    references/       # domain deep-dives (wallet, promotions, events, etc.)
    agents/           # sub-agent definitions
    tools/            # tool definitions (debug, setup, test)
    assets/           # icons, images
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
