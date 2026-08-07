import { supabase } from './supabase';
import type { CartItemWithPost } from '@/types/supabase';

/**
 * Fetch item keranjang belanja milik user beserta detail postingan produk
 */
export async function getCartItems(userId: string): Promise<CartItemWithPost[]> {
  const { data, error } = await supabase
    .from('cart_items')
    .select(`
      *,
      post:market_posts!cart_items_post_id_fkey(
        *,
        seller:profiles!market_posts_seller_id_fkey(*)
      )
    `)
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (error) {
    console.error(`Error fetching cart items for user ${userId}:`, error.message);
    throw error;
  }

  return (data || []).map((item) => ({
    ...item,
    post: {
      ...item.post,
      seller: item.post.seller
    } as unknown as CartItemWithPost['post']
  }));
}

/**
 * Tambah postingan ke keranjang pengguna
 */
export async function addToCart(userId: string, postId: string, quantity: number = 1) {
  const { data, error } = await supabase
    .from('cart_items')
    .upsert(
      {
        user_id: userId,
        post_id: postId,
        quantity
      },
      { onConflict: 'user_id,post_id' }
    )
    .select()
    .single();

  if (error) {
    console.error('Error adding to cart:', error.message);
    throw error;
  }

  return data;
}

/**
 * Ubah jumlah barang di keranjang
 */
export async function updateCartQuantity(cartItemId: string, quantity: number) {
  const { data, error } = await supabase
    .from('cart_items')
    .update({ quantity })
    .eq('id', cartItemId)
    .select()
    .single();

  if (error) {
    console.error(`Error updating cart item ${cartItemId}:`, error.message);
    throw error;
  }

  return data;
}

/**
 * Hapus barang dari keranjang
 */
export async function removeFromCart(cartItemId: string) {
  const { error } = await supabase
    .from('cart_items')
    .delete()
    .eq('id', cartItemId);

  if (error) {
    console.error(`Error removing cart item ${cartItemId}:`, error.message);
    throw error;
  }
}
