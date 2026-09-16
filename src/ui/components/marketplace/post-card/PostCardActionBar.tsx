import React from 'react';
import { motion } from 'framer-motion';
import { Heart, Repeat2, Send, Box } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';
import { SmoothCommentIcon } from '@/ui/components/icons';
import { triggerHaptic } from '@/utils/haptics';
import { formatCompactNumber } from '@/utils/formatters';

interface PostCardActionBarProps {
  item: MarketPostItem;
  isLiked: boolean;
  likesCount: number;
  onToggleLike: (e: React.MouseEvent) => void;
  isReposted: boolean;
  repostsCount: number;
  onToggleRepost: (e: React.MouseEvent) => void;
  onCommentClick: (e: React.MouseEvent) => void;
  onShare: (e: React.MouseEvent) => void;
}

export const PostCardActionBar: React.FC<PostCardActionBarProps> = ({
  item,
  isLiked,
  likesCount,
  onToggleLike,
  isReposted,
  repostsCount,
  onToggleRepost,
  onCommentClick,
  onShare,
}) => {
  const handleLikeClick = (e: React.MouseEvent) => {
    triggerHaptic(isLiked ? 'light' : 'medium');
    onToggleLike(e);
  };

  const handleRepostClick = (e: React.MouseEvent) => {
    triggerHaptic(isReposted ? 'light' : 'medium');
    onToggleRepost(e);
  };

  const handleCommentClick = (e: React.MouseEvent) => {
    triggerHaptic('light');
    onCommentClick(e);
  };

  const handleShareClick = (e: React.MouseEvent) => {
    triggerHaptic('light');
    onShare(e);
  };

  return (
    <div className="pt-1 flex items-center justify-between text-slate-700 font-normal select-none max-w-full">
      <div className="flex items-center gap-1.5 text-slate-700 text-[12px] font-normal cursor-pointer select-none">
        {/* 1. Suka (Like) - Flush-left button */}
        <motion.button
          type="button"
          whileTap={{ scale: 0.94 }}
          onClick={handleLikeClick}
          className="flex items-center justify-start h-[34px] pl-0 pr-2 gap-x-1.5 cursor-pointer select-none group transition-all leading-snug"
          aria-label={`Sukai postingan. ${likesCount} suka`}
        >
          <motion.div
            className="flex items-center justify-center shrink-0"
            animate={isLiked ? { scale: [1, 1.45, 0.88, 1.15, 1], rotate: [0, -10, 10, -4, 0] } : { scale: 1, rotate: 0 }}
            transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
          >
            <Heart
              className={`w-[18px] h-[18px] stroke-[1.85] transition-colors duration-200 ${
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
              className={`text-[12px] leading-snug tabular-nums tracking-tight transition-all select-none ${
                isLiked ? 'text-rose-600 font-semibold' : 'text-neutral-600 font-normal group-hover:text-neutral-900'
              }`}
            >
              {formatCompactNumber(likesCount)}
            </motion.span>
          )}
        </motion.button>

        {/* 2. Balas (Comment) */}
        <motion.button
          type="button"
          whileTap={{ scale: 0.94 }}
          onClick={handleCommentClick}
          className="flex items-center justify-center h-[34px] px-2 gap-x-1.5 cursor-pointer transition-all text-slate-700 group select-none leading-snug"
          aria-label={`Komentar postingan. ${item.commentsCount} komentar`}
        >
          <SmoothCommentIcon className="w-[18px] h-[18px] stroke-[1.85] text-slate-700 group-hover:text-sky-500 transition-colors duration-200 shrink-0" />
          {item.commentsCount > 0 && (
            <span className="text-[12px] leading-snug text-neutral-600 group-hover:text-neutral-900 tabular-nums tracking-tight font-normal select-none transition-all">
              {formatCompactNumber(item.commentsCount)}
            </span>
          )}
        </motion.button>

        {/* 3. Posting Ulang (Repost) */}
        <motion.button
          type="button"
          whileTap={{ scale: 0.94 }}
          onClick={handleRepostClick}
          className="flex items-center justify-center h-[34px] px-2 gap-x-1.5 cursor-pointer transition-all select-none group leading-snug"
          aria-label={`Post ulang postingan. ${repostsCount} posting ulang`}
        >
          <motion.div
            className="flex items-center justify-center shrink-0"
            animate={isReposted ? { rotate: [0, 180], scale: [1, 1.3, 0.9, 1.05, 1] } : { rotate: 0, scale: 1 }}
            transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
          >
            <Repeat2
              className={`w-[18px] h-[18px] stroke-[1.85] transition-colors duration-200 ${
                isReposted ? 'text-emerald-500 stroke-emerald-500' : 'text-slate-700 group-hover:text-emerald-500'
              }`}
            />
          </motion.div>
          {repostsCount > 0 && (
            <motion.span
              key={repostsCount}
              initial={{ opacity: 0.6, y: -2 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.15 }}
              className={`text-[12px] leading-snug tabular-nums tracking-tight transition-all select-none ${
                isReposted ? 'text-emerald-600 font-semibold' : 'text-neutral-600 font-normal group-hover:text-neutral-900'
              }`}
            >
              {formatCompactNumber(repostsCount)}
            </motion.span>
          )}
        </motion.button>

        {/* 4. Bagikan (Share) */}
        <motion.button
          type="button"
          whileTap={{ scale: 0.94 }}
          onClick={handleShareClick}
          className="flex items-center justify-center h-[34px] w-[30px] cursor-pointer transition-all text-slate-700 group select-none hover:opacity-75"
          aria-label="Bagikan postingan"
          title="Bagikan / Kirim"
        >
          <Send className="w-[18px] h-[18px] stroke-[1.85] text-slate-700 group-hover:text-slate-900 transition-colors duration-200 shrink-0" />
        </motion.button>
      </div>

      {/* Sisa Stok */}
      {item.postType !== 'thread' && !!item.price && item.price > 0 && item.stock !== undefined && item.stock > 0 && (
        <div
          className="flex items-center gap-1 min-h-[26px] px-2 py-0.5 text-neutral-600 bg-neutral-100/90 border border-neutral-200/60 rounded-full text-[12px] select-none ml-auto shrink-0 whitespace-nowrap font-medium transition-colors"
          title={`Sisa stok: ${item.stock} item`}
        >
          <Box className="w-3.5 h-3.5 stroke-[1.8] text-neutral-500 shrink-0" />
          <span className="font-semibold text-slate-800 tabular-nums tracking-tight whitespace-nowrap">{item.stock}</span>
        </div>
      )}
    </div>
  );
};
