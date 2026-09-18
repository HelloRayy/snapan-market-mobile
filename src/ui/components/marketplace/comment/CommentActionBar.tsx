import React from 'react';
import { motion } from 'framer-motion';
import { Heart, Repeat2, Send } from 'lucide-react';
import { formatCompactNumber } from '@/utils/formatters';
import { SmoothCommentIcon } from '@/ui/components/icons';
import { triggerHaptic } from '@/utils/haptics';

interface CommentActionBarProps {
  isLiked: boolean;
  likesCount: number;
  onLike?: () => void;
  onReply?: () => void;
  onShare?: () => void;
  onRepost?: () => void;
}

export const CommentActionBar: React.FC<CommentActionBarProps> = ({
  isLiked,
  likesCount,
  onLike,
  onReply,
  onShare,
  onRepost,
}) => {
  return (
    <div
      onClick={(e) => e.stopPropagation()}
      className="flex items-center gap-1.5 text-slate-700 font-normal pt-1 -ml-1 text-[13px] select-none"
    >
      {/* 1. Suka (Like) Slot - Threads-style 32px capsule pill */}
      <motion.button
        type="button"
        whileTap={{ scale: 0.94 }}
        onClick={(e) => {
          e.stopPropagation();
          triggerHaptic(isLiked ? 'light' : 'medium');
          onLike?.();
        }}
        className={`flex items-center justify-center rounded-full h-[32px] cursor-pointer select-none group active:bg-neutral-100/90 hover:bg-neutral-100/70 transition-all leading-snug ${
          likesCount > 0 ? 'px-2.5 gap-x-1.5' : 'w-[32px]'
        }`}
        aria-label={`Sukai komentar. ${likesCount} suka`}
      >
        <motion.div
          className="flex items-center justify-center shrink-0"
          animate={isLiked ? { scale: [1, 1.45, 0.88, 1.15, 1], rotate: [0, -10, 10, -4, 0] } : { scale: 1, rotate: 0 }}
          transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
        >
          <Heart
            className={`w-[17.5px] h-[17.5px] stroke-[1.8] transition-colors duration-200 ${
              isLiked ? 'fill-rose-500 text-rose-500 stroke-rose-500' : 'text-slate-700 group-hover:text-rose-500'
            }`}
          />
        </motion.div>
        {likesCount > 0 && (
          <motion.span
            key={likesCount}
            initial={{ opacity: 0.6, y: -2 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.15 }}
            className={`text-xs leading-snug tabular-nums tracking-tight transition-all select-none ${
              isLiked ? 'text-rose-600 font-semibold' : 'text-neutral-600 font-normal group-hover:text-neutral-900'
            }`}
          >
            {formatCompactNumber(likesCount)}
          </motion.span>
        )}
      </motion.button>

      {/* 2. Balas (Comment) Slot - Threads-style 32px circular button */}
      <motion.button
        type="button"
        whileTap={{ scale: 0.94 }}
        onClick={(e) => {
          e.stopPropagation();
          triggerHaptic('light');
          onReply?.();
        }}
        className="flex items-center justify-center rounded-full h-[32px] w-[32px] cursor-pointer transition-all text-slate-700 group select-none active:bg-neutral-100/90 hover:bg-neutral-100/70 leading-snug"
        aria-label="Balas komentar"
      >
        <SmoothCommentIcon className="w-[17.5px] h-[17.5px] stroke-[1.8] text-slate-700 group-hover:text-sky-500 transition-colors duration-200 shrink-0" />
      </motion.button>

      {/* 3. Posting Ulang (Repost) Slot - Threads-style 32px circular button */}
      <motion.button
        type="button"
        whileTap={{ scale: 0.94 }}
        onClick={(e) => {
          e.stopPropagation();
          triggerHaptic('light');
          onRepost?.();
        }}
        className="flex items-center justify-center rounded-full h-[32px] w-[32px] cursor-pointer transition-all select-none group active:bg-neutral-100/90 hover:bg-neutral-100/70 leading-snug"
        aria-label="Post ulang komentar"
      >
        <motion.div
          className="flex items-center justify-center shrink-0"
          animate={Boolean(likesCount > 0)}
          whileTap={{ rotate: [0, 180], scale: [1, 1.3, 0.9, 1.05, 1] }}
          transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
        >
          <Repeat2 className="w-[17.5px] h-[17.5px] stroke-[1.8] text-slate-700 group-hover:text-emerald-500 transition-colors duration-200" />
        </motion.div>
      </motion.button>

      {/* 4. Bagikan (Share) Slot - Threads-style 32px circular button */}
      <motion.button
        type="button"
        whileTap={{ scale: 0.94 }}
        onClick={(e) => {
          e.stopPropagation();
          triggerHaptic('light');
          onShare?.();
        }}
        className="flex items-center justify-center rounded-full h-[32px] w-[32px] cursor-pointer transition-all text-slate-700 group select-none active:bg-neutral-100/90 hover:bg-neutral-100/70 leading-snug"
        aria-label="Bagikan komentar"
        title="Bagikan / Kirim"
      >
        <Send className="w-[17.5px] h-[17.5px] stroke-[1.8] text-slate-700 group-hover:text-sky-500 transition-colors duration-200 shrink-0" />
      </motion.button>
    </div>
  );
};
