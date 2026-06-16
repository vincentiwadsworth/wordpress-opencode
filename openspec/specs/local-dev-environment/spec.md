# local-dev-environment Specification

## Purpose

DDEV-based local dev environment — zero-config start, reproducible across machines, committable infrastructure.

## Requirements

### Requirement: DDEV Config

`.ddev/config.yaml` MUST define PHP 8.3, MariaDB 10.11, nginx-fpm web server, and Node.js 20. The config MUST be committable (in version control).

#### Scenario: Fresh start boots WordPress

- GIVEN a machine with DDEV ≥ 1.22 and Docker Desktop
- WHEN the user runs `ddev start`
- THEN WordPress is reachable at `https://<project>.ddev.site`
- AND `ddev describe` shows PHP 8.3 and MariaDB running

#### Scenario: Port conflict auto-resolution

- GIVEN port 80 or 443 is already in use on the host
- WHEN the user runs `ddev start`
- THEN DDEV assigns the next available port
- AND the project URL prints in the start output

#### Scenario: Config is committable

- GIVEN `ddev config` has been run
- WHEN `git status` is inspected
- THEN `.ddev/config.yaml` appears as a tracked file

### Requirement: WP-CLI Integration

DDEV MUST expose `ddev wp` for server-side WordPress operations inside the container.

#### Scenario: WP-CLI version check

- GIVEN DDEV is running
- WHEN the user runs `ddev wp core version`
- THEN output shows the installed WordPress version

#### Scenario: Host-side command fails gracefully

- GIVEN the user is outside the DDEV container
- WHEN they run `wp` directly on the host
- THEN the command fails with a hint to use `ddev wp`
