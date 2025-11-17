import { initGraphQLTada } from 'gql.tada';

// Initialize GraphQL Tada - will use generated types from gql/graphql-env.d.ts
// Run `pnpm graphql:codegen` to generate types from Vendure schema
export const graphql = initGraphQLTada();

export interface VendureClientConfig {
  endpoint: string;
  channelToken?: string;
}

export class VendureClient {
  private endpoint: string;
  private channelToken?: string;

  constructor(config: VendureClientConfig) {
    this.endpoint = config.endpoint;
    this.channelToken = config.channelToken;
  }

  async query<TData = any, TVariables = Record<string, any>>(
    query: string,
    variables?: TVariables
  ): Promise<{ data: TData; errors?: any[] }> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
    };

    if (this.channelToken) {
      headers['vendure-token'] = this.channelToken;
    }

    const response = await fetch(this.endpoint, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        query,
        variables,
      }),
      credentials: 'include',
    });

    const result = await response.json();
    return result;
  }

  async mutate<TData = any, TVariables = Record<string, any>>(
    mutation: string,
    variables?: TVariables
  ): Promise<{ data: TData; errors?: any[] }> {
    return this.query<TData, TVariables>(mutation, variables);
  }
}

// Default client instance - will be configured via environment variables
let defaultClient: VendureClient | null = null;

export function getVendureClient(): VendureClient {
  if (!defaultClient) {
    throw new Error(
      'Vendure client not initialized. Call initVendureClient() first.'
    );
  }
  return defaultClient;
}

export function initVendureClient(config: VendureClientConfig): VendureClient {
  defaultClient = new VendureClient(config);
  return defaultClient;
}
