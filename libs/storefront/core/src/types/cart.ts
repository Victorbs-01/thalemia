/**
 * Cart/Order types for Vendure storefronts
 */

export interface OrderLine {
  id: string;
  productVariantId: string;
  productVariant: {
    id: string;
    name: string;
    sku: string;
    price: number;
    priceWithTax: number;
    currencyCode: string;
    product: {
      id: string;
      name: string;
      slug: string;
      featuredAsset?: {
        preview: string;
      };
    };
  };
  quantity: number;
  linePrice: number;
  linePriceWithTax: number;
}

export interface ActiveOrder {
  id: string;
  code: string;
  state: string;
  active: boolean;
  lines: OrderLine[];
  subTotal: number;
  subTotalWithTax: number;
  shipping: number;
  shippingWithTax: number;
  total: number;
  totalWithTax: number;
  currencyCode: string;
  totalQuantity: number;
}

export interface AddToCartInput {
  productVariantId: string;
  quantity: number;
}

export interface UpdateOrderLineInput {
  orderLineId: string;
  quantity: number;
}
