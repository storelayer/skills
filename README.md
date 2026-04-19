# Storelayer Skills

Claude Code plugin — skills for building loyalty programs, promotions, wallets, referrals, and customer engagement on [Storelayer](https://storelayer.io).

## Install

```
/plugin marketplace add storelayer/skills
/plugin install storelayer@storelayer
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
  marketplace.json    # marketplace manifest (so this repo is its own marketplace)
skills/
  storelayer/
    SKILL.md
    references/
    agents/
    tools/
    assets/
```

## Update

Edit `skills/storelayer/**`, commit, push. Users run `/plugin marketplace update storelayer` to pull the latest.

## License

Apache-2.0
