---
name: wp-multi-site
description: "Trigger: switch site, list sites, active site, cambiar de sitio, cambiar de cliente. Switch between configured WordPress sites in a multi-site agency workspace."
license: MIT
metadata:
  author: "gentle-orchestrator"
  version: "2.0"
---

## Activation Contract

Use this skill when the user wants to switch between client sites, list available sites, or check which site is active. This is the **site-switching** layer for the multi-site workspace.

## Site Configuration

Each client site has a YAML config file in `sites/<id>.yaml`:

```yaml
id: client-acme
name: ACME Corp Website
url: "https://acme.com"
username: "admin"
application_password: "..."
builder: elementor       # elementor | avada
theme: "Avada"
ssh:
  host: "acme.com"
  port: 22
  user: "deploy"
  path: "/var/www/html"
  wp: "wp"
```

## Commands (AI Convention)

The following are natural-language triggers interpreted by the AI:

| Command | What the AI does |
|---------|-----------------|
| "switch to `<site-id>`" | Reads `sites/<site-id>.yaml`, stores `ACTIVE_SITE` in session, confirms with site info |
| "show active site" | Reports current active site name, builder, and URL |
| "list sites" | Reads all `sites/*.yaml` files and displays a table of configured sites |
| "switch to local-ddev" | Switches to the local DDEV Elementor site |

## Builder Routing

Once a site is active, the AI routes all page-building work based on the `builder` field:

- **`builder: elementor`** — Use `elementor-mcp-agent` tools and `wp-elementor-page` skill
- **`builder: avada`** — Use WP-CLI + shortcodes and `wp-avada-page` skill

## CLI Script

For persistent switching across sessions, use `bin/switch-site.sh`:

```bash
./bin/switch-site.sh list              # List all sites
./bin/switch-site.sh status            # Show active site
./bin/switch-site.sh client-acme       # Switch to client
```

This writes a `.current-site` marker file that persists between AI sessions and sets `ACTIVE_SITE` env var.

## Output Contract

After a site switch, report:
- Which site is now active
- The builder type (Elementor or Avada)
- The site URL
- Confirmation that the previous site context is cleared
