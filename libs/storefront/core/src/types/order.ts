/**
 * Order and checkout types
 */

export interface ShippingAddress {
  fullName: string;
  company?: string;
  streetLine1: string;
  streetLine2?: string;
  city: string;
  province: string;
  postalCode: string;
  countryCode: string;
  phoneNumber?: string;
}

export interface ShippingMethod {
  id: string;
  name: string;
  description: string;
  price: number;
  priceWithTax: number;
}

export interface PaymentMethod {
  id: string;
  code: string;
  name: string;
  description: string;
  isEligible: boolean;
}

export interface OrderCustomer {
  id: string;
  firstName: string;
  lastName: string;
  emailAddress: string;
}

export interface Order {
  id: string;
  code: string;
  state: string;
  active: boolean;
  customer?: OrderCustomer;
  shippingAddress?: ShippingAddress;
  billingAddress?: ShippingAddress;
  shippingMethod?: ShippingMethod;
  payments?: Array<{
    id: string;
    method: string;
    amount: number;
    state: string;
  }>;
  total: number;
  totalWithTax: number;
  currencyCode: string;
  createdAt: string;
  updatedAt: string;
}

export type OrderState =
  | 'AddingItems'
  | 'ArrangingPayment'
  | 'PaymentAuthorized'
  | 'PaymentSettled'
  | 'OrderComplete'
  | 'Cancelled';
