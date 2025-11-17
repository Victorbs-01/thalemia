import { useState, useEffect, useCallback } from 'react';
import { getVendureClient } from '../client/vendure-client';

export interface Customer {
  id: string;
  title?: string;
  firstName: string;
  lastName: string;
  emailAddress: string;
}

export interface LoginInput {
  username: string;
  password: string;
  rememberMe?: boolean;
}

export interface RegisterInput {
  emailAddress: string;
  firstName: string;
  lastName: string;
  password: string;
}

/**
 * Hook for authentication management
 */
export function useAuth() {
  const [customer, setCustomer] = useState<Customer | null>(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  // Check current authentication status
  const checkAuth = useCallback(async () => {
    try {
      setIsLoading(true);
      const client = getVendureClient();

      const query = `
        query GetActiveCustomer {
          activeCustomer {
            id
            title
            firstName
            lastName
            emailAddress
          }
        }
      `;

      const result = await client.query<{ activeCustomer: Customer | null }>(
        query
      );

      if (result.errors) {
        throw new Error(
          result.errors[0]?.message || 'Failed to check authentication'
        );
      }

      setCustomer(result.data.activeCustomer);
      setIsAuthenticated(!!result.data.activeCustomer);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Unknown error'));
      setIsAuthenticated(false);
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Login
  const login = useCallback(
    async (input: LoginInput) => {
      try {
        setIsLoading(true);
        const client = getVendureClient();

        const mutation = `
          mutation Login($username: String!, $password: String!, $rememberMe: Boolean) {
            login(username: $username, password: $password, rememberMe: $rememberMe) {
              ... on CurrentUser {
                id
                identifier
              }
              ... on ErrorResult {
                errorCode
                message
              }
            }
          }
        `;

        const result = await client.mutate(mutation, input);

        if (result.errors) {
          throw new Error(result.errors[0]?.message || 'Login failed');
        }

        await checkAuth();
        return true;
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Login failed'));
        return false;
      } finally {
        setIsLoading(false);
      }
    },
    [checkAuth]
  );

  // Logout
  const logout = useCallback(async () => {
    try {
      setIsLoading(true);
      const client = getVendureClient();

      const mutation = `
        mutation Logout {
          logout {
            success
          }
        }
      `;

      const result = await client.mutate(mutation);

      if (result.errors) {
        throw new Error(result.errors[0]?.message || 'Logout failed');
      }

      setCustomer(null);
      setIsAuthenticated(false);
      setError(null);
      return true;
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Logout failed'));
      return false;
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Register
  const register = useCallback(
    async (input: RegisterInput) => {
      try {
        setIsLoading(true);
        const client = getVendureClient();

        const mutation = `
          mutation RegisterCustomerAccount($input: RegisterCustomerInput!) {
            registerCustomerAccount(input: $input) {
              ... on Success {
                success
              }
              ... on ErrorResult {
                errorCode
                message
              }
            }
          }
        `;

        const result = await client.mutate(mutation, { input });

        if (result.errors) {
          throw new Error(result.errors[0]?.message || 'Registration failed');
        }

        // After registration, user needs to verify email or login
        return true;
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Registration failed'));
        return false;
      } finally {
        setIsLoading(false);
      }
    },
    []
  );

  useEffect(() => {
    checkAuth();
  }, [checkAuth]);

  return {
    customer,
    isAuthenticated,
    isLoading,
    error,
    login,
    logout,
    register,
    checkAuth,
  };
}
