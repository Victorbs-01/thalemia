/**
 * Master theme colors - Clean, professional design
 * Inspired by TanStack starter aesthetic
 */
export const colors = {
  primary: '#000000',
  primaryForeground: '#FFFFFF',
  secondary: '#6B7280',
  secondaryForeground: '#FFFFFF',
  accent: '#3B82F6',
  accentForeground: '#FFFFFF',
  background: '#FFFFFF',
  foreground: '#0F172A',
  muted: '#F3F4F6',
  mutedForeground: '#6B7280',
  border: '#E5E7EB',
  success: '#10B981',
  warning: '#F59E0B',
  error: '#EF4444',
} as const;

export type ThemeColors = typeof colors;
