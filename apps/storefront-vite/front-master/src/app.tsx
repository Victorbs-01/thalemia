import { StrictMode, useEffect } from 'react';
import { RouterProvider, createRouter } from '@tanstack/react-router';
import { initVendureClient, validateEnv } from '@entrepreneur-os/storefront/core';

// Import the generated route tree
import { routeTree } from './routeTree.gen';

// Validate environment variables
try {
  validateEnv(import.meta.env);
} catch (error) {
  console.error('Environment validation failed:', error);
}

// Initialize Vendure client
initVendureClient({
  endpoint: import.meta.env.VENDURE_SHOP_API_ENDPOINT || 'http://localhost:3002/shop-api',
  channelToken: import.meta.env.VENDURE_CHANNEL_TOKEN,
});

// Create a new router instance
const router = createRouter({ routeTree });

// Register the router instance for type safety
declare module '@tanstack/react-router' {
  interface Register {
    router: typeof router;
  }
}

function App() {
  return (
    <StrictMode>
      <RouterProvider router={router} />
    </StrictMode>
  );
}

export default App;
