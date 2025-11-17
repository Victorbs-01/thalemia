# Custom Nx Generators for Entrepreneur-OS

This package provides custom code generators for the Entrepreneur-OS monorepo.

## Available Generators

### 1. shared-library

Create a new shared library in `libs/shared/`.

**Usage:**

```bash
# Interactive mode
nx generate @entrepreneur-os/generators:shared-library

# With arguments
nx g @entrepreneur-os/generators:shared-library my-feature --directory=utils

# Short form
pnpm run generate
```

**Options:**

- `name` (required): Library name (e.g., 'my-feature')
- `directory` (required): Category - one of:
  - `ui-components`: React components
  - `data-access`: API clients, GraphQL queries
  - `utils`: Helper functions
  - `types`: TypeScript interfaces

**What it creates:**

- Library structure in `libs/shared/{directory}/{name}/`
- TypeScript configuration files
- Vite test configuration
- Project configuration with build/lint/test targets
- Automatic path mapping in `tsconfig.base.json`

**Example:**

```bash
nx g @entrepreneur-os/generators:shared-library auth-helpers --directory=utils
```

Creates: `libs/shared/utils/auth-helpers/` with import path `@entrepreneur-os/shared/utils/auth-helpers`

---

### 2. vendure-plugin

Create a new Vendure plugin in `libs/vendure/plugins/`.

**Usage:**

```bash
# Interactive mode
nx generate @entrepreneur-os/generators:vendure-plugin

# With arguments
nx g @entrepreneur-os/generators:vendure-plugin multi-tenant --target=both

# Short form
pnpm run generate
```

**Options:**

- `name` (required): Plugin name (e.g., 'multi-tenant')
- `target` (optional): Target instance(s) - one of:
  - `master`: PIM instance only
  - `ecommerce`: Ecommerce instance only
  - `both`: Both instances (default)

**What it creates:**

- Plugin directory in `libs/vendure/plugins/src/{name}/`
- Plugin class with VendurePlugin decorator
- Index file for exports
- README with usage documentation

**Example:**

```bash
nx g @entrepreneur-os/generators:vendure-plugin payment-gateway --target=ecommerce
```

Creates: `libs/vendure/plugins/src/payment-gateway/`

---

## Development

### Project Structure

```
tools/generators/
├── package.json           # Package configuration
├── generators.json        # Nx collection manifest
├── tsconfig.json          # TypeScript configuration
├── shared-library/        # Shared library generator
│   ├── schema.json        # Input schema
│   ├── schema.d.ts        # TypeScript types
│   ├── index.ts           # Generator implementation
│   └── files/             # Template files
└── vendure-plugin/        # Vendure plugin generator
    ├── schema.json
    ├── schema.d.ts
    ├── index.ts
    └── files/
```

### Adding a New Generator

1. Create a new directory: `tools/generators/{name}/`
2. Add schema files:
   - `schema.json` - JSON Schema for input validation
   - `schema.d.ts` - TypeScript types
   - `index.ts` - Generator implementation
3. Create `files/` directory with template files
4. Register in `generators.json`:
   ```json
   {
     "generators": {
       "your-generator": {
         "factory": "./your-generator/index",
         "schema": "./your-generator/schema.json",
         "description": "Your description"
       }
     }
   }
   ```

### Template Files

Template files use EJS syntax:

- `__fileName__` in filename → replaced with actual name
- `<%= variable %>` → replaced with generator options
- `__template__` suffix → removed in output

**Available template variables:**

- `name` - Original name (kebab-case)
- `className` - PascalCase name
- `propertyName` - camelCase name
- `fileName` - kebab-case name
- `constantName` - UPPER_SNAKE_CASE name
- Custom options from schema

---

## Workspace Integration

This package is registered as a local workspace package in `pnpm-workspace.yaml`:

```yaml
packages:
  - 'tools/generators'
```

And configured in `nx.json`:

```json
{
  "generators": {
    "@entrepreneur-os/generators": {
      "shared-library": {},
      "vendure-plugin": {}
    }
  }
}
```

---

## Related Documentation

- [Nx Generators Documentation](https://nx.dev/extending-nx/recipes/local-generators)
- [CLAUDE.md](../../CLAUDE.md) - Main project documentation
- [README.md](../../README.md) - Project overview
