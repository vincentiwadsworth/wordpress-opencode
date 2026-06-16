---
name: wp-deploy
description: "Trigger: deploy, push a producción, staging, CI/CD, GitHub Actions, Trellis. Deploy WordPress sites from local to staging or production using CI/CD pipelines."
license: MIT
metadata:
  author: "vincentiwadsworth"
  version: "0.1"
---

## Activation Contract

Use this skill when preparing or executing WordPress deployments. Current status: CI lint pipeline is active; Trellis provisioning and zero-downtime deploys are planned but not yet configured.

## Hard Rules

- `.env` never leaves local. Secrets go through GitHub Actions secrets or Trellis vault.
- `composer.lock` is committed — production installs use `composer install --no-dev`.
- Always run `composer lint` (Pint) before push. CI enforces this on PR.
- Database migrations happen via WP-CLI, never manual SQL.
- Backups before every deploy: `ddev wp db export` to a timestamped file.

## Decision Gates

| Trigger | Action |
|---------|--------|
| User says "deploy", "push a producción" | Run `composer lint` first. If clean, proceed with CI workflow. |
| CI fails on lint | Fix lint errors with `ddev composer lint:fix`, commit, re-push. |
| Database migration needed | Export DB first, run migration script with dry-run, then apply. |
| Deploy to new server | (Trellis — pending) Provision server, deploy with atomic releases. |
| Rollback needed | (Trellis — pending) `trellis rollback production <release>` |

## Execution Steps (current, without Trellis)

1. Run lint: `ddev composer lint`.
2. Ensure all changes are committed and pushed to `main`.
3. CI runs automatically via `.github/workflows/ci.yml`.
4. For manual staging: `git push` triggers the deploy pipeline (to be configured).

## Execution Steps (future, with Trellis)

1. `trellis deploy staging` — deploys to staging with atomic release.
2. `trellis deploy production` — deploys to production after staging validation.
3. On failure: `trellis rollback production` restores the previous release atomically.

## Output Contract

After deploy, report:
- Deploy target (staging/production).
- Git SHA deployed.
- Lint status (PASS/FAIL).
- Any post-deploy tasks: cache flush, rewrite flush, transient cleanup.

## References

- `AGENTS.md` — CI/CD conventions, GitHub Actions workflow location.
- `.github/workflows/ci.yml` — current CI pipeline (lint-only).
- Trellis docs: https://roots.io/trellis/ (pending integration).
