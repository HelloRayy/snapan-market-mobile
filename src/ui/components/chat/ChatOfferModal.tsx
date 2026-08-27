import React, { useState } from 'react';
import { Tag, X, Check } from 'lucide-react';
import { formatRupiah } from '@/utils/formatters';
import { triggerHaptic } from '@/utils/haptics';

interface ChatOfferModalProps {
  isOpen: boolean;
  onClose: () => void;
  originalPrice: number;
  productTitle: string;
  onSubmitOffer: (amount: number) => void;
}

export const ChatOfferModal: React.FC<ChatOfferModalProps> = ({
  isOpen,
  onClose,
  originalPrice,
  productTitle,
  onSubmitOffer,
}) => {
  const [offerAmount, setOfferAmount] = useState<number>(() =>
    Math.max(10000, Math.floor(originalPrice * 0.9))
  );

  if (!isOpen) return null;

  const handlePercentageClick = (percent: number) => {
    triggerHaptic('selection');
    setOfferAmount(Math.floor(originalPrice * (percent / 100)));
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (offerAmount <= 0) return;
    triggerHaptic('success');
    onSubmitOffer(offerAmount);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center p-0 sm:p-4 bg-black/60 backdrop-blur-xs animate-in fade-in duration-200">
      <div
        className="w-full max-w-md bg-white rounded-t-[28px] sm:rounded-3xl p-5 shadow-2xl border border-neutral-200 animate-in slide-in-from-bottom-4 duration-200"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between pb-3 border-b border-neutral-100">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-xl bg-amber-100 text-amber-700 flex items-center justify-center">
              <Tag className="w-4 h-4" />
            </div>
            <div>
              <h3 className="font-bold text-[15px] text-slate-900 leading-tight">
                Ajukan Tawaran Harga
              </h3>
              <p className="text-[11.5px] text-neutral-500 truncate max-w-[240px]">
                {productTitle}
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={onClose}
            className="w-8 h-8 rounded-full hover:bg-neutral-100 flex items-center justify-center text-neutral-400 hover:text-slate-700 transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Form Body */}
        <form onSubmit={handleSubmit} className="pt-4 space-y-4">
          <div>
            <label className="block text-[12px] font-bold text-neutral-600 mb-1.5">
              Harga Asli Penjual
            </label>
            <div className="text-[14px] font-bold text-neutral-400 line-through">
              {formatRupiah(originalPrice)}
            </div>
          </div>

          <div>
            <label className="block text-[12px] font-bold text-slate-900 mb-1.5">
              Nominal Tawaran Anda (Rp)
            </label>
            <input
              type="number"
              value={offerAmount}
              onChange={(e) => setOfferAmount(Number(e.target.value))}
              min={1000}
              max={originalPrice}
              step={1000}
              className="w-full px-4 py-3 rounded-2xl bg-neutral-50 border border-neutral-300 text-[18px] font-black text-slate-900 focus:outline-none focus:border-[#1d64ec] focus:ring-2 focus:ring-blue-100"
            />
          </div>

          {/* Quick Percentage Chips */}
          <div className="flex items-center gap-2">
            {[90, 85, 80, 75].map((pct) => (
              <button
                key={pct}
                type="button"
                onClick={() => handlePercentageClick(pct)}
                className="flex-1 py-1.5 rounded-xl border border-neutral-200 bg-neutral-50 text-[12px] font-bold text-slate-700 hover:bg-neutral-100 active:scale-95 transition-all"
              >
                Diskon {100 - pct}%
              </button>
            ))}
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            className="w-full py-3.5 rounded-2xl bg-[#1d64ec] hover:bg-[#154ec1] active:scale-[0.98] text-white font-bold text-[14.5px] shadow-md shadow-blue-500/25 flex items-center justify-center gap-2 transition-all cursor-pointer"
          >
            <Check className="w-4 h-4 stroke-[2.5]" />
            <span>Kirim Tawaran ({formatRupiah(offerAmount)})</span>
          </button>
        </form>
      </div>
    </div>
  );
};
