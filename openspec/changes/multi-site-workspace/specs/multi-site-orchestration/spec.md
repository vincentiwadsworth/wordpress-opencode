# multi-site-orchestration Specification

## Purpose

Active site tracking, builder-aware skill routing, and site switching orchestration across the multi-site workspace.

## Requirements

### Requirement: Active Site State

The system MUST maintain an active site context (id, url, builder). Site-specific commands (page create, edit, deploy) MUST target the active site's URL and builder toolchain. No global state persists across sessions — active site is chosen each session.

#### Scenario: Active site drives tool routing

- GIVEN active site is `acme-corp` with `builder: elementor`
- WHEN the user requests "create a landing page"
- THEN the system routes to `elementor-mcp-agent` for page creation

#### Scenario: Active site switch changes routing

- GIVEN active site switches from `acme-corp` (elementor) to `beta-co` (avada)
- WHEN the user requests "create a landing page"
- THEN the system routes to WP-CLI Avada shortcode injection instead

### Requirement: Builder-Aware Skill Routing

Page creation commands MUST dispatch to the correct builder toolchain: Elementor sites use `elementor-mcp-agent`, Avada sites use WP-CLI + shortcodes.

#### Scenario: Elementor page creation

- GIVEN active site has `builder: elementor`
- WHEN the user says "create a new About page"
- THEN the system uses elementor-mcp-agent tools to build the page

#### Scenario: Avada page creation

- GIVEN active site has `builder: avada`
- WHEN the user says "create a new About page"
- THEN the system generates Fusion Builder shortcodes and injects via WP-CLI

### Requirement: Site Switch Validation

Switching to a site MUST validate that its config file exists and is parseable. A site with a malformed YAML config MUST NOT become active.

#### Scenario: Switch to site with broken config

- GIVEN `sites/broken-site.yaml` has invalid YAML syntax
- WHEN the user says "switch to broken-site"
- THEN the system reports the YAML parse error
- AND the active site remains unchanged
