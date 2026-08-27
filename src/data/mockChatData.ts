import { ChatThread, ChatProductContext } from '@/types/chat';

/**
 * Generates an Instagram-style 17-digit numeric snowflake hash identifier
 * (e.g. "17845432127501402")
 */
export function generateNumericThreadId(): string {
  const timestamp = Date.now().toString();
  const randomSuffix = Math.floor(1000 + Math.random() * 9000).toString();
  return `${timestamp}${randomSuffix}`;
}

export const MOCK_CHAT_THREADS: ChatThread[] = [
  {
    id: '17845432127501402',
    participant: {
      id: 'user-sarah',
      name: 'Sarah Anastasya',
      username: 'sarahanas',
      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80',
      isVerified: true,
      isOnline: true,
      classGroup: 'XII PPLG 1',
    },
    productContext: {
      id: 'post-thread-1',
      title: 'Kalkulator Casio FX-991EX ClassWiz Original',
      price: 185000,
      originalPrice: 220000,
      image: 'https://images.unsplash.com/photo-1594980596870-8aa52a78d8cd?w=500&q=80',
      locationTag: 'Kantin Depan',
    },
    unreadCount: 2,
    lastMessage: 'Kalkulator Casio FX-991EX nya masih ada kak? Bisa COD di kantin?',
    lastTimestamp: 'Baru saja',
    isSenderLast: false,
    isBuyerConversation: true,
    messages: [
      {
        id: 'msg-s1',
        threadId: '17845432127501402',
        senderId: 'user-sarah',
        type: 'product_inquiry',
        text: 'Halo kak, saya tertarik dengan produk ini:',
        productContext: {
          id: 'post-thread-1',
          title: 'Kalkulator Casio FX-991EX ClassWiz Original',
          price: 185000,
          originalPrice: 220000,
          image: 'https://images.unsplash.com/photo-1594980596870-8aa52a78d8cd?w=500&q=80',
          locationTag: 'Kantin Depan',
        },
        createdAt: '2026-08-27T08:15:00Z',
        timestamp: '08:15',
        status: 'read',
      },
      {
        id: 'msg-s2',
        threadId: '17845432127501402',
        senderId: 'me',
        type: 'text',
        text: 'Halo Sarah! Masih ready kok, kondisinya 95% mulus lengkap sama cover pelindungnya yaa 👍',
        createdAt: '2026-08-27T08:18:00Z',
        timestamp: '08:18',
        status: 'read',
      },
      {
        id: 'msg-s3',
        threadId: '17845432127501402',
        senderId: 'user-sarah',
        type: 'offer',
        text: 'Boleh nego tipis kak untuk persiapan ujian matematika besok?',
        offer: {
          amount: 175000,
          originalPrice: 185000,
          status: 'accepted',
          note: 'Nego Rp 175.000',
        },
        createdAt: '2026-08-27T08:22:00Z',
        timestamp: '08:22',
        status: 'read',
      },
      {
        id: 'msg-s4',
        threadId: '17845432127501402',
        senderId: 'me',
        type: 'text',
        text: 'Boleh deh kak, deal di Rp 175.000 yaa! Mau COD di mana nanti?',
        createdAt: '2026-08-27T08:25:00Z',
        timestamp: '08:25',
        status: 'read',
      },
      {
        id: 'msg-s5',
        threadId: '17845432127501402',
        senderId: 'me',
        type: 'meeting_point',
        meetingPoint: {
          spotName: 'Kantin Depan (Gazebo Barat)',
          zoneId: 'kantin-depan',
          timeLabel: 'Jam Istirahat ke-2 (12.00 - 12.30)',
          status: 'confirmed',
        },
        createdAt: '2026-08-27T08:30:00Z',
        timestamp: '08:30',
        status: 'read',
      },
      {
        id: 'msg-s6',
        threadId: '17845432127501402',
        senderId: 'user-sarah',
        type: 'text',
        text: 'Kalkulator Casio FX-991EX nya masih ada kak? Bisa COD di kantin?',
        createdAt: '2026-08-27T08:32:00Z',
        timestamp: '08:32',
        status: 'delivered',
      },
    ],
  },
  {
    id: '17892348123791823',
    participant: {
      id: 'user-dimas',
      name: 'Dimas Wicaksono',
      username: 'dimas_wicak',
      avatar: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&q=80',
      isOnline: true,
      classGroup: 'XII TJKT 2',
    },
    productContext: {
      id: 'post-thread-2',
      title: 'Buku Paket Fisika Kelas 12 Kurikulum Merdeka',
      price: 45000,
      image: 'https://images.unsplash.com/photo-1532012164546-f432f2e3edd4?w=500&q=80',
      locationTag: 'Lab Komputer 2',
    },
    unreadCount: 0,
    lastMessage: 'Siap bro, nanti jam istirahat kedua gua tunggu di depan lab komputer yaa.',
    lastTimestamp: '12m',
    isSenderLast: true,
    isBuyerConversation: false,
    messages: [
      {
        id: 'msg-d1',
        threadId: '17892348123791823',
        senderId: 'user-dimas',
        type: 'text',
        text: 'Bro, buku fisika nya masih bersih kan gak ada coretan pulpen?',
        createdAt: '2026-08-27T07:10:00Z',
        timestamp: '07:10',
        status: 'read',
      },
      {
        id: 'msg-d2',
        threadId: '17892348123791823',
        senderId: 'me',
        type: 'voice',
        text: 'Suara Voice Note: Mulus banget bro, cuma pensil dikit udah gua hapus semua kok.',
        voiceDuration: '0:18',
        createdAt: '2026-08-27T07:14:00Z',
        timestamp: '07:14',
        status: 'read',
      },
      {
        id: 'msg-d3',
        threadId: '17892348123791823',
        senderId: 'me',
        type: 'text',
        text: 'Siap bro, nanti jam istirahat kedua gua tunggu di depan lab komputer yaa.',
        createdAt: '2026-08-27T07:20:00Z',
        timestamp: '07:20',
        status: 'read',
      },
    ],
  },
  {
    id: '17950293812048512',
    participant: {
      id: 'user-nadia',
      name: 'Nadia Putri',
      username: 'nadiaputri',
      avatar: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&q=80',
      isVerified: true,
      isOnline: false,
      lastSeen: '1 jam lalu',
      classGroup: 'XI DKV 1',
    },
    unreadCount: 0,
    lastMessage: 'Halo kak, mau tanya soal portofolio Figma yang diposting kemarin...',
    lastTimestamp: '1j',
    isSenderLast: false,
    isBuyerConversation: false,
    messages: [
      {
        id: 'msg-n1',
        threadId: '17950293812048512',
        senderId: 'user-nadia',
        type: 'text',
        text: 'Halo kak, mau tanya soal portofolio Figma yang diposting kemarin, itu pakai auto-layout versi berapa ya?',
        createdAt: '2026-08-27T06:00:00Z',
        timestamp: '06:00',
        status: 'read',
      },
    ],
  },
];

/**
 * Find conversation thread by 17-digit numeric hash ID
 */
export function getChatThreadById(threadId: string): ChatThread | null {
  const found = MOCK_CHAT_THREADS.find((t) => t.id === threadId);
  return found || null;
}

/**
 * Find or lazily create a conversation thread for a specific target username
 */
export function getOrCreateChatThreadForUser(
  username: string,
  productContext?: ChatProductContext
): ChatThread {
  const cleanUsername = username.replace(/^@/, '').toLowerCase();
  const existing = MOCK_CHAT_THREADS.find(
    (t) => t.participant.username.toLowerCase() === cleanUsername
  );

  if (existing) {
    if (productContext && !existing.productContext) {
      return { ...existing, productContext };
    }
    return existing;
  }

  // Create new session thread with generated numeric snowflake ID
  const newThreadId = generateNumericThreadId();
  const displayName = cleanUsername
    .split(/[._-]/)
    .map((s) => s.charAt(0).toUpperCase() + s.slice(1))
    .join(' ');

  const newThread: ChatThread = {
    id: newThreadId,
    participant: {
      id: `user-${cleanUsername}`,
      name: displayName || cleanUsername,
      username: cleanUsername,
      avatar: `https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80`,
      isOnline: true,
      classGroup: 'Siswa SMK',
    },
    productContext,
    unreadCount: 0,
    lastMessage: 'Memulai percakapan baru',
    lastTimestamp: 'Baru saja',
    messages: [
      {
        id: `msg-${Date.now()}`,
        threadId: newThreadId,
        senderId: 'system',
        type: 'system',
        text: `Percakapan baru dengan @${cleanUsername} dimulai.`,
        createdAt: new Date().toISOString(),
        timestamp: new Date().toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }),
        status: 'read',
      },
    ],
  };

  MOCK_CHAT_THREADS.unshift(newThread);
  return newThread;
}
