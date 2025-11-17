import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { TanStackRouterVite } from '@tanstack/router-plugin/vite';
import tsconfigPaths from 'vite-tsconfig-paths';
import tailwindcss from '@tailwindcss/vite';

export default defineConfig({
  root: __dirname,
  cacheDir: '../../../node_modules/.vite/apps/storefront-vite/front-shop-01',

  plugins: [
    TanStackRouterVite({
      routesDirectory: './src/routes',
      generatedRouteTree: './src/routeTree.gen.ts',
    }),
    react(),
    tsconfigPaths({
      root: '../../../',
    }),
    tailwindcss(),
  ],

  server: {
    port: 3012,
    host: '0.0.0.0',
    proxy: {
      '/shop-api': {
        target: 'http://localhost:3002',
        changeOrigin: true,
      },
    },
  },

  build: {
    outDir: '../../../dist/apps/storefront-vite/front-shop-01',
    emptyOutDir: true,
  },

  preview: {
    port: 3012,
    host: '0.0.0.0',
  },
});
