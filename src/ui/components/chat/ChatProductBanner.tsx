import React, { useState } from 'react';
import { Tag, MapPin, X } from 'lucide-react';
import { ChatProductContext } from '@/types/chat';
import { formatRupiah } from '@/utils/formatters';
import { triggerHaptic } from '@/utils/haptics';

interface ChatProductBannerProps {
  product: ChatProductContext;
  onMakeOffer?: () => void;
  onArrangeMeeting?: () => void;
  onViewProduct?: (productId: string) => void;
}

export const ChatProductBanner: React.FC<ChatProductBannerProps> = ({
  product,
  onMakeOffer,
  onArrangeMeeting,
  onViewProduct,
}) => {
  const [isDismissed, setIsDismissed] = useState(false);

  if (isDismissed) return null;

  return (
    <div className="bg-neutral-50/95 border-b border-neutral-200/80 px-3 py-2.5 flex items-center justify-between gap-2.5 transition-all select-none">
      {/* Product Image & Info */}
      <div
        onClick={() => {
          triggerHaptic('light');
          onViewProduct?.(product.id);
        }}
        className="flex items-center gap-2.5 min-w-0 flex-1 cursor-pointer group"
      >
        <img
          src={product.image}
          alt={product.title}
          className="w-11 h-11 rounded-xl object-cover shrink-0 border border-neutral-200 shadow-2xs group-hover:scale-105 transition-transform"
        />

        <div className="min-w-0 flex-1">
          <h4 className="font-bold text-[13px] text-slate-900 truncate leading-snug group-hover:text-[#1d64ec] transition-colors">
            {product.title}
          </h4>
          <div className="flex items-center gap-1.5 mt-0.5">
            <span className="font-extrabold text-[13.5px] text-[#1d64ec]">
              {formatRupiah(product.price)}
            </span>
            {product.originalPrice && product.originalPrice > product.price && (
              <span className="text-[11px] text-neutral-400 line-through">
                {formatRupiah(product.originalPrice)}
              </span>
            )}
            {product.locationTag && (
              <span className="text-[11px] text-neutral-500 bg-neutral-200/70 px-1.5 py-0.5 rounded-md font-medium truncate">
                {product.locationTag}
              </span>
            )}
          </div>
        </div>
      </div>

      {/* Quick Action Buttons: Tawaran & COD */}
      <div className="flex items-center gap-1.5 shrink-0">
        <button
          type="button"
          onClick={() => {
            triggerHaptic('medium');
            onMakeOffer?.();
          }}
          className="h-8 px-2.5 rounded-xl bg-white border border-neutral-200 text-slate-800 text-[11.5px] font-bold shadow-2xs hover:bg-neutral-100 active:scale-[0.96] transition-all flex items-center gap-1 cursor-pointer"
        >
          <Tag className="w-3.5 h-3.5 text-[#1d64ec]" />
          <span>Tawar</span>
        </button>

        <button
          type="button"
          onClick={() => {
            triggerHaptic('medium');
            onArrangeMeeting?.();
          }}
          className="h-8 px-2.5 rounded-xl bg-[#1d64ec] text-white text-[11.5px] font-bold shadow-2xs hover:bg-[#154ec1] active:scale-[0.96] transition-all flex items-center gap-1 cursor-pointer"
        >
          <MapPin className="w-3.5 h-3.5" />
          <span>Janji COD</span>
        </button>

        <button
          type="button"
          onClick={() => {
            triggerHaptic('light');
            setIsDismissed(true);
          }}
          className="w-7 h-7 rounded-full hover:bg-neutral-200 text-neutral-400 hover:text-slate-700 flex items-center justify-center transition-colors cursor-pointer"
          aria-label="Tutup ringkasan produk"
        >
          <X className="w-3.5 h-3.5" />
        </button>
      </div>
    </div>
  );
};
