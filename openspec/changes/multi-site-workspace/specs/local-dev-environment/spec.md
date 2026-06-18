# Delta for local-dev-environment

## ADDED Requirements

### Requirement: Remote Site Access via SSH

The system MUST document remote site SSH access patterns alongside the DDEV workflow. Remote servers SHALL be accessed using SSH credentials stored in the active site's YAML config. The `wp-cli.yml` and `AGENTS.md` MUST document the SSH proxy pattern for remote WP-CLI.

#### Scenario: Remote WP-CLI via SSH documented

- GIVEN a site config with `ssh.host`, `ssh.user`, and `ssh.port`
- WHEN the developer reads the remote site workflow docs
- THEN the docs show `ssh user@host wp <command>` as the access pattern
- AND docs warn about SSH key configuration and host key verification

#### Scenario: Mixed local and remote workflow

- GIVEN one local site (DDEV) and one remote client site
- WHEN the developer switches between them
- THEN local commands use `ddev wp` and remote use `wp` via SSH
- AND the command dispatch is transparent to the user

### Requirement: DDEV for Multi-Site Local Development

A single DDEV instance SHALL serve the primary project site. Additional client sites managed from this workspace MAY be remote. The local DDEV instance MUST NOT be required to be running for remote-site operations.

#### Scenario: Remote-site work without DDEV

- GIVEN DDEV is stopped
- WHEN active site is a remote client
- THEN WP-CLI commands work via SSH without starting DDEV
- AND the system does not require DDEV to be running
