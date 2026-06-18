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

## Page Templates

Use these templates for common page types. Each template is `_elementor_data` JSON ready to inject. Randomize element IDs on each use (6-char hex).

### Template: Hero + Features + CTA (Landing)

```jsonc
[
  // HERO SECTION — dark background, full-width
  {
    "id": "a1b2c3",
    "elType": "container",
    "settings": {
      "flex_direction": "column", "align_items": "center", "justify_content": "center",
      "background_background": "classic", "background_color": "#0F172A",
      "padding": {"unit": "px", "top": "120", "right": "20", "bottom": "120", "left": "20", "isLinked": false},
      "content_width": "boxed", "boxed_width": {"unit": "px", "size": 900}
    },
    "elements": [
      {"id":"a1b001","elType":"widget","widgetType":"heading","settings":{"title":"{TITLE}","header_size":"h1","align":"center","title_color":"#FFFFFF","typography_typography":"custom","typography_font_size":{"unit":"px","size":48},"typography_font_weight":"800"}},
      {"id":"a1b002","elType":"widget","widgetType":"text-editor","settings":{"editor":"<p>{SUBTITLE}</p>","align":"center","text_color":"#94A3B8","typography_typography":"custom","typography_font_size":{"unit":"px","size":20}}},
      {"id":"a1b003","elType":"widget","widgetType":"button","settings":{"text":"{CTA_TEXT}","link":{"url":"{CTA_URL}"},"size":"lg","align":"center","button_text_color":"#FFFFFF","button_background_background":"classic","button_background_color":"#3B82F6","border_radius":{"unit":"px","top":"8","right":"8","bottom":"8","left":"8","isLinked":true},"text_padding":{"unit":"px","top":"15","right":"30","bottom":"15","left":"30","isLinked":false}}}
    ]
  },
  // FEATURES SECTION — 3 columns, white
  {
    "id": "d4e5f6",
    "elType": "container",
    "settings": {
      "flex_direction": "column", "align_items": "center",
      "padding": {"unit": "px", "top": "80", "right": "20", "bottom": "80", "left": "20", "isLinked": false},
      "content_width": "boxed", "boxed_width": {"unit": "px", "size": 1140}
    },
    "elements": [
      {"id":"d4e001","elType":"widget","widgetType":"heading","settings":{"title":"{FEATURES_TITLE}","header_size":"h2","align":"center","title_color":"#1E293B","typography_typography":"custom","typography_font_size":{"unit":"px","size":36},"typography_font_weight":"700"}},
      {"id":"d4e002","elType":"container","settings":{"flex_direction":"row","flex_gap":{"unit":"px","size":30}},
        "elements":[
          {"id":"fe1","elType":"container","settings":{"flex_direction":"column","background_background":"classic","background_color":"#FFFFFF","border_border":"solid","border_width":{"unit":"px","top":"1","right":"1","bottom":"1","left":"1","isLinked":true},"border_color":"#E2E8F0","border_radius":{"unit":"px","top":"12","right":"12","bottom":"12","left":"12","isLinked":true},"padding":{"unit":"px","top":"30","right":"30","bottom":"30","left":"30","isLinked":true},"flex_grow":"1","flex_basis":"33%"},
            "elements":[
              {"id":"fe1a","elType":"widget","widgetType":"heading","settings":{"title":"{FEATURE_1}","header_size":"h3","title_color":"#1E293B","typography_typography":"custom","typography_font_size":{"unit":"px","size":24},"typography_font_weight":"700"}},
              {"id":"fe1b","elType":"widget","widgetType":"text-editor","settings":{"editor":"<p>{FEATURE_1_DESC}</p>","text_color":"#64748B"}}
            ]},
          {"id":"fe2","elType":"container","settings":{"flex_direction":"column","background_background":"classic","background_color":"#FFFFFF","border_border":"solid","border_width":{"unit":"px","top":"1","right":"1","bottom":"1","left":"1","isLinked":true},"border_color":"#E2E8F0","border_radius":{"unit":"px","top":"12","right":"12","bottom":"12","left":"12","isLinked":true},"padding":{"unit":"px","top":"30","right":"30","bottom":"30","left":"30","isLinked":true},"flex_grow":"1","flex_basis":"33%"},
            "elements":[
              {"id":"fe2a","elType":"widget","widgetType":"heading","settings":{"title":"{FEATURE_2}","header_size":"h3","title_color":"#1E293B","typography_typography":"custom","typography_font_size":{"unit":"px","size":24},"typography_font_weight":"700"}},
              {"id":"fe2b","elType":"widget","widgetType":"text-editor","settings":{"editor":"<p>{FEATURE_2_DESC}</p>","text_color":"#64748B"}}
            ]},
          {"id":"fe3","elType":"container","settings":{"flex_direction":"column","background_background":"classic","background_color":"#FFFFFF","border_border":"solid","border_width":{"unit":"px","top":"1","right":"1","bottom":"1","left":"1","isLinked":true},"border_color":"#E2E8F0","border_radius":{"unit":"px","top":"12","right":"12","bottom":"12","left":"12","isLinked":true},"padding":{"unit":"px","top":"30","right":"30","bottom":"30","left":"30","isLinked":true},"flex_grow":"1","flex_basis":"33%"},
            "elements":[
              {"id":"fe3a","elType":"widget","widgetType":"heading","settings":{"title":"{FEATURE_3}","header_size":"h3","title_color":"#1E293B","typography_typography":"custom","typography_font_size":{"unit":"px","size":24},"typography_font_weight":"700"}},
              {"id":"fe3b","elType":"widget","widgetType":"text-editor","settings":{"editor":"<p>{FEATURE_3_DESC}</p>","text_color":"#64748B"}}
            ]}
        ]}
    ]
  },
  // CTA SECTION — light background
  {
    "id": "g7h8i9",
    "elType": "container",
    "settings": {
      "flex_direction": "column", "align_items": "center",
      "background_background": "classic", "background_color": "#F8FAFC",
      "padding": {"unit": "px", "top": "80", "right": "20", "bottom": "80", "left": "20", "isLinked": false},
      "content_width": "boxed", "boxed_width": {"unit": "px", "size": 800}
    },
    "elements": [
      {"id":"g7h001","elType":"widget","widgetType":"heading","settings":{"title":"{CTA_SECTION_TITLE}","header_size":"h2","align":"center","title_color":"#1E293B","typography_typography":"custom","typography_font_size":{"unit":"px","size":32},"typography_font_weight":"700"}},
      {"id":"g7h002","elType":"widget","widgetType":"text-editor","settings":{"editor":"<p>{CTA_SECTION_DESC}</p>","align":"center","text_color":"#64748B"}},
      {"id":"g7h003","elType":"widget","widgetType":"button","settings":{"text":"{CTA_BUTTON}","link":{"url":"{CTA_URL}"},"size":"lg","align":"center","button_text_color":"#FFFFFF","button_background_background":"classic","button_background_color":"#10B981","border_radius":{"unit":"px","top":"8","right":"8","bottom":"8","left":"8","isLinked":true},"text_padding":{"unit":"px","top":"15","right":"30","bottom":"15","left":"30","isLinked":false}}}
    ]
  }
]
```

### Template: About (Text + Image + Stats)

```jsonc
[
  // TEXT + IMAGE SECTION
  {
    "id":"j1k2l3","elType":"container","settings":{"flex_direction":"row","flex_gap":{"unit":"px","size":60},"padding":{"unit":"px","top":"80","right":"20","bottom":"80","left":"20","isLinked":false},"content_width":"boxed","boxed_width":{"unit":"px","size":1140}},
    "elements":[
      {"id":"j1k001","elType":"container","settings":{"flex_direction":"column","flex_basis":"50%"},"elements":[
        {"id":"j1k01a","elType":"widget","widgetType":"heading","settings":{"title":"{SECTION_TITLE}","header_size":"h2","title_color":"#1E293B","typography_typography":"custom","typography_font_size":{"unit":"px","size":36},"typography_font_weight":"700"}},
        {"id":"j1k01b","elType":"widget","widgetType":"text-editor","settings":{"editor":"<p>{TEXT_1}</p><p>{TEXT_2}</p>","text_color":"#64748B","typography_typography":"custom","typography_font_size":{"unit":"px","size":16}}}
      ]},
      {"id":"j1k002","elType":"container","settings":{"flex_direction":"column","flex_basis":"50%"},"elements":[
        {"id":"j1k02a","elType":"widget","widgetType":"image","settings":{"image":{"id":"{IMAGE_ID}"},"image_size":"full","align":"center","width":{"unit":"%","size":100}}}
      ]}
    ]
  },
  // STATS SECTION — 4 counters
  {
    "id":"m4n5o6","elType":"container","settings":{"flex_direction":"row","flex_gap":{"unit":"px","size":20},"background_background":"classic","background_color":"#F8FAFC","padding":{"unit":"px","top":"60","right":"20","bottom":"60","left":"20","isLinked":false},"content_width":"boxed","boxed_width":{"unit":"px","size":1140}},
    "elements":[
      {"id":"m4n001","elType":"container","settings":{"flex_direction":"column","align_items":"center","flex_basis":"25%"},"elements":[{"id":"m4n01a","elType":"widget","widgetType":"heading","settings":{"title":"{STAT_1}","header_size":"h2","align":"center","title_color":"#3B82F6","typography_typography":"custom","typography_font_size":{"unit":"px","size":42},"typography_font_weight":"800"}},{"id":"m4n01b","elType":"widget","widgetType":"text-editor","settings":{"editor":"<p>{STAT_1_LABEL}</p>","align":"center","text_color":"#64748B"}}]},
      {"id":"m4n002","elType":"container","settings":{"flex_direction":"column","align_items":"center","flex_basis":"25%"},"elements":[{"id":"m4n02a","elType":"widget","widgetType":"heading","settings":{"title":"{STAT_2}","header_size":"h2","align":"center","title_color":"#10B981","typography_typography":"custom","typography_font_size":{"unit":"px","size":42},"typography_font_weight":"800"}},{"id":"m4n02b","elType":"widget","widgetType":"text-editor","settings":{"editor":"<p>{STAT_2_LABEL}</p>","align":"center","text_color":"#64748B"}}]},
      {"id":"m4n003","elType":"container","settings":{"flex_direction":"column","align_items":"center","flex_basis":"25%"},"elements":[{"id":"m4n03a","elType":"widget","widgetType":"heading","settings":{"title":"{STAT_3}","header_size":"h2","align":"center","title_color":"#F59E0B","typography_typography":"custom","typography_font_size":{"unit":"px","size":42},"typography_font_weight":"800"}},{"id":"m4n03b","elType":"widget","widgetType":"text-editor","settings":{"editor":"<p>{STAT_3_LABEL}</p>","align":"center","text_color":"#64748B"}}]},
      {"id":"m4n004","elType":"container","settings":{"flex_direction":"column","align_items":"center","flex_basis":"25%"},"elements":[{"id":"m4n04a","elType":"widget","widgetType":"heading","settings":{"title":"{STAT_4}","header_size":"h2","align":"center","title_color":"#EF4444","typography_typography":"custom","typography_font_size":{"unit":"px","size":42},"typography_font_weight":"800"}},{"id":"m4n04b","elType":"widget","widgetType":"text-editor","settings":{"editor":"<p>{STAT_4_LABEL}</p>","align":"center","text_color":"#64748B"}}]}
    ]
  }
]
```

### Template: Contact (Info + Map)

```jsonc
[
  {
    "id":"p7q8r9","elType":"container","settings":{"flex_direction":"column","align_items":"center","padding":{"unit":"px","top":"60","right":"20","bottom":"40","left":"20","isLinked":false},"content_width":"boxed","boxed_width":{"unit":"px","size":900}},
    "elements":[
      {"id":"p7q001","elType":"widget","widgetType":"heading","settings":{"title":"Contacto","header_size":"h2","align":"center","title_color":"#1E293B","typography_typography":"custom","typography_font_size":{"unit":"px","size":36},"typography_font_weight":"700"}},
      {"id":"p7q002","elType":"widget","widgetType":"text-editor","settings":{"editor":"<p style=\"text-align:center\">{CONTACT_INTRO}</p>","align":"center","text_color":"#64748B"}}
    ]
  },
  {
    "id":"s1t2u3","elType":"container","settings":{"flex_direction":"row","flex_gap":{"unit":"px","size":60},"padding":{"unit":"px","top":"40","right":"20","bottom":"80","left":"20","isLinked":false},"content_width":"boxed","boxed_width":{"unit":"px","size":1140}},
    "elements":[
      {"id":"s1t001","elType":"container","settings":{"flex_direction":"column","flex_basis":"40%"},"elements":[
        {"id":"s1t01a","elType":"widget","widgetType":"heading","settings":{"title":"Información de Contacto","header_size":"h3","title_color":"#1E293B","typography_typography":"custom","typography_font_size":{"unit":"px","size":24},"typography_font_weight":"700"}},
        {"id":"s1t01b","elType":"widget","widgetType":"text-editor","settings":{"editor":"<p><strong>Teléfono:</strong> {PHONE}</p><p><strong>Email:</strong> {EMAIL}</p><p><strong>Dirección:</strong> {ADDRESS}</p>","text_color":"#64748B"}}
      ]},
      {"id":"s1t002","elType":"container","settings":{"flex_direction":"column","flex_basis":"60%"},"elements":[
        {"id":"s1t02a","elType":"widget","widgetType":"html","settings":{"html":"<iframe src=\"https://maps.google.com/maps?q={ENCODED_ADDRESS}&z=14&output=embed\" width=\"100%\" height=\"350\" style=\"border:0;border-radius:8px\" allowfullscreen=\"\" loading=\"lazy\"></iframe>"}}
      ]}
    ]
  }
]
```

## Workflow: Crear página completa en un paso

Cuando el usuario pide "creame una landing para Elementor":

1. Elegí el template que corresponda (Landing, About, Contact)
2. Reemplazá los placeholders `{TITLE}`, `{CTA_TEXT}`, etc con contenido real
3. Reemplazá los IDs de elementos por valores únicos (6-char hex aleatorio)
4. Ejecutá el flujo completo:
   ```bash
   # Crear page → set meta → inject JSON → flush CSS → publish
   ID=$(ddev wp post create --post_type=page --post_title='...' --post_status=draft --porcelain)
   ddev wp post meta update $ID _elementor_edit_mode builder
   ddev wp post meta update $ID _elementor_template_type wp-page
   echo '[...JSON...]' > /tmp/elementor-page.json
   ddev wp post meta update $ID _elementor_data "$(cat /tmp/elementor-page.json)"
   ddev wp elementor flush-css
   ddev wp post update $ID --post_status=publish
   ```
5. Verificá: `ddev wp post list --post_type=page --post_title='...'`

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
