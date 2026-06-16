---
name: wp-elementor-page
description: "Trigger: crear página, landing page, Elementor layout, maquetar, página con Elementor, design tokens. Build WordPress pages using Elementor via Respira CLI and elementor-mcp-agent."
license: MIT
metadata:
  author: "vincentiwadsworth"
  version: "1.0"
---

## Activation Contract

Use this skill when building or modifying Elementor pages through CLI tools. Never edit `_elementor_data` postmeta directly without a backup. Respira CLI is the primary tool for Elementor-native operations; elementor-mcp-agent provides programmatic access.

## Hard Rules

- Always snapshot before any write: `respira snapshots create <page-id> --label="pre-edit"`.
- Validate after every write: `respira read structure <url>` before publishing.
- Global colors and fonts must reference Elementor kit tokens by ID, never literal hex values.
- Pages are built as draft (`post_status: draft`), published only after validation passes.
- Never delete posts or media without explicit user approval.
- Elementor Pro features (theme builder, popups, dynamic tags) only work if `elementor-pro` plugin is active.

## Decision Gates

| Trigger | Action |
|---------|--------|
| User wants a new page with layout | Use Respira CLI: `respira write create-page` with JSON blueprint |
| User wants to read existing page structure | `respira read structure <page-id-or-url>` |
| User wants bulk find/replace across pages | Use elementor-mcp-agent: `elementor_find_replace` with dry-run first |
| User wants global design tokens (colors/fonts) | `respira read design-system` → propose → `respira write update-site-kit` |
| Operation needs WP-CLI fallback | Use `ddev wp post meta get <id> _elementor_data` or `ddev wp elementor flush-css` |
| Respira CLI unavailable or no site connected | Fall back to elementor-mcp-agent or direct WP-CLI postmeta manipulation |

## Execution Steps

1. Confirm DDEV is running and WordPress is accessible.
2. Read current page state: `respira read structure <page-id>` or anonymous URL.
3. Present the blueprint (widget tree, sections, columns) to the user for approval.
4. Build via Respira CLI: `respira write create-page --draft --data=<json>`.
5. Validate render: confirm no JSON corruption, all IDs preserved.
6. Publish only after user confirms validation passed.

## Output Contract

Return:
- Page ID, URL, and post status.
- Snapshot ID created before the write.
- Any validation warnings (broken IDs, missing dynamic tags, CSS flush needed).
- Screenshot reference if `elementor-mcp-agent` screenshot tool was used.

## References

- `AGENTS.md` — project stack, Respira CLI and elementor-mcp-agent versions.
- Respira CLI docs: https://respira.press/cli/docs
- elementor-mcp-agent docs: https://github.com/Mogacode-ma/elementor-mcp-agent
