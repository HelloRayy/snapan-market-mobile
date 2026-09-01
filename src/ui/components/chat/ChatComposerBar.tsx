import React, { useState, useRef } from 'react';
import { Send } from 'lucide-react';
import { triggerHaptic } from '@/utils/haptics';

interface ChatComposerBarProps {
  onSendMessage?: (message: string) => void;
  placeholder?: string;
  className?: string;
}

export const ChatComposerBar: React.FC<ChatComposerBarProps> = ({
  onSendMessage,
  placeholder = 'Ketik pesan...',
  className = '',
}) => {
  const [text, setText] = useState('');
  const inputRef = useRef<HTMLInputElement>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const trimmed = text.trim();
    if (!trimmed) return;

    triggerHaptic('medium');
    onSendMessage?.(trimmed);
    setText('');
  };

  return (
    <footer
      className={`sticky bottom-0 inset-x-0 z-40 bg-white/95 backdrop-blur-md border-t border-neutral-200/80 px-3.5 pt-2.5 pb-[max(0.75rem,calc(env(safe-area-inset-bottom)+6px))] font-gt-standard select-none ${className}`}
    >
      <form onSubmit={handleSubmit} className="flex items-center gap-2.5 w-full max-w-full">
        {/* Text-Only Input Field (MVP: Clean sans-serif, no attachments/links) */}
        <input
          ref={inputRef}
          type="text"
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder={placeholder}
          className="flex-1 min-w-0 bg-[#f4f5f7] hover:bg-[#ebedf1] focus:bg-white border border-transparent focus:border-[#1d64ec] rounded-full px-4.5 h-10 text-[16px] sm:text-[14.5px] text-slate-900 placeholder:text-neutral-400 focus:outline-none focus:shadow-xs transition-all"
        />

        {/* Circular Kumo Primary Blue Send Button */}
        <button
          type="submit"
          disabled={!text.trim()}
          aria-label="Kirim Pesan"
          className={`relative w-10 h-10 min-w-10 rounded-full text-white bg-[#1d64ec] hover:bg-[#154ec1] border border-[#154ec1] shadow-xs flex items-center justify-center transition-all shrink-0 overflow-hidden group select-none ${
            !text.trim()
              ? 'opacity-40 cursor-not-allowed'
              : 'active:scale-90 cursor-pointer shadow-blue-500/25 hover:shadow-md'
          }`}
        >
          {/* Kumo Inset Top Rim Highlight Gradient */}
          <span className="absolute inset-0 rounded-full bg-gradient-to-b from-[#3b82f6] to-[#1d64ec] shadow-[inset_0_1px_0_0_rgba(255,255,255,0.35)] group-hover:from-[#2563eb] transition-colors pointer-events-none" />

          {/* Paperplane / Send Icon */}
          <Send className="relative z-10 w-4.5 h-4.5 text-white stroke-[2.2] translate-x-[-0.5px] translate-y-[-0.5px]" />
        </button>
      </form>
    </footer>
  );
};
