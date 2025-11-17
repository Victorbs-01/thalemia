Implementation Plan: Nx Makefile & Plop Layers

Overview

Transform the Entrepreneur-OS monorepo with two powerful layers:

1. Makefile Layer: 30+ reusable Nx targets for common workflows (like Make, but native Nx)
2. Plop Layer: 6 custom generators for scaffolding (like Plop, but native Nx)

Phase 1: Create Makefile Layer (Root project.json)

File to Create

C:\dev\thalemia\entrepreneur-os\project.json

What It Does

- Centralizes all common commands under nx make:\* prefix
- Replaces scattered package.json scripts with cacheable Nx targets
- Integrates Docker, database, and infrastructure commands into Nx
- Enables dependency management between tasks
- Provides consistent interface for all workflows

Key Commands Created (30+ total)

Development: make:dev, make:dev-vendure, make:dev-shops
Build: make:build-all, make:build-affected
Testing: make:test-all, make:e2e-all, make:e2e-ui
Quality: make:lint-all, make:format, make:format-check
Docker: make:docker-up, make:docker-down, make:docker-clean, make:docker-rebuild
Database: make:db-reset, make:db-seed, make:db-migrate
Infrastructure: make:infra-start, make:health-check, make:preflight
Utilities: make:clean, make:setup, make:graph, make:ci

Phase 2: Create Plop Layer (Custom Generators)

Files to Create

tools/generators/
├── package.json (workspace generators config)
├── generators.json (generator registry)
├── react-component/ (Generator 1)
│ ├── schema.json
│ ├── index.ts
│ ├── generator.ts
│ └── files/
│ ├── **fileName**.tsx**template**
│ ├── **fileName**.spec.tsx**template**
│ ├── **fileName**.stories.tsx**template**
│ ├── **fileName**.module.css**template**
│ └── index.ts**template**
├── shared-library/ (Generator 2)
│ ├── schema.json
│ ├── index.ts
│ ├── generator.ts
│ └── files/
│ ├── project.json**template**
│ ├── tsconfig.json**template**
│ ├── README.md**template**
│ └── src/index.ts**template**
├── vendure-plugin/ (Generator 3)
│ ├── schema.json
│ ├── index.ts
│ ├── generator.ts
│ └── files/
│ ├── **fileName**.plugin.ts**template**
│ ├── **fileName**.service.ts**template**
│ ├── **fileName**.resolver.ts**template**
│ └── api/api-extensions.ts**template**
├── vendure-entity/ (Generator 4)
│ ├── schema.json
│ ├── index.ts
│ ├── generator.ts
│ └── files/
│ └── **fileName**.entity.ts**template**
├── n8n-workflow/ (Generator 5)
│ ├── schema.json
│ ├── index.ts
│ ├── generator.ts
│ └── files/
│ └── **fileName**.workflow.json**template**
└── api-endpoint/ (Generator 6)
├── schema.json
├── index.ts
├── generator.ts
└── files/
└── **fileName**.resolver.ts**template**

What Each Generator Does

1. react-component: Creates React component + test + Storybook story
2. shared-library: Creates Nx library with proper structure
3. vendure-plugin: Scaffolds Vendure plugin with service/resolver
4. vendure-entity: Creates Vendure database entity
5. n8n-workflow: Generates n8n workflow template JSON
6. api-endpoint: Creates GraphQL query/mutation

Phase 3: Update Configuration Files

Update nx.json

Add generator registration:
{
"generators": {
"@entrepreneur-os/generators": "tools/generators"
}
}

Update package.json

Simplify scripts to use new targets:
{
"scripts": {
"setup": "nx make:setup",
"dev": "nx make:dev",
"build": "nx make:build-all",
"test": "nx make:test-all",
"g:component": "nx generate @entrepreneur-os/generators:react-component",
"g:lib": "nx generate @entrepreneur-os/generators:shared-library",
"g:plugin": "nx generate @entrepreneur-os/generators:vendure-plugin"
}
}

Phase 4: Create Documentation

Files to Create

1. docs/development/MAKEFILE.md - Complete command reference
2. docs/development/GENERATORS.md - Generator usage guide
3. docs/development/QUICK-START.md - Developer onboarding

Implementation Order

Step 1: Makefile Layer

1. Create project.json with all 30+ targets
2. Test basic commands: nx make:clean, nx make:graph
3. Test Docker integration: nx make:docker-up, nx make:health-check
4. Test CI pipeline: nx make:ci

Step 2: Plop Layer - Core Generator

1. Create tools/generators/package.json
2. Create tools/generators/generators.json
3. Implement react-component generator (most commonly used)
4. Test: nx generate @entrepreneur-os/generators:react-component TestButton --project=shared/ui-components

Step 3: Plop Layer - Remaining Generators

1. Implement shared-library generator
2. Implement vendure-plugin generator
3. Implement vendure-entity generator
4. Implement n8n-workflow generator
5. Implement api-endpoint generator
6. Test each generator

Step 4: Integration

1. Update nx.json with generator defaults
2. Simplify package.json scripts
3. Create documentation
4. Test complete workflow end-to-end

Step 5: Team Rollout

1. Create team training documentation
2. Update README.md with new commands
3. Add examples to CLAUDE.md
4. Create video walkthrough (optional)

Expected Outcomes

Before

# Scattered commands

pnpm run docker:up
pnpm run db:reset
pnpm run dev:vendure

# Manual scaffolding

mkdir -p libs/shared/new-lib/src
touch libs/shared/new-lib/src/index.ts

# ... 10+ manual steps

After

# Unified commands

nx make:infra-start # Starts Docker with health checks
nx make:dev # Starts all dev servers

# Automated scaffolding

nx generate shared-library new-lib --domain=shared --type=utils

# ✅ Complete library structure created in seconds

Benefits

- ✅ Reduced token usage: Simple make:\* commands instead of complex scripts
- ✅ Discoverability: nx show projects, tab completion
- ✅ Consistency: All commands follow same pattern
- ✅ Speed: Nx caching applies to custom targets
- ✅ Quality: Templates enforce best practices
- ✅ Documentation: Self-documenting via schemas

Estimated Time

- Phase 1 (Makefile): 1-2 hours
- Phase 2 (Generators): 3-4 hours
- Phase 3 (Config): 30 minutes
- Phase 4 (Docs): 1 hour
- Total: 6-8 hours

Files to Create (Count)

- 1 root project.json
- 6 generator directories (36+ files total)
- 3 documentation files
- Updates to 2 existing files (nx.json, package.json)

Respuesta corta:

Makefile (Phase 1) → hazlo ahora, pero en versión mínima.

Plop / Generators (Phase 2) → haz sólo 1–2 generadores clave ahora y el resto después, cuando tus patrones estén más claros.

Te explico sin humo.

1. ¿Qué realmente te ahorra tokens?

Lo que más ahorra tokens no es tener 30 comandos y 6 generadores “perfectos”, sino:

Que todos los agentes usen los mismos comandos cortos y estables
Ejemplo:

En vez de: “levanta docker, corre vendure, corre shop, corre n8n…”

Dices: nx make:dev y punto.

Que el flujo de trabajo no cambie todo el tiempo
Si hoy defines 6 generadores y la estructura del monorepo todavía está moviéndose, mañana vas a pedirle a la IA que los repare → más tokens.

Conclusión:

Configurar un núcleo estable de targets Nx ahora sí ahorra tokens ya desde hoy.

Configurar demasiadas plantillas cuando el diseño aún se está moviendo = token burner.

2. Qué haría ya mismo (v1 reducido)

De todo el plan de Claude, yo haría ahora:

A) Makefile Layer mínimo en project.json

En vez de 30 targets desde el día uno, define un set chico pero crítico:

make:setup – instalación inicial (pnpm install, etc.)

make:dev – levantar todo el entorno de dev que realmente uses hoy.

make:docker-up / make:docker-down

make:test-all

make:lint-all

make:ci – lo que corre el pipeline básico.

Con eso ya logras:

Un lenguaje común para Claude, Codex, JetBrains, etc.

Menos texto en cada prompt:

“Run full CI = nx make:ci”

“Dev env = nx make:dev”

La estructura del resto de targets (db, infra, etc.) la puedes ir agregando cuando realmente existan.

Piensa este project.json como el “mini-make” del monorepo: mejor tenerlo temprano, aunque sea chiquito.

3. Generators (Plop layer): aquí sí conviene ir por etapas

Lo que propuso Claude es potente, pero es bastante diseño anticipado. Mejor escalonarlo:

Generadores que sí tienen sentido ahora

shared-library
Te define cómo se ve una lib en tu monorepo Nx.
Eso te obliga a decidir cosas importantes:

Dónde viven tus libs (ej. libs/core/..., libs/shared/...).

Estructura base de project.json, tsconfig, README, etc.

vendure-plugin (aunque sea muy básico)
Porque tu ERP gira alrededor de Vendure, y vas a repetir mucho el patrón “plugin + service + resolver”.

Con sólo esos 2 generadores ya:

Evitas estar pidiéndole a la IA “créame otro plugin igual a X pero con Y” una y otra vez.

Fijas el “sabor” de tu arquitectura aplicada a Vendure.

Generadores que yo dejaría para después

Cuando la arquitectura esté más madura:

react-component
Hasta que tengas claro:

Qué design system usarás,

Si habrá Storybook en este repo o en otro,

Cómo vas a organizar apps vs libs/ui.

vendure-entity
Mejor cuando tengas definido de verdad cómo vas a extender el schema de Vendure (y tengas 2–3 ejemplos reales).

n8n-workflow
Útil, pero tu forma de organizar flows (carpetas, nombres, convenciones) todavía no está 100% cristalizada.

api-endpoint
Espera a tener tu “BFF / API” ya en marcha para decidir firma, patrones de error, etc.

4. “¿Y las nuevas plantillas que aparecerán después?”

Sí, van a aparecer nuevas necesidades y patrones. Eso es normal y sano.

Lo importante:

Nx no se rompe por agregar o cambiar generators después.

Puedes tener:

Generadores v1 simples ahora (aunque sean muy básicos),

Y más adelante hacer v2 con más opciones, o nuevos generadores especializados.

Lo que te da tokens gratis a largo plazo es:

Que cuando encuentres un patrón que repites 3+ veces, digas:

“Listo, esto se vuelve generator oficial del monorepo”.

5. Orden recomendado, aterrizado a tu caso

Si lo aterrizo a tu contexto actual (Thalemia / Entrepreneur-OS, Nx, Vendure, n8n, etc.):

Esta semana (prioridad alta)

Crear project.json raíz con ~8–10 targets clave (make:dev, make:ci, make:docker-up/down, make:test-all, make:lint-all, make:setup).

Conectar package.json para que todos los scripts llamen a esos nx make:\*.

Cuando ya tengas Vendure + alguna app base montada

Implementar shared-library generator.

Implementar vendure-plugin generator.

Documentar rápido en docs/development/GENERATORS.md cómo se usan (aunque sea en versión mínima).

Más adelante (cuando empiece frontend serio y n8n real)

react-component, vendure-entity, n8n-workflow, api-endpoint.

Ahí sí haces la ronda de plantillas más completa, ya con patrones comprobados.

6. Resumen directo

¿Montar todo el mega-plan completo ya?
No vale la pena. Te vas a gastar tokens afinando cosas que todavía van a cambiar.

¿Montar un núcleo mínimo ahora?
Sí.

project.json raíz con pocos make:\* estables.

1–2 generators estratégicos (shared-library, vendure-plugin).

¿Las demás plantillas?
Cuando la arquitectura esté más quieta y ya tengas 2–3 ejemplos “manuales” de cada patrón para convertir en generator.

Así conviertes a Nx en tu “Makefile inteligente” desde temprano, pero sin casarte con 40 archivos que después tengas que estar puliendo a punta de tokens.

Create a minimal, stable foundation for the Nx Makefile layer and the Plop-style generator layer.
Do not generate the full 30+ targets or all 6 generators yet.
I only want the essential pieces that will reduce token usage now and prepare the monorepo for future expansion.

Part 1 — Minimal Makefile Layer (project.json at workspace root)

Generate a small set of Nx custom targets under the make:\* namespace:

make:setup
Runs initial workspace setup (Corepack enable, pnpm install, env checks).

make:dev
Starts the development environment for the current stage of the project.
Only include what exists today (Vendure, BFF, or the minimal apps available).

make:docker-up

make:docker-down
For bringing Docker infra up/down.

make:test-all

make:lint-all
Unified test and lint runners.

make:ci
Pipeline task for GitHub Actions.

These targets must be simple, stable, and not anticipate future infra.
I want a clean, minimal project.json that other agents can rely on.

Part 2 — Minimal Generators Layer

Create the generators workspace at:

tools/generators/
package.json
generators.json

Only implement two generators for now:

shared-library
A minimal Nx library generator with:

project.json

simple tsconfig.json

minimal src/index.ts

small README template

vendure-plugin
Basic Vendure plugin generator with:

<name>.plugin.ts

<name>.service.ts

<name>.resolver.ts

minimal api-extensions.ts

These should be intentionally simple — only the required files and a clean schema.

Part 3 — Minimal Integration

Update:

nx.json → register the local generators

package.json → replace scripts with calls to the new make:\* targets

Keep everything minimal and stable.
Do not add Storybook, do not add extra entities, do not add component generators, and do not add additional targets.

The output must reflect a v1 foundation, not the full future plan.

Minimal Nx Makefile & Generator Foundation - Implementation Plan

Part 1: Minimal Makefile Layer (project.json)

Create: C:\dev\thalemia\entrepreneur-os\project.json

This will add 7 make:\* targets to the workspace root:

1. make:setup - Initialize development environment

- Enable Corepack
- Run pnpm install
- Verify .env file exists (copy from .env.example if not)

2. make:dev - Start development servers

- Run pnpm run dev (starts all available dev servers)

3. make:docker-up - Start Docker infrastructure

- Run docker-compose up -d

4. make:docker-down - Stop Docker infrastructure

- Run docker-compose down

5. make:test-all - Run all tests

- Run pnpm run test

6. make:lint-all - Run all linters

- Run pnpm run lint

7. make:ci - Run full CI pipeline locally

- Run lint → format check → type check → tests → build in sequence

Part 2: Minimal Generators Layer

Create directory structure:
tools/generators/
├── package.json (local workspace for generators)
├── generators.json (Nx collection manifest)
├── shared-library/
│ ├── schema.json (input schema)
│ ├── schema.d.ts (TypeScript types)
│ ├── index.ts (export generator function)
│ └── files/ (template files)
└── vendure-plugin/
├── schema.json
├── schema.d.ts
├── index.ts
└── files/

Generator 1: shared-library

- Prompts: library name, directory (ui-components/data-access/utils/types)
- Creates: Library structure in libs/shared/{directory}/{name}/
- Adds: TypeScript path mapping to tsconfig.base.json
- Minimal implementation: index.ts, README.md, project.json, tsconfig.json

Generator 2: vendure-plugin

- Prompts: plugin name, target instance (master/ecommerce/both)
- Creates: Plugin in libs/vendure/plugins/src/{name}/
- Minimal implementation: plugin.ts, index.ts, README.md

Part 3: Minimal Integration

Update nx.json:

- Add generators configuration to register tools/generators as local collection

Update package.json:

- Replace selected scripts with make:\* target calls for consistency
- Keep existing scripts for backward compatibility initially

Key Constraints (Per Your Request):

- ✅ Only 7 make:\* targets (no more)
- ✅ Only 2 generators (shared-library, vendure-plugin)
- ✅ No Storybook, no extra entities, no component generators
- ✅ Simple, stable, minimal foundation
- ✅ Uses only what exists today in the repo
- ✅ No anticipation of future infrastructure

Files to Create/Modify:

1. CREATE project.json (root)
2. CREATE tools/generators/package.json
3. CREATE tools/generators/generators.json
4. CREATE tools/generators/shared-library/ (4 files)
5. CREATE tools/generators/vendure-plugin/ (4 files)
6. MODIFY nx.json (add generators registration)
7. MODIFY package.json (optional: add make:\* shortcuts)
