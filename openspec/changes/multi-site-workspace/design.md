# Design: Multi-Site Agency Workspace

## Technical Approach

Unified `sites/*.yaml` config directory with per-site credentials and builder metadata. Single `elementor-mcp-agent` MCP server handles all Elementor sites (natively multi-site via `ELEMENTOR_MCP_SITES` array). Avada sites require custom WP-CLI shortcode injection into `post_content`. Site switching via AI convention: "switch to `<site>`" → AI reads YAML → sets active context in session memory.

## Architecture Decisions

### Decision 1: Site Config Format

| Option | Tradeoff | Decision |
|--------|----------|----------|
| YAML | Readable, supports comments, native in OpenCode | **Adopted** |
| JSON | elementor-mcp-agent uses JSON, but YAML is more human-friendly | Rejected |

**Rationale**: YAML allows inline comments (e.g., `# Elementor Pro license: xyz`), native YAML support exists in the stack, and the conversion to JSON for elementor-mcp-agent is trivial.

### Decision 2: MCP Server Layout

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Single elementor-mcp-agent for all Elementor sites | elementor-mcp-agent natively supports multi-site array | **Adopted** |
| One elementor-mcp-agent per site | Bloated config, no benefit | Rejected |
| wp-cli-mcp for Avada | Generic, no Avada awareness, but avoids building custom MCP | **Adopted as bridge** |

**Rationale**: elementor-mcp-agent v1.3.0 already handles the multi-site array natively. Avada gets WP-CLI via SSH until a dedicated Avada MCP server emerges. No second MCP server needed for Avada (WP-CLI commands are called via bash/task delegation, not MCP).

### Decision 3: Site Switching Mechanism

| Option | Tradeoff | Decision |
|--------|----------|----------|
| ACTIVE_SITE marker file | File read each operation, race conditions | Rejected |
| Env var (ACTIVE_SITE) | Set per session, persists in process | **Adopted** |
| Convention-only | AI remembers from context lowest overhead | **Adopted alongside** |

**Rationale**: Dual approach — env var `ACTIVE_SITE` for explicit sessions, fallback to AI convention ("switch to X"). Skills read the env var; if absent, the user tells the AI which site.

### Decision 4: Avada Page Creation Method

| Option | Tradeoff | Decision |
|--------|----------|----------|
| Custom MCP agent | 100% custom code, maintenance burden | Rejected |
| Respira MCP | Does NOT support Avada | Rejected |
| WP-CLI + shortcode templates | No intermediate validation, but works directly | **Adopted** |

**Rationale**: Avada stores pages as shortcodes in `post_content` — simpler than Elementor's JSON meta. WP-CLI `wp post create --post_content='...'` is the most direct path. The `wp-avada-page` skill will curate a subset of common shortcodes with their parameters.

### Decision 5: Avada Site Access

| Option | Tradeoff | Decision |
|--------|----------|----------|
| SSH + remote WP-CLI | Full control, reliable, `wp post update` over SSH | **Adopted** |
| REST API + Application Password | No SSH needed, but shortcodes via REST are limited | Rejected |

**Rationale**: Avada shortcode injection needs to write `post_content` directly. WP-CLI over SSH is the most reliable path. The site config schema includes optional SSH fields.

## Data Flow

### Elementor Site Workflow

```
User: "switch to client-acme"
  → AI reads sites/client-acme.yaml (builder: elementor)
  → AI sets ACTIVE_SITE=client-acme
  → AI calls elementor-mcp-agent tools (native multi-site)
  → elementor-mcp-agent reads ELEMENTOR_MCP_SITES, matches site_id
  → Tools execute against that site's URL/credentials
```

### Avada Site Workflow

```
User: "create a homepage for client-beta"
  → AI reads sites/client-beta.yaml (builder: avada, ssh: {...})
  → AI loads wp-avada-page skill (shortcode patterns)
  → AI constructs shortcode content from page structure template
  → AI executes via SSH: wp post create --post_type=page \
      --post_title="Home" --post_content='[fusion_builder_container...]'
  → Verifies: wp post list --post_type=page --format=json
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `sites/_template.yaml` | Create | Committed site config template |
| `sites/*.yaml` | Create | Gitignored per-client configs |
| `skills/wp-avada-page/SKILL.md` | Create | Avada shortcode generation patterns + WP-CLI injection |
| `skills/wp-multi-site/SKILL.md` | Create | Site-switching conventions, commands, and workflow |
| `skills/wp-elementor-page/SKILL.md` | Modify | Add `site_id` parameter, support remote sites |
| `skills/wp-ddev-workflow/SKILL.md` | Modify | Add remote WP-CLI via SSH pattern |
| `AGENTS.md` | Rewrite | Multi-site, multi-builder (Elementor + Avada), site-switching commands |
| `opencode.json` | Modify | Extend `ELEMENTOR_MCP_SITES` array with client sites. Keep single MCP entry. |
| `.opencode/elementor-sites.json` | Modify | Add all Elementor client sites to the array |
| `.gitignore` | Modify | Add `sites/*.yaml` exclude pattern, allow `sites/_template.yaml` |
| `.env.example` | Modify | Add Avada registration note, remote site guidance |
| `wp-cli.yml` | Modify | Document remote WP-CLI via `--ssh` flag |
| `README.md` | Modify | Multi-site setup instructions |

## Site Config Schema (`sites/_template.yaml`)

```yaml
# Site configuration template
# Copy to sites/<client-id>.yaml and fill in credentials.
# This file is gitignored via sites/*.yaml in .gitignore.

id: client-id                 # Unique site identifier (kebab-case)
name: Client Name             # Human-readable name
url: "https://example.com"    # WordPress site URL
username: "admin"             # WordPress username
application_password: "..."   # Application Password (from Users → Profile)
builder: elementor            # Page builder: elementor or avada
theme: "Avada"                # Active theme (for reference, informational only)

# SSH access (REQUIRED for Avada sites, optional for Elementor)
ssh:
  host: "example.com"         # SSH host
  port: 22                    # SSH port (default: 22)
  user: "deploy"              # SSH user
  path: "/var/www/html"       # WordPress installation path on server
  wp: "wp"                    # WP-CLI binary (default: "wp")
```

## Avada Shortcode Architecture

### Container → Row → Column → Elements

```
[fusion_builder_container type="flex" hundred_percent="no" equal_height_columns="no" ...]
  [fusion_builder_row]
    [fusion_builder_column type="1_1" layout="1_1" spacing="" ...]
      [fusion_title size="2" content_align="left"]Heading[/fusion_title]
      [fusion_text]
        <p>Content paragraphs here.</p>
      [/fusion_text]
      [fusion_button link="https://..." color="default" size="medium" ...]Click[/fusion_button]
    [/fusion_builder_column]
    [fusion_builder_column type="1_2" layout="1_2" ...]...[/fusion_builder_column]
    [fusion_builder_column type="1_2" layout="1_2" ...]...[/fusion_builder_column]
  [/fusion_builder_row]
[/fusion_builder_container]
```

### Common Shortcode Reference (Core Subset)

| Element | Shortcode | Key Params |
|---------|-----------|------------|
| Container | `[fusion_builder_container]` | `type="flex\|legacy"`, `hundred_percent="yes\|no"`, `background_color`, `background_image` |
| Row | `[fusion_builder_row]` | (typically no params) |
| Column | `[fusion_builder_column]` | `type="1_1\|1_2\|1_3\|2_3\|1_4\|3_4\|1_5\|2_5\|3_5\|4_5\|1_6\|5_6"`, `spacing`, `align_self` |
| Heading | `[fusion_title]` | `size="1\|2\|3\|4\|5\|6"`, `content_align="left\|center\|right"`, `font_size`, `margin_top` |
| Text | `[fusion_text]` | Wraps HTML content |
| Button | `[fusion_button]` | `link`, `color="default\|green\|red\|blue\|orange"`, `size="small\|medium\|large\|xlarge"`, `target="_self\|_blank"` |
| Image | `[fusion_image]` | `image_id` (WP media library ID), `max_width`, `align` |
| Separator | `[fusion_separator]` | `style="none\|single\|double\|dashed\|dotted"`, `top_margin`, `bottom_margin` |
| Code | `[fusion_code]` | Wraps raw HTML/CSS/JS |

### Page Creation Command

```bash
# Local Avada site via DDEV
ddev wp post create \
  --post_type=page \
  --post_title='Home' \
  --post_status=publish \
  --post_content='[fusion_builder_container type="flex" hundred_percent="no"][fusion_builder_row][fusion_builder_column type="1_1" layout="1_1"][fusion_title size="2" content_align="left"]Welcome[/fusion_title][fusion_text]<p>Content</p>[/fusion_text][/fusion_builder_column][/fusion_builder_row][/fusion_builder_container]'

# Remote Avada site via SSH
ssh user@host "wp post create \
  --path=/var/www/html \
  --post_type=page \
  --post_title='Home' \
  --post_status=publish \
  --post_content='[fusion_builder_container...]'"
```

## Site Switching Convention

### Commands (via AI interpretation)

- `"switch to <site-id>"` → AI reads `sites/<site-id>.yaml`, sets `ACTIVE_SITE=<site-id>` in session memory, confirms with: "Active site: <name> (builder: <elementor|avada>)"
- `"show active site"` → AI reports current site info
- `"list sites"` → AI reads `sites/*.yaml` and lists all configured sites

### Skill Awareness

Skills check the active site's `builder` field to determine which tools to use:
- `builder: elementor` → Use `elementor-mcp-agent` tools (for Elementor sites)
- `builder: avada` → Use WP-CLI + shortcodes via SSH (for Avada sites)

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Config | Site YAML parses correctly | Manual validation |
| Workflow | Site switch reads correct config | Manual: "switch to X" → verify output |
| Avada | Shortcode page creates in local DDEV | `ddev wp post create` with Avada theme active |
| Elementor | elementor-mcp-agent works with multi-site array | Manual: add second site entry, call list tools |

## Migration / Rollout

1. Phase 1: Create `sites/` directory + `_template.yaml`
2. Phase 2: Create `wp-avada-page` and `wp-multi-site` skills
3. Phase 3: Modify existing skills for site-awareness
4. Phase 4: Rewrite `AGENTS.md`
5. Phase 5: Update config files (opencode.json, .gitignore, .env.example)
6. Phase 6: Add first real client site config

No database migration required. No data transformation needed.

## Open Questions

- [ ] Avada shortcode parameter depth — the curated subset covers ~80% of cases. Need a plan for handling unsupported shortcode requests.
- [ ] elementor-mcp-agent's `outputSchema` patch — confirm it survives npm update with current version's patching strategy.
