import React, { useState, useRef, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { BadgeCheck } from 'lucide-react';

interface ClickableVerifiedBadgeProps {
  sellerName?: string;
  className?: string;
}

export const ClickableVerifiedBadge: React.FC<ClickableVerifiedBadgeProps> = ({
  className = 'w-[17px] h-[17px]',
}) => {
  const [isTooltipOpen, setIsTooltipOpen] = useState(false);
  const [tooltipPos, setTooltipPos] = useState<{ top: number; left: number; arrowLeft: number } | null>(null);

  const buttonRef = useRef<HTMLButtonElement>(null);
  const tooltipRef = useRef<HTMLDivElement>(null);

  const updatePosition = () => {
    if (buttonRef.current) {
      const rect = buttonRef.current.getBoundingClientRect();
      const tooltipWidth = 168; // Width for text-[13px] font-bold single-line badge
      const centerLeft = rect.left + rect.width / 2;

      // Keep tooltip within screen boundaries
      const clampedLeft = Math.max(
        tooltipWidth / 2 + 8,
        Math.min(window.innerWidth - tooltipWidth / 2 - 8, centerLeft)
      );

      const arrowOffset = centerLeft - clampedLeft;

      setTooltipPos({
        top: rect.top - 8, // 8px above checkmark icon
        left: clampedLeft,
        arrowLeft: tooltipWidth / 2 + arrowOffset,
      });
    }
  };

  const handleToggleTooltip = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (!isTooltipOpen) {
      updatePosition();
      setIsTooltipOpen(true);
    } else {
      setIsTooltipOpen(false);
    }
  };

  // Close IMMEDIATELY on scroll, touchmove, wheel, resize, or click outside
  useEffect(() => {
    if (!isTooltipOpen) return;

    const closeTooltip = () => setIsTooltipOpen(false);

    const handleClickOutside = (event: MouseEvent | TouchEvent) => {
      if (
        buttonRef.current &&
        !buttonRef.current.contains(event.target as Node) &&
        tooltipRef.current &&
        !tooltipRef.current.contains(event.target as Node)
      ) {
        setIsTooltipOpen(false);
      }
    };

    window.addEventListener('scroll', closeTooltip, { capture: true, passive: true });
    window.addEventListener('touchmove', closeTooltip, { capture: true, passive: true });
    window.addEventListener('wheel', closeTooltip, { capture: true, passive: true });
    window.addEventListener('resize', closeTooltip, { passive: true });
    document.addEventListener('mousedown', handleClickOutside);
    document.addEventListener('touchstart', handleClickOutside, { passive: true });

    return () => {
      window.removeEventListener('scroll', closeTooltip, true);
      window.removeEventListener('touchmove', closeTooltip, true);
      window.removeEventListener('wheel', closeTooltip, true);
      window.removeEventListener('resize', closeTooltip);
      document.removeEventListener('mousedown', handleClickOutside);
      document.removeEventListener('touchstart', handleClickOutside);
    };
  }, [isTooltipOpen]);

  return (
    <span className="inline-flex items-center">
      {/* Clickable Badge Checkmark Trigger */}
      <button
        ref={buttonRef}
        type="button"
        onClick={handleToggleTooltip}
        className="inline-flex items-center shrink-0 cursor-pointer hover:opacity-80 active:scale-90 transition-transform select-none"
        title="User Terverifikasi"
        aria-label="User Terverifikasi"
      >
        <BadgeCheck className={`${className} text-[#1d64ec] fill-[#1d64ec] text-white`} />
      </button>

      {/* Larger Text & Instant Auto-Close Portal Tooltip (White Box + Sharp Pointed Caret Arrow) */}
      {isTooltipOpen &&
        tooltipPos &&
        createPortal(
          <div
            ref={tooltipRef}
            onClick={(e) => e.stopPropagation()}
            style={{
              position: 'fixed',
              top: `${tooltipPos.top}px`,
              left: `${tooltipPos.left}px`,
              transform: 'translate(-50%, -100%)',
              zIndex: 999999,
            }}
            className="px-3 py-1.5 bg-white text-slate-900 rounded-xl shadow-[0_8px_25px_rgba(0,0,0,0.16)] border border-neutral-200/90 font-gt-standard select-none animate-in fade-in zoom-in-95 duration-150 flex items-center gap-1.5 whitespace-nowrap pointer-events-auto"
          >
            {/* Ujung Runcing (Sharp Pointed Caret Notch Arrow pointing down) */}
            <div
              style={{ left: `${tooltipPos.arrowLeft}px` }}
              className="absolute -bottom-1 -translate-x-1/2 w-2.5 h-2.5 bg-white rotate-45 border-b border-r border-neutral-200/90"
            />

            <BadgeCheck className="w-4 h-4 text-[#1d64ec] fill-[#1d64ec] text-white shrink-0" />
            <span className="text-[13px] font-bold text-slate-900 tracking-tight">
              User Terverifikasi
            </span>
          </div>,
          document.body
        )}
    </span>
  );
};
