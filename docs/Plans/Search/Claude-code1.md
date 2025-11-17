Claude.md file, con jerarkia
Mentions @
plan mode Shift + tab 2 times
mcp playrigth – take pictures of frontend
Crear archivos de test
Modificar el comportamiento para dar 2 opciones de hacer las cosas
commands -->file, para tareas especificas. Dentro de la carpeta .claude -
commands, can get $ARGUMENTS  
Setting.local.json para permisos automaticos
file .tress – al menos 3 branch para hacer cosas con agentes paralelos. Ui-banch – test-branch – quality-branch
claude –resume, para ver los chat anteriores
Claude, integra y push to github - /install-github-app
/hook configuration – PreToolUse - PostToolUse– inyecta herramientas antes y despuesta de la ejecucion del codigo de ia – tambien viven en Setting.local.json
figma mcp server,
/model, cambiar opus o sonet

Escape, detiene a claude para darle una nueva instruccion.
combina esc with memory, # - usa eso para darle a claude lo que le falta si se olvida.
Create a test for getSession – (crea pruebas para lo que hizo en la session)
Dos veces esc, volvera al mensaje anterior, eliminando el ultimo mensaje
/compact – Hace un resumen de la conversacion
/Clear – limpia la conversacion e inicia denuevo, para no enredar.

Think
Think more
Think a lot
think longer
ultrathink

DEV LOCAL
JetBrains + Claude
├─ TypeScript estricto
├─ ESLint + Prettier
├─ Tests unitarios rápidos (Vitest)
└─ Hooks (lint-staged, etc.)

PULL REQUEST
CI
├─ tsc --noEmit
├─ eslint
├─ test:unit
├─ test:integration
├─ test:e2e (Playwright smoke)
├─ Qodana / Sonar
├─ pnpm audit / Snyk
└─ gitleaks / secret-scan
