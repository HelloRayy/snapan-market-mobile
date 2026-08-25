import { supabase } from './supabase';
import type { OrderNotificationWithOrder, InAppOrder } from '@/types/supabase';

/**
 * Fetch semua notifikasi order milik user beserta detail pesanan terkait
 */
export async function getOrderNotifications(userId: string): Promise<OrderNotificationWithOrder[]> {
  const { data, error } = await supabase
    .from('order_notifications')
    .select(`
      *,
      order:orders!order_notifications_order_id_fkey(*)
    `)
    .eq('recipient_id', userId)
    .order('created_at', { ascending: false });

  if (error) {
    console.error(`Error fetching order notifications for user ${userId}:`, error.message);
    throw error;
  }

  return (data || []).map((item) => ({
    ...item,
    order: item.order as unknown as InAppOrder
  }));
}

/**
 * Mendapatkan jumlah notifikasi order yang belum dibaca
 */
export async function getUnreadOrderNotificationCount(userId: string): Promise<number> {
  const { count, error } = await supabase
    .from('order_notifications')
    .select('*', { count: 'exact', head: true })
    .eq('recipient_id', userId)
    .eq('is_read', false);

  if (error) {
    console.error(`Error fetching unread order notification count for user ${userId}:`, error.message);
    return 0;
  }

  return count || 0;
}

/**
 * Tandai satu notifikasi order sebagai sudah dibaca
 */
export async function markOrderNotificationAsRead(notificationId: string): Promise<void> {
  const { error } = await supabase
    .from('order_notifications')
    .update({ is_read: true })
    .eq('id', notificationId);

  if (error) {
    console.error(`Error marking order notification ${notificationId} as read:`, error.message);
    throw error;
  }
}

/**
 * Tandai semua notifikasi order milik user sebagai sudah dibaca
 */
export async function markAllOrderNotificationsAsRead(userId: string): Promise<void> {
  const { error } = await supabase
    .from('order_notifications')
    .update({ is_read: true })
    .eq('recipient_id', userId)
    .eq('is_read', false);

  if (error) {
    console.error(`Error marking all order notifications as read for user ${userId}:`, error.message);
    throw error;
  }
}
