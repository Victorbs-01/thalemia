import { defineConfig } from 'vite';
import { nxViteTsPaths } from '@nx/vite/plugins/nx-tsconfig-paths.plugin';

export default defineConfig({
  root: __dirname,
  cacheDir: '../../../node_modules/.vite/libs/storefront/core',

  plugins: [nxViteTsPaths()],

  build: {
    lib: {
      entry: 'src/index.ts',
      name: 'storefront-core',
      fileName: 'index',
      formats: ['es', 'cjs'],
    },
    rollupOptions: {
      external: ['react', 'react-dom', 'graphql', 'gql.tada', 'zod'],
    },
  },
});
