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
- Plugin installation prefers Composer (`ddev composer require wpackagist-plugin/<slug>`), but falls back to `ddev wp plugin install <slug>` for plugins not on wpackagist.
- **`WP_HOME` in `.env` must match the DDEV URL** (`http://wordpress-opencode.ddev.site`). If it's `example.com`, the REST API breaks.
- **Permalinks must be set after any new WordPress install or URL change**: `ddev wp rewrite structure '/%postname%/' && ddev wp rewrite flush --hard`.

## Decision Gates

| Trigger | Action |
|---------|--------|
| User says "levantar WordPress", "arrancar entorno" | `ddev start` + verify with `ddev describe` |
| User wants a new free plugin | `ddev composer require wpackagist-plugin/<slug>` then `ddev wp plugin activate <slug>`. If not on wpackagist: `ddev wp plugin install <slug> --activate` |
| User wants Elementor Pro | Check `ELEMENTOR_PRO_LICENSE` in `.env`; if absent, ask for license key first |
| WP-CLI command fails with "not a WordPress installation" | Verify `ddev start` ran successfully; check `web/wp/` exists |
| Database issues | `ddev wp db check` or `ddev wp db repair` |
| REST API returns HTML instead of JSON | Check `WP_HOME` in `.env` matches `http://wordpress-opencode.ddev.site`. Also verify permalinks: `ddev wp rewrite structure '/%postname%/' && ddev wp rewrite flush --hard` |
| First time after WordPress install | Must set permalinks: `ddev wp rewrite structure '/%postname%/' --hard` and flush rewrites. Without this, `/wp-json/` doesn't resolve. |

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

## Remote WP-CLI via SSH

For **remote sites** (not local DDEV), WP-CLI runs over SSH instead of `ddev wp`:

```bash
# Basic remote WP-CLI
ssh user@host "wp --path=/var/www/html plugin list"

# Create a page on a remote site
ssh user@host "wp --path=/var/www/html post create \
  --post_type=page --post_title='Title' --post_status=publish"

# Update post meta on remote
ssh user@host "wp --path=/var/www/html post meta update <ID> _elementor_data '\''$(cat /tmp/data.json)'\''"
```

**SSH credentials** are stored in the site config (`sites/<id>.yaml`) under the `ssh` key:
- `host`, `port`, `user`, `path`, `wp` (WP-CLI binary)

### Decision Gates (Remote)

| Trigger | Action |
|---------|--------|
| Need to run WP-CLI on a remote site | Use `ssh user@host "wp --path=... <command>"` — read SSH credentials from `sites/<id>.yaml` |
| SSH key not configured | Ask user to configure SSH key-based auth. Password auth is not supported from CLI. |

## Multi-Site Awareness

This skill covers both:
- **Local DDEV**: Use `ddev wp` commands (primary workflow for the local dev site)
- **Remote sites**: Use SSH WP-CLI commands (for Elementor and Avada client sites)

The active site is determined via the `wp-multi-site` skill conventions. If `ACTIVE_SITE` is set to a remote site, use SSH. If unset or `local-ddev`, use `ddev wp`.

## References

- `AGENTS.md` — project stack, commands, conventions, gotchas.
- `.env.example` — required environment variables.
- `wp-multi-site` skill — site switching conventions.
- `sites/_template.yaml` — site config schema with SSH fields.
