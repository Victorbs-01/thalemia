import { colors } from './colors';
import { typography } from './typography';

export const masterTheme = {
  name: 'Master Theme',
  description: 'TanStack starter-inspired theme for the master storefront',
  colors,
  typography,
  layout: {
    maxWidth: '1280px',
    containerPadding: '1rem',
    headerHeight: '64px',
  },
  spacing: {
    xs: '0.25rem',
    sm: '0.5rem',
    md: '1rem',
    lg: '1.5rem',
    xl: '2rem',
    '2xl': '3rem',
  },
  borderRadius: {
    sm: '0.25rem',
    md: '0.5rem',
    lg: '0.75rem',
    xl: '1rem',
  },
} as const;

export type MasterTheme = typeof masterTheme;
