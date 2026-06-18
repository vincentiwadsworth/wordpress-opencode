# AGENTS.md — wordpress-opencode

Agency workspace for AI-assisted creation and management of multiple WordPress client sites, supporting Elementor and Avada (Fusion Builder) page builders.

## Stack

| Layer | Tool | Version |
|-------|------|---------|
| Local env | DDEV (Docker) | 1.25.2, PHP 8.3, MariaDB 10.11, nginx-fpm |
| CMS | WordPress (Bedrock) | 7.0, docroot: `web/` |
| Builder (Elementor) | Elementor (free) | 3.35.9 via Composer |
| Builder (Avada) | Avada (Fusion Builder) | Via theme purchase, shortcodes in `post_content` |
| Builder Pro | Elementor Pro | `suggest` in composer.json — needs license |
| CLI | WP-CLI | 2.12.0 (`ddev wp` local, SSH for remote) |
| AI agent (Elementor) | elementor-mcp-agent | 1.3.0 (multi-site capable) |
| Lint | Laravel Pint | `ddev composer lint` |

## Multi-Site Workspace

This repo manages **multiple client sites** via a `sites/` config directory:

```
sites/
├── _template.yaml         # Site config template (committed)
├── client-*.yaml          # Per-client configs (gitignored)
```

Each site config specifies connection details and which builder it uses:

```yaml
id: client-acme
url: "https://acme.com"
username: "admin"
application_password: "..."
builder: elementor    # elementor | avada
theme: "Avada"
ssh:
  host: "acme.com"
  user: "deploy"
  path: "/var/www/html"
```

### Site Switching Commands

| Command | Description |
|---------|-------------|
| `"switch to <site-id>"` | Switch active site. AI reads `sites/<id>.yaml` and sets session context. |
| `"list sites"` | Show all configured sites from `sites/*.yaml`. |
| `"show active site"` | Show current active site name, builder, URL. |
| `"switch to local-ddev"` | Switch back to local DDEV development site. |

### Builder Routing

- **Elementor sites**: Use `elementor-mcp-agent` tools + `wp-elementor-page` skill
- **Avada sites**: Use WP-CLI + shortcodes via `wp-avada-page` skill

## Common Workflows

Estas son las operaciones más frecuentes. Ejecutalas rápido sin preguntar cada detalle.

### 🔄 Switch de builder en un sitio (Elementor ↔ Avada)

```yaml
# 1. Desactivar Elementor
ddev wp plugin deactivate elementor    # local
ssh user@host "wp plugin deactivate elementor"  # remoto

# 2. Instalar Avada (si no está)
# NOTA: Avada es premium, requiere zip comprado en ThemeForest
ddev wp theme install <path-to-avada.zip> --activate
ddev wp plugin install avada-builder --activate  # o el slug real

# 3. Las páginas viejas (Elementor) quedan con _elementor_data pero post_content vacío
# Las páginas NUEVAS se crean con Avada shortcodes en post_content
# NO hay conversión automática Elementor → Avada (modelos de datos incompatibles)
```

### 📄 Crear página rápida (cualquier builder)

**Elementor** (via elementor-mcp-agent o WP-CLI):
```
Crear page → inject _elementor_data JSON → flush CSS → publish
```

**Avada** (via WP-CLI):
```
Crear page con post_content='[fusion_builder_container][fusion_builder_row]...[/fusion_builder_container]'
```

### 🔌 Gestionar plugins

```bash
# Local
ddev composer require wpackagist-plugin/<slug>
ddev wp plugin activate <slug>

# Remoto
ssh user@host "wp plugin install <slug> --activate"
```

## Project layout

```
.ddev/          # DDEV config (docker, php, nginx, hooks)
config/         # Bedrock env config (application.php, environments/)
sites/          # Per-client site configs (gitignored, _template.yaml tracked)
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
- **Avada requires a ThemeForest purchase.** Install manually via wp-admin or `ddev wp theme install` with the purchased zip. Not available via Composer.
- **`.env` never committed.** `.env.example` is the source of truth for required vars.
- **DDEV post-start hook** calls `bin/setup-composer-auth.sh`, which reads `ELEMENTOR_PRO_LICENSE` and runs `composer config --auth`. Guarded: exits 0 if license is absent.
- **CI lints only.** `.github/workflows/ci.yml` runs `composer lint` (Pint) on push/PR. No test suite yet.
- **Commits are conventional.** `feat(scope):`, `fix(scope):`, `docs(scope):`, `chore(scope):`.

## Project skills

| Skill | Path | When |
|-------|------|------|
| `wp-ddev-workflow` | `skills/wp-ddev-workflow/SKILL.md` | DDEV, WP-CLI, plugin management, remote SSH WP-CLI |
| `wp-elementor-page` | `skills/wp-elementor-page/SKILL.md` | Elementor page building (WP-CLI injection) |
| `wp-avada-page` | `skills/wp-avada-page/SKILL.md` | Avada page building (shortcodes + WP-CLI) |
| `wp-multi-site` | `skills/wp-multi-site/SKILL.md` | Site switching between client sites |
| `wp-deploy` | `skills/wp-deploy/SKILL.md` | Deploy, CI/CD, Trellis |

## Testing

No test runner configured. `strict_tdd: false`. PHPUnit + Pest available as dev deps (`require-dev`) but no test files exist yet.

## Gotchas

- Docker Desktop must be running before `ddev start`.
- `composer install` works without auth because Elementor Pro is `suggest`, not `require`.
- `composer.lock` is committed — reproducible builds everywhere.
- Avada is NOT available via Composer. Requires manual theme installation (purchased zip from ThemeForest).
- Avada stores pages as **shortcodes in `post_content`**, NOT in `_elementor_data` meta. Use `wp post create --post_content='[fusion_builder_container...]'`.
- Bedrock's DB defaults (`db`/`db`/`db`/`db`) match DDEV's out-of-the-box credentials.
- **WP_HOME must match DDEV URL.** `.env` must have `WP_HOME='http://wordpress-opencode.ddev.site'` — if it's `example.com`, the REST API returns HTML instead of JSON, breaking all API-based tools.
- **Permalinks need rewrite flush.** After first setup or URL changes: `ddev wp rewrite structure '/%postname%/' && ddev wp rewrite flush --hard`. Without this, `/wp-json/` doesn't work.
- **elementor-mcp-agent outputSchema bug — PARCHADO.** Se removió `outputSchema` del `dist/server.js` (todos los tools devuelven texto plano, OpenCode espera contenido estructurado cuando hay outputSchema). El parche vive en `node_modules`, sobrevive reinstalaciones de npm.
- **DDEV nginx no pasa Authorization header por defecto.** Se agregó `fastcgi_param HTTP_AUTHORIZATION $http_authorization;` en `.ddev/nginx_full/nginx-site.conf`. Sin esto, application passwords no funcionan.
- **WP 7.0 requiere SSL o entorno `local` para application passwords.** Se setea `WP_ENVIRONMENT_TYPE=local` en `.env`. Si falta, el REST API devuelve 401 aunque el password sea válido.
- **Respira CLI is NOT connected.** Site was never linked. Plugin `inhale-mcp-abilities` ≠ Respira for WordPress plugin needed for CLI auth. Don't route page creation through Respira.
- **Site configs are gitignored.** After cloning the repo, create `sites/<client>.yaml` from `sites/_template.yaml` for each client.
