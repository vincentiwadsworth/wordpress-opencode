# Design: WordPress Foundation Stack

## Technical Approach

Scaffold a Bedrock-based WordPress project inside a DDEV container, then layer Elementor Pro (via Composer auth) and host-side CLI tools (Respira, elementor-mcp-agent). DDEV `post-start` hooks bootstrap Composer auth from `.env` and auto-install dependencies. This maps directly to the proposal's 8-step approach and the 4 spec domains: `local-dev-environment`, `dependency-management`, `cli-tooling`, `env-configuration`.

## Architecture Decisions

| # | Decision | Choice | Alternatives | Rationale |
|---|----------|--------|--------------|-----------|
| 1 | Scaffold method | `composer create-project roots/bedrock .` into project root | Manual file creation; `ddev composer-create` | Bedrock generates correct layout, installer paths, `.gitignore`, `wp-cli.yml`, and `config/application.php` in one step. Avoids drift from upstream. |
| 2 | Elementor Pro auth | DDEV `post-start` exec reads `ELEMENTOR_PRO_LICENSE` from `.env`, sets Composer auth via `composer config --auth http-basic.composer.elementor.com token <key>` inside container | Committed `auth.json`; global `COMPOSER_AUTH` env | License never touches disk as a file; `.env` is the single secret source. CI uses a `COMPOSER_AUTH` secret (same `token`/key format) for headless install. Confirmed format: username is literal `token`, password is the license key (Elementor dev docs). |
| 3 | DDEV webserver + docroot | `nginx-fpm`, `docroot: web` | apache-fpm; `docroot: web/wp` | nginx-fpm matches production Trellis target. `docroot: web` (Bedrock web root) — Bedrock's `wp-config.php` routes to `web/wp/` internally. |
| 4 | DB credentials mapping | `.env.example` ships DDEV defaults: `db`/`db`/`db`/`db` | Random gen; manual entry | Works out of the box — `ddev start` creates the `db` database/user automatically. Users override only for non-DDEV environments. |
| 5 | CLI tool placement | WP-CLI: container-side (`ddev wp`). Respira + MCP agent: host-side (`npm i -g`) | All in container; all on host | WP-CLI needs the WP filesystem (container). Respira/MCP manipulate JSON and connect to OpenCode host (LLM side). Spec requires host-side `respira --help` and `elementor-mcp-agent --help`. |
| 6 | elementor-mcp-agent install | Host-side npm global (`npx`/`npm i -g`), configured as MCP server in OpenCode config | WP plugin via Composer | Spec mandates host-global availability. Agent is an MCP server the LLM connects to; it calls WP via REST/WP-CLI, not as a loaded WP plugin. Companion WP REST plugin (if needed) deferred to future change. |
| 7 | ProElements | Optional `wpackagist-plugin/pro-elements` as free fallback when no Elementor Pro license | Required alongside Pro; omit | ProElements is a standalone GPL alternative, not a companion to Elementor Pro. Running both conflicts. Include as commented-out `require-dev` entry. |

## Data Flow

```
  Clone repo
     │
     ▼
  .env.example ──copy──▶ .env  (user fills ELEMENTOR_PRO_LICENSE, salts)
     │
     ▼
  ddev start
     │
     ├─▶ post-start hook: read .env → composer config --auth (token/key)
     │
     ├─▶ post-start hook: composer install
     │         │
     │         ├─▶ roots/wordpress      → web/wp/
     │         ├─▶ wpackagist elementor → web/app/plugins/elementor/
     │         └─▶ elementor-pro        → web/app/plugins/elementor-pro/
     │
     └─▶ ddev wp core install  (headless, no web UI)
              │
              └─▶ wp plugin activate elementor elementor-pro
                     │
                     └─▶ wp elementor-pro license activate <key>

  Host side (separate, not gated by DDEV):
     npm i -g respira  elementor-mcp-agent
              │
              └─▶ OpenCode config: MCP server endpoint
```

## File Changes

| File | Action | Work Unit | Description |
|------|--------|-----------|-------------|
| `.ddev/config.yaml` | Create | U1: DDEV | PHP 8.3, MariaDB 10.11, nginx-fpm, Node 20, `post-start` hooks |
| `.ddev/nginx/bedrock.conf` (if needed) | Create | U1 | Bedrock rewrite rules if DDEV default nginx doesn't route `web/` correctly |
| `composer.json` | Modify (Bedrock generates base) | U2: Bedrock+Deps | Add `repositories` (wpackagist + composer.elementor.com with `only`), `require` elementor/elementor-pro |
| `composer.lock` | Create | U2 | Committed — reproducible installs |
| `config/application.php` | Keep (Bedrock) | U2 | Bedrock's config loader; unchanged |
| `web/wp-config.php` | Keep (Bedrock) | U2 | Environment bootstrap; unchanged |
| `wp-cli.yml` | Keep (Bedrock) | U2 | `path: web/wp` — tells `ddev wp` where WP lives |
| `.env.example` | Modify | U3: Env | Extend Bedrock's template: DDEV DB defaults + `ELEMENTOR_PRO_LICENSE` + salts reference |
| `.gitignore` | Modify | U3 | Add `auth.json`, ensure `.env` ignored, `.env.example` tracked |
| `bin/setup-composer-auth.sh` | Create | U3 | Reads `.env`, runs `composer config --auth`; exits with message pointing to `ELEMENTOR_PRO_LICENSE` if absent |
| `.github/workflows/ci.yml` | Create | U4: CI | Composer validate + PHP lint; `COMPOSER_AUTH` secret for Pro |
| `README.md` | Modify | U4 | Update install steps to match final flow |

### composer.json key sections

```json
{
  "repositories": [
    { "type": "composer", "url": "https://wpackagist.org",
      "only": ["wpackagist-plugin/*", "wpackagist-theme/*"] },
    { "type": "composer", "url": "https://composer.elementor.com",
      "only": ["elementor/elementor-pro"] }
  ],
  "require": {
    "php": ">=8.3",
    "composer/installers": "^2.2",
    "vlucas/phpdotenv": "^5.5",
    "oscarotero/env": "^2.1",
    "roots/wordpress": "^6.7",
    "roots/bedrock-autoloader": "^1.0",
    "roots/bedrock-disallow-indexing": "^2.0",
    "wpackagist-plugin/elementor": "^3.27",
    "elementor/elementor-pro": "^3.27"
  },
  "extra": {
    "installer-paths": {
      "web/app/mu-plugins/{$name}/": ["type:wordpress-muplugin"],
      "web/app/plugins/{$name}/":    ["type:wordpress-plugin"],
      "web/app/themes/{$name}/":     ["type:wordpress-theme"]
    },
    "wordpress-install-dir": "web/wp"
  }
}
```

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Smoke (manual) | `ddev start` boots WP, `ddev describe` shows PHP 8.3 + MariaDB | Follow spec scenario: Fresh start |
| Integration | `composer install` resolves all deps incl. Elementor Pro with valid license | Run in DDEV with `ELEMENTOR_PRO_LICENSE` set |
| Integration | Missing license → clear error | Unset var, run `bin/setup-composer-auth.sh`, assert message |
| Integration | `ddev wp core install` creates site headless | WP-CLI with `--url`, `--title`, `--admin_user`, `--admin_password`, `--admin_email` |
| Smoke | Host tools: `respira --help`, `elementor-mcp-agent --help` | Run on host, not container |
| CI | Composer validate + PHP lint | GitHub Actions on push |

> No automated test runner exists yet (`openspec/config.yaml` confirms `strict_tdd: false`). All verification is smoke/integration manual or CI lint. PHPUnit + Playwright are a future change.

## Migration / Rollout

Greenfield project — no existing data to migrate. Rollback: `git checkout` prior commit + `ddev delete --snapshot`.

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| `composer.elementor.com` rate-limiting (HTTP 429) on repeated installs | Medium | Commit `composer.lock` so installs use cached dist archives, not repo metadata. Document in README. (Confirmed: real-world 429 lockouts reported.) |
| Elementor Pro auth format changes | Low | `bin/setup-composer-auth.sh` is the single integration point — update there only. |
| Bedrock scaffold overwrites existing files | Low | `composer create-project roots/bedrock .` refuses non-empty dirs; run before committing other files. |
| elementor-mcp-agent needs a companion WP plugin | Unknown | Open question below — defer to verify phase or future change. |

## Open Questions

- [ ] Does `elementor-mcp-agent` require a companion WordPress plugin for REST endpoints, or does it operate purely via WP-CLI? Needs verification against the agent's actual docs/package.
- [ ] Should `pro-elements` be included as `require-dev` (commented) or omitted entirely from the initial foundation? Affects license-free onboarding path.
- [ ] CI secret strategy: single `COMPOSER_AUTH` JSON secret vs. individual `ELEMENTOR_PRO_LICENSE` secret composed in workflow? Recommend individual + compose in CI for clarity.
