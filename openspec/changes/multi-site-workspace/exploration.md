# Exploration: Multi-Site Agency Workspace

## Current State

The repository is a single-site, single-builder workspace focused on WordPress (Bedrock) + Elementor Pro running locally via DDEV. Key facts:

### Architecture
- **Site config**: Single hardcoded site in `opencode.json` (`MCP > elementor > environment > ELEMENTOR_MCP_SITES`), pointing to `http://wordpress-opencode.ddev.site`
- **Site secrets**: Also stored in `.opencode/elementor-sites.json` — already a JSON array format (multi-site ready), but only contains `local-ddev`
- **AGENTS.md**: Describes only Elementor + DDEV. No multi-site or multi-builder concepts
- **Skills folder**: 3 skills (`wp-ddev-workflow`, `wp-elementor-page`, `wp-deploy`) — all single-site/Elementor focused
- **OpenSpec**: 4 domain specs (local-dev-environment, cli-tooling, env-configuration, dependency-management), all describing a single-site setup
- **`.env.example`**: Single-site DB + WP_HOME config, no remote site concept
- **Composer**: Single-site Bedrock structure with `web/wp/` as WordPress core, `web/app/plugins/` for plugins
- **Gitignore**: Already excludes `opencode.json` (line 46) and `.opencode/elementor-sites.json` (line 45) — good for local site credentials

### Builder Support
- **Elementor**: `elementor-mcp-agent` (v1.3.0) installed as MCP server — already supports **multiple sites** natively via `ELEMENTOR_MCP_SITES` JSON array or `ELEMENTOR_MCP_CONFIG_PATH` file reference. The agent auto-detects sites and provides site-aware tools.
- **Avada/Fusion Builder**: NOT supported by `elementor-mcp-agent`. **Respira MCP also does NOT support Avada** (their 12 supported builders list excludes Avada/Fusion Builder). Avada stores page data as shortcodes in `post_content`, not as JSON meta like Elementor.

### DDEV Local Dev Environment
- WordPress lives inside DDEV (Bedrock pattern, docroot: `web/`)
- WP-CLI accessible as `ddev wp` for local operations
- For remote sites, WP-CLI would need SSH or REST API access
- `elementor-mcp-agent` already supports remote sites via URL + application_password (optional SSH for 8 additional tools)

## Affected Areas

| File / Directory | Why Affected |
|---|---|
| `opencode.json` | Single MCP entry for Elementor; needs multi-site config, possibly multiple MCP entries (one per builder type), or a dynamic generation mechanism |
| `.opencode/elementor-sites.json` | Already has multi-site array format — can extend to hold all Elementor site configs. However, Avada sites need a different approach since Avada data lives in `post_content`, not `_elementor_data` |
| `AGENTS.md` | Single-site Elementor description. Needs multi-site, multi-builder, site-switching documentation |
| `skills/wp-elementor-page/SKILL.md` | Hardcoded to local DDEV URL and `ddev wp` commands. Needs to work with remote Elementor sites too |
| `skills/wp-ddev-workflow/SKILL.md` | DDEV-specific. For remote sites, SSH-based WP-CLI is needed instead |
| `openspec/config.yaml` | Context describes an Elementor-only stack. Needs to include Avada and multi-site |
| `openspec/specs/*/spec.md` | All 4 domain specs describe a single-site Elementor setup, need multi-site expansion |
| `composer.json` | Single-site Bedrock structure. Multi-site config management needs a different approach (sites are remote, not all managed via Composer) |
| `.env.example` | Single-site DDEV config. Avada sites and remote Elementor sites don't use `.env` |
| `wp-cli.yml` | Points to `web/wp` (local DDEV). Remote Avada/Elementor sites need site-specific WP-CLI config or SSH-tunneled commands |

## Key Research Findings

### 1. Elementor-MCP-Agent Already Multi-Site Ready
`elementor-mcp-agent` (v1.3.0) natively supports multiple sites via:
- **Environment variable**: `ELEMENTOR_MCP_SITES` — JSON array of `{id, url, username, application_password, ssh?}` objects
- **Config file**: `ELEMENTOR_MCP_CONFIG_PATH` — path to JSON file with `{sites: [...]}`
- **Default site**: `ELEMENTOR_MCP_DEFAULT_SITE_ID` — if not set, tools that need a site prompt the AI

The `.opencode/elementor-sites.json` file already follows this schema. For the multi-site workspace, we simply need to add more site entries to this array.

### 2. Avada/Fusion Builder Data Architecture
Avada stores page data in WordPress **`post_content`** as nested shortcodes, NOT in `_elementor_data` post meta:

```
[fusion_builder_container hundred_percent="yes" min_height="" ...]
  [fusion_builder_row]
    [fusion_builder_column type="1_3" spacing="" ...]
      [fusion_text]
        <h2>Heading</h2>
        <p>Content here...</p>
      [/fusion_text]
      [fusion_button link="https://example.com" color="default" size="small" ...]Click[/fusion_button]
    [/fusion_builder_column]
    [fusion_builder_column type="2_3" ...]
      [fusion_title size="2" ...]Section Title[/fusion_title]
      [fusion_text]More content...[/fusion_text]
    [/fusion_builder_column]
  [/fusion_builder_row]
[/fusion_builder_container]
```

Key shortcodes:
- `[fusion_builder_container]` — Full-width section wrapper (was `[fullwidth]` — legacy)
- `[fusion_builder_row]` — Row inside container
- `[fusion_builder_column type="1_X"]` — Column with fractional width (1/1, 1/2, 1/3, 2/3, 1/4, 3/4, 1/5, 2/5, 3/5, 4/5, 1/6, 5/6)
- `[fusion_builder_column_inner]` — Nested column
- Content elements: `[fusion_text]`, `[fusion_title]`, `[fusion_button]`, `[fusion_image]`, `[fusion_separator]`, `[fusion_code]`, `[fusion_alert]`, `[fusion_pricing_table]`, etc.
- Layout helpers: `[fusion_tabs]` / `[fusion_tab]`, `[fusion_accordian]` / `[fusion_toggle]`

### 3. No Existing MCP for Avada
- **elementor-mcp-agent**: Elementor-only
- **Respira MCP**: Does NOT support Avada (builders list: Elementor, Divi, Bricks, Gutenberg, Oxygen, WPBakery, Beaver, Brizy, Breakdance, Thrive, Flatsome, Visual Composer)
- **wp-cli-mcp**: Generic WP-CLI MCP (45+ tools) — could work for both builders but has no element-level awareness
- **Conclusion**: Avada interactions must be handled via raw WP-CLI (`ddev wp` for local, SSH WP-CLI or REST API for remote) with custom post_content shortcode generation

### 4. Site Switching Approaches

| Approach | Pros | Cons |
|---|---|---|
| **A: Single opencode.json, all sites in MCP config** | elementor-mcp-agent already supports it. Avada handled via `wp-cli-mcp` or script. One config file | opencode.json must be local (gitignored). Need a way for AI to know which site is "active" |
| **B: Dynamic opencode.json generation** | Script generates opencode.json per active site. Clean separation | Requires regeneration on every switch. Extra tooling |
| **C: Env var toggle + AGENTS.md convention** | User tells AI "switch to client-x". AI reads site config and adjusts behavior. No MCP config changes | Manual. AI needs to know which site config file to read. Prone to confusion |
| **D: Separate MCP entries per site** | Each site gets its own MCP server entry. Clear separation | Bloats opencode.json. elementor-mcp-agent doesn't need this (it's multi-site natively) |

### 5. Proposed Site Config Schema
Each site needs:
```yaml
id: client-acme            # unique identifier
name: ACME Corp Website    # human-readable name
url: "https://acme.com"    # WordPress URL
username: "admin"          # WordPress username
application_password: "..."  # Application Password (REST API auth)
builder: elementor         # elementor | avada
theme: "Avada"             # active theme (for reference)
ssh:                       # optional — for WP-CLI access
  host: "acme.com"
  user: "deploy"
  path: "/var/www/html"
  wp_cli_path: "wp"
```

## Approaches

### Approach A: Unified Multi-Site Config + Builder-Aware Skills (Recommended)

**Core idea**: Extend the existing structure with a `sites/` directory for per-site config files, keep `elementor-mcp-agent` as the single MCP server for all Elementor sites (already multi-site capable), and add a new `avada-mcp-agent` or handle Avada via WP-CLI with shortcode generation. Skills become builder-aware and accept a `site_id` parameter.

**Structure**:
```
sites/
├── _template.yaml         # Site config template
├── local-ddev.yaml        # Existing local DDEV site
├── client-acme.yaml       # Elementor client site
└── client-beta.yaml       # Avada client site
```

**MCP Servers**:
1. `elementor-mcp-agent` — Configured with ALL Elementor sites via `ELEMENTOR_MCP_SITES`
2. `wp-cli-mcp` (or custom `avada-mcp-agent`) — For Avada site interactions
3. Optional: Respira MCP — For builders they support

**Site switching**: The AI reads the active site's config file from context. A `bin/switch-site.sh` script sets an `ACTIVE_SITE` env var and updates a `CURRENT_SITE` file. Skills read this file to know which site to operate on.

**Pros**:
- elementor-mcp-agent already supports multi-site natively
- Clear separation of concerns (sites/ for config, skills/ for behavior)
- Works with both local DDEV and remote sites
- Gitignored secrets stay safe
- Future-proof for additional builders

**Cons**:
- Avada has no MCP agent — requires building a custom solution or using raw WP-CLI
- Site switching is semi-manual (AI-assisted, not fully automated)
- More complex than single-site setup

**Effort**: High (structural change + Avada tooling)

### Approach B: Branch-Per-Client

**Core idea**: Each client site lives on its own git branch. `main` has shared skills and templates. Branch-specific `opencode.json`, `AGENTS.md`, `sites/` config.

**Pros**:
- Cleanest separation between clients
- Each branch is a self-contained workspace
- No secrets cross-contamination

**Cons**:
- Horrible for shared skill evolution (merging changes across branches)
- Branch switching ≠ site switching (git checkout for every site change)
- Multiple clients in one session impossible
- Conflicts when updating shared skills

**Effort**: Low per-branch, High maintenance

**Rejected** — violates the "one repository, many sites" requirement.

### Approach C: Unified Config + File-Based Site Routing

**Core idea**: Single `opencode.json` with one MCP entry per site AND per builder type. A `sites/` directory with YAML configs. AI reads `CURRENT_SITE` marker file to know which client is active. No dynamic config generation.

**openocode.json** approach:
```json
{
  "mcp": {
    "elementor-sites": {
      "type": "local",
      "command": ["elementor-mcp-agent"],
      "env": {
        "ELEMENTOR_MCP_CONFIG_PATH": "/path/to/elementor-sites.json"
      }
    },
    "avada-sites": {
      "type": "local",
      "command": ["wp-cli-mcp"],
      "env": {
        "WP_CLI_MCP_CONFIG_PATH": "/path/to/avada-sites.json"
      }
    }
  }
}
```

**Pros**:
- No dynamic config generation needed
- elementor-mcp-agent tools always available for all Elementor sites
- Simpler mental model

**Cons**:
- Both MCP servers always running (resource usage)
- AI needs to know which builder tools to call per site
- Avada still needs WP-CLI or custom agent

**Effort**: Medium

## Recommendation

**Adopt Approach A (Unified Multi-Site Config + Builder-Aware Skills)** as the primary architecture, with these specifics:

1. **Sites config directory**: `sites/*.yaml` — one file per client site, gitignored by default with `sites/*.yaml` pattern, allow `sites/_template.yaml` as committed template
2. **Elementor sites**: Extend `.opencode/elementor-sites.json` with all Elementor client sites (already multi-site format). `elementor-mcp-agent` handles all Elementor operations natively.
3. **Avada sites**: Build a **custom Avada page building workflow via WP-CLI + shortcode templates** since no existing MCP agent supports Avada. Create `skills/wp-avada-page/SKILL.md` with shortcode generation patterns and WP-CLI injection commands.
4. **Site switching**: Simple convention + helper script. User tells the AI "switch to client-acme" → AI reads `sites/client-acme.yaml` → sets ACTIVE_SITE context. Skills check `ACTIVE_SITE` to determine which WP URL/credentials to use.
5. **AGENTS.md**: Rewrite to document multi-site stack, site config format, site-switching commands
6. **New skills created**: `wp-avada-page`, `wp-multi-site`

## Risks

1. **No Avada MCP agent exists** — We'll need to build Avada interactions from scratch using WP-CLI + shortcode generation. This is more limited than Elementor's JSON manipulation since it requires correct shortcode syntax at all times.
2. **Shortcode complexity** — Avada's shortcode system has hundreds of parameters per element. A reference guide will be needed for the AI to generate correct shortcodes.
3. **Shortcode validation** — Unlike Elementor's JSON which validates on CSS flush, Avada shortcodes either render or produce "not parsable" errors. No intermediate validation exists.
4. **Secrets management** — Application passwords for multiple client sites in one unencrypted file is a risk. Consider using a password manager or encrypted config file.
5. **openocode.json excluded from git** — Since it's gitignored, restoring the development environment requires remembering to configure it. Should document setup steps.
6. **elementor-mcp-agent outputSchema bug** — The existing bug (patched in `dist/server.js`) means updates to elementor-mcp-agent may reset the fix. Need to document and re-apply on updates.

## Ready for Proposal

Yes — exploration is complete. The proposal should define the multi-site config schema, site switching mechanism, builder-specific interaction methods, and new skills needed.

## Next Steps

1. **sdd-propose**: Define scope, approach, config schema, and rollback plan
2. Key architectural decisions to make in proposal:
   - Exact site config file format (YAML vs JSON)
   - MCP server layout (one elementor-mcp-agent for all Elementor sites vs. one per site)
   - Avada interaction method (custom MCP agent vs. WP-CLI-only)
   - Site switching mechanism (env var vs. config file vs. convention)
   - Credential storage strategy
