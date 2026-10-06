---
name: commit-message
model: haiku
effort: standard
description: Review working-tree changes and draft a free-form versionedcommits message with explicit release hints and user-facing notes. Use when preparing a commit or explaining its SemVer impact.
---

# story: e82s02

# Commit Message

> **HARD GATE** — Explain the change and its reason. Use versionedcommits metadata
> for release impact: `@major`, `@minor`, or `@patch` on a separate unindented line.
> Never infer a bump from the subject prefix. Internal-only work can omit a hint.

## Workflow

1. Read `specs/state.yaml` `vcs.kind`. For Git, inspect `git status`, `git diff`, and
   `git diff --cached`; for Jujutsu, inspect `jj status`, `jj diff`, and `jj log -r @`.
   Base the proposed commit on the changes that will actually be included.
2. Use conversation context to explain intent and identify incompatible behavior.
   Separate unrelated changes into atomic commits when appropriate.
3. Choose impact: `@major` for breaking behavior, `@minor` for a compatible feature,
   `@patch` for a compatible fix, or no hint for internal work with no release.
4. Write a free-form subject (at most 72 characters) and optional implementation
   body. Add a user-facing release note separately; follow [REFERENCE.md](REFERENCE.md)
   for matching block delimiters, bare-hint fallback, and squash handling.
5. Report relevant defensive-code categories: rate limiting, retry/backoff,
   circuit breaker, timeout, graceful degradation. Existing fix-ratio metrics
   based on `fix:` prefixes are legacy and cannot classify free-form subjects;
   do not distort the message or claim a recalculated ratio from those prefixes.
6. Deliver the complete proposed message and its explicit impact (`major`, `minor`,
   `patch`, or `none`). Distinguish this commit's impact from the aggregate next
   release. Drafting a message does not authorize committing or publishing.

## Example

```text
Handle missing catalog entries

Return an actionable error instead of crashing during skill lookup.

@patch Fixed crashes when a skill is unavailable
Users now see which skill is missing and can select another one.
@patch
```

## Checklist

- [ ] Subject and body explain the actual change; no prescribed type/scope prefix.
- [ ] Release hint matches compatibility impact; breaking changes include migration guidance.
- [ ] Detailed release notes end with the same bare hint on its own line.
- [ ] No hint is invented for internal-only work; no bump is inferred from title wording.
- [ ] Final squash/merge message preserves the intended release metadata.
- [ ] No `Co-authored-by` footers, per the repository attribution rule.
- [ ] For other repositories, verify that their release automation consumes versionedcommits hints.

## Handoff

Gate: READY -> next: release-branch
Writes: state.yaml handoff.next_skill = release-branch
