#!/usr/bin/env bash
# story: e38s08
# sync-version-mirrors.sh — bump version mirrors across all config files
# Manual utility for a separately authorized package release; see docs/RELEASE.md.
# Usage: bash scripts/sync-version-mirrors.sh <version>
#
# Run after updating package.json (so derived
# artifacts like .gemini/ and .pi/ read the new version from there).
# Review and commit resulting mirror changes as part of that package release.

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib/python-env.sh"

VERSION="${1:?usage: sync-version-mirrors.sh <version>}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "sync-version-mirrors.sh: bumping mirrors to $VERSION"

# ── 1. YAML mirror fields ──────────────────────────────────────────────
$PYTHON "$REPO_ROOT/scripts/yaml-tools.py" set \
  "$REPO_ROOT/specs/state.yaml" bigpowers_version "$VERSION"

$PYTHON "$REPO_ROOT/scripts/yaml-tools.py" set \
  "$REPO_ROOT/specs/release-plan.yaml" release.version "$VERSION"

# ── 2. Regenerate derived artifacts (reads already-bumped package.json) ─
bash "$REPO_ROOT/scripts/sync-skills.sh"

echo "sync-version-mirrors.sh: done — all mirrors at $VERSION"
