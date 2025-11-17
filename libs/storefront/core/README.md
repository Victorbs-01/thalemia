# @entrepreneur-os/storefront/core

Core data layer for Entrepreneur-OS storefronts.

## Features

- **Vendure GraphQL Client**: Type-safe API client with gql.tada
- **React Hooks**: useProducts, useCart, useAuth
- **TypeScript Types**: Product, Cart, Order types
- **Environment Validation**: Zod-based env validation

## Usage

```typescript
import {
  initVendureClient,
  useProducts,
  useCart,
  useAuth,
} from '@entrepreneur-os/storefront/core';

// Initialize client
initVendureClient({
  endpoint: process.env.VENDURE_SHOP_API_ENDPOINT,
  channelToken: process.env.VENDURE_CHANNEL_TOKEN,
});

// Use hooks in components
function ProductList() {
  const { products, isLoading } = useProducts();
  // ...
}
```

## GraphQL Code Generation

Generate types from Vendure schema:

```bash
pnpm graphql:codegen
```

## Development

```bash
# Build
nx build storefront-core

# Test
nx test storefront-core

# Lint
nx lint storefront-core
```
