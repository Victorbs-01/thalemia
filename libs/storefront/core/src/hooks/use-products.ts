import { useState, useEffect } from 'react';
import { getVendureClient } from '../client/vendure-client';
import type { Product, ProductSearchResult, ProductListOptions } from '../types/product';

/**
 * Hook to fetch products from Vendure
 * In production, replace with gql.tada typed queries
 */
export function useProducts(options: ProductListOptions = {}) {
  const [products, setProducts] = useState<Product[]>([]);
  const [totalItems, setTotalItems] = useState(0);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        setIsLoading(true);
        const client = getVendureClient();

        // Simple products query - replace with gql.tada in production
        const query = `
          query GetProducts($options: ProductListOptions) {
            products(options: $options) {
              items {
                id
                name
                slug
                description
                featuredAsset {
                  id
                  preview
                }
                variants {
                  id
                  name
                  sku
                  price
                  priceWithTax
                  currencyCode
                }
              }
              totalItems
            }
          }
        `;

        const result = await client.query<{ products: ProductSearchResult }>(
          query,
          { options }
        );

        if (result.errors) {
          throw new Error(result.errors[0]?.message || 'Failed to fetch products');
        }

        setProducts(result.data.products.items);
        setTotalItems(result.data.products.totalItems);
        setError(null);
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Unknown error'));
      } finally {
        setIsLoading(false);
      }
    };

    fetchProducts();
  }, [JSON.stringify(options)]);

  return {
    products,
    totalItems,
    isLoading,
    error,
  };
}

/**
 * Hook to fetch a single product by slug
 */
export function useProduct(slug: string) {
  const [product, setProduct] = useState<Product | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const fetchProduct = async () => {
      try {
        setIsLoading(true);
        const client = getVendureClient();

        const query = `
          query GetProduct($slug: String!) {
            product(slug: $slug) {
              id
              name
              slug
              description
              featuredAsset {
                id
                preview
              }
              assets {
                id
                preview
              }
              variants {
                id
                name
                sku
                price
                priceWithTax
                currencyCode
                stockLevel
              }
            }
          }
        `;

        const result = await client.query<{ product: Product }>(query, { slug });

        if (result.errors) {
          throw new Error(result.errors[0]?.message || 'Failed to fetch product');
        }

        setProduct(result.data.product);
        setError(null);
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Unknown error'));
      } finally {
        setIsLoading(false);
      }
    };

    if (slug) {
      fetchProduct();
    }
  }, [slug]);

  return {
    product,
    isLoading,
    error,
  };
}
