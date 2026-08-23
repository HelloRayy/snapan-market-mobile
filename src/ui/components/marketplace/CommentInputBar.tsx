import React, { useState, useRef, useEffect } from 'react';
import { Send, ArrowLeft } from 'lucide-react';
import { triggerHaptic } from '@/utils/haptics';

interface CommentInputBarProps {
  replyToUser?: string | null;
  targetAuthor?: string;
  onCancelReply?: () => void;
  onSubmitComment: (text: string) => void;
  isInline?: boolean;
  onFocusChange?: (isFocused: boolean) => void;
  onClose?: () => void;
  autoFocus?: boolean;
  userAvatar?: string;
}

export const CommentInputBar: React.FC<CommentInputBarProps> = ({
  replyToUser,
  targetAuthor,
  userAvatar,
  onCancelReply,
  onSubmitComment,
  isInline = false,
  onFocusChange,
  onClose,
  autoFocus = false,
}) => {
  const [text, setText] = useState('');
  const inputRef = useRef<HTMLInputElement>(null);

  // Auto-focus when replying or when autoFocus prop is true
  useEffect(() => {
    if (replyToUser || autoFocus) {
      setTimeout(() => {
        inputRef.current?.focus();
      }, 100);
    }
  }, [replyToUser, autoFocus]);

  const handleFocus = () => {
    onFocusChange?.(true);
  };

  const handleBlur = () => {
    onFocusChange?.(false);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!text.trim()) return;
    onSubmitComment(text.trim());
    setText('');
  };

  if (isInline) {
    return (
      <div className="w-full min-w-0 bg-white py-2 font-gt-standard mb-1">
        {replyToUser && (
          <div className="flex items-center justify-between px-1 pb-1.5 text-[12px] text-neutral-500 animate-in fade-in duration-150 select-none">
            <span className="flex items-center gap-1">
              <span>Membalas</span>
              <strong className="text-[#1d64ec] font-semibold">@{replyToUser.replace(/^@/, '')}</strong>
            </span>
            <button
              type="button"
              onClick={onCancelReply}
              className="text-neutral-400 hover:text-rose-500 text-[11.5px] font-medium transition-colors cursor-pointer"
            >
              Batal
            </button>
          </div>
        )}
        <form onSubmit={handleSubmit} className="flex items-center gap-2 w-full min-w-0">
          <div className="w-8 h-8 rounded-full overflow-hidden shrink-0 border border-neutral-200 shadow-2xs">
            <img
              src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80"
              alt="Profil Saya"
              className="w-full h-full object-cover"
            />
          </div>
          <input
            ref={inputRef}
            id="comment-input-field"
            type="text"
            value={text}
            onChange={(e) => setText(e.target.value)}
            onFocus={handleFocus}
            onBlur={handleBlur}
            placeholder={
              replyToUser
                ? `Balas @${replyToUser.replace(/^@/, '')}...`
                : targetAuthor
                ? `Balas postingan @${targetAuthor.replace(/^@/, '')}...`
                : 'Balas postingan...'
            }
            className="flex-1 min-w-0 bg-neutral-100 hover:bg-neutral-100/80 focus:bg-white border border-transparent focus:border-[#1d64ec] rounded-full px-3.5 sm:px-4 h-10 text-[13.5px] sm:text-[14px] text-slate-900 placeholder:text-neutral-400 focus:outline-none transition-all shadow-2xs"
          />
          <button
            type="submit"
            disabled={!text.trim()}
            className={`relative inline-flex items-center justify-center gap-1.5 rounded-full px-3.5 sm:px-4 h-10 text-[13px] font-bold text-white bg-[#18181b] border border-black/40 shadow-xs overflow-hidden shrink-0 transition-all ${
              !text.trim()
                ? 'opacity-40 cursor-not-allowed'
                : 'active:scale-95 cursor-pointer hover:bg-black'
            }`}
            aria-label="Kirim Komentar"
          >
            <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-neutral-700/60 to-neutral-900/90 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.25)] pointer-events-none" />
            <span className="relative z-10 flex items-center gap-1.5">
              <span>Kirim</span>
              <Send className="w-3.5 h-3.5 stroke-[2.25]" />
            </span>
          </button>
        </form>
      </div>
    );
  }

  // FLOATING CAPSULE PILL MODE (100% Identical to StickyBuyBar)
  return (
    <div
      className="fixed left-4 right-4 max-w-md mx-auto z-40 font-gt-standard select-none transition-all duration-200 ease-out"
      style={{
        bottom: 'max(1rem, calc(env(safe-area-inset-bottom, 0px) + 8px))',
      }}
    >
      {/* Floating Reply Banner if replying to a user */}
      {replyToUser && (
        <div className="flex items-center justify-between px-3.5 py-1 mb-1.5 bg-white/95 backdrop-blur-md rounded-full border border-neutral-200/90 text-[11.5px] text-slate-700 shadow-xs animate-in fade-in select-none">
          <span className="flex items-center gap-1 truncate">
            <span>Membalas</span>
            <strong className="text-[#1d64ec] font-semibold">@{replyToUser.replace(/^@/, '')}</strong>
          </span>
          <button
            type="button"
            onClick={() => {
              triggerHaptic('light');
              onCancelReply?.();
              onClose?.();
            }}
            className="text-neutral-400 hover:text-rose-500 text-[11px] font-semibold transition-colors cursor-pointer px-1 shrink-0"
          >
            Batal
          </button>
        </div>
      )}

      {/* Floating White Pill Dock Container (Identical to StickyBuyBar) */}
      <div className="bg-white/95 backdrop-blur-xl border border-neutral-200/80 p-1.5 rounded-full shadow-[0_12px_40px_rgba(0,0,0,0.12)] flex items-center gap-2">
        <form onSubmit={handleSubmit} className="flex items-center gap-2 w-full min-w-0">
          {/* Left Slot: ArrowLeft Button (if in Product Mode) OR User Avatar (in Thread Mode) */}
          {onClose ? (
            <button
              type="button"
              onClick={() => {
                triggerHaptic('light');
                onClose();
              }}
              className="w-9 h-9 rounded-full bg-neutral-100 hover:bg-neutral-200 active:bg-neutral-300 active:scale-90 flex items-center justify-center text-slate-700 transition-all cursor-pointer shrink-0 border border-neutral-200/60 shadow-2xs"
              title="Kembali ke Tombol Beli"
              aria-label="Kembali ke Tombol Beli"
            >
              <ArrowLeft className="w-4.5 h-4.5 stroke-[2.25]" />
            </button>
          ) : (
            <div className="w-9 h-9 rounded-full overflow-hidden shrink-0 border border-neutral-200 shadow-2xs">
              <img
                src={userAvatar || "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80"}
                alt="Profil Saya"
                className="w-full h-full object-cover"
              />
            </div>
          )}

          {/* Input Text Field with Maximum Horizontal Breathable Space */}
          <input
            ref={inputRef}
            id="comment-input-field"
            type="text"
            value={text}
            onChange={(e) => setText(e.target.value)}
            onFocus={handleFocus}
            onBlur={handleBlur}
            placeholder={
              replyToUser
                ? `Balas @${replyToUser.replace(/^@/, '')}...`
                : targetAuthor
                ? `Tulis pertanyaan untuk @${targetAuthor.replace(/^@/, '')}...`
                : 'Tulis pertanyaan / komentar...'
            }
            className="flex-1 min-w-0 bg-transparent border-none text-[13.5px] sm:text-[14px] text-slate-900 placeholder:text-neutral-400 focus:outline-none px-1 h-9"
          />

          {/* Send Button CTA */}
          <button
            type="submit"
            disabled={!text.trim()}
            className={`relative inline-flex items-center justify-center gap-1.5 rounded-full px-3.5 h-9 text-[13px] font-bold text-white bg-[#18181b] border border-black/40 shadow-xs overflow-hidden shrink-0 transition-all ${
              !text.trim()
                ? 'opacity-40 cursor-not-allowed'
                : 'active:scale-95 cursor-pointer hover:bg-black'
            }`}
            aria-label="Kirim Komentar"
          >
            <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-neutral-700/60 to-neutral-900/90 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.25)] pointer-events-none" />
            <span className="relative z-10 flex items-center gap-1">
              <span>Kirim</span>
              <Send className="w-3.5 h-3.5 stroke-[2.25]" />
            </span>
          </button>
        </form>
      </div>
    </div>
  );
};
