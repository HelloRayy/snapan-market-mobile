import React, { useState, useRef } from 'react';
import { ArrowUp, Paperclip, Smile } from 'lucide-react';
import { triggerHaptic } from '@/utils/haptics';

interface ChatComposerBarProps {
  onSendMessage?: (message: string) => void;
  onAttachmentClick?: () => void;
  placeholder?: string;
  className?: string;
}

export const ChatComposerBar: React.FC<ChatComposerBarProps> = ({
  onSendMessage,
  onAttachmentClick,
  placeholder = 'Message',
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
      className={`sticky bottom-0 inset-x-0 z-40 bg-transparent px-4 pt-1.5 pb-[max(0.75rem,calc(env(safe-area-inset-bottom)+6px))] font-gt-standard select-none ${className}`}
    >
      <form onSubmit={handleSubmit} className="flex items-center gap-1.5 w-full max-w-full">
        {/* Leading Button (pen.dev Frame 1 jxdH0: 42x42 circle, frosted liquid glass + shadow) */}
        <button
          type="button"
          onClick={() => {
            triggerHaptic('light');
            onAttachmentClick?.();
          }}
          aria-label="Lampirkan berkas"
          className="w-[42px] h-[42px] min-w-[42px] rounded-full bg-white/75 backdrop-blur-2xl border border-white/80 shadow-[0_8px_35px_rgba(0,0,0,0.12),0_2px_10px_rgba(0,0,0,0.04)] flex items-center justify-center text-[#1a1a1a] hover:bg-white/90 active:scale-95 transition-all cursor-pointer shrink-0"
        >
          <Paperclip className="w-5 h-5 text-[#1a1a1a]" />
        </button>

        {/* Write Bar (pen.dev Frame 1 cXg3A: cornerRadius 21, height 42, frosted liquid glass + shadow) */}
        <div className="flex-1 min-w-0 h-[42px] bg-white/75 backdrop-blur-2xl border border-white/80 shadow-[0_8px_35px_rgba(0,0,0,0.12),0_2px_10px_rgba(0,0,0,0.04)] rounded-full pl-3.5 pr-1 flex items-center gap-1">
          <input
            ref={inputRef}
            type="text"
            value={text}
            onChange={(e) => setText(e.target.value)}
            placeholder={placeholder}
            className="flex-1 min-w-0 bg-transparent border-none text-[15.5px] text-black placeholder:text-[#999999] focus:outline-none"
          />

          {text.trim() ? (
            <button
              type="submit"
              aria-label="Kirim Pesan"
              className="w-9 h-9 min-w-9 rounded-full bg-[#008bff] hover:bg-[#007be5] text-white flex items-center justify-center shadow-xs active:scale-90 transition-all cursor-pointer shrink-0"
            >
              <ArrowUp className="w-5 h-5 text-white stroke-[2.5]" />
            </button>
          ) : (
            <div className="w-9 h-9 min-w-9 flex items-center justify-center text-[#727272] shrink-0">
              <Smile className="w-5 h-5 text-[#727272]" />
            </div>
          )}
        </div>
      </form>
    </footer>
  );
};

