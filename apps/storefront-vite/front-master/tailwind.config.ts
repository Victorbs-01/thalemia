import type { Config } from 'tailwindcss';
import baseConfig from '../../../libs/storefront/ui/tailwind.config';

export default {
  ...baseConfig,
  content: [
    './src/**/*.{ts,tsx}',
    './index.html',
    '../../../libs/storefront/ui/src/**/*.{ts,tsx}',
  ],
} satisfies Config;
