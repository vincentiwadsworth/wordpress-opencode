# site-configuration Specification

## Purpose

Per-site YAML configuration directory enabling a single workspace to manage multiple client WordPress sites. Configs define site identity, builder choice, and remote access.

## Requirements

### Requirement: Site Config Schema

The `sites/` directory MUST contain one YAML file per client site with fields: `id`, `url`, `builder` (`elementor` | `avada`), `wp_admin`, `ssh` (host, user, port), and `gitignore: true`. The schema MUST reject unknown builder values.

#### Scenario: Template validates

- GIVEN no `sites/*.yaml` files exist yet
- WHEN the user inspects `sites/_template.yaml`
- THEN it contains all required fields with placeholder values and documentation comments

#### Scenario: Invalid builder rejected

- GIVEN a `sites/client.yaml` with `builder: gutenberg`
- WHEN the system validates the config
- THEN config load fails with an error identifying the unsupported builder value

### Requirement: Gitignore Convention

Actual `sites/*.yaml` files (except `_template.yaml`) MUST be listed in `.gitignore`. Only `_template.yaml` is committed.

#### Scenario: New site config stays local

- GIVEN a developer adds `sites/acme-corp.yaml`
- WHEN `git status` is inspected
- THEN the new config does NOT appear as an untracked file

### Requirement: Site Switching Convention

Switching active site MUST update the active context to load that site's config. Output MUST echo which builder is active and the target URL.

#### Scenario: Switch to existing site

- GIVEN `sites/acme-corp.yaml` exists with valid credentials
- WHEN the user says "switch to acme-corp"
- THEN the active site is set to `acme-corp`
- AND output confirms "Switched to acme-corp (builder: elementor, url: ...)"

#### Scenario: Switch to non-existent site

- GIVEN no config file for `nonexistent-client`
- WHEN the user says "switch to nonexistent-client"
- THEN the system reports "No config found for nonexistent-client"
- AND the active site remains unchanged
