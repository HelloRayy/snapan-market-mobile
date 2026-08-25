import { supabase } from './supabase';
import type {
  InAppOrder,
  InAppOrderWithDetails,
  CreateInAppOrderResult,
  SellerVerifiedStats,
  Profile,
  MarketPost,
  OrderStatusEnum
} from '@/types/supabase';

/**
 * Checkout: Membuat pesanan baru via RPC `create_in_app_order`
 * Menggunakan row-level lock (FOR UPDATE) untuk mencegah race condition double-buy
 */
export async function createInAppOrder(payload: {
  post_id: string;
  quantity: number;
  meeting_point_id: string;
  meeting_point_name: string;
  meeting_time_notes?: string;
  buyer_notes?: string;
}): Promise<CreateInAppOrderResult> {
  const { data, error } = await supabase.rpc('create_in_app_order', {
    p_post_id: payload.post_id,
    p_quantity: payload.quantity,
    p_meeting_point_id: payload.meeting_point_id,
    p_meeting_point_name: payload.meeting_point_name,
    p_meeting_notes: payload.meeting_time_notes || '',
    p_buyer_notes: payload.buyer_notes || ''
  });

  if (error) {
    console.error('Error creating in-app order:', error.message);
    throw error;
  }

  return data as CreateInAppOrderResult;
}

/**
 * Fetch detail order lengkap beserta profil buyer, seller, postingan, dan meeting point
 */
export async function getOrderDetail(orderId: string): Promise<InAppOrderWithDetails | null> {
  const { data, error } = await supabase
    .from('orders')
    .select(`
      *,
      buyer:profiles!orders_buyer_id_fkey(*),
      seller:profiles!orders_seller_id_fkey(*),
      post:market_posts!orders_post_id_fkey(*),
      meeting_point:school_meeting_points!orders_meeting_point_id_fkey(*)
    `)
    .eq('id', orderId)
    .maybeSingle();

  if (error) {
    console.error(`Error fetching order detail ${orderId}:`, error.message);
    throw error;
  }

  if (!data) return null;

  return {
    ...data,
    buyer: data.buyer as unknown as Profile,
    seller: data.seller as unknown as Profile,
    post: data.post as unknown as MarketPost,
    meeting_point: data.meeting_point as unknown as InAppOrderWithDetails['meeting_point']
  };
}

/**
 * Fetch semua pesanan user sebagai pembeli (Riwayat Pembelian)
 */
export async function getOrdersAsBuyer(buyerId: string): Promise<InAppOrderWithDetails[]> {
  const { data, error } = await supabase
    .from('orders')
    .select(`
      *,
      buyer:profiles!orders_buyer_id_fkey(*),
      seller:profiles!orders_seller_id_fkey(*),
      post:market_posts!orders_post_id_fkey(*),
      meeting_point:school_meeting_points!orders_meeting_point_id_fkey(*)
    `)
    .eq('buyer_id', buyerId)
    .order('created_at', { ascending: false });

  if (error) {
    console.error(`Error fetching buyer orders for ${buyerId}:`, error.message);
    throw error;
  }

  return (data || []).map((item) => ({
    ...item,
    buyer: item.buyer as unknown as Profile,
    seller: item.seller as unknown as Profile,
    post: item.post as unknown as MarketPost,
    meeting_point: item.meeting_point as unknown as InAppOrderWithDetails['meeting_point']
  }));
}

/**
 * Fetch semua pesanan masuk untuk penjual (Penjualan Masuk / Incoming Orders)
 */
export async function getOrdersAsSeller(sellerId: string): Promise<InAppOrderWithDetails[]> {
  const { data, error } = await supabase
    .from('orders')
    .select(`
      *,
      buyer:profiles!orders_buyer_id_fkey(*),
      seller:profiles!orders_seller_id_fkey(*),
      post:market_posts!orders_post_id_fkey(*),
      meeting_point:school_meeting_points!orders_meeting_point_id_fkey(*)
    `)
    .eq('seller_id', sellerId)
    .order('created_at', { ascending: false });

  if (error) {
    console.error(`Error fetching seller orders for ${sellerId}:`, error.message);
    throw error;
  }

  return (data || []).map((item) => ({
    ...item,
    buyer: item.buyer as unknown as Profile,
    seller: item.seller as unknown as Profile,
    post: item.post as unknown as MarketPost,
    meeting_point: item.meeting_point as unknown as InAppOrderWithDetails['meeting_point']
  }));
}

/**
 * Filter pesanan berdasarkan status tertentu
 */
export async function getOrdersByStatus(
  userId: string,
  role: 'buyer' | 'seller',
  status: OrderStatusEnum
): Promise<InAppOrderWithDetails[]> {
  const filterColumn = role === 'buyer' ? 'buyer_id' : 'seller_id';

  const { data, error } = await supabase
    .from('orders')
    .select(`
      *,
      buyer:profiles!orders_buyer_id_fkey(*),
      seller:profiles!orders_seller_id_fkey(*),
      post:market_posts!orders_post_id_fkey(*),
      meeting_point:school_meeting_points!orders_meeting_point_id_fkey(*)
    `)
    .eq(filterColumn, userId)
    .eq('status', status)
    .order('created_at', { ascending: false });

  if (error) {
    console.error(`Error fetching ${role} orders with status ${status}:`, error.message);
    throw error;
  }

  return (data || []).map((item) => ({
    ...item,
    buyer: item.buyer as unknown as Profile,
    seller: item.seller as unknown as Profile,
    post: item.post as unknown as MarketPost,
    meeting_point: item.meeting_point as unknown as InAppOrderWithDetails['meeting_point']
  }));
}

/**
 * Penjual menerima pesanan: pending → in_cod
 */
export async function acceptOrder(orderId: string): Promise<InAppOrder> {
  const { data, error } = await supabase
    .from('orders')
    .update({
      status: 'in_cod' as OrderStatusEnum,
      accepted_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    })
    .eq('id', orderId)
    .select()
    .single();

  if (error) {
    console.error(`Error accepting order ${orderId}:`, error.message);
    throw error;
  }

  // Kirim notifikasi ke pembeli bahwa pesanan diterima
  if (data) {
    await supabase.from('order_notifications').insert({
      recipient_id: data.buyer_id,
      order_id: data.id,
      title: 'Pesanan Diterima! ✅',
      message: `Penjual telah menerima pesanan ${data.order_code}. Silakan temui penjual di ${data.meeting_point_name}.`,
      type: 'order_accepted'
    });
  }

  return data;
}

/**
 * Penjual menolak pesanan: pending → rejected
 */
export async function rejectOrder(orderId: string, reason?: string): Promise<InAppOrder> {
  const { data: userData } = await supabase.auth.getUser();
  const currentUserId = userData?.user?.id;

  const { data, error } = await supabase
    .from('orders')
    .update({
      status: 'rejected' as OrderStatusEnum,
      cancelled_by: currentUserId || null,
      cancel_reason: reason || 'Pesanan ditolak oleh penjual',
      updated_at: new Date().toISOString()
    })
    .eq('id', orderId)
    .select()
    .single();

  if (error) {
    console.error(`Error rejecting order ${orderId}:`, error.message);
    throw error;
  }

  // Kirim notifikasi ke pembeli bahwa pesanan ditolak
  if (data) {
    await supabase.from('order_notifications').insert({
      recipient_id: data.buyer_id,
      order_id: data.id,
      title: 'Pesanan Ditolak ❌',
      message: `Pesanan ${data.order_code} telah ditolak oleh penjual. ${reason ? `Alasan: ${reason}` : ''}`,
      type: 'order_rejected'
    });
  }

  return data;
}

/**
 * Pembeli membatalkan pesanan: pending → cancelled
 */
export async function cancelOrder(orderId: string, reason?: string): Promise<InAppOrder> {
  const { data: userData } = await supabase.auth.getUser();
  const currentUserId = userData?.user?.id;

  const { data, error } = await supabase
    .from('orders')
    .update({
      status: 'cancelled' as OrderStatusEnum,
      cancelled_by: currentUserId || null,
      cancel_reason: reason || 'Pesanan dibatalkan oleh pembeli',
      updated_at: new Date().toISOString()
    })
    .eq('id', orderId)
    .select()
    .single();

  if (error) {
    console.error(`Error cancelling order ${orderId}:`, error.message);
    throw error;
  }

  // Kirim notifikasi ke penjual bahwa pesanan dibatalkan
  if (data) {
    await supabase.from('order_notifications').insert({
      recipient_id: data.seller_id,
      order_id: data.id,
      title: 'Pesanan Dibatalkan ⚠️',
      message: `Pesanan ${data.order_code} telah dibatalkan oleh pembeli. ${reason ? `Alasan: ${reason}` : ''}`,
      type: 'order_cancelled'
    });
  }

  return data;
}

/**
 * Selesaikan transaksi COD: in_cod → completed
 * Trigger database secara otomatis: kurangi stok, update statistik penjualan, kirim notifikasi
 */
export async function completeOrder(orderId: string): Promise<InAppOrder> {
  const { data, error } = await supabase
    .from('orders')
    .update({
      status: 'completed' as OrderStatusEnum,
      updated_at: new Date().toISOString()
    })
    .eq('id', orderId)
    .select()
    .single();

  if (error) {
    console.error(`Error completing order ${orderId}:`, error.message);
    throw error;
  }

  return data;
}

/**
 * Fetch statistik penjualan terverifikasi per seller via RPC
 */
export async function getSellerVerifiedStats(sellerId: string): Promise<SellerVerifiedStats> {
  const { data, error } = await supabase.rpc('get_seller_verified_stats', {
    target_seller_id: sellerId
  });

  if (error) {
    console.error(`Error fetching seller stats for ${sellerId}:`, error.message);
    return {
      completed_sales_count: 0,
      unique_buyers_count: 0,
      total_revenue_idr: 0
    };
  }

  return data as SellerVerifiedStats;
}

/**
 * Hitung jumlah pesanan pending masuk untuk penjual (untuk badge counter)
 */
export async function getPendingOrdersCount(sellerId: string): Promise<number> {
  const { count, error } = await supabase
    .from('orders')
    .select('*', { count: 'exact', head: true })
    .eq('seller_id', sellerId)
    .eq('status', 'pending');

  if (error) {
    console.error(`Error fetching pending orders count for seller ${sellerId}:`, error.message);
    return 0;
  }

  return count || 0;
}
