/**
 * Shop default theme colors - Vibrant, engaging retail design
 */
export const colors = {
  primary: '#6366F1',      // Indigo
  primaryForeground: '#FFFFFF',
  secondary: '#8B5CF6',    // Purple
  secondaryForeground: '#FFFFFF',
  accent: '#EC4899',       // Pink
  accentForeground: '#FFFFFF',
  background: '#FFFFFF',
  foreground: '#1E293B',
  muted: '#F1F5F9',
  mutedForeground: '#64748B',
  border: '#E2E8F0',
  success: '#22C55E',
  warning: '#F97316',
  error: '#DC2626',
} as const;

export type ThemeColors = typeof colors;
