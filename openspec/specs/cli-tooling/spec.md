# cli-tooling Specification

## Purpose

CLI tools for WordPress administration (WP-CLI), Elementor-native content management (Respira CLI), and AI agent integration (elementor-mcp-agent).

## Requirements

### Requirement: WP-CLI for Server-Side Operations

`ddev wp` MUST expose the full WP-CLI command set inside the DDEV container for WordPress admin operations.

#### Scenario: Headless WordPress install

- GIVEN DDEV is running and the database is empty
- WHEN the user runs `ddev wp core install --url=... --title=... --admin_user=... --admin_email=...`
- THEN WordPress is fully installed without the web installer
- AND the admin user is created

### Requirement: Respira CLI for Elementor Content

Respira CLI MUST be installed globally on the host machine for Elementor-native JSON content manipulation.

#### Scenario: Respira responds to help

- GIVEN Node.js 20+ is installed on the host
- WHEN the user runs `respira --help`
- THEN output lists available Elementor content commands

### Requirement: elementor-mcp-agent for AI Integration

elementor-mcp-agent MUST be installed globally on the host, exposing 101+ tools for LLM-driven Elementor manipulation.

#### Scenario: Agent verifies installation

- GIVEN Node.js 20+ is installed on the host
- WHEN the user runs `elementor-mcp-agent --help`
- THEN output confirms the agent is available and lists tool categories

#### Scenario: Tools persist across DDEV restart

- GIVEN DDEV has been restarted
- WHEN the user runs `ddev wp --help`
- THEN WP-CLI is still functional inside the container
- AND host-side tools (respira, elementor-mcp-agent) are unaffected
