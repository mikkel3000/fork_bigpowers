# Release & publishing guide

This repository uses [versionedcommits](https://github.com/mikkel3000/versionedcommits)
through `.github/workflows/publish.yml`. Commit subjects are free-form; explicit
`@major`, `@minor`, and `@patch` hints drive release notes and the next SemVer tag.
See the [agent reference](../skills/commit-message/REFERENCE.md) for message syntax.

## Installed workflow

The caller runs on pushes to `main`, closed PRs targeting `main`, and manual dispatch.
Skill-health and compliance jobs must both pass before the reusable workflow runs.
The upstream workflow is pinned to commit
`eb9ac58a58fb9ef7ed92802cbdcc244106e3e8b0`; the README's `v0.1.0` tag predates that
workflow, so it is not a usable workflow reference.

1. Hinted commits cause the action to create or update a PR from
   `versionedcommits/release` containing the final versioned changelog entry.
2. Review and merge that PR. The closed-PR event verifies the changelog and creates
   the release tag on its merge commit.
3. Commits without release hints do not request a release. The highest hint since
   the latest stable semantic tag determines the next version.

In repository Settings → Actions → General, enable **Allow GitHub Actions to
create and approve pull requests**. The action uses `GITHUB_TOKEN` with
`contents: write`, `pull-requests: write`, and `statuses: write`. No extra secret is
needed. Its `versionedcommits/release-pr` status marks generated release PRs ready.

The old semantic-release job, configuration, npm script, and dependencies are
removed. The new workflow manages changelog PRs and Git tags. It does not publish
npm packages, create GitHub Release objects, or update `package.json` and version
mirrors. Package publication is a separate workflow and is not configured here.
For a separately authorized package release, update the package version and use
`bash scripts/sync-version-mirrors.sh <version>` to refresh its mirrors.

## Local preview

With the upstream binary installed and the intended commits present:

```bash
versionedcommits --format json
versionedcommits --next-tag
```

These commands preview notes and the next tag without changing Git history.
The CI workflow manages release tags; do not run a competing local tag writer.
