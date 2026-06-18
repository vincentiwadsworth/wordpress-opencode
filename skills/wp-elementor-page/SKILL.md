---
name: wp-elementor-page
description: "Trigger: crear página, landing page, Elementor layout, maquetar, página con Elementor, design tokens, inyectar Elementor data, _elementor_data. Build WordPress pages using Elementor via WP-CLI _elementor_data injection."
license: MIT
metadata:
  author: "vincentiwadsworth"
  version: "2.0"
---

## Activation Contract

Use this skill when building or modifying Elementor pages. The **primary method** is injecting `_elementor_data` via WP-CLI (`ddev wp post meta update`). Respira CLI is NOT connected and elementor-mcp-agent has outputSchema bugs with OpenCode — do not rely on them.

## Hard Rules

- **Always create pages with `_elementor_edit_mode=builder`** so Elementor recognizes them.
- **Write Elementor JSON to a temp file first**, then inject via `ddev wp post meta update <id> _elementor_data "$(cat /tmp/file.json)"`. Do NOT inline massive JSON in shell commands — escaping will break.
- Pages are draft (`post_status: draft`) until validation passes, then publish.
- After any `_elementor_data` write, run `ddev wp elementor flush-css` to regenerate CSS.
- Never delete posts or media without explicit user approval.
- Elementor Pro features (theme builder, popups, dynamic tags) only work if `elementor-pro` plugin is active.

## Known Tooling Issues

| Tool | Issue | Status |
|------|-------|--------|
| Respira CLI 0.1.4 | Not connected to site. Plugin `inhale-mcp-abilities` ≠ Respira for WordPress plugin. Needs different plugin + API key from wp-admin. | Not working |
| elementor-mcp-agent 1.3.0 | outputSchema bug: tools declare outputSchema but errors get caught by OpenCode as "has an output schema but did not return structured content". Also `pages.map is not a function` on empty results. npm only has v1.3.0. | Partially broken |
| WP-CLI `_elementor_data` injection | Works. Group_Control_Background (e.g., button bg color) doesn't generate CSS from programmatic data. Workaround: inject HTML `<style>` widget targeting button element IDs. | Primary method |

## Decision Gates

| Trigger | Action |
|---------|--------|
| Build new Elementor page | Create via WP-CLI + inject `_elementor_data` JSON (see Execution Steps) |
| Read existing page structure | `ddev wp post meta get <id> _elementor_data` or REST API: `curl -u admin:APP_PASS http://wordpress-opencode.ddev.site/wp-json/wp/v2/pages/<id>` |
| Edit existing Elementor page | Read current data → modify JSON → write back → flush CSS |
| Bulk find/replace text across pages | `ddev wp search-replace` with `--dry-run` first |
| User wants to use Elementor visual editor | Direct them to wp-admin → Pages → Edit with Elementor |
| MCP tools available and working | Use elementor-mcp-agent tools as secondary option, not primary |

## Execution Steps

1. Verify DDEV is running: `ddev describe` — web service must show "OK".
2. Verify REST API works: `curl -sL -u "admin:APP_PASS" "http://wordpress-opencode.ddev.site/wp-json/wp/v2/pages/"` must return JSON.
3. Create page: `ddev wp post create --post_type=page --post_title="Title" --post_name="slug" --post_status=draft --porcelain` → get ID.
4. Set Elementor meta:
   ```bash
   ddev wp post meta update <ID> _elementor_edit_mode builder
   ddev wp post meta update <ID> _elementor_template_type wp-page
   ```
5. Build Elementor JSON structure (see Elementor JSON Reference below).
6. Write JSON to temp file, then inject:
   ```bash
   ddev wp post meta update <ID> _elementor_data "$(cat /tmp/page-data.json)"
   ddev wp elementor flush-css
   ```
7. Publish: `ddev wp post update <ID> --post_status=publish`.
8. Verify: open URL in browser, check layout renders correctly.

## Elementor JSON Reference

`_elementor_data` is a JSON array of top-level elements. Each element:

```jsonc
{
  "id": "unique-hex-string",  // required, any unique string
  "elType": "container",       // "container" for layout, "widget" for content
  "settings": {},              // Elementor settings (see below)
  "elements": []               // child elements (containers or widgets)
}
```

Container settings:
```jsonc
// Background color
{"background_background": "classic", "background_color": "#0f172a"}
// Padding (px)
{"padding": {"unit": "px", "top": "80", "right": "0", "bottom": "80", "left": "0", "isLinked": false}}
// Flex layout + width
{"flex_direction": "column", "align_items": "center", "content_width": "1000"}
// 3-column flex
{"flex_direction": "row", "flex_gap": {"unit": "px", "size": "20"}, "content_width": "1200"}
// Border + radius
{"border_border": "solid", "border_width": {"unit": "px", "size": "1"}, "border_color": "#e2e8f0", "border_radius": {"unit": "px", "size": "12"}}
```

Widget settings:
```jsonc
// Heading
{"title": "My Title", "title_color": "#1a1a2e", "typography_font_size": {"unit": "px", "size": 42}, "typography_font_weight": "800", "text_alignment": "center", "_element_id": "unique"}
// Text editor
{"editor": "<p>Content here</p>", "text_color": "#666666", "typography_font_size": {"unit": "px", "size": 18}, "text_alignment": "center"}
// Button
{"text": "Click me", "link": {"url": "/page/", "is_external": ""}, "button_text_color": "#ffffff", "border_radius": {"unit": "px", "size": 8}, "size": "lg", "text_padding": {"unit": "px", "top": "15", "right": "30", "bottom": "15", "left": "30", "isLinked": false}, "_element_id": "unique"}
// HTML (for workaround styles)
{"html": "<style>#unique-id .elementor-button { background-color: #3b82f6 !important; }</style>"}
// Spacer
{"spacer": {"unit": "px", "size": "40", "sizes": []}}
// Divider
{"divider_type": "solid", "divider_weight": {"unit": "px", "size": "1"}, "divider_color": "#e2e8f0"}
```

**Button background workaround**: Group_Control_Background doesn't generate CSS from programmatic data. Use an HTML widget with `<style>` targeting the button's `_element_id`.

## Output Contract

Return:
- Page ID, URL, slug, and post status.
- Number of containers and widgets created.
- Any workarounds applied (e.g., button bg style injection).
- CSS flush confirmation.

## Multi-Site Awareness

This skill is part of a **multi-site agency workspace**. When working on a remote Elementor site (not local DDEV):

1. The site config is in `sites/<id>.yaml` — includes URL, credentials, builder type
2. Elementor sites use `elementor-mcp-agent` which natively supports multiple sites via `ELEMENTOR_MCP_SITES` array in `.opencode/elementor-sites.json`
3. `elementor-mcp-agent` tools accept a `site_id` parameter — use the site ID from the config
4. For the local DDEV site, the existing `ddev wp` commands continue to work

### Site Switching

- Use the `wp-multi-site` skill to switch between sites
- "switch to <site-id>" → AI reads site config and uses the correct credentials
- Active site context is maintained in session memory

## References

- `AGENTS.md` — project stack, commands, conventions, gotchas.
- `sites/_template.yaml` — site config schema.
- `wp-multi-site` skill — site switching conventions.
- Elementor 3.35.9 container documentation: https://developers.elementor.com/docs/elements/
