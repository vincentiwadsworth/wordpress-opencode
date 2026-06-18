# WordPress OpenCode — Multi-Site Agency Workspace

Workspace para gestionar múltiples sitios WordPress desde un solo repositorio, con soporte para Elementor y Avada (Fusion Builder).

Estado: **desarrollo activo** — la herramienta funciona pero estamos armándola sobre la marcha.

[![CI](https://github.com/vincentiwadsworth/wordpress-opencode/actions/workflows/ci.yml/badge.svg)](https://github.com/vincentiwadsworth/wordpress-opencode/actions/workflows/ci.yml)

---

## Qué es

Un repo pensado para diseñadores/devs de WordPress que manejan varios sitios de clientes. En vez de tener un entorno por cliente, este workspace centraliza:

- Conexiones a distintos sitios (URL, credenciales, builder que usa cada uno)
- Skills para que la IA sepa cómo laburar con cada builder
- Un sitio local con DDEV para desarrollo/pruebas

### Builders soportados

- **Elementor** — via `elementor-mcp-agent` (MCP server con soporte multi-site nativo)
- **Avada** (Fusion Builder) — via WP-CLI + shortcodes en `post_content` (no hay MCP agent, funciona igual)

## Qué NO es

- ❌ No es un conversor automático Elementor → Avada (modelos de datos incompatibles)
- ❌ No reemplaza el wp-admin para diseño visual fino
- ❌ No deploya a producción (todavía)

## Setup

```bash
git clone <repo> && cd wordpress-opencode
cp .env.example .env
ddev start                          # levanta PHP 8.3, MariaDB, nginx
ddev wp core install --url='...' --title='...' --admin_user=admin --admin_password=admin --admin_email=admin@example.com
ddev launch
```

**Requiere:** [Docker Desktop](https://www.docker.com/products/docker-desktop/) + [DDEV ≥ 1.22](https://ddev.com/get-started/).

## Agregar un cliente

```bash
cp sites/_template.yaml sites/mi-cliente.yaml
# Completar: url, username, application_password, builder (elementor|avada), ssh (si aplica)
```

**Elementor**: agregar también a `.opencode/elementor-sites.json` (gitignored).
**Avada**: el skill `wp-avada-page` tiene los shortcodes y templates listos.

## Commands reference

| Qué | Cómo |
|-----|------|
| Switch a cliente | `"switch a cliente-id"` |
| Listar clientes | `"list sites"` |
| Crear página | Decile a la IA qué páginas necesitás |
| Instalar plugin | `ddev composer require wpackagist-plugin/<slug>` + `ddev wp plugin activate <slug>` |
| WP-CLI remoto | `ssh user@host "wp --path=... <command>"` |

Ver [AGENTS.md](AGENTS.md) para flujos de trabajo y documentación de skills.

## Stack

DDEV 1.25.2 / PHP 8.3 / MariaDB 10.11 / WordPress 7.0 (Bedrock) / Elementor 3.35.9 / Avada (Fusion Builder, premium) / WP-CLI 2.12.0 / elementor-mcp-agent 1.3.0 / Laravel Pint

## Licencia

MIT
