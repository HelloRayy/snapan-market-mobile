import React, { useState, useRef, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { X, Send, MessageSquare, Sparkles } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';
import { ClickableVerifiedBadge } from './VerifiedBadgeModal';
import { triggerHaptic } from '@/utils/haptics';

interface AskSellerBottomSheetProps {
  isOpen: boolean;
  post: MarketPostItem;
  onClose: () => void;
  onSubmitQuestion: (text: string) => void;
}

const QUICK_PROMPTS = [
  'Apakah stok masih ada kak?',
  'Bisa nego tipis ngga kak?',
  'Kondisinya masih mulus?',
  'Bisa COD di mana kak?',
];

export const AskSellerBottomSheet: React.FC<AskSellerBottomSheetProps> = ({
  isOpen,
  post,
  onClose,
  onSubmitQuestion,
}) => {
  const [text, setText] = useState('');
  const [dragY, setDragY] = useState(0);
  const [isDragging, setIsDragging] = useState(false);
  const startYRef = useRef(0);
  const inputRef = useRef<HTMLTextAreaElement>(null);

  // Body scroll lock effect
  useEffect(() => {
    if (isOpen) {
      setDragY(0);
      setText('');

      const originalOverflow = document.body.style.overflow;
      const originalPosition = document.body.style.position;
      const originalWidth = document.body.style.width;
      const scrollY = window.scrollY;

      document.body.style.overflow = 'hidden';
      document.body.style.position = 'fixed';
      document.body.style.width = '100%';
      document.body.style.top = `-${scrollY}px`;

      setTimeout(() => {
        inputRef.current?.focus();
      }, 250);

      return () => {
        document.body.style.overflow = originalOverflow;
        document.body.style.position = originalPosition;
        document.body.style.width = originalWidth;
        document.body.style.top = '';
        window.scrollTo(0, scrollY);
      };
    }
  }, [isOpen]);

  if (!isOpen) return null;

  const handleTouchStart = (e: React.TouchEvent) => {
    startYRef.current = e.touches[0].clientY;
    setIsDragging(true);
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (!isDragging) return;
    const currentY = e.touches[0].clientY;
    const deltaY = currentY - startYRef.current;
    if (deltaY > 0) {
      setDragY(deltaY);
    }
  };

  const handleTouchEnd = () => {
    if (dragY > 120) {
      triggerHaptic('light');
      onClose();
    }
    setDragY(0);
    setIsDragging(false);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!text.trim()) return;
    triggerHaptic('medium');
    onSubmitQuestion(text.trim());
    onClose();
  };

  const handleChipClick = (prompt: string) => {
    triggerHaptic('light');
    setText(prompt);
    inputRef.current?.focus();
  };

  const modalContent = (
    <div className="fixed inset-0 z-50 flex items-end justify-center font-gt-standard">
      {/* Dimmed Backdrop */}
      <div
        onClick={onClose}
        className="fixed inset-0 bg-black/60 backdrop-blur-xs transition-opacity duration-300 animate-in fade-in"
      />

      {/* Sheet Container */}
      <div
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
        style={{
          transform: `translateY(${dragY}px)`,
          transition: isDragging ? 'none' : 'transform 0.3s cubic-bezier(0.16, 1, 0.3, 1)',
        }}
        className="relative z-10 w-full max-w-lg bg-white rounded-t-[28px] shadow-2xl overflow-hidden flex flex-col max-h-[85vh] animate-in slide-in-from-bottom duration-300"
      >
        {/* Drag Handle Bar */}
        <div className="w-full flex items-center justify-center pt-3 pb-1 cursor-grab active:cursor-grabbing">
          <div className="w-10 h-1.5 bg-neutral-300 rounded-full" />
        </div>

        {/* Header */}
        <div className="px-5 py-3 border-b border-neutral-100 flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-full bg-blue-50 text-[#1d64ec] flex items-center justify-center">
              <MessageSquare className="w-4 h-4 stroke-[2]" />
            </div>
            <div>
              <h2 className="font-bold text-[15px] text-slate-900 leading-snug">Tanya Penjual</h2>
              <p className="text-[12px] text-neutral-400">Pertanyaan akan terkirim ke kolom diskusi</p>
            </div>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="p-1.5 rounded-full hover:bg-neutral-100 text-neutral-400 hover:text-slate-700 transition-colors cursor-pointer"
            aria-label="Tutup"
          >
            <X className="w-5 h-5 stroke-[2]" />
          </button>
        </div>

        {/* Seller Info Capsule */}
        <div className="px-5 py-3 bg-neutral-50/80 border-b border-neutral-100 flex items-center gap-3">
          <img
            src={post.seller.avatar}
            alt={post.seller.name}
            className="w-9 h-9 rounded-full object-cover border border-neutral-200"
          />
          <div className="min-w-0 flex-1">
            <div className="flex items-center gap-1">
              <span className="font-semibold text-[13.5px] text-slate-900 truncate">
                {post.seller.name}
              </span>
              {post.seller.isVerified && (
                <ClickableVerifiedBadge
                  sellerName={post.seller.name}
                  className="w-3.5 h-3.5 shrink-0"
                />
              )}
            </div>
            <p className="text-[11.5px] text-neutral-500 truncate">
              {post.seller.classGroup || 'Penjual Terverifikasi'}
            </p>
          </div>
        </div>

        {/* Quick Suggestion Chips */}
        <div className="px-5 pt-3 pb-1">
          <div className="flex items-center gap-1 text-[11.5px] font-semibold text-neutral-500 mb-2">
            <Sparkles className="w-3 h-3 text-[#1d64ec]" />
            <span>Pertanyaan Cepat:</span>
          </div>
          <div className="flex flex-wrap gap-1.5">
            {QUICK_PROMPTS.map((prompt) => (
              <button
                key={prompt}
                type="button"
                onClick={() => handleChipClick(prompt)}
                className="text-[12px] px-2.5 py-1 rounded-full bg-neutral-100 hover:bg-neutral-200/80 active:scale-95 text-slate-700 font-medium transition-all cursor-pointer select-none"
              >
                {prompt}
              </button>
            ))}
          </div>
        </div>

        {/* Form Input Textarea */}
        <form onSubmit={handleSubmit} className="p-5 flex flex-col gap-3">
          <textarea
            ref={inputRef}
            rows={3}
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder={`Tulis pertanyaan untuk @${(post.seller.username || post.seller.name).replace(/^@/, '')}...`}
            className="w-full bg-neutral-100 focus:bg-white border border-transparent focus:border-[#1d64ec] rounded-2xl p-3.5 text-[14px] text-slate-900 placeholder:text-neutral-400 focus:outline-none transition-all resize-none shadow-2xs"
          />

          <button
            type="submit"
            disabled={!text.trim()}
            className={`relative inline-flex items-center justify-center gap-2 rounded-full h-11 px-6 font-bold text-[14px] text-white bg-[#1d64ec] border border-[#154ec1] shadow-md shadow-blue-500/20 active:scale-[0.98] transition-all cursor-pointer ${
              !text.trim() ? 'opacity-40 cursor-not-allowed' : 'hover:bg-blue-600'
            }`}
          >
            <span>Kirim Pertanyaan</span>
            <Send className="w-4 h-4 stroke-[2.2]" />
          </button>
        </form>
      </div>
    </div>
  );

  return createPortal(modalContent, document.body);
};
