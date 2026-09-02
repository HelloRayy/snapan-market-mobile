import { supabase } from './supabase';
import type { RealtimeChannel } from '@supabase/supabase-js';
import type {
  Conversation,
  DirectMessage,
  Profile,
} from '@/types/supabase';

// ─────────────────────────────────────────────────────────────────────────────
// Extended Types
// ─────────────────────────────────────────────────────────────────────────────

export interface ConversationWithParticipant extends Conversation {
  /** The other participant (not the current user) */
  other_user: Profile;
  /** Unread message count for the current user */
  unread_count: number;
  /**
   * If product_id is set → Pembeli tab (product inquiry)
   * If null            → Obrolan tab (casual chat)
   */
  product_id: string | null;
}

export interface DirectMessageWithSender extends DirectMessage {
  sender: Profile;
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Conversations
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Fetch semua percakapan milik user yang sedang login,
 * diurutkan berdasarkan pesan terakhir (terbaru dulu).
 */
export async function getUserConversations(
  currentUserId: string
): Promise<ConversationWithParticipant[]> {
  const { data, error } = await supabase
    .from('conversations')
    .select(`
      *,
      participant_one_profile:profiles!conversations_participant_one_fkey(*),
      participant_two_profile:profiles!conversations_participant_two_fkey(*)
    `)
    .or(`participant_one.eq.${currentUserId},participant_two.eq.${currentUserId}`)
    .order('last_message_at', { ascending: false });

  if (error) {
    console.error('Error fetching conversations:', error.message);
    throw error;
  }

  if (!data || data.length === 0) return [];

  // Fetch unread counts per conversation for the current user
  const conversationIds = data.map((c) => c.id);
  const { data: unreadData } = await supabase
    .from('direct_messages')
    .select('conversation_id')
    .in('conversation_id', conversationIds)
    .neq('sender_id', currentUserId)
    .eq('is_read', false);

  const unreadMap: Record<string, number> = {};
  (unreadData || []).forEach((msg) => {
    unreadMap[msg.conversation_id] = (unreadMap[msg.conversation_id] || 0) + 1;
  });

  return data.map((conv) => {
    const p1 = conv.participant_one_profile as unknown as Profile;
    const p2 = conv.participant_two_profile as unknown as Profile;
    const otherUser = p1.id === currentUserId ? p2 : p1;

    return {
      ...conv,
      other_user: otherUser,
      unread_count: unreadMap[conv.id] || 0,
    } as ConversationWithParticipant;
  });
}

/**
 * Cari atau buat percakapan antara dua user.
 * Jika product_id diisi → masuk ke tab Pembeli.
 * Jika null            → masuk ke tab Obrolan.
 */
export async function getOrCreateConversation(
  currentUserId: string,
  otherUserId: string,
  productId?: string | null
): Promise<Conversation> {
  // Cari percakapan yang sudah ada
  const { data: existing } = await supabase
    .from('conversations')
    .select('*')
    .or(
      `and(participant_one.eq.${currentUserId},participant_two.eq.${otherUserId}),` +
      `and(participant_one.eq.${otherUserId},participant_two.eq.${currentUserId})`
    );

  // Filter by product_id separately to handle null correctly
  let matchingConv: Conversation | null = null;
  if (existing) {
    matchingConv = (existing as Conversation[]).find((c) =>
      productId ? c.product_id === productId : c.product_id === null
    ) ?? null;
  }

  if (matchingConv) return matchingConv;

  // Buat percakapan baru jika belum ada
  const { data: newConv, error } = await supabase
    .from('conversations')
    .insert({
      participant_one: currentUserId,
      participant_two: otherUserId,
      product_id: productId || null,
      last_message: '',
    })
    .select()
    .single();

  if (error) {
    console.error('Error creating conversation:', error.message);
    throw error;
  }

  return newConv as Conversation;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Direct Messages
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Fetch semua pesan dalam satu percakapan, diurutkan dari yang terlama.
 * Sekaligus menandai semua pesan masuk sebagai sudah dibaca.
 */
export async function getConversationMessages(
  conversationId: string,
  currentUserId: string
): Promise<DirectMessageWithSender[]> {
  const { data, error } = await supabase
    .from('direct_messages')
    .select(`
      *,
      sender:profiles!direct_messages_sender_id_fkey(*)
    `)
    .eq('conversation_id', conversationId)
    .order('created_at', { ascending: true });

  if (error) {
    console.error(`Error fetching messages for conversation ${conversationId}:`, error.message);
    throw error;
  }

  // Mark incoming messages as read in the background (fire-and-forget)
  supabase
    .from('direct_messages')
    .update({ is_read: true })
    .eq('conversation_id', conversationId)
    .neq('sender_id', currentUserId)
    .eq('is_read', false)
    .then(({ error: readError }) => {
      if (readError) console.warn('Error marking messages as read:', readError.message);
    });

  return (data || []).map((msg) => ({
    ...msg,
    sender: msg.sender as unknown as Profile,
  })) as DirectMessageWithSender[];
}

/**
 * Kirim pesan baru ke dalam percakapan.
 * Juga memperbarui field last_message & last_message_at di tabel conversations.
 */
export async function sendDirectMessage(payload: {
  conversation_id: string;
  sender_id: string;
  message_text: string;
}): Promise<DirectMessageWithSender> {
  const { data, error } = await supabase
    .from('direct_messages')
    .insert({
      conversation_id: payload.conversation_id,
      sender_id: payload.sender_id,
      message_text: payload.message_text,
      is_read: false,
    })
    .select(`
      *,
      sender:profiles!direct_messages_sender_id_fkey(*)
    `)
    .single();

  if (error) {
    console.error('Error sending message:', error.message);
    throw error;
  }

  // Update snapshot last_message on conversation (fire-and-forget)
  const previewText =
    payload.message_text.length > 80
      ? payload.message_text.slice(0, 80) + '…'
      : payload.message_text;

  supabase
    .from('conversations')
    .update({
      last_message: previewText,
      last_message_at: new Date().toISOString(),
    })
    .eq('id', payload.conversation_id)
    .then(({ error: updateError }) => {
      if (updateError) console.warn('Error updating conversation last_message:', updateError.message);
    });

  return {
    ...data,
    sender: data.sender as unknown as Profile,
  } as DirectMessageWithSender;
}

/**
 * Hapus pesan milik sendiri (hanya pengirim yang bisa menghapus).
 */
export async function deleteDirectMessage(
  messageId: string,
  senderId: string
): Promise<void> {
  const { error } = await supabase
    .from('direct_messages')
    .delete()
    .eq('id', messageId)
    .eq('sender_id', senderId);

  if (error) {
    console.error(`Error deleting message ${messageId}:`, error.message);
    throw error;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Realtime Subscriptions (Direct Messages)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Subscribe ke pesan baru dalam satu percakapan secara realtime.
 * Gunakan di halaman chat aktif agar bubble muncul tanpa refresh.
 */
export function subscribeToConversationMessages(
  conversationId: string,
  onNewMessage: (payload: DirectMessageWithSender) => void
): RealtimeChannel {
  return supabase
    .channel(`dm-chat-${conversationId}`)
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'direct_messages',
        filter: `conversation_id=eq.${conversationId}`,
      },
      async (payload) => {
        // Hydrate sender profile for the new message
        const newMsg = payload.new as DirectMessage;
        const { data: senderProfile } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', newMsg.sender_id)
          .single();

        onNewMessage({
          ...newMsg,
          sender: (senderProfile ?? {}) as Profile,
        } as DirectMessageWithSender);
      }
    )
    .subscribe();
}

/**
 * Subscribe ke semua percakapan user — menerima notifikasi ketika ada
 * pesan baru di conversation manapun (berguna di list DM page).
 */
export function subscribeToUserInbox(
  currentUserId: string,
  onConversationUpdate: (payload: any) => void
): RealtimeChannel {
  return supabase
    .channel(`dm-inbox-${currentUserId}`)
    .on(
      'postgres_changes',
      {
        event: 'INSERT',
        schema: 'public',
        table: 'direct_messages',
      },
      (payload) => onConversationUpdate(payload)
    )
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'conversations',
        filter: `participant_one=eq.${currentUserId}`,
      },
      (payload) => onConversationUpdate(payload)
    )
    .on(
      'postgres_changes',
      {
        event: 'UPDATE',
        schema: 'public',
        table: 'conversations',
        filter: `participant_two=eq.${currentUserId}`,
      },
      (payload) => onConversationUpdate(payload)
    )
    .subscribe();
}
