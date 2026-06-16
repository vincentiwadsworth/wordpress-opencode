# env-configuration Specification

## Purpose

Environment configuration template — secrets out of version control, clear documentation for all required values.

## Requirements

### Requirement: Committed .env.example

The project MUST commit an `.env.example` file documenting all required environment variables with placeholder values and descriptions.

#### Scenario: Fresh clone setup

- GIVEN a developer cloned the repository for the first time
- WHEN they copy `.env.example` to `.env` and fill in real values
- THEN `ddev start` detects the `.env` and Bedrock loads the configuration

### Requirement: Gitignored .env File

The `.env` file MUST be listed in `.gitignore` to prevent secret leakage. `.env.example` MUST NOT be gitignored.

#### Scenario: Prevent accidental secret commit

- GIVEN `.env` contains real database credentials and license keys
- WHEN the user runs `git add .`
- THEN git does NOT stage `.env`
- AND git does stage `.env.example`

### Requirement: Required Environment Variables

`.env.example` MUST define the following variables with clear placeholders:
- Database: `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `DB_HOST`
- WordPress: `WP_HOME`, `WP_SITEURL`, `WP_ENV`
- Security: `AUTH_KEY`, `SECURE_AUTH_KEY`, `LOGGED_IN_KEY`, `NONCE_KEY`, and salts
- Elementor: `ELEMENTOR_PRO_LICENSE`

#### Scenario: Elementor Pro license validates

- GIVEN `.env` has a valid `ELEMENTOR_PRO_LICENSE` value
- WHEN `composer install` resolves Elementor Pro
- THEN the license key is passed to repository authentication
- AND the plugin installs successfully

#### Scenario: Missing required variable produces error

- GIVEN `.env` is missing `DB_NAME`
- WHEN DDEV starts or Bedrock boots
- THEN WordPress shows a configuration error
- AND the error identifies the missing variable
