# avada-page-building Specification

## Purpose

Avada (Fusion Builder) page creation via WP-CLI post_content shortcode injection. No dedicated MCP agent exists — all page building uses WP-CLI writing Fusion Builder shortcodes directly into `wp_posts.post_content`.

## Requirements

### Requirement: Shortcode Injection via WP-CLI

The system MUST create Avada pages by writing Fusion Builder shortcodes into `post_content` using `ddev wp post create` (local) or `wp post create` via SSH (remote).

#### Scenario: Create Avada page with heading

- GIVEN a site configured with `builder: avada`
- WHEN the system runs `wp post create --post_type=page --post_title='About Us' --post_content='[fusion_builder_container][fusion_builder_row][fusion_builder_column type="1_1"][fusion_title content_align="center"]About Us[/fusion_title][/fusion_builder_column][/fusion_builder_row][/fusion_builder_container]'`
- THEN a new draft page is created with the shortcode content
- AND the page renders correctly in Avada's frontend

#### Scenario: Invalid shortcode structure

- GIVEN a Fusion Builder shortcode with a missing closing tag
- WHEN the post is created via WP-CLI
- THEN Avada renders the page without that broken element
- AND the page remains accessible for editing

### Requirement: Curated Shortcode Reference

The `skills/wp-avada-page/SKILL.md` skill MUST include a curated reference of common Fusion Builder shortcodes (container, row, column, title, text, image, button, separator). The reference SHALL limit to ~20 patterns initially.

#### Scenario: Skill generates valid shortcodes

- GIVEN the Avada page-building skill is loaded
- WHEN the user requests a hero section with title, text, and button
- THEN the generated shortcode includes `<fusion_builder_container>`, `<fusion_builder_row>`, `<fusion_builder_column>`, `<fusion_title>`, `<fusion_text>`, and `<fusion_button>`

#### Scenario: Unsupported shortcode requested

- GIVEN the curated reference does not include `fusion_tabs`
- WHEN the user requests a tabs section
- THEN the skill responds with "tabs pattern not yet in curated reference — manual shortcode needed"
