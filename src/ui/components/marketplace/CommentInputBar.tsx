import React, { useState } from 'react';
import { Send } from 'lucide-react';

interface CommentInputBarProps {
  replyToUser?: string | null;
  onSubmitComment: (text: string) => void;
  isInline?: boolean;
}

export const CommentInputBar: React.FC<CommentInputBarProps> = ({
  replyToUser,
  onSubmitComment,
  isInline = false,
}) => {
  const [text, setText] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!text.trim()) return;
    onSubmitComment(text.trim());
    setText('');
  };

  const containerClasses = isInline
    ? 'w-full bg-white py-3 border-b border-neutral-200 font-gt-standard mb-1'
    : 'fixed bottom-0 left-0 right-0 max-w-xl mx-auto bg-white/95 backdrop-blur-md border-t border-neutral-200 px-4 py-2.5 z-40 font-gt-standard shadow-lg';

  return (
    <div className={containerClasses}>
      <form onSubmit={handleSubmit} className="flex items-center gap-2.5">
        {/* Current User Avatar */}
        <div className="w-8 h-8 rounded-full overflow-hidden shrink-0 border border-neutral-200 shadow-2xs">
          <img
            src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80"
            alt="Profil Saya"
            className="w-full h-full object-cover"
          />
        </div>

        {/* Input Text Field */}
        <input
          id="comment-input-field"
          type="text"
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder={replyToUser ? `Balas @${replyToUser}...` : 'Ketik komentar / pertanyaan produk...'}
          className="flex-1 bg-neutral-100 hover:bg-neutral-100/80 focus:bg-white border border-transparent focus:border-[#1d64ec] rounded-full px-4 h-10 text-[14px] text-slate-900 placeholder:text-slate-400 focus:outline-none transition-all"
        />

        {/* Kumo UI Primary Black Send Button (Larger Height & Width) */}
        <button
          type="submit"
          disabled={!text.trim()}
          className={`relative inline-flex items-center justify-center gap-1.5 rounded-full px-4.5 h-10 text-[13px] font-bold text-white bg-[#18181b] border border-black/40 shadow-xs overflow-hidden shrink-0 transition-all ${
            !text.trim() ? 'opacity-40 cursor-not-allowed' : 'active:scale-95 cursor-pointer hover:bg-black'
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
