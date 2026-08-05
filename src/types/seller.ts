export interface Seller {
  id: string;
  shopName: string;
  logoUrl?: string;
  bannerUrl?: string;
  rating: number;
  isVerified: boolean;
  city: string;
  totalProducts: number;
}
