# WordPress OpenCode — Multi-Site Agency Workspace

Workspace para gestionar múltiples sitios WordPress desde un solo repositorio usando [opencode](https://opencode.ai), un asistente de coding CLI que trabaja directamente sobre tu código. Con **opencode zen** (incluido, sin API key ni suscripción) tenés acceso a varios LLMs gratuitos — Claude, GPT, Gemini y más — aptos para editar páginas en Elementor/Avada, generar CSS, debuggear plugins, y cualquier tarea de desarrollo web.

Estado: **desarrollo activo** — la herramienta funciona pero estamos armándola sobre la marcha.

[![CI](https://github.com/vincentiwadsworth/wordpress-opencode/actions/workflows/ci.yml/badge.svg)](https://github.com/vincentiwadsworth/wordpress-opencode/actions/workflows/ci.yml)

---

## Quick Start

### Prerrequisitos

Necesitás instalar estas herramientas (si no las tenés):

- **[opencode CLI](https://opencode.ai)** — el asistente que recibe tus instrucciones y ejecuta los comandos sobre tu código
- **[Git](https://git-scm.com/downloads)** — para clonar el repositorio
- **[Docker Desktop](https://www.docker.com/products/docker-desktop/)** — para correr los contenedores del entorno local
- **[DDEV](https://ddev.com/get-started/)** — orquesta PHP, MariaDB y nginx adentro de Docker

No necesitás API keys ni suscripciones. opencode zen te da LLMs gratuitos.

### 1. Instalá opencode y activá los LLMs

```bash
npm install -g @opencode/cli
opencode zen
```

Si no tenés npm, bajá el instalador desde [opencode.ai](https://opencode.ai).

### 2. Cloná el repositorio

```bash
git clone https://github.com/vincentiwadsworth/wordpress-opencode.git
cd wordpress-opencode
```

### 3. Configurá el entorno

```bash
cp .env.example .env
```

### 4. Inicializá el entorno local (DDEV)

```bash
ddev start
```

La primera vez descarga las imágenes Docker — puede tardar unos minutos.

### 5. Instalá WordPress

```bash
ddev wp core install \
  --url='http://wordpress-opencode.ddev.site' \
  --title='Mi sitio' \
  --admin_user=admin \
  --admin_password=admin \
  --admin_email=admin@example.com

ddev wp rewrite structure '/%postname%/' && ddev wp rewrite flush --hard
```

### 6. Abrí el sitio

```bash
ddev launch
```

Probá en la terminal con:

```
"mostrame los plugins activos"
"creame una página de prueba con fondo oscuro y texto blanco"
```

---

## Qué es

**opencode** es un CLI que lee tu código, ejecuta herramientas (WP-CLI, git, Docker, etc.) y entiende instrucciones en lenguaje natural. **opencode zen** provee los LLMs gratis — no necesitás API keys de OpenAI/Anthropic ni pagar suscripciones, y los modelos son aptos para editar páginas, diseñar CSS, debuggear, auditar SEO, escribir contenido, etc.

Este repo configura opencode para trabajar con WordPress multisitio. En vez de tener un entorno por cliente, centraliza:

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

## Agregar un cliente

```bash
cp sites/_template.yaml sites/mi-cliente.yaml
# Completar: url, username, application_password, builder (elementor|avada), ssh (si aplica)
```

**Elementor**: agregar también a `.opencode/elementor-sites.json` (gitignored).
**Avada**: el skill `wp-avada-page` tiene los shortcodes y templates listos.

## Cómo pedirle cosas a la IA

No necesitás saber PHP ni WordPress internals. Con HTML/CSS básico alcanza. Sé específico con el diseño:

| Estilo | Ejemplo |
|--------|---------|
| ❌ Muy vago | "Creame una página" |
| ✅ Específico | "Creame una landing con hero oscuro, fondo #0F172A, fuente blanca grande, tres columnas de servicios con bordes redondeados, y un botón verde al final" |
| ❌ Muy vago | "Poneme esto lindo" |
| ✅ Acción concreta | "Cambiá el color de fondo a #F8FAFC y la fuente a algo más moderno" |

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

## Ecosystem skills disponibles

| Skill | Para qué |
|-------|----------|
| `seo-audit` | Auditoría SEO completa del sitio activo |
| `wordpress-content` | Gestión de posts, media, categorías, menús |
| `seo` (web-quality) | SEO técnico: structured data, Core Web Vitals |
| `accessibility` | Auditoría WCAG 2.2 |
| `impeccable` | Diseño frontend, pulido visual |

Ver [AGENTS.md](AGENTS.md) para la documentación completa de skills y flujos.

## Licencia

MIT
