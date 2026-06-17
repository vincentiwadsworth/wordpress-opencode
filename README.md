# WordPress + Elementor Pro — Stack Open Source

Stack open source para crear sitios WordPress con Elementor Pro desde la terminal, con DDEV + Composer + WP-CLI, pensado para flujos con asistencia LLM (OpenCode, Claude Code, Cursor).

[![CI](https://github.com/vincentiwadsworth/wordpress-opencode/actions/workflows/ci.yml/badge.svg)](https://github.com/vincentiwadsworth/wordpress-opencode/actions/workflows/ci.yml)
[![PHP](https://img.shields.io/badge/PHP-8.3-777bb4?logo=php)](https://www.php.net/)
[![DDEV](https://img.shields.io/badge/DDEV-local-02a8e0?logo=docker)](https://ddev.com/)
[![WordPress](https://img.shields.io/badge/WordPress-7.0-3858e9?logo=wordpress)](https://wordpress.org/)
[![Elementor](https://img.shields.io/badge/Elementor-3.35-c1316d?logo=elementor)](https://elementor.com/)

---

> **📸 TODO — Agregar screenshot del sitio funcionando**
>
> Capturar la home de `https://wordpress-opencode.ddev.site` después de `ddev start`.
> Guardar en `docs/screenshots/site-preview.png` (1440×900, PNG).

## Arranque rápido

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

La primera vez que corrés `ddev start`, Docker descarga las imágenes — puede llevar unos minutos. Las veces siguientes arranca en segundos.

### Instalar Elementor Pro (requiere licencia)

```bash
# 1. Poné tu licencia en .env
echo "ELEMENTOR_PRO_LICENSE='tu-licencia'" >> .env

# 2. Reiniciá DDEV (ejecuta el hook de auth)
ddev restart

# 3. Instalá Elementor Pro
ddev composer require elementor/elementor-pro

# 4. Activá los plugins
ddev wp plugin activate elementor elementor-pro

# 5. Activá la licencia
ddev wp elementor-pro license activate tu-licencia
```

---

## Para quién es

- **Desarrolladores** que mantienen sitios WordPress con Elementor y quieren entorno reproducible + Git + CI.
- **Usuarios de asistentes LLM** (OpenCode, Claude Code, Cursor) que necesitan interfaces de texto (CLI, archivos de configuración) en vez del panel visual.
- **Equipos chicos** que quieren que cualquier dev pueda clonar y tener el mismo entorno con un comando.

### No es para vos si

- Preferís administrar WordPress desde el admin visual nomás.
- No usás Docker o no querés tenerlo instalado.
- Necesitás Elementor Pro **sin** licencia — la dependencia está como `suggest`, no se instala sola.

---

## Stack

| Capa | Herramienta | Versión |
|------|------------|---------|
| Entorno | [DDEV](https://ddev.com/) + Docker | 1.25.2 · PHP 8.3 · MariaDB 10.11 |
| CMS | [WordPress](https://wordpress.org/) (Bedrock) | 7.0 |
| Builder | [Elementor](https://elementor.com/) | 3.35.9 (free) |
| Builder Pro | Elementor Pro | Opcional (requiere licencia) |
| CLI server | [WP-CLI](https://wp-cli.org/) | 2.12.0 |
| Lint | [Laravel Pint](https://laravel.com/pint) | 1.x |
| CI/CD | [GitHub Actions](https://github.com/features/actions) | — |

**Prerrequisitos:** [Docker Desktop](https://www.docker.com/products/docker-desktop/) + [DDEV ≥ 1.22](https://ddev.com/get-started/).

### CLI builder (experimental)

- **[Respira CLI](https://respira.press/cli) 0.1.4** — instalado globalmente en el host, pero **no conectado** al sitio. Requiere el plugin `inhale-mcp-abilities` y que el sitio esté vinculado. Hoy no es parte del flujo activo.
- **[elementor-mcp-agent](https://github.com/Mogacode-ma/elementor-mcp-agent) 1.3.0** — host-side, expone operaciones de Elementor a la IA. Tiene un bug conocido con `outputSchema` que rompe algunas herramientas en OpenCode. El método principal para crear páginas programáticamente hoy es inyectar `_elementor_data` vía WP-CLI (ver skill `wp-elementor-page`).

---

## Layout del proyecto

```
.
├── .ddev/                       # Entorno DDEV (PHP 8.3, MariaDB 10.11, nginx-fpm)
├── .github/workflows/ci.yml     # CI: composer lint en cada push/PR
├── bin/setup-composer-auth.sh   # Lee ELEMENTOR_PRO_LICENSE del .env y configura auth
├── config/                      # Bedrock: config por entorno (application.php)
├── web/                         # Document root
│   ├── app/plugins/             #   Plugins vía Composer
│   ├── app/themes/              #   Temas
│   ├── app/uploads/             #   Media
│   ├── wp/                      #   WordPress core (Composer, no tocar)
│   └── wp-config.php            #   Bedrock bootstrap
├── .env.example                 # Template trackeado para variables de entorno
├── .env                         # Secretos locales (gitignored)
├── composer.json                # Dependencias
├── composer.lock                # Versiones exactas — instalación reproducible
└── wp-cli.yml                   # path: web/wp
```

---

## Estado del proyecto

El stack base está armado y funciona en local. Esto es lo que hay hoy:

| Área | Estado |
|------|--------|
| DDEV + PHP 8.3 + MariaDB 10.11 | ✅ Funciona |
| WordPress 7.0 (Bedrock) | ✅ Instalado vía Composer |
| Elementor 3.35.9 (free) | ✅ Instalado y activo |
| WP-CLI 2.12.0 | ✅ `ddev wp` |
| CI (composer lint) | ✅ Funciona en push/PR |
| Respira CLI + conexión al sitio | ❌ No conectado aún |
| elementor-mcp-agent en OpenCode | ⚠️ Funcional parcial (bug outputSchema) |
| Deploy a producción | ❌ No implementado (Trellis planeado) |
| Tests automatizados | ❌ No hay suite todavía |

### Lo que aprendimos (y anotamos para quien llegue después)

- **WP_HOME** tiene que coincidir con la URL de DDEV. Si está como `example.com`, la REST API devuelve HTML en vez de JSON.
- **Permalinks** necesitan rewrite flush después del primer setup: `ddev wp rewrite structure '/%postname%/' && ddev wp rewrite flush --hard`.
- **Elementor Pro** está como `suggest` en composer.json, no como `require`. `composer install` funciona sin autenticación.
- **`composer.lock`** está commiteado — las instalaciones son reproducibles en cualquier máquina.

---

## Cómo contribuir

¿Encontraste un bug, tenés una mejora, o querés agregar un skill? Abrí un issue o mandá un PR.

Commits con conventional commits: `feat(scope):`, `fix(scope):`, `docs(scope):`, `chore(scope):`.

---

## Licencia

MIT
