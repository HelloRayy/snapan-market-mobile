import React from 'react';
import { motion } from 'framer-motion';
import { Heart, Repeat2, Send, Box } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';
import { SmoothCommentIcon } from '@/ui/components/icons';

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
  return (
    <div className="pt-1 flex items-center justify-between text-slate-700 font-normal -ml-1.5 select-none max-w-full">
      <div className="flex items-center gap-2 text-slate-700 text-sm font-normal cursor-pointer select-none">
        {/* 1. Suka (Like) */}
        <motion.button
          type="button"
          whileTap={{ scale: 0.96 }}
          onClick={onToggleLike}
          className="flex items-center justify-center gap-1.5 px-2 py-1.5 min-h-[36px] min-w-[36px] cursor-pointer select-none group active:bg-neutral-100 rounded-full transition-colors"
          aria-label={`Sukai postingan. ${likesCount} suka`}
        >
          <motion.div
            animate={isLiked ? { scale: [1, 1.45, 0.88, 1.15, 1], rotate: [0, -10, 10, -4, 0] } : { scale: 1, rotate: 0 }}
            transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
          >
            <Heart
              className={`w-[19px] h-[19px] stroke-[1.85] transition-colors duration-200 ${
                isLiked ? 'fill-rose-500 text-rose-500 stroke-rose-500' : 'text-slate-700'
              }`}
            />
          </motion.div>
          {likesCount > 0 && (
            <motion.span
              key={likesCount}
              initial={{ opacity: 0.6, y: -2 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.15 }}
              className={`font-medium text-[13.5px] tabular-nums tracking-tight transition-colors duration-200 ${
                isLiked ? 'text-rose-600 font-bold' : 'text-slate-700'
              }`}
            >
              {likesCount}
            </motion.span>
          )}
        </motion.button>

        {/* 2. Balas (Comment) */}
        <motion.button
          type="button"
          whileTap={{ scale: 0.96 }}
          onClick={onCommentClick}
          className="flex items-center justify-center gap-1.5 px-2 py-1.5 min-h-[36px] min-w-[36px] cursor-pointer transition-colors text-slate-700 group select-none active:bg-neutral-100 rounded-full"
          aria-label={`Komentar postingan. ${item.commentsCount} komentar`}
        >
          <SmoothCommentIcon className="w-[19px] h-[19px] stroke-[1.85] text-slate-700 group-hover:text-sky-500 transition-colors duration-200" />
          {item.commentsCount > 0 && (
            <span className="font-medium text-[13.5px] text-slate-700 tabular-nums tracking-tight">{item.commentsCount}</span>
          )}
        </motion.button>

        {/* 3. Posting Ulang (Repost) */}
        <motion.button
          type="button"
          whileTap={{ scale: 0.96 }}
          onClick={onToggleRepost}
          className="flex items-center justify-center gap-1.5 px-2 py-1.5 min-h-[36px] min-w-[36px] cursor-pointer transition-colors select-none group active:bg-neutral-100 rounded-full"
          aria-label={`Post ulang postingan. ${repostsCount} posting ulang`}
        >
          <motion.div
            animate={isReposted ? { rotate: [0, 180], scale: [1, 1.3, 0.9, 1.05, 1] } : { rotate: 0, scale: 1 }}
            transition={{ duration: 0.35, ease: [0.175, 0.885, 0.32, 1.275] }}
          >
            <Repeat2
              className={`w-[19px] h-[19px] stroke-[1.85] transition-colors duration-200 ${
                isReposted ? 'text-emerald-500 stroke-emerald-500' : 'text-slate-700'
              }`}
            />
          </motion.div>
          {repostsCount > 0 && (
            <motion.span
              key={repostsCount}
              initial={{ opacity: 0.6, y: -2 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.15 }}
              className={`font-medium text-[13.5px] tabular-nums tracking-tight transition-colors duration-200 ${
                isReposted ? 'text-emerald-600 font-bold' : 'text-slate-700'
              }`}
            >
              {repostsCount}
            </motion.span>
          )}
        </motion.button>

        {/* 4. Bagikan (Share) */}
        <motion.button
          type="button"
          whileTap={{ scale: 0.96 }}
          onClick={onShare}
          className="flex items-center justify-center p-2 min-h-[36px] min-w-[36px] cursor-pointer transition-colors text-slate-700 group select-none active:bg-neutral-100 rounded-full"
          aria-label="Bagikan postingan"
          title="Bagikan / Kirim"
        >
          <Send className="w-[19px] h-[19px] stroke-[1.85] text-slate-700 group-hover:text-slate-900 transition-colors duration-200" />
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
