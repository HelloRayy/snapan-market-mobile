import React from 'react';
import { triggerHaptic } from '@/utils/haptics';
import { cn } from '@/utils/cn';

export interface ChatProductContext {
  id: string;
  title: string;
  price: string;
  image: string;
  itemCount?: number;
  statusText?: string;
  statusColor?: string;
  location?: string;
  category?: string;
  orderId?: string;
  orderTime?: string;
}

interface ChatProductCardProps {
  product: ChatProductContext;
  shape?: 'single' | 'firstReceived' | 'lastReceived';
  onViewProduct?: (productId: string) => void;
  onCheckLocation?: (locationName: string) => void;
  className?: string;
}

const shapeClasses = {
  single: 'rounded-[20px]',
  firstReceived: 'rounded-[20px] rounded-bl-[6px]',
  lastReceived: 'rounded-[20px] rounded-tl-[6px] rounded-bl-[4px]',
};

export const ChatProductCard: React.FC<ChatProductCardProps> = ({
  product,
  shape = 'firstReceived',
  onViewProduct,
  onCheckLocation,
  className = '',
}) => {
  const codLocation = product.location || 'Lab PPLG';

  const handleCheckLocationClick = (e: React.MouseEvent) => {
    e.stopPropagation();
    triggerHaptic('medium');
    if (onCheckLocation) {
      onCheckLocation(codLocation);
    }
  };

  return (
    <div
      onClick={() => onViewProduct?.(product.id)}
      className={cn(
        'relative mr-auto bg-white text-slate-900 border border-neutral-200/80 hover:border-blue-200/90 p-3 text-[14.5px] leading-[1.38] tracking-[-0.01em] break-words shadow-2xs transition-all select-none cursor-pointer',
        shapeClasses[shape],
        className
      )}
    >
      {/* 1. Top Product Summary Inset Box */}
      <div className="bg-[#f8f9fa] border border-neutral-100/80 rounded-xl p-2.5 flex items-start gap-2.5">
        <img
          src={product.image}
          alt={product.title}
          className="w-14 h-14 rounded-lg object-cover bg-neutral-100 shrink-0 ring-1 ring-black/5"
          loading="eager"
          onError={(e) => {
            (e.target as HTMLImageElement).src =
              'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=200&q=80';
          }}
        />
        <div className="min-w-0 flex-1 flex flex-col justify-between self-stretch">
          <h4 className="text-[13px] font-normal text-neutral-600 line-clamp-1 leading-snug">
            {product.title}
          </h4>
          <p className="text-[13px] text-slate-900 mt-0.5 leading-snug">
            <span className="text-neutral-500 font-normal">
              {product.itemCount ? `${product.itemCount} item, ` : ''}Total:{' '}
            </span>
            <span className="font-semibold text-slate-950">{product.price}</span>
          </p>
          <span
            className={`text-[12.5px] font-medium mt-0.5 ${
              product.statusColor || 'text-[#1d64ec]'
            }`}
          >
            {product.statusText || 'Tersedia'}
          </span>
        </div>
      </div>

      {/* 2. Thin Horizontal Divider Line */}
      <div className="border-t border-neutral-100 my-2.5" />

      {/* 3. Bottom Metadata & Full-Width Secondary Action Button */}
      <div className="px-0.5 space-y-2">
        {/* Row 1: Titik COD Label & Value */}
        <div className="flex items-center justify-between gap-2 text-[12.5px]">
          <span className="text-neutral-500 font-normal">Titik COD</span>
          <span className="text-slate-900 font-medium truncate">
            {codLocation}
          </span>
        </div>

        {/* Row 2: Full-Width Secondary Button "Cek Lokasi di Peta" (Label Only) */}
        <button
          type="button"
          onClick={handleCheckLocationClick}
          className="w-full h-8.5 px-3.5 rounded-xl bg-white hover:bg-neutral-50 active:bg-neutral-100 active:scale-[0.98] text-slate-800 hover:text-slate-950 font-medium text-[12px] border border-neutral-200/90 shadow-2xs flex items-center justify-center transition-all cursor-pointer select-none"
          title="Lihat denah lokasi di peta sekolah"
          aria-label={`Cek lokasi ${codLocation} di peta sekolah`}
        >
          <span>Cek Lokasi di Peta</span>
        </button>
      </div>
    </div>
  );
};
