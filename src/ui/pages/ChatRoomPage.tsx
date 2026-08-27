import React, { useState, useEffect, useRef } from 'react';
import { ChatThread, ChatMessage, ChatProductContext } from '@/types/chat';
import {
  getChatThreadById,
  getOrCreateChatThreadForUser,
} from '@/data/mockChatData';
import { ChatHeader } from '@/ui/components/chat/ChatHeader';
import { ChatProductBanner } from '@/ui/components/chat/ChatProductBanner';
import { ChatBubbleItem } from '@/ui/components/chat/ChatBubbleItem';
import { ChatInputBar } from '@/ui/components/chat/ChatInputBar';
import { ChatOfferModal } from '@/ui/components/chat/ChatOfferModal';
import { ChatMeetingPointModal } from '@/ui/components/chat/ChatMeetingPointModal';
import { MarketPostItem } from '@/types/marketFeed';
import { triggerHaptic } from '@/utils/haptics';

interface ChatRoomPageProps {
  threadId?: string;
  targetUsername?: string;
  initialProduct?: ChatProductContext | MarketPostItem | null;
  onBack: () => void;
  onViewProfile?: (username: string) => void;
  onViewProduct?: (productId: string) => void;
  onViewMap?: () => void;
}

export const ChatRoomPage: React.FC<ChatRoomPageProps> = ({
  threadId,
  targetUsername,
  initialProduct,
  onBack,
  onViewProfile,
  onViewProduct,
  onViewMap,
}) => {
  // Convert MarketPostItem to ChatProductContext if needed
  const normalizedProductContext: ChatProductContext | undefined = initialProduct
    ? 'caption' in initialProduct
      ? {
          id: initialProduct.id,
          title: initialProduct.title || initialProduct.caption,
          price: initialProduct.price || 0,
          originalPrice: initialProduct.originalPrice,
          image:
            initialProduct.images?.[0] ||
            'https://images.unsplash.com/photo-1594980596870-8aa52a78d8cd?w=500&q=80',
          locationTag: initialProduct.locationTag,
        }
      : (initialProduct as ChatProductContext)
    : undefined;

  // Initialize Thread Data
  const [thread] = useState<ChatThread>(() => {
    if (threadId) {
      const found = getChatThreadById(threadId);
      if (found) return found;
    }
    if (targetUsername) {
      return getOrCreateChatThreadForUser(targetUsername, normalizedProductContext);
    }
    // Fallback default
    return getOrCreateChatThreadForUser('sarahanas', normalizedProductContext);
  });

  const [messages, setMessages] = useState<ChatMessage[]>(thread.messages);
  const [isOfferModalOpen, setIsOfferModalOpen] = useState(false);
  const [isMeetingModalOpen, setIsMeetingModalOpen] = useState(false);

  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Auto-scroll to bottom on mount or new message
  const scrollToBottom = (behavior: ScrollBehavior = 'smooth') => {
    messagesEndRef.current?.scrollIntoView({ behavior });
  };

  useEffect(() => {
    scrollToBottom('instant');
  }, [thread.id]);

  useEffect(() => {
    scrollToBottom('smooth');
  }, [messages.length]);

  // Handle Send Message
  const handleSendMessage = (text: string) => {
    const newMessage: ChatMessage = {
      id: `msg-${Date.now()}`,
      threadId: thread.id,
      senderId: 'me',
      type: 'text',
      text,
      createdAt: new Date().toISOString(),
      timestamp: new Date().toLocaleTimeString('id-ID', {
        hour: '2-digit',
        minute: '2-digit',
      }),
      status: 'sent',
    };

    setMessages((prev) => [...prev, newMessage]);

    // Simulate automatic response from peer after 1.2 seconds
    setTimeout(() => {
      triggerHaptic('light');
      const replies = [
        'Siap kak! Nanti kita ketemuan di spot yaa 👍',
        'Oke deal, nanti pas jam istirahat aku bawa barangnya.',
        'Boleh kak, kabari aja kalau udah di lokasi yaa!',
      ];
      const autoReplyText = replies[Math.floor(Math.random() * replies.length)];

      const autoReplyMessage: ChatMessage = {
        id: `msg-reply-${Date.now()}`,
        threadId: thread.id,
        senderId: thread.participant.id,
        type: 'text',
        text: autoReplyText,
        createdAt: new Date().toISOString(),
        timestamp: new Date().toLocaleTimeString('id-ID', {
          hour: '2-digit',
          minute: '2-digit',
        }),
        status: 'delivered',
      };

      setMessages((prev) => [...prev, autoReplyMessage]);
    }, 1200);
  };

  // Handle Send Image
  const handleSendImage = (imageUrl: string) => {
    const newMessage: ChatMessage = {
      id: `msg-img-${Date.now()}`,
      threadId: thread.id,
      senderId: 'me',
      type: 'text',
      text: '📷 [Lampiran Foto Produk]',
      mediaUrl: imageUrl,
      createdAt: new Date().toISOString(),
      timestamp: new Date().toLocaleTimeString('id-ID', {
        hour: '2-digit',
        minute: '2-digit',
      }),
      status: 'sent',
    };
    setMessages((prev) => [...prev, newMessage]);
  };

  // Handle Submit Offer
  const handleSubmitOffer = (amount: number) => {
    const product = thread.productContext || normalizedProductContext;
    const originalPrice = product?.price || 185000;

    const offerMessage: ChatMessage = {
      id: `msg-offer-${Date.now()}`,
      threadId: thread.id,
      senderId: 'me',
      type: 'offer',
      text: 'Mengajukan tawaran harga baru',
      offer: {
        amount,
        originalPrice,
        status: 'pending',
      },
      createdAt: new Date().toISOString(),
      timestamp: new Date().toLocaleTimeString('id-ID', {
        hour: '2-digit',
        minute: '2-digit',
      }),
      status: 'sent',
    };

    setMessages((prev) => [...prev, offerMessage]);

    // Simulate seller accepting offer after 2 seconds
    setTimeout(() => {
      triggerHaptic('success');
      setMessages((prev) =>
        prev.map((msg) =>
          msg.id === offerMessage.id
            ? {
                ...msg,
                offer: { ...msg.offer!, status: 'accepted' },
              }
            : msg
        )
      );

      const acceptanceNote: ChatMessage = {
        id: `msg-acc-${Date.now()}`,
        threadId: thread.id,
        senderId: thread.participant.id,
        type: 'text',
        text: `Oke saya setuju dengan tawaran Rp ${amount.toLocaleString(
          'id-ID'
        )}! Mau ketemuan di mana kak?`,
        createdAt: new Date().toISOString(),
        timestamp: new Date().toLocaleTimeString('id-ID', {
          hour: '2-digit',
          minute: '2-digit',
        }),
        status: 'delivered',
      };
      setMessages((prev) => [...prev, acceptanceNote]);
    }, 2000);
  };

  // Handle Submit Meeting Point
  const handleSubmitMeetingPoint = (
    spotName: string,
    timeLabel: string,
    zoneId?: string
  ) => {
    const meetingMessage: ChatMessage = {
      id: `msg-meet-${Date.now()}`,
      threadId: thread.id,
      senderId: 'me',
      type: 'meeting_point',
      meetingPoint: {
        spotName,
        timeLabel,
        zoneId,
        status: 'confirmed',
      },
      createdAt: new Date().toISOString(),
      timestamp: new Date().toLocaleTimeString('id-ID', {
        hour: '2-digit',
        minute: '2-digit',
      }),
      status: 'sent',
    };

    setMessages((prev) => [...prev, meetingMessage]);
  };

  // Handle Accept Offer from Peer
  const handleAcceptOffer = (messageId: string) => {
    triggerHaptic('success');
    setMessages((prev) =>
      prev.map((msg) =>
        msg.id === messageId && msg.offer
          ? { ...msg, offer: { ...msg.offer, status: 'accepted' } }
          : msg
      )
    );
  };

  const currentProduct = thread.productContext || normalizedProductContext;

  return (
    <div className="fixed inset-0 z-50 bg-white flex flex-col font-gt-standard overflow-hidden select-none animate-in slide-in-from-right duration-200">
      {/* 1. Sticky Chat Header */}
      <ChatHeader
        participant={thread.participant}
        onBack={onBack}
        onViewProfile={onViewProfile}
        onClearChat={() => setMessages([])}
      />

      {/* 2. Pinned Product Context Banner */}
      {currentProduct && (
        <ChatProductBanner
          product={currentProduct}
          onMakeOffer={() => setIsOfferModalOpen(true)}
          onArrangeMeeting={() => setIsMeetingModalOpen(true)}
          onViewProduct={onViewProduct}
        />
      )}

      {/* 3. Messages Stream Container with Lenis Isolation */}
      <main
        data-lenis-prevent
        className="flex-1 overflow-y-auto px-3.5 py-3 space-y-1 bg-[#fbfbfb] touch-pan-y"
      >
        {/* Date separator pill */}
        <div className="flex justify-center my-2">
          <span className="text-[11px] font-semibold text-neutral-400 bg-neutral-200/60 px-2.5 py-0.5 rounded-full">
            Hari Ini
          </span>
        </div>

        {messages.map((message) => (
          <ChatBubbleItem
            key={message.id}
            message={message}
            onOpenProduct={onViewProduct}
            onOpenMapLocation={() => onViewMap?.()}
            onAcceptOffer={handleAcceptOffer}
          />
        ))}

        <div ref={messagesEndRef} className="h-2" />
      </main>

      {/* 4. Interactive Sticky Chat Input Bar */}
      <ChatInputBar
        onSendMessage={handleSendMessage}
        onSendImage={handleSendImage}
        onQuickActionOffer={() => setIsOfferModalOpen(true)}
        onQuickActionMeeting={() => setIsMeetingModalOpen(true)}
        hasProductContext={Boolean(currentProduct)}
      />

      {/* 5. Modals for Offer & Meeting Point */}
      {currentProduct && (
        <ChatOfferModal
          isOpen={isOfferModalOpen}
          onClose={() => setIsOfferModalOpen(false)}
          originalPrice={currentProduct.price}
          productTitle={currentProduct.title}
          onSubmitOffer={handleSubmitOffer}
        />
      )}

      <ChatMeetingPointModal
        isOpen={isMeetingModalOpen}
        onClose={() => setIsMeetingModalOpen(false)}
        onSubmitMeetingPoint={handleSubmitMeetingPoint}
      />
    </div>
  );
};
