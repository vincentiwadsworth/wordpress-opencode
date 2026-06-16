# AGENTS.md — wordpress-opencode

WordPress + Elementor Pro stack for AI-assisted site creation and management.

## Stack

| Layer | Tool | Version |
|-------|------|---------|
| Local env | DDEV (Docker) | 1.25.2, PHP 8.3, MariaDB 10.11, nginx-fpm |
| CMS | WordPress (Bedrock) | 7.0, docroot: `web/` |
| Builder | Elementor (free) | 3.35.9 via Composer |
| Builder Pro | Elementor Pro | `suggest` in composer.json — needs license |
| CLI | WP-CLI | 2.12.0 (`ddev wp`) |
| CLI builder | Respira CLI | 0.1.4 (`respira`, host-side) |
| AI agent | elementor-mcp-agent | 1.3.0 (host-side) |
| Lint | Laravel Pint | `ddev composer lint` |

## Commands

```bash
ddev start               # start environment
ddev stop                # stop
ddev restart             # restart (re-runs post-start hooks)
ddev wp <command>        # WP-CLI inside container
ddev composer <command>  # Composer inside container
ddev launch              # open site in browser
respira --help           # Respira CLI on host
```

## Project layout

```
.ddev/          # DDEV config (docker, php, nginx, hooks)
config/         # Bedrock env config (application.php, environments/)
web/wp/         # WordPress core (Composer-managed, gitignored)
web/app/        # Plugins, themes, uploads (Composer-managed)
web/wp-config.php # Bedrock bootstrap → loads .env → application.php
.env.example    # Tracked template
.env            # Secrets (gitignored)
composer.json   # Dependencies
composer.lock   # Locked versions (committed)
wp-cli.yml      # path: web/wp
```

## Conventions

- **No core edits.** WordPress lives in `web/wp/` (Composer). Edit themes/plugins only.
- **Plugins via Composer.** `composer require wpackagist-plugin/<slug>`. Free plugins from wpackagist.org. Pro from composer.elementor.com.
- **Elementor Pro is optional.** It's in `suggest`. Add with: `ddev composer require elementor/elementor-pro` after setting `ELEMENTOR_PRO_LICENSE` in `.env` and running `ddev restart`.
- **`.env` never committed.** `.env.example` is the source of truth for required vars.
- **DDEV post-start hook** calls `bin/setup-composer-auth.sh`, which reads `ELEMENTOR_PRO_LICENSE` and runs `composer config --auth`. Guarded: exits 0 if license is absent.
- **CI lints only.** `.github/workflows/ci.yml` runs `composer lint` (Pint) on push/PR. No test suite yet.
- **Commits are conventional.** `feat(scope):`, `fix(scope):`, `docs(scope):`, `chore(scope):`.

## Testing

No test runner configured. `strict_tdd: false`. PHPUnit + Pest available as dev deps (`require-dev`) but no test files exist yet.

## Gotchas

- Docker Desktop must be running before `ddev start`.
- `composer install` works without auth because Elementor Pro is `suggest`, not `require`.
- `composer.lock` is committed — reproducible builds everywhere.
- Respira CLI and elementor-mcp-agent are host-side (npm global), not inside DDEV.
- Bedrock's DB defaults (`db`/`db`/`db`/`db`) match DDEV's out-of-the-box credentials.
