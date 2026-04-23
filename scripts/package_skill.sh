#!/usr/bin/env bash
set -euo pipefail

# Package storelayer skill into a .skill zip file for skills.sh distribution
# Usage: ./scripts/package_skill.sh [output-dir]
#
# Output: storelayer.skill (ZIP format) in output-dir (default: ./dist)

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$REPO_ROOT/skills/storelayer"
OUTPUT_DIR="${1:-$REPO_ROOT/dist}"

# Validate
if [ ! -f "$SKILL_DIR/SKILL.md" ]; then
  echo "Error: SKILL.md not found in $SKILL_DIR" >&2
  exit 1
fi

# Check frontmatter has required fields
if ! head -10 "$SKILL_DIR/SKILL.md" | grep -q "^name:"; then
  echo "Error: SKILL.md missing 'name' in frontmatter" >&2
  exit 1
fi
if ! head -10 "$SKILL_DIR/SKILL.md" | grep -q "^description:"; then
  echo "Error: SKILL.md missing 'description' in frontmatter" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

SKILL_FILE="$OUTPUT_DIR/storelayer.skill"
rm -f "$SKILL_FILE"

# Create zip from skills/ directory, preserving storelayer/ prefix
# Excludes: .DS_Store, __pycache__, node_modules, .git
cd "$REPO_ROOT/skills"
zip -r "$SKILL_FILE" storelayer/ \
  -x "*.DS_Store" \
  -x "*__pycache__/*" \
  -x "*node_modules/*" \
  -x "*.pyc" \
  -x "*/.git/*"

echo ""
echo "Packaged: $SKILL_FILE"
echo "Contents:"
unzip -l "$SKILL_FILE"
