# @entrepreneur-os/storefront/ui

Shared UI component library for Entrepreneur-OS storefronts.

## Components

### shadcn/ui Components
- Button
- Card
- Dialog
- Select

### Business Primitives
- ProductCard - Product listing card with image, price, add to cart
- CartItem - Shopping cart line item with quantity controls

## Usage

```tsx
import {
  Button,
  Card,
  ProductCard,
  CartItem,
} from '@entrepreneur-os/storefront/ui';

function MyComponent() {
  return (
    <ProductCard
      product={product}
      onAddToCart={(variantId) => console.log('Add', variantId)}
      onViewDetails={(slug) => console.log('View', slug)}
    />
  );
}
```

## Styling

This library uses Tailwind CSS with shadcn/ui design system.

Import the global styles in your app:

```tsx
import '@entrepreneur-os/storefront/ui/src/styles/globals.css';
```

## Development

```bash
# Build
nx build storefront-ui

# Test
nx test storefront-ui

# Lint
nx lint storefront-ui
```
