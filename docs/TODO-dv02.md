✅ FASE A — Sistema base (todo listo)

Formatear dev02 con Ubuntu — READY

Usuario con permisos sudo — READY

Mirrors Tsinghua configurados — READY

Ejecutar sudo apt update && sudo apt upgrade — READY

Entrar a bitwarden loguear

Conectarse a GitHub (login + SSH key) — READY

Ver este documento.

vpn para el pc - logear aqui - https://w05.qytwebb05.cc/dashboard
instala https://www.clashverge.dev/install.html

✅ FASE B — Instalar DOCKER (script 1, obligatorio y SIEMPRE antes que VPN)

🔴 Este script es el más importante. Nada de tailscale ni VPN aquí.
🔴 Docker debe funcionar perfecto ANTES de pasar a cualquier otra cosa.

Script: start-dev02-docker.sh

Crear script dedicado:

Verificar SO = Ubuntu

Instalar paquetes base (git, curl, gnupg, lsb-release, ca-certificates, htop)

Instalar Docker Engine desde repos oficiales (NO snap, NO docker.io)

Instalar docker-compose-plugin

Habilitar docker, iniciar servicio

Agregar usuario al grupo docker

Probar docker:

docker run --rm hello-world

Si funciona → continuar

Si no funciona → DETENER TODO, no instalar VPN ni tailscale

✅ FASE C — Instalar aplicaciones del sistema (script 2)

🔹 Esto no tiene riesgo para Docker, se puede instalar después sin problema.

Script: start-dev02-apps.sh

Instalar Cursor (AppImage o .deb oficial), vscode,

Instalar JetBrains Toolbox (descarga + instalar)

Instalar Weixin / WeChat (solo si lo necesitas en ese PC)

🔥 FASE D — Instalar Tailscale (script 3 aislado)

🔴 Tailscale NO se instala junto a Docker.
🔴 Nunca antes. Nunca mezclado.
🔴 Siempre probado después.

Script: start-dev02-tailscale.sh

Instalar paquete tailscale (solo instalación)

NO ejecutar tailscale up en el script

Mostrar instrucciones:

Ejecutar manualmente:

sudo tailscale up --authkey=XXXX

No activar exit node

No tocar routing

PROBAR que Docker sigue funcionando:

docker ps

docker run --rm hello-world

Si Docker falla → documentar, desinstalar tailscale, reiniciar.

✅ FASE E — Clonar el proyecto
Script o manual:

Clonar repo:

git clone git@github.com:Victorbs-01/thalemia.git entrepreneur-os

o si ya está:

git pull

Instalar Claude (si usas la instalación local o scripts necesarios)

⭐ FASE F — Levantar las apps (script 4)

Este script es para comenzar el proyecto en dev02.

Script: start-dev02-project.sh

Levantar vendure-shop backend (docker compose o scripts del repo)

Levantar dashboard

Levantar frontend i18n con los 5 servicios:

crear empresa en China

abrir cuenta bancaria

realizar inscripción + contabilidad

arrendar oficina

traducción + visa

Crear empresa de prueba → flujo completo

Probar flujo de venta completo (~7 pasos)

🚀 FASE G — Servir el sitio al exterior

Instalar NGINX reverse proxy

Exponer website

Revisar DNS + registrar dominio

Instalar SSL (Let’s Encrypt si tienes dominio abierto)

Verificar que todo responde afuera

🛡 FASE H — Monitoring (script 5)
Script: start-dev02-monitoring.sh

Instalar Prometheus + Grafana (docker)

Instalar node-exporter

Conectar dashboards

Activar alertas básicas

Revisar pérdidas, caídas, uso CPU, RAM y errores

📌 RESUMEN DE LOS 5 SCRIPTS QUE DEBE GENERAR JUNIE

start-dev02-docker.sh
Solo Docker. Nada más.

start-dev02-apps.sh
Cursor, JetBrains, Weixin, ClashVerge.

start-dev02-tailscale.sh
Solo instalar tailscale, aviso para hacer el up a mano.

start-dev02-project.sh
Levantar backend, dashboard, frontend, flujo de venta.

start-dev02-monitoring.sh
Prometheus, Grafana, alerting.
