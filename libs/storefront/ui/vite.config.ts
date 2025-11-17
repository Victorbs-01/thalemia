import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { nxViteTsPaths } from '@nx/vite/plugins/nx-tsconfig-paths.plugin';

export default defineConfig({
  root: __dirname,
  cacheDir: '../../../node_modules/.vite/libs/storefront/ui',

  plugins: [react(), nxViteTsPaths()],

  build: {
    lib: {
      entry: 'src/index.ts',
      name: 'storefront-ui',
      fileName: 'index',
      formats: ['es', 'cjs'],
    },
    rollupOptions: {
      external: [
        'react',
        'react-dom',
        'react/jsx-runtime',
        '@radix-ui/react-dialog',
        '@radix-ui/react-dropdown-menu',
        '@radix-ui/react-label',
        '@radix-ui/react-select',
        '@radix-ui/react-slot',
        'lucide-react',
        'class-variance-authority',
        'clsx',
        'tailwind-merge',
        '@entrepreneur-os/storefront/core',
      ],
    },
  },
});
