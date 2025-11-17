import { useState, useEffect, useCallback } from 'react';
import { getVendureClient } from '../client/vendure-client';
import type {
  ActiveOrder,
  AddToCartInput,
  UpdateOrderLineInput,
} from '../types/cart';

/**
 * Hook to manage shopping cart (Active Order in Vendure)
 */
export function useCart() {
  const [cart, setCart] = useState<ActiveOrder | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  // Fetch active order
  const fetchCart = useCallback(async () => {
    try {
      setIsLoading(true);
      const client = getVendureClient();

      const query = `
        query GetActiveOrder {
          activeOrder {
            id
            code
            state
            active
            lines {
              id
              quantity
              linePrice
              linePriceWithTax
              productVariant {
                id
                name
                sku
                price
                priceWithTax
                currencyCode
                product {
                  id
                  name
                  slug
                  featuredAsset {
                    preview
                  }
                }
              }
            }
            subTotal
            subTotalWithTax
            shipping
            shippingWithTax
            total
            totalWithTax
            totalQuantity
            currencyCode
          }
        }
      `;

      const result = await client.query<{ activeOrder: ActiveOrder | null }>(
        query
      );

      if (result.errors) {
        throw new Error(result.errors[0]?.message || 'Failed to fetch cart');
      }

      setCart(result.data.activeOrder);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err : new Error('Unknown error'));
    } finally {
      setIsLoading(false);
    }
  }, []);

  // Add item to cart
  const addToCart = useCallback(
    async (input: AddToCartInput) => {
      try {
        setIsLoading(true);
        const client = getVendureClient();

        const mutation = `
          mutation AddItemToOrder($productVariantId: ID!, $quantity: Int!) {
            addItemToOrder(productVariantId: $productVariantId, quantity: $quantity) {
              ... on Order {
                id
                code
                totalQuantity
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
          throw new Error(result.errors[0]?.message || 'Failed to add to cart');
        }

        // Refresh cart
        await fetchCart();
        return true;
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Unknown error'));
        return false;
      } finally {
        setIsLoading(false);
      }
    },
    [fetchCart]
  );

  // Update cart line quantity
  const updateCartLine = useCallback(
    async (input: UpdateOrderLineInput) => {
      try {
        setIsLoading(true);
        const client = getVendureClient();

        const mutation = `
          mutation AdjustOrderLine($orderLineId: ID!, $quantity: Int!) {
            adjustOrderLine(orderLineId: $orderLineId, quantity: $quantity) {
              ... on Order {
                id
                totalQuantity
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
          throw new Error(
            result.errors[0]?.message || 'Failed to update cart line'
          );
        }

        await fetchCart();
        return true;
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Unknown error'));
        return false;
      } finally {
        setIsLoading(false);
      }
    },
    [fetchCart]
  );

  // Remove item from cart
  const removeFromCart = useCallback(
    async (orderLineId: string) => {
      try {
        setIsLoading(true);
        const client = getVendureClient();

        const mutation = `
          mutation RemoveOrderLine($orderLineId: ID!) {
            removeOrderLine(orderLineId: $orderLineId) {
              ... on Order {
                id
                totalQuantity
              }
              ... on ErrorResult {
                errorCode
                message
              }
            }
          }
        `;

        const result = await client.mutate(mutation, { orderLineId });

        if (result.errors) {
          throw new Error(
            result.errors[0]?.message || 'Failed to remove from cart'
          );
        }

        await fetchCart();
        return true;
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Unknown error'));
        return false;
      } finally {
        setIsLoading(false);
      }
    },
    [fetchCart]
  );

  useEffect(() => {
    fetchCart();
  }, [fetchCart]);

  return {
    cart,
    isLoading,
    error,
    addToCart,
    updateCartLine,
    removeFromCart,
    refreshCart: fetchCart,
  };
}
