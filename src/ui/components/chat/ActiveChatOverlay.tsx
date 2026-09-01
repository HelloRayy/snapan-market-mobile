import React, { useState, useRef, useEffect } from 'react';
import { CheckCheck } from 'lucide-react';
import { MOCK_CONVERSATIONS } from '@/ui/pages/DirectMessagesPage';
import { ChatTopBar } from './ChatTopBar';
import { ChatProductCard } from './ChatProductCard';
import { ChatComposerBar } from './ChatComposerBar';
import {
  ChatBubble,
  ChatBubbleMessage,
  ChatBubbleTimestamp,
} from '@/ui/components/ui/chat-bubble';

interface ActiveChatOverlayProps {
  activeChatThreadId: string;
  onClose: () => void;
  onNavigateToProfile: (username: string) => void;
}

export const ActiveChatOverlay: React.FC<ActiveChatOverlayProps> = ({
  activeChatThreadId,
  onClose,
  onNavigateToProfile,
}) => {
  const [extraChatMessages, setExtraChatMessages] = useState<
    Record<string, Array<{ id: string; text: string; time: string }>>
  >({});
  const messagesEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [extraChatMessages, activeChatThreadId]);

  const participant = (() => {
    const conv = MOCK_CONVERSATIONS.find((c) => c.id === activeChatThreadId);
    if (conv) {
      return {
        name: conv.user.name,
        username: conv.user.username,
        avatar: conv.user.avatar,
        isVerified: conv.user.isVerified,
        isOnline: conv.user.isOnline,
      };
    }
    return {
      name: 'Sarah Anastasya',
      username: 'sarahanas',
      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80',
      isVerified: true,
      isOnline: true,
    };
  })();

  const handleSendMessage = (text: string) => {
    if (!text.trim()) return;
    const now = new Date();
    const timeStr = `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;
    const newMsg = {
      id: `msg-${Date.now()}`,
      text,
      time: timeStr,
    };

    setExtraChatMessages((prev) => ({
      ...prev,
      [activeChatThreadId]: [...(prev[activeChatThreadId] || []), newMsg],
    }));

    // Simulated Auto-Reply for realistic mobile chat experience
    setTimeout(() => {
      const replyMsg = {
        id: `reply-${Date.now()}`,
        text: 'Halo! Pesan kamu sudah diterima yaa 👍 Btw barangnya masih ready dan bisa COD di area sekolah!',
        time: timeStr,
      };
      setExtraChatMessages((prev) => ({
        ...prev,
        [activeChatThreadId]: [...(prev[activeChatThreadId] || []), replyMsg],
      }));
    }, 1200);
  };

  return (
    <div
      key={activeChatThreadId}
      data-lenis-prevent
      className="fixed inset-0 z-50 bg-white overflow-hidden transform-gpu animate-page-zoom touch-pan-y flex flex-col"
      style={{
        willChange: 'transform, opacity',
        backfaceVisibility: 'hidden',
        WebkitBackfaceVisibility: 'hidden',
      }}
    >
      <ChatTopBar
        participant={participant}
        onBack={onClose}
        onViewProfile={(uname) => {
          onClose();
          onNavigateToProfile(uname);
        }}
      />

      <main data-lenis-prevent className="flex-1 overflow-y-auto px-3.5 py-4 space-y-4 bg-[#f6f7f9] touch-pan-y">
        {activeChatThreadId === '17892348123791823' ? (
          <>
            <div className="flex flex-col items-start gap-y-1 max-w-[85%] sm:max-w-[75%] mr-auto">
              <ChatProductCard
                shape="firstReceived"
                className="w-full"
                product={{
                  id: 'market-post-fisika-12',
                  title: 'Modul Praktikum Fisika Terapan Kelas XII',
                  price: 'Rp 45.000',
                  image: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&q=80',
                  location: 'Lab Fisika Lt 2',
                  statusText: 'Terverifikasi',
                }}
              />
              <ChatBubble variant="received" shape="lastReceived">
                <ChatBubbleMessage>
                  Kak modul fisika terapan ini masih ready ga ya? Mau tanya kondisi coretannya banyak ga?
                </ChatBubbleMessage>
                <ChatBubbleTimestamp>14:20</ChatBubbleTimestamp>
              </ChatBubble>
            </div>

            <div className="flex flex-col items-end gap-y-1 max-w-[85%] sm:max-w-[75%] ml-auto">
              <ChatBubble variant="sent" shape="single">
                <ChatBubbleMessage>
                  Masih ready banget Dimas! Coretannya minim pakai pensil, bisa dihapus kok 👍
                </ChatBubbleMessage>
                <ChatBubbleTimestamp>
                  14:21
                  <CheckCheck className="w-3.5 h-3.5 text-[#1d64ec] stroke-[2.5]" />
                </ChatBubbleTimestamp>
              </ChatBubble>
            </div>
          </>
        ) : (
          <div className="flex flex-col items-start gap-y-1 max-w-[85%] sm:max-w-[75%] mr-auto">
            <ChatBubble variant="received" shape="single">
              <ChatBubbleMessage>
                Hai kak! Boleh tanya-tanya barang yang diposting kemarin?
              </ChatBubbleMessage>
              <ChatBubbleTimestamp>10:15</ChatBubbleTimestamp>
            </ChatBubble>
          </div>
        )}

        {(extraChatMessages[activeChatThreadId] || []).map((msg) => (
          <div
            key={msg.id}
            className={`flex flex-col gap-y-1 max-w-[85%] sm:max-w-[75%] ${
              msg.id.startsWith('reply') ? 'mr-auto items-start' : 'ml-auto items-end'
            }`}
          >
            <ChatBubble variant={msg.id.startsWith('reply') ? 'received' : 'sent'} shape="single">
              <ChatBubbleMessage>
                {msg.text}
              </ChatBubbleMessage>
              <ChatBubbleTimestamp>
                {msg.time}
                {!msg.id.startsWith('reply') && (
                  <CheckCheck className="w-3.5 h-3.5 text-[#1d64ec] stroke-[2.5]" />
                )}
              </ChatBubbleTimestamp>
            </ChatBubble>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </main>

      <ChatComposerBar onSendMessage={handleSendMessage} />
    </div>
  );
};
