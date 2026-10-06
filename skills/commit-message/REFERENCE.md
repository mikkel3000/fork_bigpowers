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
