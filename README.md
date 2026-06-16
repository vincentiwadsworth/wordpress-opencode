# WordPress + Elementor Pro — Stack Open Source

<!-- badges: start -->
<!-- TODO: add CI status badge once repo is on GitHub -->
[![CI](https://github.com/nicolasventures/wordpress-opencode/actions/workflows/ci.yml/badge.svg)](https://github.com/nicolasventures/wordpress-opencode/actions/workflows/ci.yml)
[![PHP](https://img.shields.io/badge/PHP-8.3-777bb4?logo=php)](https://www.php.net/)
[![DDEV](https://img.shields.io/badge/DDEV-local-02a8e0?logo=docker)](https://ddev.com/)
[![WordPress](https://img.shields.io/badge/WordPress-7.0-3858e9?logo=wordpress)](https://wordpress.org/)
[![Elementor](https://img.shields.io/badge/Elementor-3.35-c1316d?logo=elementor)](https://elementor.com/)
<!-- badges: end -->

Stack open source para crear, gestionar y deployar sitios WordPress con Elementor Pro usando herramientas CLI e IA. Diseñado para desarrolladores que trabajan con asistencia LLM (OpenCode, Claude Code, Cursor).

## Estado del proyecto

El stack base está armado y corriendo en local. Esto es lo que ya funciona:

- ✅ DDEV con PHP 8.3, MariaDB 10.11, nginx-fpm
- ✅ WordPress 7.0 instalado vía Bedrock (Composer-managed)
- ✅ Elementor 3.35.9 (free) instalado y activo
- ✅ WP-CLI 2.12.0 disponible (`ddev wp`)
- ✅ Entorno reproducible: `ddev start` levanta todo

Elementor Pro está configurado como dependencia opcional (`suggest` en `composer.json`) — necesita una licencia válida para instalarse. Más abajo te cuento cómo activarlo.

---

## Arranque rápido

Si ya tenés [Docker Desktop](https://www.docker.com/products/docker-desktop/) y [DDEV](https://ddev.com/get-started/) (≥ 1.22):

```bash
# 1. Cloná el repo
git clone https://github.com/nicolasventures/wordpress-opencode.git
cd wordpress-opencode

# 2. Creá tu .env a partir del template
cp .env.example .env

# 3. (Opcional) Si tenés licencia Elementor Pro, completala en .env
#    ELEMENTOR_PRO_LICENSE='tu-licencia'

# 4. Levantá el entorno
ddev start

# 5. Instalá WordPress (la primera vez)
ddev wp core install \
  --url='https://wordpress-opencode.ddev.site' \
  --title='WordPress OpenCode' \
  --admin_user=admin \
  --admin_password=admin \
  --admin_email=admin@example.com

# 6. Abrí el sitio
ddev launch
```

Listo. WordPress corriendo en `https://wordpress-opencode.ddev.site`. Admin: `admin` / `admin`.

### Instalar Elementor Pro (requiere licencia)

Si tenés una licencia de Elementor Pro:

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

## Layout del proyecto

```
.
├── .ddev/                       # Entorno local DDEV (PHP 8.3, MariaDB 10.11)
│   ├── config.yaml              #   Config del contenedor + hooks post-start
│   ├── config.composer.yaml     #   Composer 2 forzado
│   └── nginx/
│       └── bedrock.conf         #   Hardening: bloquea .env, auth.json, etc.
├── .github/
│   └── workflows/
│       └── ci.yml               # CI: composer install + lint en cada push/PR
├── bin/
│   └── setup-composer-auth.sh   # Lee ELEMENTOR_PRO_LICENSE de .env y configura Composer
├── config/                      # Bedrock: configuración por entorno
│   ├── application.php          #   Config base
│   └── environments/
│       ├── development.php
│       ├── staging.php
│       └── production.php
├── web/                         # Document root (nginx-fpm apunta acá)
│   ├── app/
│   │   ├── mu-plugins/          #   Must-use plugins (Bedrock autoloader)
│   │   ├── plugins/             #   Plugins vía Composer (Elementor, etc.)
│   │   ├── themes/              #   Temas vía Composer
│   │   └── uploads/             #   Media
│   ├── wp/                      #   WordPress core (Composer-managed)
│   ├── wp-config.php            #   Bedrock bootstrap (carga .env)
│   └── index.php                #   Front controller
├── .editorconfig                # Editor settings (spaces, charset, EOL)
├── .env.example                 # Template de variables de entorno (git tracked)
├── .env                         # Tus secretos locales (gitignored)
├── .gitignore
├── composer.json                # Dependencias: Bedrock + Elementor + tooling
├── composer.lock                # Versiones exactas — instalación reproducible
├── README.md                    # Este archivo
└── wp-cli.yml                   # WP-CLI config: path: web/wp
```

---

## Cómo funciona

Imaginá que querés crear y mantener sitios web para clientes. Cada sitio usa WordPress + Elementor Pro. Pero en vez de hacer todo a mano desde el panel de administración, vos le pedís a la IA que haga el trabajo pesado.

El problema: la IA no puede hacer clics en una interfaz visual. Necesita **interfaces de texto** — archivos de configuración y líneas de comando.

### Las 4 capas del taller

```
┌─────────────────────────────────────────┐
│  VOS  ←→  OpenCode (LLM)                │  ← Le pedís cosas
├─────────────────────────────────────────┤
│  Skills + CLI tools                     │  ← Traducen órdenes a WP
├─────────────────────────────────────────┤
│  WordPress + Elementor Pro              │  ← El motor real del sitio
├─────────────────────────────────────────┤
│  DDEV / Docker (entorno local)          │  ← La computadora virtual
└─────────────────────────────────────────┘
```

### Flujo real, paso a paso

**1. Arrancás un proyecto nuevo**

```bash
# Un comando, y tenés WordPress corriendo en tu máquina
ddev start
```

Esto levanta un WordPress completo (PHP, base de datos, todo) en 30 segundos. Nada de instalar XAMPP, ni configurar Apache a mano.

**2. Instalás Elementor Pro desde la terminal**

En vez de bajar un `.zip` y subirlo por el panel:

```bash
# WP-CLI instala y activa plugins con una línea
wp plugin install elementor --activate
wp elementor-pro license activate TU-LICENCIA
```

**3. Le pedís a la IA que cree una página**

Vos decís: _"Creame un landing page para una inmobiliaria con hero, 3 cards de propiedades, y formulario de contacto"_

La IA:
- Usa **Respira CLI** para inyectar el layout directamente en el JSON que Elementor entiende
- O usa **elementor-mcp-agent** para crear widgets, secciones, y estilos
- Hace un snapshot antes de tocar nada (si algo sale mal, vuelve atrás)
- Valida que la página renderice bien

**4. Todo vive en Git**

```
composer.json   ← Qué plugins, qué versión de WP, qué tema
.ddev/          ← Configuración del entorno (idéntico para todo el equipo)
.env            ← API keys, licencias (NUNCA al repositorio)
```

Cuando otro dev clona el repo y hace `ddev start`, tiene EXACTAMENTE el mismo entorno que vos.

**5. Deploy a producción**

```bash
# Trellis o un pipeline de GitHub Actions
git push → se construye → se deploya al servidor → cero downtime
```

---

### ¿Qué hace cada pieza?

| Pieza | Rol | Analogía |
|-------|-----|----------|
| **DDEV** | Entorno local idéntico al servidor | La mesa de trabajo del taller |
| **WP-CLI** | Administrar WordPress desde terminal | La llave inglesa multiuso |
| **Respira CLI** | Leer/escribir layouts de Elementor como JSON | El CNC que corta con precisión |
| **Elementor MCP** | Exponer 100+ operaciones de Elementor a la IA | El tablero de control del CNC |
| **Bedrock** | Manejar WP y plugins con Composer | El inventario de partes |
| **Trellis** | Provisionar servidores y hacer deploy | El camión que lleva el mueble a la casa |

---

### Lo que NO necesitás hacer más

- ❌ Instalar WordPress manualmente
- ❌ Configurar PHP, MySQL, Apache/NGINX a mano
- ❌ Hacer clic en "Update" para cada plugin
- ❌ Subir archivos por FTP
- ❌ Rezar que no se rompa al migrar de local a producción
- ❌ Arrastrar widgets en Elementor durante horas

---

## Prerrequisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [DDEV](https://ddev.com/get-started/) (≥ 1.22)
- PHP 8.3+, Composer 2, Node.js 20+ (para tooling host-side)

---

## Stack

- **WordPress 7.0** gestionado con Composer (Bedrock)
- **Elementor 3.35.9** (free) como builder principal
- **Elementor Pro** disponible como dependencia opcional (requiere licencia)
- **DDEV** para entorno local reproducible
- **WP-CLI 2.12.0** para administración server-side
- **Laravel Pint** para linting PHP
- **Pest** para testing PHP (futuro)
- **Respira CLI** para manipulación nativa de layouts Elementor (host-side, futuro)
- **elementor-mcp-agent** para integración LLM-Elementor (host-side, futuro)
- **Trellis** para deploy y provisioning (futuro)
- **GitHub Actions** para CI/CD

---

## Licencia

MIT
