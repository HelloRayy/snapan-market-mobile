import React, { useState } from 'react';
import { Copy, Check } from 'lucide-react';
import { triggerHaptic } from '@/utils/haptics';
import { cn } from '@/utils/cn';

export interface ChatProductContext {
  id: string;
  title: string;
  price: string;
  image: string;
  itemCount?: number;
  statusText: string;
  statusColor?: string;
  orderId?: string;
  orderTime?: string;
}

interface ChatProductCardProps {
  product: ChatProductContext;
  timestamp?: string;
  shape?: 'single' | 'firstReceived' | 'lastReceived';
  onViewProduct?: (productId: string) => void;
  className?: string;
}

const shapeClasses = {
  single: 'rounded-[20px]',
  firstReceived: 'rounded-[20px] rounded-bl-[6px]',
  lastReceived: 'rounded-[20px] rounded-tl-[6px] rounded-bl-[4px]',
};

export const ChatProductCard: React.FC<ChatProductCardProps> = ({
  product,
  timestamp = '10:55',
  shape = 'firstReceived',
  onViewProduct,
  className = '',
}) => {
  const [copied, setCopied] = useState(false);

  const handleCopyOrderId = (e: React.MouseEvent) => {
    e.stopPropagation();
    triggerHaptic('light');

    if (!product.orderId) return;

    try {
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(product.orderId);
      } else {
        const textarea = document.createElement('textarea');
        textarea.value = product.orderId;
        textarea.style.position = 'fixed';
        textarea.style.opacity = '0';
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
      }
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      // Fallback
    }
  };

  return (
    <div
      onClick={() => onViewProduct?.(product.id)}
      className={cn(
        'relative mr-auto bg-[#f1f3f5] text-slate-900 p-3 text-[14.5px] leading-[1.38] tracking-[-0.01em] break-words shadow-2xs transition-all select-none cursor-pointer',
        shapeClasses[shape],
        className
      )}
    >
      {/* Inset Product Media & Summary Box */}
      <div className="bg-white/95 border border-neutral-200/80 rounded-xl p-2.5 flex items-start gap-2.5 shadow-2xs">
        <img
          src={product.image}
          alt={product.title}
          className="w-13 h-13 sm:w-14 sm:h-14 rounded-lg object-cover bg-neutral-100 shrink-0 ring-1 ring-black/5"
          loading="eager"
          onError={(e) => {
            (e.target as HTMLImageElement).src =
              'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=200&q=80';
          }}
        />
        <div className="min-w-0 flex-1 flex flex-col justify-between self-stretch">
          <h4 className="text-[13.5px] font-medium text-slate-900 line-clamp-1 leading-snug">
            {product.title}
          </h4>
          <p className="text-[12px] text-neutral-600 font-normal mt-0.5">
            {product.itemCount ? `${product.itemCount} item, ` : ''}Total: {product.price}
          </p>
          <span
            className={`text-[12px] font-semibold mt-0.5 ${
              product.statusColor || 'text-[#ff5722]'
            }`}
          >
            {product.statusText}
          </span>
        </div>
      </div>

      {/* Bottom Order / Transaction Metadata */}
      {(product.orderId || product.orderTime) && (
        <div className="mt-2.5 px-0.5 space-y-1.5 text-[12px] text-neutral-600">
          {product.orderId && (
            <div className="flex items-center justify-between gap-2">
              <span className="text-neutral-500 shrink-0">No. Pesanan</span>
              <div className="flex items-center gap-1.5 font-mono text-slate-900 font-medium min-w-0">
                <span className="truncate">{product.orderId}</span>
                <button
                  type="button"
                  onClick={handleCopyOrderId}
                  aria-label={copied ? 'Tersalin' : 'Salin No. Pesanan'}
                  className="p-1 -mr-1 hover:bg-neutral-200/70 rounded transition-colors text-[#1d64ec] hover:text-blue-700 cursor-pointer flex items-center gap-1"
                  title="Salin No. Pesanan"
                >
                  {copied ? (
                    <>
                      <Check className="w-3.5 h-3.5 text-emerald-600 stroke-[2.5]" />
                      <span className="text-[10.5px] font-sans text-emerald-600 font-medium">
                        Tersalin
                      </span>
                    </>
                  ) : (
                    <Copy className="w-3.5 h-3.5 text-[#1d64ec] stroke-[2.2]" />
                  )}
                </button>
              </div>
            </div>
          )}

          {product.orderTime && (
            <div className="flex items-center justify-between gap-2">
              <span className="text-neutral-500 shrink-0">Waktu Pesanan</span>
              <span className="text-slate-800 font-normal">
                {product.orderTime}
              </span>
            </div>
          )}
        </div>
      )}

      {/* Timestamp inside bottom-right of bubble */}
      {timestamp && (
        <div className="flex items-center justify-end mt-1 select-none">
          <span className="text-[11px] text-neutral-600 font-medium">
            {timestamp}
          </span>
        </div>
      )}
    </div>
  );
};
