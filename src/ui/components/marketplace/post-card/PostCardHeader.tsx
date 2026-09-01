import React from 'react';
import { ChevronRight, PartyPopper, MoreHorizontal } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';
import { ClickableVerifiedBadge } from '@/ui/components/marketplace/VerifiedBadgeModal';
import { formatSmartTimestamp } from '@/utils/formatters';
import { ThreadsTopicIcon } from '@/ui/components/icons';

interface PostCardHeaderProps {
  item: MarketPostItem;
  onUserClick?: (username: string) => void;
  onTopicClick?: (topic: string) => void;
  onToggleMenu: (e: React.MouseEvent) => void;
  isMenuOpen: boolean;
  variant?: 'feed' | 'detail';
}

export const PostCardHeader: React.FC<PostCardHeaderProps> = ({
  item,
  onUserClick,
  onTopicClick,
  onToggleMenu,
  isMenuOpen,
  variant = 'feed',
}) => {
  return (
    <div className="flex items-start justify-between gap-2 min-w-0">
      <div className="flex items-center gap-2 min-w-0 flex-1 overflow-hidden">
        {variant === 'detail' && (
          <div
            onClick={(e) => {
              e.stopPropagation();
              onUserClick?.(item.seller.username || item.seller.name);
            }}
            className="w-9 h-9 rounded-full overflow-hidden border border-neutral-200/80 shadow-2xs shrink-0 cursor-pointer active:scale-95 transition-transform"
          >
            <img src={item.seller.avatar} alt={item.seller.name} className="w-full h-full object-cover" />
          </div>
        )}

        <div className="flex items-center gap-1.5 min-w-0 flex-1 overflow-hidden leading-none">
          {/* 1. Author Name (Primary Priority - Shrink 0, never truncated before secondary elements) */}
          <span
            onClick={(e) => {
              e.stopPropagation();
              onUserClick?.(item.seller.username || item.seller.name);
            }}
            className="font-semibold text-[15px] text-slate-900 tracking-tight shrink-0 hover:underline cursor-pointer leading-none"
          >
            {item.seller.name}
          </span>

          {/* Verified Badge (Always attached to Name) */}
          {item.seller.isVerified && (
            <ClickableVerifiedBadge sellerName={item.seller.name} className="w-[15px] h-[15px] shrink-0" />
          )}

          {/* 2. Secondary Priority: Topic Tag (If exists -> class removed; topic truncates if space constrained) */}
          {item.topicTag ? (
            <div className="flex items-center gap-1 min-w-0 flex-1 overflow-hidden leading-none">
              <ChevronRight className="w-3 h-3 text-neutral-400 stroke-[2.5] shrink-0" />

              {item.isOfficialTopic &&
                (item.topicIcon === 'presentation' || item.topicIcon === 'party-popper' ? (
                  <PartyPopper className="w-3.5 h-3.5 text-[#1d64ec] stroke-[2.2] shrink-0" />
                ) : (
                  <ThreadsTopicIcon className="w-3.5 h-3.5 text-[#1d64ec] fill-current shrink-0" />
                ))}

              <button
                type="button"
                onClick={(e) => {
                  e.stopPropagation();
                  onTopicClick?.(item.topicTag!);
                }}
                className={`font-semibold text-[15px] tracking-tight leading-none transition-colors cursor-pointer truncate flex-1 min-w-0 text-left ${
                  item.isOfficialTopic ? 'text-[#1d64ec] hover:underline' : 'text-slate-900 hover:underline'
                }`}
              >
                <span className="truncate">{item.topicTag}</span>
              </button>
            </div>
          ) : (
            /* 3. Last Priority: Class Group (Only if NO topic AND name is short <= 14 chars) */
            item.seller.name.length <= 14 && item.seller.classGroup && (
              <span className="text-[13.5px] font-normal text-neutral-400 truncate min-w-0 flex-1 leading-none">
                {item.seller.classGroup}
              </span>
            )
          )}
        </div>
      </div>

      <div className="flex items-center gap-1.5 shrink-0 ml-auto leading-none">
        <span
          className="text-[13px] font-normal text-neutral-400 whitespace-nowrap tabular-nums cursor-default select-none leading-none"
          title={formatSmartTimestamp(item.timestamp).full}
        >
          {formatSmartTimestamp(item.timestamp).display}
        </span>
        <div className="relative flex items-center">
          <button
            type="button"
            id={`post-options-btn-${item.id}`}
            data-submenu-trigger="true"
            aria-haspopup="menu"
            aria-expanded={isMenuOpen}
            aria-controls={`post-options-menu-${item.id}`}
            onClick={onToggleMenu}
            className="w-5 h-5 flex items-center justify-center rounded-full hover:bg-neutral-100 text-neutral-400 hover:text-slate-700 transition-colors cursor-pointer"
            aria-label="Opsi postingan lainnya"
          >
            <MoreHorizontal className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
};
