export interface Product {
  id: string;
  name: string;
  slug: string;
  description: string;
  price: number;
  originalPrice?: number;
  stock: number;
  rating: number;
  soldCount: number;
  category: string;
  images: string[];
  sellerId: string;
  sellerName: string;
  isVerifiedSeller?: boolean;
  createdAt: string;
}

export interface ProductFilter {
  category?: string;
  minPrice?: number;
  maxPrice?: number;
  searchQuery?: string;
  sortBy?: 'popular' | 'latest' | 'price_low' | 'price_high';
}
