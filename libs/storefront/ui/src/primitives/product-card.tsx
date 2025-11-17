import * as React from 'react';
import { Card, CardContent, CardFooter, CardHeader, CardTitle } from '../components/card';
import { Button } from '../components/button';
import { formatPrice, truncate } from '../lib/utils';
import type { Product } from '@entrepreneur-os/storefront/core';

export interface ProductCardProps {
  product: Product;
  onAddToCart?: (productVariantId: string) => void;
  onViewDetails?: (slug: string) => void;
}

export function ProductCard({
  product,
  onAddToCart,
  onViewDetails,
}: ProductCardProps) {
  const defaultVariant = product.variants[0];
  const image = product.featuredAsset?.preview || product.assets[0]?.preview;

  return (
    <Card className="overflow-hidden hover:shadow-lg transition-shadow">
      <div
        className="aspect-square bg-muted cursor-pointer"
        onClick={() => onViewDetails?.(product.slug)}
      >
        {image ? (
          <img
            src={image}
            alt={product.name}
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-muted-foreground">
            No image
          </div>
        )}
      </div>
      <CardHeader>
        <CardTitle className="text-lg cursor-pointer hover:underline" onClick={() => onViewDetails?.(product.slug)}>
          {product.name}
        </CardTitle>
      </CardHeader>
      <CardContent>
        <p className="text-sm text-muted-foreground">
          {truncate(product.description, 100)}
        </p>
        {defaultVariant && (
          <p className="mt-2 text-xl font-bold">
            {formatPrice(defaultVariant.priceWithTax, defaultVariant.currencyCode)}
          </p>
        )}
      </CardContent>
      <CardFooter>
        <Button
          className="w-full"
          onClick={() => defaultVariant && onAddToCart?.(defaultVariant.id)}
        >
          Add to Cart
        </Button>
      </CardFooter>
    </Card>
  );
}
