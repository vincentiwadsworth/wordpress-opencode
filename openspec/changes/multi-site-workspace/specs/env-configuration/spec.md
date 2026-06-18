# Delta for env-configuration

## ADDED Requirements

### Requirement: Per-Site Credential Guidance

The `.env.example` and `AGENTS.md` MUST document that per-site credentials (SSH keys, WordPress application passwords, Elementor license keys for client sites) belong in `sites/*.yaml`, NOT in `.env`. The `.env` retains only the primary (local) project's secrets. The `_template.yaml` SHALL include placeholder fields for all credential types.

#### Scenario: Credential separation documented

- GIVEN a developer reads `.env.example`
- THEN the file documents that `sites/*.yaml` holds per-client secrets
- AND the primary site's `.env` contains only DDEV/Bedrock/Elementor Pro secrets

#### Scenario: Template includes credential placeholders

- GIVEN the developer inspects `sites/_template.yaml`
- THEN it includes commented credential fields for `wp_admin.user`, `wp_admin.app_password`, `ssh.key_path`, and optionally `elementor.license_key`
- AND the template warns that actual values are gitignored
