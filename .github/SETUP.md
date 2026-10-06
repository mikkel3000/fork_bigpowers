# GitHub Actions CI/CD Setup

## 1. Repository permissions

Enable **Allow GitHub Actions to create and approve pull requests** in Settings →
Actions → General. The release action uses the built-in `GITHUB_TOKEN`; it does
not need an npm token.

## 2. Release Workflow

Use [versionedcommits messages](VERSIONEDCOMMITS.md). Read
[release setup](../docs/RELEASE.md) for the installed versionedcommits action.
Enable **Allow GitHub Actions to create and approve pull requests** in Settings →
Actions → General. Releases use `GITHUB_TOKEN`; npm publication is not configured.

## 3. Sync Skills Workflow

Automatically syncs skill artifacts when SKILL.md files change:

```bash
git push origin main
# .cursor/rules and .gemini/ auto-regenerated and committed
```

## 4. Verify Setup

```bash
# Workflows enabled
gh workflow list

# Inspect release workflow configuration
gh workflow view publish.yml

# Release tags in this fork
git ls-remote --tags origin
```
