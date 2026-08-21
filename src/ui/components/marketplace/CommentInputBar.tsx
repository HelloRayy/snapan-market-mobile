import React, { useState, useRef, useEffect } from 'react';
import { Send } from 'lucide-react';

interface CommentInputBarProps {
  replyToUser?: string | null;
  targetAuthor?: string;
  onCancelReply?: () => void;
  onSubmitComment: (text: string) => void;
  isInline?: boolean;
  onFocusChange?: (isFocused: boolean) => void;
}

export const CommentInputBar: React.FC<CommentInputBarProps> = ({
  replyToUser,
  targetAuthor,
  onCancelReply,
  onSubmitComment,
  isInline = false,
  onFocusChange,
}) => {
  const [text, setText] = useState('');
  const inputRef = useRef<HTMLInputElement>(null);

  // Auto-focus and scroll smoothly into view when replying to a user
  useEffect(() => {
    if (replyToUser) {
      inputRef.current?.focus();
      setTimeout(() => {
        inputRef.current?.scrollIntoView({ behavior: 'smooth', block: 'center' });
      }, 150);
    }
  }, [replyToUser]);

  const handleFocus = () => {
    onFocusChange?.(true);
    // Smooth scroll into visible center above mobile keyboard
    setTimeout(() => {
      inputRef.current?.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }, 150);
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

  const containerClasses = isInline
    ? 'w-full min-w-0 bg-white py-2 font-gt-standard mb-1'
    : 'fixed bottom-0 left-0 right-0 max-w-xl mx-auto bg-white border-t border-neutral-200/80 px-4 py-2.5 z-40 font-gt-standard shadow-md';

  return (
    <div className={containerClasses}>
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
        {/* Current User Avatar */}
        <div className="w-8 h-8 rounded-full overflow-hidden shrink-0 border border-neutral-200 shadow-2xs">
          <img
            src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80"
            alt="Profil Saya"
            className="w-full h-full object-cover"
          />
        </div>

        {/* Input Text Field with min-w-0 for responsive auto-adjusting flex width */}
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

        {/* Send Button CTA (Always visible & fits perfectly) */}
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
};
