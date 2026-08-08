import React, { useState } from 'react';
import { Send } from 'lucide-react';
import { ButtonPrimary } from '../ui/ButtonPrimary';

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
          type="text"
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder={replyToUser ? `Balas @${replyToUser}...` : 'Ketik komentar / pertanyaan produk...'}
          className="flex-1 bg-neutral-100 hover:bg-neutral-100/80 focus:bg-white border border-transparent focus:border-[#1d64ec] rounded-full px-4 py-2 text-[14px] text-slate-900 placeholder:text-slate-400 focus:outline-none transition-all"
        />

        {/* Kumo UI Primary Send Button */}
        <ButtonPrimary
          type="submit"
          disabled={!text.trim()}
          size="sm"
          className={`rounded-full px-3.5 h-8 text-[12px] shrink-0 transition-opacity ${
            !text.trim() ? 'opacity-50 cursor-not-allowed' : 'active:scale-95'
          }`}
          aria-label="Kirim Komentar"
        >
          <span className="flex items-center gap-1">
            <span>Kirim</span>
            <Send className="w-3 h-3 stroke-[2.25]" />
          </span>
        </ButtonPrimary>
      </form>
    </div>
  );
};
