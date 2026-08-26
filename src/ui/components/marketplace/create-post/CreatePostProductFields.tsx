import React from 'react';
import { MapPin, X } from 'lucide-react';

export interface CreatePostProductFieldsProps {
  productTitle: string;
  onProductTitleChange: (val: string) => void;
  priceInput: string;
  onPriceInputChange: (val: string) => void;
  productDescription: string;
  onProductDescriptionChange: (val: string) => void;
  locationInput: string;
  onLocationInputChange: (val: string) => void;
  onInputFocus?: (e: React.FocusEvent<HTMLInputElement | HTMLTextAreaElement>) => void;
}
const COD_PRESETS = [
  { name: 'Kantin', emoji: '🍜' },
  { name: 'Lab PPLG', emoji: '💻' },
  { name: 'Perpustakaan', emoji: '📚' },
  { name: 'Depan Gerbang', emoji: '🏫' },
  { name: 'Lapangan', emoji: '⚽' },
  { name: 'Gazebo DKV', emoji: '☕' },
];

export const CreatePostProductFields: React.FC<CreatePostProductFieldsProps> = ({
  productTitle,
  onProductTitleChange,
  priceInput,
  onPriceInputChange,
  productDescription,
  onProductDescriptionChange,
  locationInput,
  onLocationInputChange,
  onInputFocus,
}) => {
  return (
    <div
      className="mt-4 space-y-4 w-full pt-3 border-t border-neutral-100 transform-gpu animate-sheet-slide"
      style={{ willChange: 'transform' }}
    >
      {/* Field 1: Nama / Judul Barang */}
      <div className="space-y-1">
        <label className="block text-[12.5px] font-bold text-slate-800">
          Nama Barang / Jasa <span className="text-rose-500">*</span>
        </label>
        <input
          type="text"
          placeholder="Tulis nama barang atau jasa..."
          value={productTitle}
          onFocus={onInputFocus}
          onChange={(e) => onProductTitleChange(e.target.value)}
          className="w-full px-3.5 py-2.5 text-[14px] rounded-xl border border-neutral-300 focus:outline-none focus:border-[#1d64ec] focus:ring-4 focus:ring-blue-500/10 bg-white font-semibold text-slate-900 placeholder:font-normal placeholder:text-neutral-400 transition-all shadow-2xs"
        />
      </div>

      {/* Field 2: Harga (Rp) */}
      <div className="space-y-1">
        <label className="block text-[12.5px] font-bold text-slate-800">
          Harga (Rp) <span className="text-rose-500">*</span>
        </label>
        <div className="relative">
          {priceInput && (
            <span className="absolute left-3.5 top-2.5 text-[13.5px] font-bold text-slate-900 pointer-events-none select-none">
              Rp
            </span>
          )}
          <input
            type="text"
            inputMode="numeric"
            pattern="[0-9]*"
            placeholder="Masukkan nominal harga..."
            value={priceInput}
            onFocus={onInputFocus}
            onChange={(e) => {
              const raw = e.target.value.replace(/[^0-9]/g, '');
              if (!raw) {
                onPriceInputChange('');
                return;
              }
              const formatted = new Intl.NumberFormat('id-ID').format(Number(raw));
              onPriceInputChange(formatted);
            }}
            className={`w-full ${
              priceInput ? 'pl-10 font-bold text-slate-900' : 'pl-3.5 font-normal text-slate-900'
            } pr-3.5 py-2.5 text-[14px] rounded-xl border border-neutral-300 focus:outline-none focus:border-[#1d64ec] focus:ring-4 focus:ring-blue-500/10 bg-white placeholder:font-normal placeholder:text-neutral-400 transition-all shadow-2xs`}
          />
        </div>
      </div>

      {/* Field 3: Deskripsi Singkat / Rincian Barang */}
      <div className="space-y-1">
        <div className="flex items-center justify-between">
          <label className="block text-[12.5px] font-bold text-slate-800">
            Deskripsi Singkat
          </label>
          {250 - productDescription.length <= 30 && (
            <span
              className={`text-[11.5px] font-semibold transition-colors ${
                productDescription.length >= 250 ? 'text-rose-600 font-bold' : 'text-rose-500'
              }`}
            >
              {productDescription.length >= 250
                ? 'Batas maksimal tercapai'
                : `Sisa ${250 - productDescription.length} karakter`}
            </span>
          )}
        </div>
        <textarea
          rows={4}
          maxLength={250}
          placeholder="Tulis kondisi barang, kelengkapan, atau alasan jual..."
          value={productDescription}
          onFocus={onInputFocus}
          onChange={(e) => onProductDescriptionChange(e.target.value)}
          className={`w-full min-h-[96px] px-3.5 py-2.5 text-[14px] leading-relaxed rounded-xl border ${
            productDescription.length >= 250
              ? 'border-rose-400 focus:border-rose-500 focus:ring-rose-500/10'
              : 'border-neutral-300 focus:border-[#1d64ec] focus:ring-blue-500/10'
          } focus:outline-none focus:ring-4 bg-white text-slate-900 placeholder:text-neutral-400 transition-all shadow-2xs resize-none`}
        />
      </div>

      {/* Field 4: Titik COD di Sekolah (Direct Form Field + 1-Tap Chips) */}
      <div className="space-y-1.5 pt-0.5">
        <div className="flex items-center justify-between">
          <label className="block text-[12.5px] font-bold text-slate-800">
            Titik COD di Sekolah
          </label>
          {locationInput && (
            <button
              type="button"
              onClick={() => onLocationInputChange('')}
              className="text-[11.5px] font-medium text-neutral-400 hover:text-rose-500 transition-colors cursor-pointer"
            >
              Hapus
            </button>
          )}
        </div>

        <div className="relative">
          <MapPin className="absolute left-3.5 top-3 w-4 h-4 text-neutral-400 pointer-events-none" />
          <input
            type="text"
            placeholder="Ketik titik temu COD (Kantin, Lab, dll)..."
            value={locationInput}
            onFocus={onInputFocus}
            onChange={(e) => onLocationInputChange(e.target.value)}
            className="w-full pl-9.5 pr-8 py-2.5 text-[13.5px] rounded-xl border border-neutral-300 focus:outline-none focus:border-[#1d64ec] focus:ring-4 focus:ring-blue-500/10 bg-white text-slate-900 placeholder:text-neutral-400 transition-all shadow-2xs font-normal"
          />
          {locationInput && (
            <button
              type="button"
              onClick={() => onLocationInputChange('')}
              className="absolute right-2.5 top-2.5 w-5 h-5 rounded-full bg-neutral-200/80 hover:bg-neutral-300 text-neutral-600 flex items-center justify-center transition-colors cursor-pointer"
            >
              <X className="w-3 h-3 stroke-[2.5]" />
            </button>
          )}
        </div>

        {/* 1-Tap Preset Recommendations */}
        <div className="flex items-center gap-1.5 flex-wrap pt-0.5">
          {COD_PRESETS.map((loc) => {
            const isSelected = locationInput.toLowerCase() === loc.name.toLowerCase();
            return (
              <button
                key={loc.name}
                type="button"
                onClick={() => onLocationInputChange(isSelected ? '' : loc.name)}
                className={`flex items-center gap-1 px-2.5 py-1 rounded-lg text-[12px] font-semibold transition-all cursor-pointer select-none active:scale-95 border ${
                  isSelected
                    ? 'bg-blue-50 border-blue-400 text-[#1d64ec] shadow-2xs font-bold'
                    : 'bg-neutral-50 hover:bg-neutral-100/90 border-neutral-200 text-slate-700'
                }`}
              >
                <span>{loc.emoji}</span>
                <span>{loc.name}</span>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
};
