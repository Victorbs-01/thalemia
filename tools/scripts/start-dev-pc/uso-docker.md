### Cómo usarlo en tu dev02

1. Copia el script en la ruta indicada dentro del repo:

- `tools/start-dev-pc/start-dev02-docker.sh`

2. Da permisos de ejecución:
   ```bash
   chmod +x tools/start-dev-pc/start-dev02-docker.sh
   ```
3. Ejecútalo con sudo:
   ```bash
   sudo tools/start-dev-pc/start-dev02-docker.sh
   ```
4. Observa la salida en modo verbose (gracias a `set -x`).
5. Si ves el mensaje `Reinicia sesión`, cierra sesión y vuelve a entrar para que el grupo `docker` se aplique a tu usuario.
6. Si `docker run hello-world` falla, el script mostrará explícitamente:
   ```
   No instalar VPN ni Tailscale
   ```
   y se detendrá.

Si quieres, en un siguiente paso puedo ayudarte a revisar el script 2 (`start-dev02-apps.sh`) para mantener la misma filosofía y estructura.
