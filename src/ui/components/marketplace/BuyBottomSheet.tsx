import React, { useState } from 'react';
import { X, Plus, Minus, MapPin, Send, MessageCircle } from 'lucide-react';
import { MarketPostItem } from '@/types/marketFeed';

interface BuyBottomSheetProps {
  isOpen: boolean;
  post: MarketPostItem;
  onClose: () => void;
}

const COD_LOCATIONS = [
  'Kantin Depan SMKN 8',
  'Gedung PPLG (Lab 3)',
  'Parkiran Belakang',
  'Lapangan Utama',
  'Lobi Depan Sekolah',
];

export const BuyBottomSheet: React.FC<BuyBottomSheetProps> = ({
  isOpen,
  post,
  onClose,
}) => {
  const [quantity, setQuantity] = useState(1);
  const [selectedLocation, setSelectedLocation] = useState(COD_LOCATIONS[0]);
  const [note, setNote] = useState('');

  if (!isOpen) return null;

  const maxStock = post.stock || 5;
  const totalPrice = post.price * quantity;

  const formatRupiah = (val: number) =>
    new Intl.NumberFormat('id-ID', {
      style: 'currency',
      currency: 'IDR',
      maximumFractionDigits: 0,
    }).format(val);

  const handleDecrease = () => {
    if (quantity > 1) setQuantity((prev) => prev - 1);
  };

  const handleIncrease = () => {
    if (quantity < maxStock) setQuantity((prev) => prev + 1);
  };

  const handleWhatsAppCheckout = () => {
    const sellerName = post.seller.name;
    const itemTitle = post.caption.slice(0, 50);
    
    const message = `Halo ${sellerName}, saya mau beli *${itemTitle}* di Snapan Market:\n\n` +
      `📦 *Jumlah*: ${quantity} Pcs\n` +
      `💰 *Total*: ${formatRupiah(totalPrice)}\n` +
      `📍 *Lokasi COD*: ${selectedLocation}\n` +
      (note.trim() ? `📝 *Catatan*: ${note.trim()}\n\n` : '\n') +
      `Kira-kira bisa COD jam berapa ya kak? Terima kasih!`;

    // Dummy WA number fallback (can be dynamically pulled from seller profile)
    const waNumber = '6281234567890';
    const waUrl = `https://wa.me/${waNumber}?text=${encodeURIComponent(message)}`;
    
    window.open(waUrl, '_blank');
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/60 backdrop-blur-xs animate-in fade-in duration-200 font-gt-standard">
      {/* Overlay Backdrop Click */}
      <div className="absolute inset-0" onClick={onClose} />

      {/* Bottom Sheet Drawer */}
      <div className="relative w-full max-w-xl bg-white rounded-t-3xl p-5 z-10 shadow-2xl animate-in slide-in-from-bottom duration-300 space-y-4.5">
        {/* Handle Bar Indicator */}
        <div className="w-12 h-1 bg-neutral-300 rounded-full mx-auto -mt-1 mb-1" />

        {/* Sheet Header */}
        <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
          <div className="flex items-center gap-2">
            <div className="w-7 h-7 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center border border-emerald-200">
              <MessageCircle className="w-4 h-4 stroke-[2.2]" />
            </div>
            <h2 className="font-bold text-base text-slate-900">Detail Pembelian COD</h2>
          </div>
          <button
            type="button"
            onClick={onClose}
            className="w-8 h-8 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-500 transition-colors"
          >
            <X className="w-5 h-5 stroke-[2.2]" />
          </button>
        </div>

        {/* Product Card Info */}
        <div className="flex gap-3 bg-neutral-50 p-3 rounded-2xl border border-neutral-200/70">
          <img
            src={post.images[0]}
            alt={post.caption}
            className="w-16 h-16 rounded-xl object-cover border border-neutral-200 shrink-0"
          />
          <div className="flex-1 min-w-0 space-y-1">
            <span className="text-[11px] font-medium text-neutral-500 block truncate">
              Penjual: <strong className="text-slate-900">{post.seller.name}</strong> ({post.seller.classGroup})
            </span>
            <h3 className="font-semibold text-sm text-slate-900 truncate leading-snug">
              {post.caption}
            </h3>
            <div className="flex items-center justify-between pt-0.5">
              <span className="font-bold text-sm text-[#1d64ec]">
                {formatRupiah(post.price)}
              </span>
              <span className="text-[11px] font-medium px-2 py-0.5 rounded-md bg-emerald-100 text-emerald-700">
                Stok: {maxStock}
              </span>
            </div>
          </div>
        </div>

        {/* Quantity Stepper */}
        <div className="flex items-center justify-between py-1 border-b border-neutral-100">
          <div>
            <span className="font-semibold text-sm text-slate-900 block">Jumlah Pesanan</span>
            <span className="text-xs text-neutral-400">Maksimal {maxStock} item</span>
          </div>

          <div className="flex items-center gap-3 bg-neutral-100 p-1 rounded-xl border border-neutral-200/80">
            <button
              type="button"
              onClick={handleDecrease}
              disabled={quantity <= 1}
              className="w-8 h-8 rounded-lg bg-white shadow-2xs flex items-center justify-center text-slate-700 disabled:opacity-40 disabled:cursor-not-allowed active:scale-95 transition-all"
            >
              <Minus className="w-4 h-4 stroke-[2.5]" />
            </button>
            <span className="font-bold text-sm text-slate-900 min-w-[20px] text-center">
              {quantity}
            </span>
            <button
              type="button"
              onClick={handleIncrease}
              disabled={quantity >= maxStock}
              className="w-8 h-8 rounded-lg bg-white shadow-2xs flex items-center justify-center text-slate-700 disabled:opacity-40 disabled:cursor-not-allowed active:scale-95 transition-all"
            >
              <Plus className="w-4 h-4 stroke-[2.5]" />
            </button>
          </div>
        </div>

        {/* COD Location Selector */}
        <div className="space-y-1.5">
          <label className="font-semibold text-sm text-slate-900 flex items-center gap-1.5">
            <MapPin className="w-4 h-4 text-emerald-600 stroke-[2.2]" />
            <span>Pilih Lokasi COD Sekolah:</span>
          </label>
          <select
            value={selectedLocation}
            onChange={(e) => setSelectedLocation(e.target.value)}
            className="w-full bg-neutral-100 border border-neutral-200 rounded-xl px-3.5 py-2.5 text-sm text-slate-900 font-medium focus:outline-none focus:border-[#1d64ec] transition-all cursor-pointer"
          >
            {COD_LOCATIONS.map((loc) => (
              <option key={loc} value={loc}>
                📍 {loc}
              </option>
            ))}
          </select>
        </div>

        {/* Note Input */}
        <div className="space-y-1">
          <label className="font-semibold text-xs text-neutral-500">
            Catatan untuk Penjual (Opsional):
          </label>
          <input
            type="text"
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder="misal: Pedes ya kak / Ukuran L / COD jam istirahat"
            className="w-full bg-neutral-100 border border-neutral-200 rounded-xl px-3.5 py-2 text-xs text-slate-900 placeholder:text-slate-400 focus:outline-none focus:border-[#1d64ec] transition-all"
          />
        </div>

        {/* Total & Checkout Button */}
        <div className="pt-2 space-y-2">
          <div className="flex items-center justify-between text-slate-900 px-1">
            <span className="text-xs font-normal text-neutral-500">Total Pembayaran ({quantity} item)</span>
            <span className="font-bold text-lg text-slate-900">{formatRupiah(totalPrice)}</span>
          </div>

          {/* Kumo UI WhatsApp Direct Button */}
          <button
            type="button"
            onClick={handleWhatsAppCheckout}
            className="relative inline-flex items-center justify-center gap-2 w-full h-12.5 rounded-2xl text-white bg-emerald-600 hover:bg-emerald-700 active:scale-[0.98] font-bold text-sm shadow-lg transition-all cursor-pointer overflow-hidden select-none group"
          >
            <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-emerald-500 to-emerald-700 shadow-[inset_0_1px_0_0_rgba(255,255,255,0.35)] pointer-events-none" />
            <span className="relative z-10 flex items-center justify-center gap-2">
              <Send className="w-4 h-4 stroke-[2.2]" />
              <span>Pesan via WhatsApp Penjual</span>
            </span>
          </button>
        </div>
      </div>
    </div>
  );
};
