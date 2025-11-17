import { z } from 'zod';

/**
 * Environment variable schema for storefront applications
 */
export const envSchema = z.object({
  VENDURE_SHOP_API_ENDPOINT: z.string().url(),
  VENDURE_CHANNEL_TOKEN: z.string().optional(),
  VITE_SITE_NAME: z.string().default('Entrepreneur Store'),
  VITE_COMPANY_NAME: z.string().default('Entrepreneur OS'),
  VITE_WEBSITE_URL: z.string().url().optional(),
  NODE_ENV: z
    .enum(['development', 'production', 'test'])
    .default('development'),
});

export type Env = z.infer<typeof envSchema>;

/**
 * Validate environment variables
 * @param env - Environment variables object (e.g., process.env or import.meta.env)
 * @returns Validated and typed environment variables
 * @throws Error if validation fails
 */
export function validateEnv(env: Record<string, any>): Env {
  try {
    return envSchema.parse(env);
  } catch (error) {
    if (error instanceof z.ZodError) {
      const missing = error.errors.map((e) => e.path.join('.')).join(', ');
      throw new Error(
        `Environment validation failed. Missing or invalid variables: ${missing}`
      );
    }
    throw error;
  }
}

/**
 * Get environment variable with fallback
 */
export function getEnv(key: string, fallback?: string): string {
  // Support both Node.js and Vite environments
  const value =
    typeof process !== 'undefined'
      ? process.env[key]
      : (import.meta.env as any)?.[key];

  if (!value && !fallback) {
    throw new Error(`Required environment variable ${key} is not set`);
  }

  return value || fallback || '';
}
