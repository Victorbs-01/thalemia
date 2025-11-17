# Front Master - TanStack Start Storefront

Main customer-facing storefront for Entrepreneur OS, built with TanStack Start.

## Tech Stack

- **TanStack Start** - Full-stack React framework
- **TanStack Router** - Type-safe file-based routing
- **React 19** - Latest React with concurrent features
- **Vite 7** - Lightning-fast build tool
- **Tailwind CSS 4** - Utility-first styling
- **shadcn/ui** - Beautiful, accessible components
- **gql.tada** - Compile-time GraphQL type generation
- **Vendure** - Headless commerce backend

## Development

### Prerequisites

1. Vendure backend running on `http://localhost:3002`
2. Copy `.env.example` to `.env` and configure

### Start Dev Server

```bash
# From repository root
nx serve front-master

# Or using pnpm script
pnpm run dev:master-shop
```

Opens on http://localhost:3011

### Build for Production

```bash
nx build front-master
```

Output: `dist/apps/storefront-vite/front-master/`

### Preview Production Build

```bash
nx preview front-master
```

## Environment Variables

See `.env.example` for all available variables.

Required:
- `VENDURE_SHOP_API_ENDPOINT` - Vendure Shop API URL
- `SESSION_SECRET` - Random 32-character string for session security

Optional:
- `VENDURE_CHANNEL_TOKEN` - For multi-channel setups
- `VITE_COMPANY_NAME` - Company name (client-side)
- `VITE_SITE_NAME` - Site name (client-side)

## Project Structure

```
src/
├── routes/           # File-based routing (TanStack Router)
│   ├── __root.tsx    # Root layout with header/footer
│   ├── index.tsx     # Home page
│   └── products/     # Product pages
├── components/       # App-specific components
├── lib/              # Utilities
├── styles/           # Global styles
├── app.tsx           # Root app component
├── entry-client.tsx  # Client entry point
└── entry-server.tsx  # Server entry point (SSR)
```

## Features

### Current
- Product listing with Vendure integration
- Responsive layout with Tailwind CSS
- Type-safe routing with TanStack Router
- shadcn/ui components for consistent design

### Planned
- Shopping cart with persistence
- Checkout flow
- User authentication
- Order history
- Product search and filtering
- Customer reviews

## Deployment

See `apps/storefront-vite/front-master/Dockerfile` for container deployment.

For local hosting:
```bash
# Build Docker image
docker build -t front-master -f apps/storefront-vite/front-master/Dockerfile .

# Run container
docker run -p 3011:80 front-master
```
