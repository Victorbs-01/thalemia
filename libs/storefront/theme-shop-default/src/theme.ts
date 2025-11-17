import { colors } from './colors';
import { typography } from './typography';

export const shopDefaultTheme = {
  name: 'Shop Default Theme',
  description: 'Modern, vibrant theme for retail storefronts',
  colors,
  typography,
  layout: {
    maxWidth: '1400px',
    containerPadding: '1.5rem',
    headerHeight: '72px',
  },
  spacing: {
    xs: '0.375rem',
    sm: '0.625rem',
    md: '1rem',
    lg: '1.75rem',
    xl: '2.5rem',
    '2xl': '4rem',
  },
  borderRadius: {
    sm: '0.375rem',
    md: '0.625rem',
    lg: '1rem',
    xl: '1.5rem',
  },
} as const;

export type ShopDefaultTheme = typeof shopDefaultTheme;
