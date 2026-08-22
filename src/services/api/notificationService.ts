import { supabase } from './supabase';
import type { Notification, NotificationWithActor } from '@/types/supabase';

/**
 * Fetch daftar notifikasi user beserta detail profil actor (pengirim) & postingan terkait
 */
export async function getUserNotifications(userId: string): Promise<NotificationWithActor[]> {
  const { data, error } = await supabase
    .from('notifications')
    .select(`
      *,
      actor:profiles!notifications_actor_id_fkey(*),
      post:market_posts!notifications_post_id_fkey(*)
    `)
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (error) {
    console.error(`Error fetching notifications for user ${userId}:`, error.message);
    throw error;
  }

  return (data || []).map((item) => ({
    ...item,
    actor: item.actor as unknown as NotificationWithActor['actor'],
    post: item.post as unknown as NotificationWithActor['post']
  }));
}

/**
 * Mendapatkan jumlah notifikasi yang belum dibaca (unread count)
 */
export async function getUnreadNotificationCount(userId: string): Promise<number> {
  const { count, error } = await supabase
    .from('notifications')
    .select('*', { count: 'exact', head: true })
    .eq('user_id', userId)
    .eq('is_read', false);

  if (error) {
    console.error(`Error fetching unread notification count for user ${userId}:`, error.message);
    throw error;
  }

  return count || 0;
}

/**
 * Tandai satu notifikasi sebagai sudah dibaca
 */
export async function markNotificationAsRead(notificationId: string): Promise<void> {
  const { error } = await supabase
    .from('notifications')
    .update({ is_read: true })
    .eq('id', notificationId);

  if (error) {
    console.error(`Error marking notification ${notificationId} as read:`, error.message);
    throw error;
  }
}

/**
 * Tandai semua notifikasi milik user sebagai sudah dibaca
 */
export async function markAllNotificationsAsRead(userId: string): Promise<void> {
  const { error } = await supabase
    .from('notifications')
    .update({ is_read: true })
    .eq('user_id', userId)
    .eq('is_read', false);

  if (error) {
    console.error(`Error marking all notifications as read for user ${userId}:`, error.message);
    throw error;
  }
}

/**
 * Buat notifikasi baru (misal saat ada yang menyukai post, memberi komentar, atau order baru)
 */
export async function createNotification(payload: {
  user_id: string;
  actor_id?: string;
  type: 'like' | 'comment' | 'reply' | 'order' | 'system';
  title: string;
  message: string;
  post_id?: string;
}): Promise<Notification> {
  const { data, error } = await supabase
    .from('notifications')
    .insert({
      user_id: payload.user_id,
      actor_id: payload.actor_id || null,
      type: payload.type,
      title: payload.title,
      message: payload.message,
      post_id: payload.post_id || null,
      is_read: false
    })
    .select()
    .single();

  if (error) {
    console.error('Error creating notification:', error.message);
    throw error;
  }

  return data;
}
