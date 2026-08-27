import React, { useState } from 'react';
import { Copy, Check } from 'lucide-react';
import { triggerHaptic } from '@/utils/haptics';

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
  onViewProduct?: (productId: string) => void;
  className?: string;
}

export const ChatProductCard: React.FC<ChatProductCardProps> = ({
  product,
  timestamp = '10:55',
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
    <div className={`w-full max-w-[340px] sm:max-w-[360px] mx-auto select-none ${className}`}>
      {/* Outer Card Container */}
      <div
        onClick={() => onViewProduct?.(product.id)}
        className="bg-white border border-neutral-200/90 rounded-[20px] p-3 shadow-2xs transition-all hover:border-neutral-300"
      >
        {/* Top Product Summary Inset Box */}
        <div className="bg-[#f8f9fa] rounded-xl p-2.5 flex items-start gap-2.5">
          <img
            src={product.image}
            alt={product.title}
            className="w-14 h-14 rounded-lg object-cover bg-neutral-200 shrink-0 ring-1 ring-black/5"
            loading="eager"
            onError={(e) => {
              // Fallback image if network fails
              (e.target as HTMLImageElement).src =
                'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=200&q=80';
            }}
          />
          <div className="min-w-0 flex-1 flex flex-col justify-between self-stretch">
            <h4 className="text-[13px] font-medium text-slate-900 line-clamp-1 leading-snug">
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

        {/* Bottom Order Metadata Box */}
        {(product.orderId || product.orderTime) && (
          <div className="mt-2.5 px-1 space-y-1.5 text-[12px] text-neutral-500">
            {product.orderId && (
              <div className="flex items-center justify-between gap-2">
                <span className="shrink-0">No. Pesanan</span>
                <div className="flex items-center gap-1.5 font-mono text-slate-800 font-medium min-w-0">
                  <span className="truncate">{product.orderId}</span>
                  <button
                    type="button"
                    onClick={handleCopyOrderId}
                    aria-label={copied ? 'Tersalin' : 'Salin No. Pesanan'}
                    className="p-1 -mr-1 hover:bg-neutral-100 rounded transition-colors text-[#1d64ec] hover:text-blue-700 cursor-pointer flex items-center gap-1"
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
                <span className="shrink-0">Waktu Pesanan</span>
                <span className="text-slate-700 font-normal">
                  {product.orderTime}
                </span>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Message Timestamp underneath the card on the right */}
      {timestamp && (
        <p className="text-[11px] text-neutral-400 text-right mt-1 mr-1">
          {timestamp}
        </p>
      )}
    </div>
  );
};
