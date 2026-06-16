# WordPress + Elementor Pro — Stack Open Source

Stack open source para crear, gestionar y deployar sitios WordPress con Elementor Pro usando herramientas CLI e IA. Diseñado para desarrolladores que trabajan con asistencia LLM (OpenCode, Claude Code, Cursor).

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

## Empezar

### Prerrequisitos

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [DDEV](https://ddev.com/get-started/) (≥ 1.22)
- PHP 8.3+, Composer 2, Node.js 20+

### Instalación

```bash
git clone <este-repo>
cd wordpress-opencode
ddev start
ddev composer install
```

### Stack

- **WordPress** gestionado con Composer (Bedrock)
- **Elementor Pro** + **ProElements** como builder
- **DDEV** para entorno local reproducible
- **WP-CLI** para administración server-side
- **Respira CLI** para manipulación nativa de layouts Elementor
- **Trellis** para deploy y provisioning
- **GitHub Actions** para CI/CD

---

## Licencia

MIT
