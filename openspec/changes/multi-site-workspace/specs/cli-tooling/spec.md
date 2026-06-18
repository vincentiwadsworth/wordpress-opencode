# Delta for cli-tooling

## ADDED Requirements

### Requirement: Avada WP-CLI Commands

The system MUST use `wp post create` with Fusion Builder shortcodes in `post_content` to create pages for sites configured with `builder: avada`. WP-CLI SHALL target the active site (local DDEV container or remote SSH).

#### Scenario: Create Avada page on local DDEV

- GIVEN the active site is local (`builder: avada`)
- WHEN the system runs `ddev wp post create --post_type=page --post_title='Services' --post_content='[fusion_builder_container]...[/fusion_builder_container]'`
- THEN the page is created and Avada parses the shortcodes

#### Scenario: Create Avada page on remote site

- GIVEN the active site is remote with SSH credentials in its config
- WHEN the system runs `ssh user@host wp post create ...`
- THEN the remote WordPress creates the page

### Requirement: Site-Aware Command Dispatch

WP-CLI commands MUST target the active site's environment. Local sites use `ddev wp`, remote sites use `wp` via SSH with credentials from the site config. Dispatch MUST fail if the active site config lacks required SSH fields for remote operations.

#### Scenario: Dispatch to local site

- GIVEN the active site config has no `ssh` key
- WHEN any WP-CLI command is issued
- THEN the system uses `ddev wp` inside the local DDEV container

#### Scenario: Dispatch to remote site

- GIVEN the active site config has valid `ssh.host`, `ssh.user`, and `ssh.port`
- WHEN a WP-CLI command is issued
- THEN the system runs `wp` via SSH tunnel to the remote server

#### Scenario: Dispatch with missing SSH fields

- GIVEN the active site has `ssh.host` but no `ssh.user`
- WHEN a WP-CLI command is issued
- THEN the system reports "Remote SSH credentials incomplete"
- AND the command is NOT executed

## MODIFIED Requirements

### Requirement: WP-CLI for Server-Side and Remote Operations

`ddev wp` MUST expose the full WP-CLI command set inside the DDEV container for local WordPress operations. For remote sites, `wp` via SSH MUST be available using the credentials from the active site config.
(Previously: `ddev wp` only for local DDEV container operations)

#### Scenario: Headless WordPress install

- GIVEN DDEV is running and the database is empty
- WHEN the user runs `ddev wp core install --url=... --title=... --admin_user=... --admin_email=...`
- THEN WordPress is fully installed without the web installer
- AND the admin user is created

#### Scenario: Remote WP-CLI against client site

- GIVEN an active site config with remote SSH credentials
- WHEN the user runs `wp core version` through the SSH proxy
- THEN output shows the client site's WordPress version
