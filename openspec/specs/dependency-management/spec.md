# dependency-management Specification

## Purpose

Bedrock + Composer for dependency management — WordPress core, plugins, and mu-plugins as managed dependencies, no GUI installs, fully reproducible.

## Requirements

### Requirement: Bedrock Directory Layout

The web root MUST follow the Bedrock structure: `web/wp/` (core), `web/app/plugins/`, `web/app/themes/`, `web/app/mu-plugins/`.

#### Scenario: Bedrock scaffold produces correct layout

- GIVEN Composer 2.x is installed
- WHEN the user runs `composer create-project roots/bedrock`
- THEN the directory contains `web/wp/`, `web/app/plugins/`, and `web/app/mu-plugins/`

### Requirement: Composer Dependency Resolution

All WordPress packages MUST be declared in `composer.json`: core via `roots/wordpress`, plugins from wpackagist.org, Elementor Pro via authenticated private repository. `composer.lock` MUST be committed.

#### Scenario: Plugin install via Composer succeeds

- GIVEN `ELEMENTOR_PRO_LICENSE` is set in the environment
- WHEN the user runs `composer require elementor/elementor-pro`
- THEN the plugin is installed under `web/app/plugins/elementor-pro/`

#### Scenario: Dependency resolution fails without auth

- GIVEN the Elementor Pro repository auth is NOT configured
- WHEN the user runs `composer install`
- THEN the command fails with an authentication error
- AND the error points to `ELEMENTOR_PRO_LICENSE` as the missing variable

### Requirement: Autoloader for mu-plugins

Bedrock MUST autoload PHP files placed in `web/app/mu-plugins/`.

#### Scenario: mu-plugin code executes on page load

- GIVEN a PHP file exists in `web/app/mu-plugins/`
- WHEN any WordPress page is requested
- THEN the mu-plugin code executes before normal plugins
