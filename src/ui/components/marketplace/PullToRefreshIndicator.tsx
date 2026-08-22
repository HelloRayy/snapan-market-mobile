import React from 'react';
import { Loader2, ArrowDown } from 'lucide-react';

interface PullToRefreshIndicatorProps {
  pullDistance: number;
  isRefreshing: boolean;
  threshold?: number;
}

export const PullToRefreshIndicator: React.FC<PullToRefreshIndicatorProps> = ({
  pullDistance,
  isRefreshing,
  threshold = 60,
}) => {
  if (pullDistance <= 0 && !isRefreshing) return null;

  const isTriggered = pullDistance >= threshold;
  const progress = Math.min(1, pullDistance / threshold);

  return (
    <div
      className="fixed left-0 right-0 z-40 flex justify-center pointer-events-none transition-transform duration-100 ease-out"
      style={{
        top: 'calc(54px + env(safe-area-inset-top, 0px))',
        transform: `translateY(${isRefreshing ? 16 : pullDistance * 0.35}px)`,
        opacity: isRefreshing ? 1 : Math.max(0, (progress - 0.2) / 0.8),
      }}
    >
      <div className="w-10 h-10 rounded-full bg-white border border-neutral-200/90 shadow-md flex items-center justify-center text-slate-900 transition-all">
        {isRefreshing ? (
          <Loader2 className="w-5 h-5 text-slate-900 animate-spin" />
        ) : (
          <div
            className="transition-transform duration-150"
            style={{
              transform: `rotate(${isTriggered ? 180 : pullDistance * 3}deg) scale(${0.75 + progress * 0.25})`,
            }}
          >
            <ArrowDown className={`w-4 h-4 ${isTriggered ? 'text-[#1d64ec]' : 'text-slate-600'}`} />
          </div>
        )}
      </div>
    </div>
  );
};
