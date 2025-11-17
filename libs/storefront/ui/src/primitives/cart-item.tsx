import * as React from 'react';
import { Minus, Plus, X } from 'lucide-react';
import { Button } from '../components/button';
import { formatPrice } from '../lib/utils';
import type { OrderLine } from '@entrepreneur-os/storefront/core';

export interface CartItemProps {
  item: OrderLine;
  onUpdateQuantity?: (orderLineId: string, quantity: number) => void;
  onRemove?: (orderLineId: string) => void;
}

export function CartItem({ item, onUpdateQuantity, onRemove }: CartItemProps) {
  const { productVariant, quantity, linePriceWithTax } = item;
  const image = productVariant.product.featuredAsset?.preview;

  return (
    <div className="flex gap-4 py-4 border-b">
      <div className="w-20 h-20 bg-muted rounded-md overflow-hidden flex-shrink-0">
        {image ? (
          <img
            src={image}
            alt={productVariant.name}
            className="w-full h-full object-cover"
          />
        ) : (
          <div className="w-full h-full flex items-center justify-center text-sm text-muted-foreground">
            No image
          </div>
        )}
      </div>

      <div className="flex-1 min-w-0">
        <h3 className="font-semibold text-sm truncate">
          {productVariant.product.name}
        </h3>
        <p className="text-sm text-muted-foreground">{productVariant.name}</p>
        <p className="text-sm font-medium mt-1">
          {formatPrice(productVariant.priceWithTax, productVariant.currencyCode)}
        </p>
      </div>

      <div className="flex flex-col items-end gap-2">
        <Button
          variant="ghost"
          size="icon"
          className="h-6 w-6"
          onClick={() => onRemove?.(item.id)}
        >
          <X className="h-4 w-4" />
        </Button>

        <div className="flex items-center gap-2 border rounded-md">
          <Button
            variant="ghost"
            size="icon"
            className="h-8 w-8"
            onClick={() => onUpdateQuantity?.(item.id, Math.max(1, quantity - 1))}
            disabled={quantity <= 1}
          >
            <Minus className="h-3 w-3" />
          </Button>
          <span className="w-8 text-center text-sm font-medium">{quantity}</span>
          <Button
            variant="ghost"
            size="icon"
            className="h-8 w-8"
            onClick={() => onUpdateQuantity?.(item.id, quantity + 1)}
          >
            <Plus className="h-3 w-3" />
          </Button>
        </div>

        <p className="text-sm font-bold">
          {formatPrice(linePriceWithTax, productVariant.currencyCode)}
        </p>
      </div>
    </div>
  );
}
