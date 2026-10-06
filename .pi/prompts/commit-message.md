---
name: commit-message
description: "Review working-tree changes and draft a free-form versionedcommits message with explicit release hints and user-facing notes. Use when preparing a commit or explaining its SemVer impact."
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

---

# versionedcommits agent reference

Source: [mikkel3000/versionedcommits](https://github.com/mikkel3000/versionedcommits).

## Message format

Write a clear free-form subject and a body explaining the implementation and why it
changed. No type prefix or parenthesized scope is required. This repository keeps
its 72-character subject limit; that is a local rule, not part of versionedcommits.
Release metadata belongs on separate lines starting at column one:

```text
Cache parsed skill metadata

Reuse parsed metadata to reduce repeated filesystem reads.

@patch Fixed slow skill discovery
Large skill catalogs now load faster without changing the available skills.
@patch
```

The commit prose addresses maintainers. The hint title and description address
release users. Start note titles with `Added`, `Changed`, `Deprecated`, `Removed`,
`Fixed`, or `Security` to group Markdown changelog entries.

## Choose the release impact explicitly

| Hint | SemVer impact | Use for |
|------|---------------|---------|
| `@major` | Breaking change | Incompatible public API or behavior; explain migration |
| `@minor` | Compatible feature | New user-visible capability |
| `@patch` | Compatible fix | Bug fix or compatible improvement |
| No hint | No release entry or bump | Internal work that should not trigger a release |

Decide from the actual user impact. Prefixes such as `feat:` or `fix:`, an `!`, and
`BREAKING CHANGE:` prose do not request a version bump. A breaking change needs
`@major` even if its subject describes a fix. Do not add hints to every internal
checkpoint just to pass a gate.

Use one of these forms:

- One-line note: `@patch Fixed missing skill links` on its own line.
- Detailed note: opening hint with a title, description on following lines, and
  the same bare hint on its own line to close the block. Always close detailed
  blocks: the current parser only captures the description between matching hints.
- Bare hint: `@minor` on its own line uses the commit title and body as the note.
  Use this only when that prose is already suitable for release users.

Hints are lowercase and unindented; do not put them inline in a sentence or prefix
with a bullet. Prefer one impact per atomic commit. If multiple notes are needed,
close each block with its matching hint before starting the next; mismatched hints
can discard notes. The highest impact since the latest stable SemVer tag determines
the next version (`major` > `minor` > `patch`). No hints means no release.

## Squash, merge, and preview

Review full messages with `git log main..HEAD --format=%B`; `--oneline` hides hints.
For a squash, explicitly preserve the intended metadata in the final squash commit
body. A PR title alone carries no release hint. Use `gh pr merge --squash --subject
"..." --body-file <release-message-file>` when merging, or pass the full multiline
message to `land-branch.sh`. Review that final message before landing. Do not assume
GitHub copies PR descriptions or all individual commit bodies into the squash.

With the upstream binary installed, `versionedcommits --format json` and
`versionedcommits --next-tag` preview the release from the current branch history
without creating tags. They cannot inspect uncommitted changes. Compare the output
with the intended impact; do not add `--tag`, `--commit`, or push to preview.

## Release automation

This repository uses the upstream reusable versionedcommits workflow in
`.github/workflows/publish.yml`, gated by skill health and compliance checks.
It creates or updates a changelog PR on `versionedcommits/release`; merging that
PR creates the release tag. Actions must be allowed to create and approve PRs.

The action does not publish npm packages or update package version mirrors.
See [release setup](../../docs/RELEASE.md) for the installed workflow and limits.
