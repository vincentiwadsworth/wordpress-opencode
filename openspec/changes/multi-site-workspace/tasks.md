# Tasks: Multi-Site Agency Workspace

## Review Workload Forecast

Decision needed before apply: No
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: Medium

| Field | Value |
|-------|-------|
| Estimated changed lines | 450–650 |
| 400-line budget risk | Medium |
| Chained PRs recommended | Yes |
| Suggested split | PR 1 (Foundation + Skills) → PR 2 (Docs + Config) |
| Delivery strategy | auto-forecast |
| Chain strategy | stacked-to-main |

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Foundation (sites/, skills, gitignore) | PR 1 | Main branch. `_template.yaml`, `wp-multi-site`, `wp-avada-page`, modified existing skills |
| 2 | Config + Docs (AGENTS.md, opencode.json, env) | PR 2 | Depends on PR 1. Final wiring and documentation |

## Phase 1: Foundation ✅

- [x] 1.1 Create `sites/` directory and `sites/_template.yaml` with site config schema (id, name, url, username, application_password, builder, theme, ssh)
- [x] 1.2 Update `.gitignore` — add `sites/*.yaml` exclude, allow `sites/_template.yaml` via negation pattern `!sites/_template.yaml`
- [x] 1.3 Create `skills/wp-multi-site/SKILL.md` — site-switching conventions, "switch to <id>" command, "list sites", "show active site"
- [x] 1.4 Create `skills/wp-avada-page/SKILL.md` — Avada shortcode reference (container→row→column→elements), WP-CLI injection for local (`ddev wp`) and remote (SSH), common patterns (title, text, button, image, separator, columns)
- [x] 1.5 Modify `skills/wp-elementor-page/SKILL.md` — add `site_id` parameter support, document remote site workflow (not just local DDEV)
- [x] 1.6 Modify `skills/wp-ddev-workflow/SKILL.md` — add remote WP-CLI via SSH pattern using `wp --ssh` flag, document that DDEV is for local dev only

## Phase 2: Config + Documentation ✅

- [x] 2.1 Rewrite `AGENTS.md` — multi-site, multi-builder stack (Elementor + Avada), site-switching commands (switch to / list sites / show active site), updated table with Avada skill row
- [x] 2.2 Extend `.opencode/elementor-sites.json` — clean JSON format; added `.opencode/elementor-sites.template.json` as example
- [x] 2.3 Update `opencode.json` — use `ELEMENTOR_MCP_CONFIG_PATH` instead of inline `ELEMENTOR_MCP_SITES`
- [x] 2.4 Update `wp-cli.yml` — document `--ssh` flag usage for remote WP-CLI
- [x] 2.5 Update `.env.example` — add note about Avada registration, remote site credential guidance
- [x] 2.6 Update `openspec/config.yaml` context — add Avada to stack description, update for multi-site
- [x] 2.7 Update `README.md` — multi-site workspace description, Avada support, updated project layout
