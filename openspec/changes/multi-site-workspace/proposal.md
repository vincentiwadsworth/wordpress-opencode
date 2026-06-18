# Proposal: Multi-Site Agency Workspace

## Intent

Transform the single-site Elementor repository into a unified agency workspace supporting multiple client sites built with Elementor or Avada (Fusion Builder). Eliminate the one-repo-per-site limitation by introducing site-agnostic tooling, a shared `sites/` config directory, and builder-aware skills.

## Scope

### In Scope
- `sites/` YAML config directory with per-site schema (id, url, builder, credentials)
- Multi-site `elementor-mcp-agent` config for all Elementor sites
- Avada page-building workflow via WP-CLI + shortcode templates
- `skills/wp-avada-page/SKILL.md` — Avada shortcode generation + WP-CLI injection
- `skills/wp-multi-site/SKILL.md` — site switching conventions
- `AGENTS.md` rewrite for multi-site, multi-builder context
- `.env.example` and `wp-cli.yml` updates for remote site patterns

### Out of Scope
- Dedicated Avada MCP agent (none exists — WP-CLI + shortcodes is the path)
- Dynamic `opencode.json` generation (rejected in exploration)
- Branch-per-client workflow (rejected — maintenance cost too high)
- Automated credential encryption (deferred — gitignore convention)
- Cross-builder page migration

## Capabilities

### New Capabilities
- `site-configuration`: Per-site YAML configs, `sites/` directory with `_template.yaml`, switching convention
- `avada-page-building`: WP-CLI post_content shortcode injection for Avada pages
- `multi-site-orchestration`: Active site tracking, builder-aware skill routing

### Modified Capabilities
- `cli-tooling`: Add Avada WP-CLI commands, remote-site WP-CLI via SSH, site-aware dispatch
- `local-dev-environment`: Document remote site patterns alongside DDEV workflow
- `env-configuration`: Add per-site credential storage guidance

## Approach

Unified `sites/*.yaml` directory (gitignored, `_template.yaml` committed). Single `elementor-mcp-agent` MCP server with `ELEMENTOR_MCP_SITES` JSON array for all Elementor sites (natively supported). Avada via custom WP-CLI commands writing `post_content` shortcodes. Site switching via convention: "switch to <site>" → AI reads YAML → sets active context.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `sites/` | New | Per-site YAML configs, `_template.yaml` committed |
| `opencode.json` | Modified | Multi-site `ELEMENTOR_MCP_SITES` array |
| `.opencode/elementor-sites.json` | Modified | Extended with client Elementor sites |
| `AGENTS.md` | Rewritten | Multi-site, multi-builder docs |
| `skills/wp-elementor-page/SKILL.md` | Modified | Site-aware (`site_id` param) |
| `skills/wp-ddev-workflow/SKILL.md` | Modified | Remote WP-CLI via SSH pattern |
| `skills/wp-avada-page/` | New | Avada shortcode generation |
| `skills/wp-multi-site/` | New | Site-switching conventions |
| `openspec/specs/cli-tooling/spec.md` | Modified | Multi-builder CLI requirements |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| No Avada MCP — limited to WP-CLI + shortcodes | High | Curated shortcode reference in skill |
| Shortcode complexity (hundreds of params) | High | Limit to common patterns initially |
| Credential sprawl across clients | Medium | Gitignore `sites/*.yaml`, template only |
| elementor-mcp-agent outputSchema bug | Medium | Document patch in AGENTS.md gotchas |

## Rollback Plan

1. Revert `opencode.json` to single-site Elementor config
2. Remove `sites/` directory (local copy, gitignored)
3. Revert `AGENTS.md`, `wp-cli.yml`, `.env.example`
4. Remove new skills (`wp-avada-page`, `wp-multi-site`)
5. Revert modified skills (`wp-elementor-page`, `wp-ddev-workflow`)

## Dependencies

- elementor-mcp-agent v1.3.0 (already installed, multi-site capable)
- WP-CLI 2.12.0 (via `ddev wp` local, SSH for remote)
- Composer (existing, site-specific plugin management)

## Success Criteria

- [ ] `sites/_template.yaml` committed, all client configs gitignored
- [ ] `elementor-mcp-agent` tools work against any configured Elementor site
- [ ] Avada page generated via WP-CLI shortcode injection renders correctly
- [ ] `AGENTS.md` documents site-switching convention
- [ ] `skills/wp-avada-page/SKILL.md` produces valid shortcode-based pages
- [ ] Site switch works: "switch to client-x" → AI loads correct config
