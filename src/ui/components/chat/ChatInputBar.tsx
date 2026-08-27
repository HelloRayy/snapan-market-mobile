import React, { useState, useRef, useEffect } from 'react';
import { Send, Image as ImageIcon, Mic, MapPin, Tag } from 'lucide-react';
import { triggerHaptic } from '@/utils/haptics';

interface ChatInputBarProps {
  onSendMessage: (text: string) => void;
  onSendImage?: (imageUrl: string) => void;
  onQuickActionOffer?: () => void;
  onQuickActionMeeting?: () => void;
  hasProductContext?: boolean;
}

const QUICK_REPLIES = [
  'Halo kak, barangnya masih ada?',
  'Bisa COD di kantin depan kak?',
  'Bisa nego tipis gak ya?',
  'Kondisinya masih mulus kan kak?',
];

export const ChatInputBar: React.FC<ChatInputBarProps> = ({
  onSendMessage,
  onSendImage,
  onQuickActionOffer,
  onQuickActionMeeting,
  hasProductContext,
}) => {
  const [inputText, setInputText] = useState('');
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const handleSend = () => {
    const trimmed = inputText.trim();
    if (!trimmed) return;

    triggerHaptic('medium');
    onSendMessage(trimmed);
    setInputText('');

    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
    }
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  const handleSelectQuickReply = (reply: string) => {
    triggerHaptic('selection');
    onSendMessage(reply);
  };

  const handleMockImageUpload = () => {
    triggerHaptic('medium');
    const mockImages = [
      'https://images.unsplash.com/photo-1594980596870-8aa52a78d8cd?w=500&q=80',
      'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=500&q=80',
    ];
    const picked = mockImages[Math.floor(Math.random() * mockImages.length)];
    onSendImage?.(picked);
  };

  // Adjust textarea height automatically
  useEffect(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = 'auto';
      textareaRef.current.style.height = `${Math.min(
        textareaRef.current.scrollHeight,
        120
      )}px`;
    }
  }, [inputText]);

  return (
    <div className="bg-white/95 backdrop-blur-md border-t border-neutral-200/80 p-2.5 pb-[max(10px,env(safe-area-inset-bottom,10px))] select-none">
      {/* 1. Quick Reply Suggestion Chips */}
      <div className="flex items-center gap-1.5 overflow-x-auto no-scrollbar pb-2 px-1">
        {hasProductContext && (
          <>
            <button
              type="button"
              onClick={() => {
                triggerHaptic('light');
                onQuickActionOffer?.();
              }}
              className="flex items-center gap-1 px-2.5 py-1 rounded-full bg-amber-50 text-amber-900 border border-amber-200 text-[11.5px] font-bold shrink-0 hover:bg-amber-100 active:scale-95 transition-all cursor-pointer"
            >
              <Tag className="w-3 h-3" />
              <span>Nego Harga</span>
            </button>

            <button
              type="button"
              onClick={() => {
                triggerHaptic('light');
                onQuickActionMeeting?.();
              }}
              className="flex items-center gap-1 px-2.5 py-1 rounded-full bg-blue-50 text-blue-900 border border-blue-200 text-[11.5px] font-bold shrink-0 hover:bg-blue-100 active:scale-95 transition-all cursor-pointer"
            >
              <MapPin className="w-3 h-3" />
              <span>Ajukan Titik Temu</span>
            </button>
          </>
        )}

        {QUICK_REPLIES.map((reply, idx) => (
          <button
            key={idx}
            type="button"
            onClick={() => handleSelectQuickReply(reply)}
            className="px-3 py-1 rounded-full bg-neutral-100 text-slate-700 hover:bg-neutral-200/80 active:scale-95 border border-neutral-200/80 text-[12px] font-medium shrink-0 transition-all cursor-pointer"
          >
            {reply}
          </button>
        ))}
      </div>

      {/* 2. Main Input Action Bar */}
      <div className="flex items-end gap-2 bg-neutral-100/90 rounded-[24px] px-2.5 py-1.5 border border-neutral-200/80 focus-within:border-[#1d64ec] focus-within:bg-white focus-within:ring-2 focus-within:ring-blue-100 transition-all">
        {/* Left: Image Attachment Trigger */}
        <button
          type="button"
          onClick={handleMockImageUpload}
          className="w-8 h-8 rounded-full flex items-center justify-center text-neutral-500 hover:text-slate-800 hover:bg-neutral-200/60 active:scale-90 transition-all cursor-pointer shrink-0"
          aria-label="Lampirkan foto"
          title="Lampirkan foto"
        >
          <ImageIcon className="w-4.5 h-4.5 stroke-[2]" />
        </button>

        {/* Center: Auto-resizing Text Input */}
        <textarea
          ref={textareaRef}
          value={inputText}
          onChange={(e) => setInputText(e.target.value)}
          onKeyDown={handleKeyDown}
          rows={1}
          placeholder="Ketik pesan obrolan..."
          className="flex-1 max-h-28 bg-transparent py-1.5 text-[14.5px] text-slate-900 placeholder:text-neutral-400 focus:outline-none resize-none leading-snug"
        />

        {/* Right: Send Button or Mic Button */}
        {inputText.trim().length > 0 ? (
          <button
            type="button"
            onClick={handleSend}
            className="w-8 h-8 rounded-full bg-[#1d64ec] text-white flex items-center justify-center shadow-xs hover:bg-[#154ec1] active:scale-90 transition-all cursor-pointer shrink-0"
            aria-label="Kirim Pesan"
          >
            <Send className="w-4 h-4 ml-0.5 fill-current" />
          </button>
        ) : (
          <button
            type="button"
            onClick={() => {
              triggerHaptic('medium');
              onSendMessage('🎙️ [Voice Note 0:14]');
            }}
            className="w-8 h-8 rounded-full flex items-center justify-center text-neutral-500 hover:text-slate-800 hover:bg-neutral-200/60 active:scale-90 transition-all cursor-pointer shrink-0"
            aria-label="Rekam Voice Note"
            title="Rekam Voice Note"
          >
            <Mic className="w-4.5 h-4.5 stroke-[2]" />
          </button>
        )}
      </div>
    </div>
  );
};
