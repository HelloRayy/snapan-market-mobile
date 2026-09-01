import React from 'react';
import { ChevronRight, PartyPopper, MoreHorizontal } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';
import { ClickableVerifiedBadge } from '../VerifiedBadgeModal';
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
    <div className="flex items-center justify-between gap-2 min-w-0">
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

        <div className="flex items-center gap-1 min-w-0 flex-1 overflow-hidden">
          <span
            onClick={(e) => {
              e.stopPropagation();
              onUserClick?.(item.seller.username || item.seller.name);
            }}
            className="font-semibold text-[14.5px] text-slate-900 truncate hover:underline shrink-1 max-w-[62%] cursor-pointer"
          >
            {item.seller.name}
          </span>

          {item.seller.isVerified && (
            <ClickableVerifiedBadge sellerName={item.seller.name} className="w-[16px] h-[16px] shrink-0" />
          )}

          {item.topicTag ? (
            <div className="flex items-center gap-x-0.5 shrink-1 min-w-0 overflow-hidden ml-0.5 h-[21px] leading-snug">
              <span className="h-[21px] leading-snug flex items-center">
                <ChevronRight className="w-3.5 h-3.5 text-neutral-400 stroke-[2] shrink-0" />
              </span>

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
                className={`font-semibold text-base h-[21px] leading-snug transition-colors cursor-pointer truncate max-w-[140px] sm:max-w-[220px] flex items-center ${
                  item.isOfficialTopic ? 'text-[#1d64ec] hover:underline' : 'text-slate-900 hover:underline'
                }`}
              >
                <span className="leading-snug">{item.topicTag}</span>
              </button>
            </div>
          ) : (
            <span className="text-[13.5px] font-normal text-neutral-400 truncate min-w-0 shrink">
              {item.seller.classGroup}
            </span>
          )}
        </div>
      </div>

      <div className="flex items-center gap-1 shrink-0 ml-auto">
        <span
          className="text-[12px] sm:text-[12.5px] font-normal text-slate-500 whitespace-nowrap tabular-nums cursor-default select-none"
          title={formatSmartTimestamp(item.timestamp).full}
        >
          {formatSmartTimestamp(item.timestamp).display}
        </span>
        <div className="relative">
          <button
            type="button"
            id={`post-options-btn-${item.id}`}
            data-submenu-trigger="true"
            aria-haspopup="menu"
            aria-expanded={isMenuOpen}
            aria-controls={`post-options-menu-${item.id}`}
            onClick={onToggleMenu}
            className="w-7 h-7 flex items-center justify-center rounded-full hover:bg-neutral-100 text-neutral-400 hover:text-slate-700 transition-colors cursor-pointer"
            aria-label="Opsi postingan lainnya"
          >
            <MoreHorizontal className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
};
