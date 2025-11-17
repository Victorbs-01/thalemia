# Frontend Stack Architecture

## Overview

The Entrepreneur-OS frontend architecture uses **TanStack Start + React + Vite** for modern, high-performance storefronts. The architecture separates data layer, UI components, and themes to enable multiple distinct storefronts sharing common functionality.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Storefront Applications                  │
├──────────────────────────┬──────────────────────────────────┤
│   front-master (:3011)   │    front-shop-01 (:3012)        │
│   TanStack Start         │    TanStack Start                │
│   theme-master           │    theme-shop-default            │
└───────────┬──────────────┴──────────────┬───────────────────┘
            │                              │
            ├──────────────┬───────────────┤
            │   Shared Libraries           │
            ├──────────────────────────────┤
            │  @entrepreneur-os/           │
            │  ├─ storefront/core          │ ← Vendure client, hooks, types
            │  ├─ storefront/ui            │ ← shadcn/ui components
            │  ├─ storefront/theme-master  │ ← Master theme config
            │  └─ storefront/theme-shop-*  │ ← Shop theme configs
            └──────────────┬───────────────┘
                           │
            ┌──────────────┴───────────────┐
            │    Vendure Backend           │
            │  vendure-ecommerce (:3002)   │
            │  PostgreSQL (:5433)          │
            └──────────────────────────────┘
```

## Storefront Applications

### front-master (Port 3011)
- **Purpose**: Main customer-facing storefront
- **Theme**: `@entrepreneur-os/storefront/theme-master`
- **Design**: Clean, professional TanStack starter-inspired
- **Use Case**: Primary product catalog and master store

### front-shop-01 (Port 3012)
- **Purpose**: Alternative branded shop
- **Theme**: `@entrepreneur-os/storefront/theme-shop-default`
- **Design**: Vibrant, engaging retail design
- **Use Case**: Secondary shops, different product lines, or tenant-specific stores

## Shared Libraries

### libs/storefront/core
**Purpose**: Vendure API client and data layer

**Contents**:
- `client/vendure-client.ts` - GraphQL client with gql.tada
- `hooks/useProducts.ts` - Product data fetching
- `hooks/useCart.ts` - Shopping cart management
- `hooks/useAuth.ts` - Customer authentication
- `types/` - TypeScript interfaces for Product, Cart, Order
- `utils/env.ts` - Environment variable validation (Zod)

**Import Example**:
```typescript
import {
  initVendureClient,
  useProducts,
  useCart,
  useAuth,
} from '@entrepreneur-os/storefront/core';
```

### libs/storefront/ui
**Purpose**: Shared UI component library (shadcn/ui-based)

**Contents**:
- `components/` - shadcn/ui components (Button, Card, Dialog, Select)
- `primitives/` - Business components (ProductCard, CartItem)
- `lib/utils.ts` - Utility functions (cn, formatPrice, truncate)
- `styles/globals.css` - Tailwind CSS base styles

**Import Example**:
```typescript
import {
  Button,
  Card,
  ProductCard,
  CartItem,
} from '@entrepreneur-os/storefront/ui';
```

### libs/storefront/theme-master
**Purpose**: Theme configuration for front-master

**Contents**:
- `theme.ts` - Complete theme object
- `colors.ts` - Color palette (black/white/blue accent)
- `typography.ts` - Font configuration (Inter)

### libs/storefront/theme-shop-default
**Purpose**: Theme configuration for shop storefronts

**Contents**:
- `theme.ts` - Complete theme object
- `colors.ts` - Color palette (indigo/purple/pink)
- `typography.ts` - Font configuration (Poppins)

## Technology Stack

### Core Framework
- **TanStack Start** 1.132.0 - Full-stack React framework with SSR
- **TanStack Router** 1.132.0 - Type-safe file-based routing
- **React** 19.2.0 - Latest with concurrent features
- **Vite** 7.1.7 - Lightning-fast build tool

### GraphQL & Type Safety
- **gql.tada** 1.8.13 - Compile-time GraphQL type generation
- **graphql** 16.11.0 - GraphQL runtime

### UI & Styling
- **Tailwind CSS** 4.0.6 - Utility-first CSS framework
- **shadcn/ui** - Radix UI-based components
- **Radix UI** - Accessible primitives
- **lucide-react** - Icon library
- **class-variance-authority** - Component variant styling

### State Management
- **TanStack Form** 1.23.8 - Form state management
- React hooks for global state (cart, auth)

### Build & Dev Tools
- **@vitejs/plugin-react** 5.0.4 - React Fast Refresh
- **vite-tsconfig-paths** 5.1.4 - Import path resolution
- **@tanstack/router-plugin** 1.132.0 - Route generation

## Design Patterns

### Separation of Concerns

1. **Data Layer** (`storefront/core`)
   - Vendure API interactions
   - Business logic
   - Type definitions

2. **UI Layer** (`storefront/ui`)
   - Reusable components
   - Consistent design system
   - No business logic

3. **Theme Layer** (`storefront/theme-*`)
   - Visual design tokens
   - Typography, colors, spacing
   - No components or logic

4. **Application Layer** (`front-*`)
   - Routes and pages
   - App-specific components
   - Compose shared libraries

### Multi-Shop Strategy

Each shop can:
- **Share**: Data layer, UI components
- **Customize**: Theme, branding, routes, layout
- **Scale**: Add new shops by combining shared libraries with new themes

**Example: Adding front-shop-02**:
```bash
# Copy existing shop
cp -r apps/storefront-vite/front-shop-01 apps/storefront-vite/front-shop-02

# Update port (3013), name, branding
# Create custom theme if needed
nx generate @nx/js:library theme-shop-02 --directory=libs/storefront
```

## Data Flow

```
User Action (Add to Cart)
         ↓
React Component (ProductCard)
         ↓
Hook (useCart.addToCart)
         ↓
Vendure Client (GraphQL mutation)
         ↓
Vendure Ecommerce API (:3002/shop-api)
         ↓
PostgreSQL (:5433)
         ↓
Response propagated back
         ↓
React re-renders with new cart state
```

## Environment Configuration

### Build-time Variables (VITE_*)
Embedded in client bundle, publicly visible:
```bash
VITE_SITE_NAME=My Store
VITE_COMPANY_NAME=My Company
VITE_WEBSITE_URL=https://store.example.com
```

### Runtime Variables
Server-side only, not exposed to client:
```bash
VENDURE_SHOP_API_ENDPOINT=http://localhost:3002/shop-api
VENDURE_CHANNEL_TOKEN=secret-token
SESSION_SECRET=32-character-secret
```

## Deployment Architecture

### Development
- Each storefront runs on its own port (3011, 3012)
- Vite dev server with HMR
- Direct proxy to Vendure API

### Production (Docker)
- Multi-stage builds with nginx
- Static assets served by nginx
- API requests proxied to Vendure
- Gzip compression, caching headers
- Health checks

### Reverse Proxy (Your Datacenter)
```
nginx/Caddy (Public Gateway)
  ├─ store.example.com → front-master:80
  ├─ shop1.example.com → front-shop-01:80
  └─ api.example.com → vendure-ecommerce:3002
```

## Performance Considerations

### Build Optimization
- Tree-shaking with Vite
- Code splitting by route
- Lazy loading for heavy components
- Minification and compression

### Runtime Optimization
- React 19 concurrent features
- TanStack Router preloading
- Image lazy loading
- API response caching (planned)

### Network Optimization
- nginx gzip compression
- Static asset caching (1 year)
- CDN-ready (planned)

## Security

### Client-Side
- XSS protection headers
- Content Security Policy (planned)
- HTTPS only in production

### API Communication
- Session-based authentication
- CORS configuration
- Rate limiting (planned)

### Secrets Management
- Environment variables only
- No secrets in client bundle
- Docker secrets in production

## Future Enhancements

### Planned Features
1. **State Management**: Add Zustand or Jotai for complex global state
2. **Internationalization**: i18n support with multiple languages
3. **Analytics**: Google Analytics / Plausible integration
4. **SEO**: Meta tags, sitemaps, structured data
5. **PWA**: Service worker, offline support
6. **Performance Monitoring**: Sentry error tracking, Core Web Vitals
7. **E2E Testing**: Playwright test suite
8. **GraphQL Codegen**: Automate type generation from Vendure schema

### Scalability Path
- Redis caching layer for product queries
- CDN for static assets
- Kubernetes deployment with autoscaling
- Multi-region deployment

## Related Documentation
- [front-master Development Guide](../dev-env/front-master-tanstack.md)
- [front-shop-01 Development Guide](../dev-env/front-shop-01.md)
- [Local Hosting Guide](../dev-env/front-hosting-local.md)
- [Vendure Setup Guide](../guides/VENDURE-SETUP.md)
