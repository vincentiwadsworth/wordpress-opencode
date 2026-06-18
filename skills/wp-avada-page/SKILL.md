---
name: wp-avada-page
description: "Trigger: Avada page, Avada builder, Fusion Builder page, página Avada, crear página Avada, shortcode Avada. Build and manage Avada (Fusion Builder) pages via WP-CLI shortcode injection."
license: MIT
metadata:
  author: "gentle-orchestrator"
  version: "1.0"
---

## Activation Contract

Use this skill when building or editing pages on an Avada/Fusion Builder WordPress site. Avada stores page content as shortcodes in `post_content` — NOT in post meta like Elementor.

**Hard rule**: Avada pages MUST be constructed as nested shortcodes. The hierarchy is always: Container → Row → Column → Elements.

## Shortcode Architecture

```
[fusion_builder_container type="flex" hundred_percent="no"]
  [fusion_builder_row]
    [fusion_builder_column type="1_1" layout="1_1"]
      [fusion_title size="2" content_align="left"]Heading[/fusion_title]
      [fusion_text]<p>Content</p>[/fusion_text]
      [fusion_button link="https://..." color="default" size="medium"]Click[/fusion_button]
    [/fusion_builder_column]
  [/fusion_builder_row]
[/fusion_builder_container]
```

### Column Types

| Type | Width | Use Case |
|------|-------|----------|
| `1_1` | Full width | Single column layout |
| `1_2` | Half | Two-column row |
| `1_3` | One third | Three-column row, sidebar layout |
| `2_3` | Two thirds | Main content with sidebar |
| `1_4` | One quarter | Four-column row |
| `3_4` | Three quarters | Wide content + thin sidebar |

## Common Shortcode Reference

| Element | Shortcode | Key Parameters |
|---------|-----------|---------------|
| Container | `[fusion_builder_container]` | `type="flex\|legacy"`, `hundred_percent="yes\|no"`, `background_color`, `background_image`, `background_repeat` |
| Row | `[fusion_builder_row]` | Minimal params — wraps columns |
| Column | `[fusion_builder_column]` | `type="1_1\|1_2\|1_3\|2_3\|1_4\|3_4"`, `spacing=""`, `align_self="auto\|stretch\|flex-start\|flex-end\|center"` |
| Title | `[fusion_title]` | `size="1\|2\|3\|4\|5\|6"`, `content_align="left\|center\|right"`, `font_size=""`, `margin_top=""` |
| Text | `[fusion_text]` | Wraps HTML. Use `<p>`, `<ul>`, `<hX>` inside. No key params. |
| Button | `[fusion_button]` | `link=""`, `color="default\|green\|red\|blue\|orange"`, `size="small\|medium\|large\|xlarge"`, `target="_self\|_blank"` |
| Image | `[fusion_image]` | `image_id=""` (WP media ID), `max_width=""`, `align="left\|center\|right"`, `lightbox="yes\|no"` |
| Separator | `[fusion_separator]` | `style="none\|single\|double\|dashed\|dotted"`, `top_margin=""`, `bottom_margin=""`, `icon="fa-*"` |
| Code | `[fusion_code]` | Wraps raw HTML, CSS, or JS. No key params. |

## WP-CLI Page Creation

### Local DDEV
```bash
ddev wp post create \
  --post_type=page \
  --post_title='Page Title' \
  --post_status=publish \
  --post_content='[fusion_builder_container...]'
```

### Remote Site via SSH
```bash
ssh user@host "wp --path=/var/www/html post create \
  --post_type=page \
  --post_title='Page Title' \
  --post_status=publish \
  --post_content='[fusion_builder_container...]'"
```

### Updating Existing Page
```bash
# Local
ddev wp post update <ID> --post_content='[shortcodes]'

# Remote
ssh user@host "wp --path=/var/www/html post update <ID> --post_content='[shortcodes]'"
```

## Important Gotchas

1. **No intermediate validation** — Unlike Elementor's JSON which validates on CSS flush, Avada shortcodes either render or produce "not parsable" errors. Always verify with `ddev wp post list --post_type=page`.
2. **Shortcode escaping** — In SSH commands, escape single quotes inside `post_content` carefully. Use `'\''` to embed a single quote, or use heredoc syntax.
3. **Elementor vs Avada** — Avada lives in `post_content`, NOT in `_elementor_data` meta. Never try to set `_elementor_data` on an Avada site.
4. **HTML inside fusion_text** — The `[fusion_text]` shortcode wraps raw HTML. Use standard WP HTML tags (`<p>`, `<h2>`, `<ul>`, etc.).
5. **IDs for images** — `[fusion_image]` requires a WordPress media library ID (`image_id`), not a URL. Use `ddev wp media import <url>` first to get the ID.
