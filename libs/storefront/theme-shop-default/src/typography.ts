/**
 * Shop default theme typography
 */
export const typography = {
  fontFamily: {
    sans: 'Poppins, system-ui, -apple-system, sans-serif',
    mono: 'Fira Code, Monaco, Consolas, monospace',
  },
  fontSize: {
    xs: '0.75rem',
    sm: '0.875rem',
    base: '1rem',
    lg: '1.125rem',
    xl: '1.25rem',
    '2xl': '1.625rem',
    '3xl': '2rem',
    '4xl': '2.5rem',
  },
  fontWeight: {
    normal: 400,
    medium: 500,
    semibold: 600,
    bold: 700,
  },
  lineHeight: {
    tight: 1.2,
    normal: 1.6,
    relaxed: 1.8,
  },
} as const;

export type Typography = typeof typography;
