import { createFileRoute } from '@tanstack/react-router';
import { useProducts } from '@entrepreneur-os/storefront/core';
import { ProductCard } from '@entrepreneur-os/storefront/ui';

export const Route = createFileRoute('/products/')({
  component: ProductsPage,
});

function ProductsPage() {
  const { products, isLoading, error } = useProducts({ take: 12 });

  if (isLoading) {
    return (
      <div className="container mx-auto px-4 py-12">
        <div className="text-center">
          <p className="text-lg text-muted-foreground">Loading products...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="container mx-auto px-4 py-12">
        <div className="text-center">
          <p className="text-lg text-destructive">
            Error loading products: {error.message}
          </p>
          <p className="text-sm text-muted-foreground mt-2">
            Make sure the Vendure backend is running on {import.meta.env.VENDURE_SHOP_API_ENDPOINT}
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-12">
      <div className="mb-8">
        <h1 className="text-4xl font-bold">Products</h1>
        <p className="text-muted-foreground mt-2">
          Browse our collection of {products.length} products
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6">
        {products.map((product) => (
          <ProductCard
            key={product.id}
            product={product}
            onAddToCart={(variantId) => {
              console.log('Add to cart:', variantId);
              // TODO: Implement add to cart
            }}
            onViewDetails={(slug) => {
              console.log('View details:', slug);
              // TODO: Navigate to product page
            }}
          />
        ))}
      </div>

      {products.length === 0 && (
        <div className="text-center py-12">
          <p className="text-lg text-muted-foreground">
            No products found. Add products to your Vendure backend to see them
            here.
          </p>
        </div>
      )}
    </div>
  );
}
