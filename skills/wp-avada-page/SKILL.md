---
name: wp-avada-page
description: "Trigger: Avada page, Avada builder, Fusion Builder page, página Avada, crear página Avada, shortcode Avada. Build and manage Avada (Fusion Builder) pages via WP-CLI shortcode injection."
license: MIT
metadata:
  author: "gentle-orchestrator"
  version: "2.0"
---

## Activation Contract

Use this skill when building or editing pages on an Avada/Fusion Builder WordPress site. Avada stores page content as shortcodes in `post_content` — NOT in post meta like Elementor.

**Hard rule**: Avada pages MUST be constructed as nested shortcodes. The hierarchy is always: Container → Row → Column → Elements.

## Shortcode Architecture

```
[fusion_builder_container type="flex" hundred_percent="no" background_color="" ...]
  [fusion_builder_row]
    [fusion_builder_column type="1_1" layout="1_1" spacing="" ...]
      [fusion_title size="2" content_align="left"]Heading[/fusion_title]
      [fusion_text]<p>Content</p>[/fusion_text]
      [fusion_button link="..." color="default" size="medium"]Click[/fusion_button]
    [/fusion_builder_column]
  [/fusion_builder_row]
[/fusion_builder_container]
```

### Column Types

| Type | Width | Use Case |
|------|-------|----------|
| `1_1` | Full width | Single column |
| `1_2` | Half | Two-column row |
| `1_3` | One third | Three-column / sidebar |
| `2_3` | Two thirds | Main + sidebar |
| `1_4` | One quarter | Four-column |
| `3_4` | Three quarters | Wide + thin sidebar |
| `1_5` | One fifth | Five-column / tight grids |
| `1_6` | One sixth | Six-column / tight grids |

## Complete Element Reference

### Layout Elements
| Element | Shortcode | Key Parameters |
|---------|-----------|---------------|
| Container | `[fusion_builder_container]` | `type="flex\|legacy"`, `hundred_percent="yes\|no"`, `background_color`, `background_image`, `background_repeat`, `background_position`, `padding_top`, `padding_bottom`, `margin_top`, `margin_bottom` |
| Row | `[fusion_builder_row]` | Minimal params — wraps columns |
| Column | `[fusion_builder_column]` | `type="1_1\|1_2\|1_3\|2_3\|1_4\|3_4\|1_5\|1_6"`, `spacing=""`, `align_self="auto\|stretch\|flex-start\|flex-end\|center"`, `center_content="yes\|no"` |
| Nested Column | `[fusion_builder_column_inner]` | Same params as column, used inside other elements |

### Content Elements
| Element | Shortcode | Key Parameters |
|---------|-----------|---------------|
| Title | `[fusion_title]` | `size="1\|2\|3\|4\|5\|6"`, `content_align="left\|center\|right"`, `font_size=""`, `margin_top=""`, `color=""` |
| Text | `[fusion_text]` | Wraps HTML (`<p>`, `<ul>`, `<hX>`). No key params. |
| Button | `[fusion_button]` | `link=""`, `color="default\|green\|red\|blue\|orange\|teal\|pink"`, `size="small\|medium\|large\|xlarge"`, `target="_self\|_blank"`, `border_radius=""` |
| Image | `[fusion_image]` | `image_id=""` (WP media ID), `max_width=""`, `align="left\|center\|right"`, `lightbox="yes\|no"` |
| Separator | `[fusion_separator]` | `style="none\|single\|double\|dashed\|dotted"`, `top_margin=""`, `bottom_margin=""`, `icon="fa-*"` |
| Code | `[fusion_code]` | Wraps raw HTML, CSS, or JS. No key params. |

### Interactive Elements
| Element | Shortcode | Key Parameters |
|---------|-----------|---------------|
| Tabs | `[fusion_tabs]` + `[fusion_tab]` | `design="classic\|clean\|vertical"`, `layout="horizontal\|vertical"`, `nav_width="30px"` |
| Accordion | `[fusion_accordion]` + `[fusion_toggle]` | `divider_line="yes\|no"`, `title=""`, `open="yes\|no"` |
| Alert | `[fusion_alert]` | `type="general\|error\|success\|notice\|warning\|custom"`, `dismissable="yes\|no"`, `icon="fa-*"`, `border_size=""` |
| Modal | `[fusion_modal]` | `name=""`, `title=""`, `size="small\|medium\|large"`, `background=""` |
| Tagline | `[fusion_tagline]` | `description=""`, `button_text=""`, `button_link=""`, `description_color=""` |

### Data Elements
| Element | Shortcode | Key Parameters |
|---------|-----------|---------------|
| Counter Circle | `[fusion_countdown]` | `number=""`, `counter_circle_color=""`, `counter_circle_border_color=""`, `title=""`, `icon="fa-*"` |
| Counter Box | `[fusion_counter_box]` | `value=""`, `unit=""`, `icon=""`, `direction="up\|down"`, `position="left\|right\|center"`, `counter_box_color=""` |
| Progress Bar | `[fusion_progress]` | `percentage=""`, `unit=""`, `filledcolor=""`, `unfilledcolor=""`, `show_percentage="yes\|no"` |
| Pricing Table | `[fusion_pricing_table]` + `[fusion_pricing_column]` | `title=""`, `price=""`, `currency=""`, `time=""`, `button_text=""`, `button_link=""` |
| Table | `[fusion_table]` | Wraps `<table>` HTML |

### Media Elements
| Element | Shortcode | Key Parameters |
|---------|-----------|---------------|
| Image Gallery | `[fusion_imageframe]` | `image_id=""`, `max_width=""`, `style_type="none\|border\|shadow\|dropshadow"`, `hover_type="none\|zoomin\|zoomout\|lift"` |
| Video | `[fusion_video]` | `url=""`, `width=""`, `height=""`, `autoplay="yes\|no"`, `mute="yes\|no"` |
| Slider | `[fusion_slider]` + `[fusion_slide]` | `height=""`, `nav="yes\|no"`, `pagination="yes\|no"`, `autoplay="yes\|no"` |
| Google Map | `[fusion_map]` | `address=""`, `type="roadmap\|satellite\|hybrid\|terrain"`, `zoom="14"`, `height=""` |

## Page Templates

Use these templates for common page types. Replace content placeholders with actual text.

### Template: Hero + Features + CTA (Landing Page)

```
[fusion_builder_container hundred_percent="no" background_color="#0F172A" padding_top="100" padding_bottom="100"]
[fusion_builder_row][fusion_builder_column type="1_1"]
[fusion_title size="1" content_align="center" color="#FFFFFF"]{TITLE}[/fusion_title]
[fusion_text]<p style="text-align:center;color:#94A3B8;font-size:1.2em">{SUBTITLE}</p>[/fusion_text]
[fusion_button link="{CTA_URL}" color="blue" size="large" border_radius="8" target="_self"]{CTA_TEXT}[/fusion_button]
[/fusion_builder_column][/fusion_builder_row]
[/fusion_builder_container]

[fusion_builder_container hundred_percent="no" background_color="#FFFFFF" padding_top="80" padding_bottom="80"]
[fusion_builder_row]
[fusion_builder_column type="1_3" spacing="30"]
[fusion_title size="3" content_align="center"]{FEATURE_1_TITLE}[/fusion_title]
[fusion_text]<p style="text-align:center">{FEATURE_1_DESC}</p>[/fusion_text]
[/fusion_builder_column]
[fusion_builder_column type="1_3" spacing="30"]
[fusion_title size="3" content_align="center"]{FEATURE_2_TITLE}[/fusion_title]
[fusion_text]<p style="text-align:center">{FEATURE_2_DESC}</p>[/fusion_text]
[/fusion_builder_column]
[fusion_builder_column type="1_3" spacing="30"]
[fusion_title size="3" content_align="center"]{FEATURE_3_TITLE}[/fusion_title]
[fusion_text]<p style="text-align:center">{FEATURE_3_DESC}</p>[/fusion_text]
[/fusion_builder_column]
[/fusion_builder_row]
[/fusion_builder_container]

[fusion_builder_container hundred_percent="no" background_color="#F8FAFC" padding_top="80" padding_bottom="80"]
[fusion_builder_row][fusion_builder_column type="1_1"]
[fusion_title size="2" content_align="center"]{CTA_SECTION_TITLE}[/fusion_title]
[fusion_text]<p style="text-align:center;font-size:1.1em">{CTA_SECTION_DESC}</p>[/fusion_text]
[fusion_button link="{CTA_URL}" color="green" size="large" border_radius="8"]{CTA_BUTTON}[/fusion_button]
[/fusion_builder_column][/fusion_builder_row]
[/fusion_builder_container]
```

### Template: About Page

```
[fusion_builder_container hundred_percent="no" padding_top="60" padding_bottom="60"]
[fusion_builder_row]
[fusion_builder_column type="1_2"]
[fusion_title size="2"]{SECTION_TITLE}[/fusion_title]
[fusion_text]<p>{CONTENT_PARAGRAPH_1}</p><p>{CONTENT_PARAGRAPH_2}</p>[/fusion_text]
[/fusion_builder_column]
[fusion_builder_column type="1_2"]
[fusion_image image_id="{IMAGE_ID}" align="center" max_width="100%"]
[/fusion_builder_column]
[/fusion_builder_row]
[/fusion_builder_container]

[fusion_builder_container hundred_percent="no" background_color="#F8FAFC" padding_top="60" padding_bottom="60"]
[fusion_builder_row]
[fusion_builder_column type="1_4"]
[fusion_counter_box value="10" unit="+" icon="fa-briefcase" counter_box_color="#3B82F6"]{LABEL_1}[/fusion_counter_box]
[/fusion_builder_column]
[fusion_builder_column type="1_4"]
[fusion_counter_box value="50" unit="+" icon="fa-users" counter_box_color="#10B981"]{LABEL_2}[/fusion_counter_box]
[/fusion_builder_column]
[fusion_builder_column type="1_4"]
[fusion_counter_box value="99" unit="%" icon="fa-star" counter_box_color="#F59E0B"]{LABEL_3}[/fusion_counter_box]
[/fusion_builder_column]
[fusion_builder_column type="1_4"]
[fusion_counter_box value="5" unit="+" icon="fa-trophy" counter_box_color="#EF4444"]{LABEL_4}[/fusion_counter_box]
[/fusion_builder_column]
[/fusion_builder_row]
[/fusion_builder_container]
```

### Template: Contact Page

```
[fusion_builder_container hundred_percent="no" padding_top="60" padding_bottom="60"]
[fusion_builder_row][fusion_builder_column type="1_1"]
[fusion_title size="2" content_align="center"]Contacto[/fusion_title]
[fusion_text]<p style="text-align:center">{CONTACT_INTRO}</p>[/fusion_text]
[/fusion_builder_column][/fusion_builder_row]
[/fusion_builder_container]

[fusion_builder_container hundred_percent="no" padding_top="40" padding_bottom="60"]
[fusion_builder_row]
[fusion_builder_column type="1_2"]
[fusion_title size="3" margin_top="0"]Información de Contacto[/fusion_title]
[fusion_text]
<p><strong>Teléfono:</strong> {PHONE}</p>
<p><strong>Email:</strong> {EMAIL}</p>
<p><strong>Dirección:</strong> {ADDRESS}</p>
[/fusion_text]
[/fusion_builder_column]
[fusion_builder_column type="1_2"]
[fusion_title size="3" margin_top="0"]Ubicación[/fusion_title]
[fusion_map address="{ADDRESS}" type="roadmap" zoom="14" height="300"]
[/fusion_builder_column]
[/fusion_builder_row]
[/fusion_builder_container]
```

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

## Workflow: Crear página completa en un paso

Cuando el usuario pide "creame una landing para Avada", ejecutá:

1. Elegí el template que corresponda (Hero+Features+CTA, About, Contact)
2. Reemplazá los placeholders `{TITLE}`, `{SUBTITLE}`, `{CTA_URL}` etc con el contenido real
3. Construí el `post_content` completo con todos los shortcodes reemplazados
4. Ejecutá `ddev wp post create --post_content='...'` (local) o `ssh...` (remoto)
5. Verificá que se creó: `post list --post_type=page --post_title='...'`

## Important Gotchas

1. **No intermediate validation** — Avada shortcodes either render or error. Always verify with `wp post list --post_type=page`.
2. **Shortcode escaping** — In SSH, use `'\''` to embed single quotes, or heredoc. For complex pages, write shortcodes to a temp file.
3. **Elementor vs Avada** — Avada lives in `post_content`, NOT in `_elementor_data`. Never mix them.
4. **HTML inside fusion_text** — `[fusion_text]` wraps raw HTML (`<p>`, `<h2>`, `<ul>`, etc.).
5. **Image IDs** — `[fusion_image]` needs WP media library ID. Use `wp media import <url>` first.
6. **Container nesting** — Containers are always top-level. Do NOT nest containers inside containers. Each container is a full-width section.
