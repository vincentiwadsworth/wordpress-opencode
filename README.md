# WordPress OpenCode — Multi-Site Agency Workspace

Dejá de perder horas en tareas repetitivas de gestión y desarrollo de sitios WordPress. Un solo repo para manejar toda tu cartera de clientes, con Elementor **o** Avada.

```bash
# En vez de:
#   loguearte en 10 wp-admin, crear páginas una por una,
#   instalar plugins a mano, switchear entre builders...
#
# Hacés:
"switch a cliente-uno, creame una landing con hero + servicios + CTA"
# La IA lo hace en segundos. Para Elementor o Avada.
```

[![CI](https://github.com/vincentiwadsworth/wordpress-opencode/actions/workflows/ci.yml/badge.svg)](https://github.com/vincentiwadsworth/wordpress-opencode/actions/workflows/ci.yml)

---

## Para qué sirve

Gestionás sitios WordPress para clientes. Algunos usan **Elementor**, otros **Avada**. Este repo te permite:

- **Unificar** todos tus clientes en un solo lugar
- **Switchear** entre sitios al toque
- **Crear páginas** en segundos para cualquier builder
- **Automatizar** tareas repetitivas (plugins, temas, migraciones)
- **Trabajar con IA** — le decís qué hacer y lo hace

## Lo que NO hace (para que estemos claros)

- ❌ **No convierte páginas de Elementor a Avada automáticamente** — los modelos de datos son incompatibles (`_elementor_data` vs shortcodes en `post_content`). Si migrás un sitio, hay que recrear las páginas.
- ❌ **No reemplaza el wp-admin** — para diseño visual fino, entrás al editor de cada builder.
- ❌ **No deploya a producción** (todavía) — está planeado.
- ❌ **No corré tests automáticos** (todavía).

---

## Setup rápido

```bash
git clone <repo> && cd wordpress-opencode
cp .env.example .env
ddev start                          # levanta entorno local
ddev wp core install --url='...' --title='...' --admin_user=admin --admin_password=admin --admin_email=admin@example.com
ddev launch                         # WordPress funcionando 🚀
```

**Requisitos:** [Docker Desktop](https://www.docker.com/products/docker-desktop/) + [DDEV ≥ 1.22](https://ddev.com/get-started/).

---

## Agregar un cliente

```bash
cp sites/_template.yaml sites/mi-cliente.yaml
# Completá URL, credenciales, builder (elementor|avada), SSH
```

Después, desde la IA: `"switch a mi-cliente"` y ya estás trabajando en ese sitio.

### Si el cliente usa Elementor

Agregalo también a `.opencode/elementor-sites.json` (gitignored). La IA usa `elementor-mcp-agent` con soporte multi-site nativo.

### Si el cliente usa Avada

La IA crea páginas inyectando shortcodes de Fusion Builder en `post_content` via WP-CLI. No hay MCP agent para Avada — funciona igual de rápido.

---

## Commands reference

| Lo que querés hacer | Comando |
|---------------------|---------|
| Switch a un cliente | `"switch a cliente-id"` |
| Listar clientes | `"list sites"` |
| Crear página Elementor | Decile a la IA el contenido |
| Crear página Avada | Decile a la IA el contenido |
| Instalar plugin | `ddev composer require wpackagist-plugin/<slug>` |
| WP-CLI remoto | `ssh user@host "wp --path=... <command>"` |

Ver la documentación completa de skills y flujos en [AGENTS.md](AGENTS.md).

## Stack

| Capa | Herramienta |
|------|-------------|
| Entorno local | DDEV 1.25.2 + PHP 8.3 + MariaDB 10.11 |
| CMS | WordPress 7.0 (Bedrock) |
| Builder (Elementor) | Elementor 3.35.9 (free, Composer) |
| Builder (Avada) | Fusion Builder (tema premium ThemeForest) |
| CLI | WP-CLI 2.12.0 |
| AI agent (Elementor) | elementor-mcp-agent 1.3.0 |
| Lint | Laravel Pint |

## Project layout

```
sites/               # Config de clientes (gitignored, _template.yaml trackeado)
skills/              # Skills LLM por builder/flujo
  wp-avada-page/     #   Avada: shortcodes + WP-CLI
  wp-elementor-page/ #   Elementor: WP-CLI + MCP
  wp-multi-site/     #   Site switching
  wp-ddev-workflow/  #   DDEV + WP-CLI + SSH
  wp-deploy/         #   Deploy (WIP)
web/                 # WordPress + plugins + temas
.ddev/               # Entorno Docker
```

## Licencia

MIT
