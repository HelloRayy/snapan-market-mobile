import React, { useState, useRef, useEffect, useLayoutEffect } from 'react';
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
      const buttonRect = buttonRef.current.getBoundingClientRect();
      const iconCenter = buttonRect.left + buttonRect.width / 2;

      // Measure exact rendered tooltip DOM width if available, or fallback
      const tooltipWidth = tooltipRef.current?.getBoundingClientRect().width || 172;

      // Clamp tooltip position within screen margins (8px padding)
      const clampedLeft = Math.max(
        tooltipWidth / 2 + 8,
        Math.min(window.innerWidth - tooltipWidth / 2 - 8, iconCenter)
      );

      // Left edge of the rendered tooltip container in fixed coordinates
      const tooltipLeftEdge = clampedLeft - tooltipWidth / 2;

      // Exact pixel distance from tooltip container's left edge to icon center
      const arrowLeftPixel = iconCenter - tooltipLeftEdge;

      setTooltipPos({
        top: buttonRect.top - 8, // 8px above badge checkmark icon
        left: clampedLeft,
        arrowLeft: arrowLeftPixel,
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

  // Measure exact DOM width after mount
  useLayoutEffect(() => {
    if (isTooltipOpen) {
      updatePosition();
    }
  }, [isTooltipOpen]);

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
        <BadgeCheck className={`${className} text-[#3d38f5] fill-[#3d38f5] text-white`} />
      </button>

      {/* Portal Tooltip (Exact Pixel Caret Alignment with Icon Center) */}
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
            {/* Ujung Runcing (Exact pixel placement pointing 100% dead-center to badge icon) */}
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
