🧱 ROADMAP FINAL PARA dev02 – FASE L0 (Versión Limpia y Correcta)
🟢 FASE A — Sistema base (terminado)

Formatear dev02 con Ubuntu — ✔
Usuario con sudo — ✔
Mirrors Tsinghua — ✔
apt update && apt upgrade — ✔
GitHub login + SSH — ✔ Crea con ssh-keygen -t ed25519 -C "tu-email-de-github"

🟦 FASE B — Docker (script 1, obligatorio y antes de todo lo demás)

Script: start-dev02-docker.sh

Instalar paquetes base

Instalar Docker Engine + compose plugin

Habilitar servicio docker

Agregar usuario al grupo docker

Probar Docker (hello-world)

Si Docker funciona → seguir.

Si Docker falla → DETENER TODO (no tailscale).

🟣 FASE C — Apps del sistema (script 2)

Script: start-dev02-apps.sh

Instalar Cursor

Instalar JetBrains Toolbox

Instalar WeChat/Weixin

Instalar cliente VPN GUI (ClashVerge) — app, no configs

🟠 FASE D — Tailscale (script 3 aislado)

NO usar si Docker falló.

Script: start-dev02-tailscale.sh

Instalar paquete tailscale

NO ejecutar tailscale up

Mostrar instrucciones para hacerlo manualmente

Probar Docker después de activar tailscale

docker ps

docker run hello-world

Si Docker se rompe → desinstalar tailscale, reiniciar, documentar el error.

🟣 FASE E — Clonar proyecto

Clonar repo (o git pull)

Instalar Claude local si corresponde

🟩 FASE F — Levantar proyecto (script 4)

Script: start-dev02-project.sh

Levantar vendure-shop backend

Levantar dashboard

Levantar frontend multi-servicio (los 5 servicios iniciales)

Completar un flujo de venta completo

Crear empresa de prueba - Levantar frontend i18n con los 5 servicios:

crear empresa en China

abrir cuenta bancaria

realizar inscripción + contabilidad

arrendar oficina

traducción + visa

Verificar todo en localhost

🔵 FASE G — Exponer web (nginx)

No obligatorio para L0 pero si lo quieres hacer:

Configurar reverse proxy nginx

Exponer servicio

Configurar dominio

Instalar SSL

Probar acceso externo

🟡 FASE H — Monitoreo básico (L0)

Esto va en L0, y solo esto:

Herramientas

Instalar Uptime Kuma vía Docker

Crear checks:

check HTTP vendure

check HTTP dashboard

check HTTP frontend

check ping dev02

check docker.sock si quieres

Probar que Uptime Kuma detecta DOWN y UP (al menos una vez)

Uso local

Instalar htop

Instalar glances

Saber leer: CPU %, RAM, swap, load, contenedores activos.

🎯 ¿Qué scripts pide Junie entonces?

Son solo 4 scripts + 1 opcional mínimo:

start-dev02-docker.sh (prioridad máxima)

start-dev02-apps.sh

start-dev02-tailscale.sh

start-dev02-project.sh

(opcional L0) check-minimal.sh o start-dev02-uptime-kuma.sh
