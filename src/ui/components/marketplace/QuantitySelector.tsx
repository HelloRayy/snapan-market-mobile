import React from 'react';
import { Plus, Minus } from 'lucide-react';

interface QuantitySelectorProps {
  quantity: number;
  onDecrease: () => void;
  onIncrease: () => void;
  max?: number;
}

export const QuantitySelector: React.FC<QuantitySelectorProps> = ({
  quantity,
  onDecrease,
  onIncrease,
  max
}) => {
  return (
    <div className="inline-flex items-center rounded-xl border border-slate-800 bg-slate-950 p-1">
      <button
        onClick={onDecrease}
        className="flex h-7 w-7 items-center justify-center rounded-lg text-slate-300 hover:bg-slate-800 hover:text-white transition-colors active:scale-95 disabled:opacity-40"
        aria-label="Kurangi kuantitas"
      >
        <Minus className="h-3.5 w-3.5" />
      </button>

      <span className="w-8 text-center text-xs font-semibold text-slate-100">
        {quantity}
      </span>

      <button
        onClick={onIncrease}
        disabled={max !== undefined && quantity >= max}
        className="flex h-7 w-7 items-center justify-center rounded-lg text-slate-300 hover:bg-slate-800 hover:text-white transition-colors active:scale-95 disabled:opacity-40"
        aria-label="Tambah kuantitas"
      >
        <Plus className="h-3.5 w-3.5" />
      </button>
    </div>
  );
};
