/**
 * Product types for Vendure storefronts
 * These are simplified types - in production, use gql.tada generated types
 */

export interface ProductAsset {
  id: string;
  preview: string;
  source: string;
}

export interface ProductVariantPrice {
  value: number;
  currencyCode: string;
}

export interface ProductVariant {
  id: string;
  name: string;
  sku: string;
  price: number;
  priceWithTax: number;
  currencyCode: string;
  stockLevel: string;
  assets: ProductAsset[];
}

export interface Product {
  id: string;
  name: string;
  slug: string;
  description: string;
  variants: ProductVariant[];
  assets: ProductAsset[];
  featuredAsset?: ProductAsset;
}

export interface ProductListOptions {
  take?: number;
  skip?: number;
  sort?: {
    [key: string]: 'ASC' | 'DESC';
  };
  filter?: {
    [key: string]: any;
  };
}

export interface ProductSearchResult {
  items: Product[];
  totalItems: number;
}
