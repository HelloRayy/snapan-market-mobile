import { supabase } from './supabase';
import type { RealtimeChannel } from '@supabase/supabase-js';

/**
 * Subscribe ke event pesanan realtime untuk user tertentu (sebagai buyer atau seller)
 */
export function subscribeToUserOrders(
  userId: string,
  onOrderChange: (payload: any) => void
): RealtimeChannel {
  return supabase
    .channel(`orders-user-${userId}`)
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'orders',
        filter: `seller_id=eq.${userId}`
      },
      (payload) => onOrderChange(payload)
    )
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'orders',
        filter: `buyer_id=eq.${userId}`
      },
      (payload) => onOrderChange(payload)
    )
    .subscribe();
}

/**
 * Subscribe ke notifikasi order realtime untuk user tertentu
 */
export function subscribeToOrderNotifications(
  userId: string,
  onNewNotification: (payload: any) => void
): RealtimeChannel {
  return supabase
    .channel(`order-notifs-${userId}`)
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'order_notifications',
        filter: `recipient_id=eq.${userId}`
      },
      (payload) => onNewNotification(payload)
    )
    .subscribe();
}

/**
 * Subscribe ke live feed market posts (postingan baru / likes counter)
 */
export function subscribeToMarketFeed(
  onFeedChange: (payload: any) => void
): RealtimeChannel {
  return supabase
    .channel('market-feed-live')
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'market_posts'
      },
      (payload) => onFeedChange(payload)
    )
    .subscribe();
}

/**
 * Unsubscribe dari channel Realtime
 */
export async function unsubscribeChannel(channel: RealtimeChannel): Promise<void> {
  await supabase.removeChannel(channel);
}
