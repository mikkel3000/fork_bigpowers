#!/usr/bin/env bash
# story: e82s03
# bigpowers — pre-tool-use hook for OMP bash tool
# Shell fallback for runtimes that invoke hooks as processes rather than
# calling the TypeScript extension directly. Blocks dangerous git commands
# and permits versionedcommits free-form messages. Primary implementation lives in
# extensions/omp-hooks.ts (ExtensionAPI tool_call handler).
set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.command // .tool_input.command // empty' 2>/dev/null || true)
[ -z "$COMMAND" ] && exit 0

DANGEROUS_PATTERNS=(
  "git reset --hard"
  "git clean -f"
  "git branch -D"
  "push --force"
  "push -f"
)
PROTECTED_BRANCHES=("main" "master")

for p in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qE "$p"; then
    printf '{"decision":"block","reason":"BLOCKED: dangerous pattern %q"}\n' "$p"
    exit 0
  fi
done

if [[ "$COMMAND" =~ git[[:space:]]+commit ]]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  for b in "${PROTECTED_BRANCHES[@]}"; do
    if [[ "$BRANCH" == "$b" ]]; then
      printf '{"decision":"block","reason":"BLOCKED: direct commit to %q"}\n' "$b"
      exit 0
    fi
  done
fi

exit 0
