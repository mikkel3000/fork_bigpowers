#!/usr/bin/env bash
# Then it must mandate versionedcommits and SemVer 2.0.0
if grep -q "versionedcommits" CONVENTIONS.md 2>/dev/null && grep -q "Semantic Versioning" CONVENTIONS.md 2>/dev/null; then
  exit 0
else
  echo "CONVENTIONS.md does not mandate versionedcommits and Semantic Versioning"
  exit 1
fi
