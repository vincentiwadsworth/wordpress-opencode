# Tasks: WordPress Foundation Stack

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~520 (handwritten) + ~3000 (composer.lock) |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | PR 1 → PR 2 → PR 3 → PR 4 → PR 5 |
| Delivery strategy | auto-chain |
| Chain strategy | stacked-to-main |

Decision needed before apply: No
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | PR | Base | Est. Lines |
|------|------|----|------|------------|
| U1 | DDEV container config | PR 1 | main | ~50 |
| U2a | Bedrock scaffold + composer.json | PR 2 | main | ~300 |
| U2b | composer.lock (generated lockfile) | PR 3 | main | ~3000 |
| U3 | Env template + auth script + gitignore | PR 4 | main | ~75 |
| U4 | CI stub + README | PR 5 | main | ~90 |

## Phase 1: DDEV Layer (U1 → PR 1)

- [x] 1.1 Create `.ddev/config.yaml`: name=wordpress-opencode, php_version=8.3, database=mariadb:10.11, webserver_type=nginx-fpm, docroot=web, nodejs_version=20
- [x] 1.2 Create `.ddev/config.composer.yaml`: composer_version=2 + any composer-specific DDEV overrides
- [x] 1.3 Add `hooks.post-start` to config.yaml: exec `bin/setup-composer-auth.sh` then `composer install` (guard: skip if script absent)
- [x] 1.4 Create `.ddev/nginx/bedrock.conf` if DDEV default nginx fails to route `web/` (Bedrock try_files rewrites)
- [x] 1.5 Verify: `ddev config` shows PHP 8.3 + MariaDB 10.11; `git status` tracks `.ddev/config.yaml`

## Phase 2: WordPress/Bedrock Layer (U2a → PR 2)

- [x] 2.1 Scaffold Bedrock: `composer create-project roots/bedrock .` (generates composer.json, config/application.php, config/environments/*.php, web/wp-config.php, wp-cli.yml, .gitignore)
- [x] 2.2 Modify `composer.json`: add repositories (wpackagist + composer.elementor.com with `only`), require elementor/elementor-pro ^3.25, wpackagist-plugin/elementor ^3.25
- [x] 2.3 Verify layout exists: `web/wp/`, `web/app/plugins/`, `web/app/mu-plugins/`, `config/application.php`
- [x] 2.4 Verify: `composer validate` passes; `wp-cli.yml` contains `path: web/wp`

## Phase 3: Composer Lock (U2b → PR 3, size:exception)

- [ ] 3.1 Run `composer install` in DDEV with valid `ELEMENTOR_PRO_LICENSE` to generate `composer.lock`
- [ ] 3.2 Commit `composer.lock` — PR tagged `size:exception` (generated lockfile, not splittable)
- [ ] 3.3 Verify: `composer install --dry-run` reports "nothing to install / update"

## Phase 4: Environment Layer (U3 → PR 4)

- [x] 4.1 Create `.env.example`: DB_NAME/USER/PASSWORD/HOST=db, WP_HOME/WP_SITEURL, WP_ENV=development, WP salts placeholders, ELEMENTOR_PRO_LICENSE=your-license-here
- [x] 4.2 Modify `.gitignore`: add `auth.json`, ensure `.env` ignored, `.env.example` NOT ignored, `/web/wp/` ignored, `/vendor/` ignored
- [x] 4.3 Create `bin/setup-composer-auth.sh`: source `.env`, set `composer config --auth http-basic.composer.elementor.com token <key>`, exit 1 with `ELEMENTOR_PRO_LICENSE` message if unset
- [x] 4.4 Verify: unset license → script errors with license hint; `git add -A` does NOT stage `.env`

## Phase 5: Deploy/CI Layer (U4 → PR 5)

- [x] 5.1 Create `.github/workflows/ci.yml`: PHP 8.3, `composer install`, `composer lint` (Elementor Pro not required in CI — now `suggest`)
- [x] 5.2 Update `README.md`: status, quick start, Elementor Pro install note, directory layout, badges, prerequisites, stack
- [x] 5.3 Verify: `.editorconfig` exists from Bedrock scaffold (PHP/JS/CSS) ✅; no new file needed
