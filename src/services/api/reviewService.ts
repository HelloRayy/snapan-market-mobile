import { supabase } from './supabase';
import type { ReviewWithUser } from '@/types/supabase';

/**
 * Fetch semua ulasan & rating untuk postingan produk tertentu
 */
export async function getProductReviews(productId: string): Promise<ReviewWithUser[]> {
  const { data, error } = await supabase
    .from('reviews')
    .select(`
      *,
      user:profiles!reviews_user_id_fkey(*)
    `)
    .eq('product_id', productId)
    .order('created_at', { ascending: false });

  if (error) {
    console.error(`Error fetching reviews for product ${productId}:`, error.message);
    throw error;
  }

  return (data || []).map((item) => ({
    ...item,
    user: item.user as unknown as ReviewWithUser['user']
  }));
}

/**
 * Mendapatkan rata-rata rating dan total ulasan produk
 */
export async function getProductRatingStats(productId: string) {
  const { data, error } = await supabase
    .from('reviews')
    .select('rating')
    .eq('product_id', productId);

  if (error) {
    console.error(`Error getting rating stats for product ${productId}:`, error.message);
    return { averageRating: 0, totalReviews: 0 };
  }

  if (!data || data.length === 0) {
    return { averageRating: 0, totalReviews: 0 };
  }

  const sum = data.reduce((acc, curr) => acc + curr.rating, 0);
  const average = Number((sum / data.length).toFixed(1));

  return {
    averageRating: average,
    totalReviews: data.length
  };
}

/**
 * Tulis ulasan produk baru
 */
export async function createProductReview(payload: {
  product_id: string;
  user_id: string;
  rating: number;
  comment?: string;
}): Promise<ReviewWithUser> {
  const { data, error } = await supabase
    .from('reviews')
    .insert({
      product_id: payload.product_id,
      user_id: payload.user_id,
      rating: payload.rating,
      comment: payload.comment || null
    })
    .select(`
      *,
      user:profiles!reviews_user_id_fkey(*)
    `)
    .single();

  if (error) {
    console.error('Error creating product review:', error.message);
    throw error;
  }

  return {
    ...data,
    user: data.user as unknown as ReviewWithUser['user']
  };
}
