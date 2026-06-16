# Proposal: WordPress Foundation Stack

## Intent

Set up the complete open-source infrastructure for creating and managing WordPress sites with Elementor Pro — CLI-driven, no GUI admin. This is the root change everything builds on.

## Scope

### In Scope
- DDEV config (PHP 8.3, MariaDB, Node.js 20+, committable)
- Bedrock + Composer for dependency management (WordPress, plugins, mu-plugins)
- CLI tooling: WP-CLI, Respira CLI, elementor-mcp-agent
- `.env` template (gitignored) + `.env.example` committed
- Project-specific OpenCode skills for DDEV, WP-CLI, Elementor
- GitHub Actions CI/CD stub (Composer validate + PHP lint)
- Final directory layout

### Out of Scope
- Theme development (Sage or custom)
- Content creation (pages, templates)
- Production deployment (Trellis) — future change
- Testing infrastructure (PHPUnit, Playwright) — future change

## Capabilities

### New Capabilities
- `local-dev-environment`: DDEV-based reproducible WordPress dev environment
- `dependency-management`: Bedrock + Composer for WordPress core and plugins
- `cli-tooling`: WP-CLI, Respira CLI, elementor-mcp-agent install and shell integration
- `env-configuration`: .env with DB creds, WP salts, Elementor license key

### Modified Capabilities

None

## Approach

1. `ddev config` — PHP 8.3, MariaDB 10.11, Node.js 20, nginx-fpm
2. `composer create-project roots/bedrock` — scaffold web root
3. Add Elementor Pro + Elementor Pro Elements + wp-cli to `composer.json` (repo auth via env)
4. Create `.env.example` — DB, WP salts, Elementor license, auth keys
5. Install Respira CLI + elementor-mcp-agent globally via npm/npx
6. Create `.opencode/skills/` — skills for DDEV, WP-CLI, Elementor page ops
7. Add `.github/workflows/ci.yml` — Composer validate + PHP lint
8. DDEV `config.hooks` — auto `composer install` on start

Decision: **Bedrock over vanilla** — cleaner structure, Composer-native, built-in .env, beginner-friendly with `wp home` CLI.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `.ddev/config.yaml` | New | DDEV project config, PHP 8.3, MariaDB |
| `web/` | New | Bedrock web root (wp/wp-content) |
| `composer.json` | New | Core + plugins + mu-plugins |
| `.env.example` | New | Environment template (committed) |
| `.github/workflows/` | New | CI stub workflow |
| `.opencode/skills/` | New | Project-level LLM skills |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Elementor Pro license in env leaks | Med | `.gitignore` enforced; git hooks check |
| Bedrock unfamiliar to beginner | Low | DDEV auto-runs Composer; README CLI cookbook |
| DDEV port conflict | Low | DDEV auto-detects; override via config |

## Rollback Plan

- `ddev delete --snapshot` + `git checkout` prior commit → full revert
- Composer failure: `composer.lock` in git, `git checkout -- composer.lock` + reinstall
- Worst case: `git revert` + `ddev restart`

## Dependencies

- DDEV ≥ 1.22, Docker Desktop
- Composer 2.x, Node.js 20+
- Elementor Pro license (env var)

## Success Criteria

- [ ] `ddev start` boots WordPress reachable at `*.ddev.site`
- [ ] `composer install` resolves all deps including Elementor Pro
- [ ] `ddev wp core install --url=...` creates site without GUI
- [ ] `respira --help` and `elementor-mcp-agent --help` respond
- [ ] CI workflow passes on push (Composer validate + PHP lint)
