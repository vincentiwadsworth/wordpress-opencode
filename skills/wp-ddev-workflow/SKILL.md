---
name: wp-ddev-workflow
description: "Trigger: DDEV, ddev start, WordPress local, WP-CLI, instalar plugin, activar plugin. Manage WordPress local environments with DDEV and WP-CLI."
license: MIT
metadata:
  author: "vincentiwadsworth"
  version: "1.0"
---

## Activation Contract

Use this skill for any DDEV or WP-CLI operation in this project. All WordPress administration runs through `ddev wp` inside the container.

## Hard Rules

- Never run `wp` directly on the host. Always `ddev wp <command>`.
- `ddev start` runs Composer install and post-start hooks; `ddev restart` re-runs hooks.
- `.env` is gitignored. Read `.env.example` for required vars, never modify `.env` without user approval.
- `web/wp/` is Composer-managed — never edit WordPress core files.
- Plugin installation uses Composer (`ddev composer require wpackagist-plugin/<slug>`), not `wp plugin install`.

## Decision Gates

| Trigger | Action |
|---------|--------|
| User says "levantar WordPress", "arrancar entorno" | `ddev start` + verify with `ddev describe` |
| User wants a new free plugin | `ddev composer require wpackagist-plugin/<slug>` then `ddev wp plugin activate <slug>` |
| User wants Elementor Pro | Check `ELEMENTOR_PRO_LICENSE` in `.env`; if absent, ask for license key first |
| WP-CLI command fails with "not a WordPress installation" | Verify `ddev start` ran successfully; check `web/wp/` exists |
| Database issues | `ddev wp db check` or `ddev wp db repair` |

## Execution Steps

1. Verify DDEV is running: `ddev describe` — all services must show "OK".
2. For WP-CLI ops: prefix with `ddev` (e.g., `ddev wp plugin list`).
3. For Composer ops: prefix with `ddev` (e.g., `ddev composer require`).
4. After installing plugins, verify: `ddev wp plugin list --status=active`.
5. After any db-altering command, run `ddev wp transient delete --all` and `ddev wp cache flush`.

## Output Contract

After any state change, report:
- What was installed/activated/modified
- Verify command output showing success
- URL if relevant (`ddev launch` or `http://wordpress-opencode.ddev.site`)

## References

- `AGENTS.md` — project stack, commands, conventions, gotchas.
- `.env.example` — required environment variables.
