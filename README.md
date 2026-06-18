# WordPress OpenCode — Multi-Site Agency Workspace

Agency workspace para crear y mantener sitios WordPress con Elementor **o** Avada (Fusion Builder), desde la terminal, con DDEV + Composer + WP-CLI, pensado para flujos con asistencia LLM (OpenCode).

[![CI](https://github.com/vincentiwadsworth/wordpress-opencode/actions/workflows/ci.yml/badge.svg)](https://github.com/vincentiwadsworth/wordpress-opencode/actions/workflows/ci.yml)
[![PHP](https://img.shields.io/badge/PHP-8.3-777bb4?logo=php)](https://www.php.net/)
[![DDEV](https://img.shields.io/badge/DDEV-local-02a8e0?logo=docker)](https://ddev.com/)
[![WordPress](https://img.shields.io/badge/WordPress-7.0-3858e9?logo=wordpress)](https://wordpress.org/)

**Workspace multi-sitio.** Un solo repo para gestionar múltiples sitios WordPress de clientes, cada uno con su builder (Elementor o Avada). [Ver AGENTS.md](AGENTS.md) para el detalle completo del multi-site.

---

## Arranque rápido (sitio local DDEV)

Necesitás [Docker Desktop](https://www.docker.com/products/docker-desktop/) y [DDEV ≥ 1.22](https://ddev.com/get-started/).

```bash
# 1. Cloná el repo
git clone https://github.com/vincentiwadsworth/wordpress-opencode.git
cd wordpress-opencode

# 2. Creá tu .env a partir del template
cp .env.example .env

# 3. (Opcional) Si tenés licencia Elementor Pro, agregala en .env
#    ELEMENTOR_PRO_LICENSE='tu-licencia'

# 4. Levantá el entorno
ddev start

# 5. Instalá WordPress (solo la primera vez)
ddev wp core install \
  --url='https://wordpress-opencode.ddev.site' \
  --title='WordPress OpenCode' \
  --admin_user=admin \
  --admin_password=admin \
  --admin_email=admin@example.com

# 6. Abrí el sitio
ddev launch
```

WordPress corriendo en `https://wordpress-opencode.ddev.site`. Usuario: `admin` / `admin`.

## Multi-Site: Gestionar Varios Clientes

Este repo maneja múltiples sitios WordPress via archivos de configuración en `sites/`:

```bash
sites/
├── _template.yaml      # Template commiteado (referencia)
├── cliente-uno.yaml    # Config por cliente (gitignored)
└── cliente-dos.yaml    # Otro cliente
```

**Comandos de switcheo** (vía lenguaje natural con la IA):
- "switch to `cliente-uno`" — Cambia al sitio activo
- "list sites" — Muestra todos los sitios configurados
- "show active site" — Muestra el sitio activo actual

Cada sitio puede usar **Elementor** o **Avada** (Fusion Builder). La IA elige las herramientas correctas según el builder del sitio activo.

[Ver AGENTS.md para la documentación completa del multi-site →](AGENTS.md)

---

## Stack

| Capa | Herramienta | Versión |
|------|------------|---------|
| Entorno | [DDEV](https://ddev.com/) + Docker | 1.25.2 · PHP 8.3 · MariaDB 10.11 |
| CMS | [WordPress](https://wordpress.org/) (Bedrock) | 7.0 |
| Builder (Elementor) | [Elementor](https://elementor.com/) | 3.35.9 (free, vía Composer) |
| Builder (Avada) | Avada (Fusion Builder) | Via ThemeForest (tema premium) |
| Builder Pro | Elementor Pro | Opcional (requiere licencia) |
| CLI server | [WP-CLI](https://wp-cli.org/) | 2.12.0 (`ddev wp` local, SSH para remoto) |
| AI agent (Elementor) | [elementor-mcp-agent](https://github.com/Mogacode-ma/elementor-mcp-agent) | 1.3.0 (multi-site vía MCP) |
| Lint | [Laravel Pint](https://laravel.com/pint) | 1.x |
| CI/CD | [GitHub Actions](https://github.com/features/actions) | — |

**Prerrequisitos:** [Docker Desktop](https://www.docker.com/products/docker-desktop/) + [DDEV ≥ 1.22](https://ddev.com/get-started/).

---

## Layout del proyecto

```
.
├── .ddev/                       # Entorno DDEV (PHP 8.3, MariaDB 10.11, nginx-fpm)
├── .github/workflows/ci.yml     # CI: composer lint en cada push/PR
├── .opencode/
│   ├── elementor-sites.json     # Sitios Elementor para MCP (gitignored)
│   └── elementor-sites.template.json  # Template para copiar
├── bin/setup-composer-auth.sh   # Auth para Elementor Pro
├── config/                      # Bedrock: config por entorno
├── sites/                       # Per-client configs (gitignored)
│   └── _template.yaml           # Template del schema de sitio
├── skills/                      # Skills LLM por dominio
│   ├── wp-avada-page/           #   Avada page building (shortcodes + WP-CLI)
│   ├── wp-ddev-workflow/        #   DDEV, WP-CLI, remote SSH
│   ├── wp-deploy/               #   Deploy, CI/CD
│   ├── wp-elementor-page/       #   Elementor page building (WP-CLI + MCP)
│   └── wp-multi-site/           #   Site switching entre clientes
├── web/                         # Document root
│   ├── app/plugins/             #   Plugins vía Composer
│   ├── app/themes/              #   Temas
│   ├── app/uploads/             #   Media
│   ├── wp/                      #   WordPress core (Composer, no tocar)
│   └── wp-config.php            #   Bedrock bootstrap
├── .env.example                 # Template de variables de entorno
├── .env                         # Secretos locales (gitignored)
├── composer.json                # Dependencias
├── composer.lock                # Versiones exactas
├── AGENTS.md                    # Documentación completa del workspace
└── wp-cli.yml                   # path: web/wp
```

---

## Estado del proyecto

| Área | Estado |
|------|--------|
| DDEV + PHP 8.3 + MariaDB 10.11 | ✅ Funciona |
| WordPress 7.0 (Bedrock) | ✅ Instalado vía Composer |
| Elementor 3.35.9 (free) | ✅ Instalado y activo |
| Avada/Fusion Builder | ⚠️ Skill listo, requiere compra de tema |
| WP-CLI 2.12.0 | ✅ `ddev wp` + SSH remoto |
| CI (composer lint) | ✅ Funciona en push/PR |
| elementor-mcp-agent en OpenCode | ✅ Funcional (multi-site) |
| Multi-site (sites/*.yaml) | ✅ Skills + AGENTS.md documentados |
| Site switching (Elementor ↔ Avada) | ✅ Skills documentados |
| Deploy a producción | ❌ No implementado (planeado) |
| Tests automatizados | ❌ No hay suite todavía |

---

## Cómo contribuir

¿Encontraste un bug, tenés una mejora, o querés agregar un skill? Abrí un issue o mandá un PR.

Commits con conventional commits: `feat(scope):`, `fix(scope):`, `docs(scope):`, `chore(scope):`.

---

## Licencia

MIT
