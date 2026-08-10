import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { MessageSquarePlus, ShoppingBag, X } from 'lucide-react';

interface CreateOptionBottomSheetProps {
  isOpen: boolean;
  onClose: () => void;
  onSelectOption: (mode: 'thread' | 'product') => void;
}

export const CreateOptionBottomSheet: React.FC<CreateOptionBottomSheetProps> = ({
  isOpen,
  onClose,
  onSelectOption,
}) => {
  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/60 backdrop-blur-xs transition-opacity duration-200">
        {/* Backdrop overlay click to close */}
        <div
          className="absolute inset-0 cursor-pointer"
          onClick={onClose}
        />

        {/* Half-Screen Bottom Sheet Container */}
        <motion.div
          initial={{ y: '100%' }}
          animate={{ y: 0 }}
          exit={{ y: '100%' }}
          transition={{ type: 'spring', stiffness: 350, damping: 32 }}
          className="relative z-10 w-full max-w-lg bg-white rounded-t-3xl shadow-2xl p-5 pb-8 font-gt-standard border-t border-neutral-200/80 flex flex-col space-y-4"
        >
          {/* Top Handle Drag Indicator */}
          <div className="w-12 h-1 bg-neutral-300 rounded-full mx-auto mb-1 shrink-0" />

          {/* Header Bar: Title + Close Button */}
          <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
            <div>
              <h3 className="text-[17px] font-bold text-slate-900">
                Buat Postingan Baru
              </h3>
              <p className="text-[12.5px] text-neutral-500 font-normal">
                Pilih jenis konten yang ingin kamu bagikan
              </p>
            </div>

            <button
              type="button"
              onClick={onClose}
              className="w-8 h-8 rounded-full bg-neutral-100 hover:bg-neutral-200 text-slate-700 flex items-center justify-center transition-colors cursor-pointer"
            >
              <X className="w-4 h-4 stroke-[2.2]" />
            </button>
          </div>

          {/* 2 Big Action Cards (Utas Biasa vs Jual Produk) */}
          <div className="space-y-2.5 pt-1">
            {/* Option 1: Utas Biasa */}
            <button
              type="button"
              onClick={() => onSelectOption('thread')}
              className="w-full p-4 rounded-2xl border border-neutral-200 hover:border-slate-400 bg-neutral-50/80 hover:bg-neutral-100/80 transition-all flex items-start gap-3.5 group cursor-pointer active:scale-[0.98] text-left"
            >
              <div className="w-10 h-10 rounded-2xl bg-white border border-neutral-200 text-slate-900 flex items-center justify-center shrink-0 shadow-2xs group-hover:scale-105 transition-transform">
                <MessageSquarePlus className="w-5 h-5 stroke-[2] text-slate-800" />
              </div>

              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between">
                  <span className="font-bold text-[15px] text-slate-900 group-hover:text-[#1d64ec] transition-colors">
                    💬 Utas / Status Biasa
                  </span>
                  <span className="text-[11px] font-bold px-2 py-0.5 rounded-md bg-neutral-200/80 text-neutral-600">
                    Sosial
                  </span>
                </div>
                <p className="text-[12.5px] text-neutral-500 leading-snug mt-0.5">
                  Bagikan ide, cerita, foto random, atau diskusi seputar sekolah tanpa memasang harga.
                </p>
              </div>
            </button>

            {/* Option 2: Jual Produk / Jasa */}
            <button
              type="button"
              onClick={() => onSelectOption('product')}
              className="w-full p-4 rounded-2xl border border-blue-200 hover:border-blue-500 bg-blue-50/40 hover:bg-blue-50/90 transition-all flex items-start gap-3.5 group cursor-pointer active:scale-[0.98] text-left"
            >
              <div className="w-10 h-10 rounded-2xl bg-[#1d64ec] text-white flex items-center justify-center shrink-0 shadow-md shadow-blue-500/20 group-hover:scale-105 transition-transform">
                <ShoppingBag className="w-5 h-5 stroke-[2]" />
              </div>

              <div className="flex-1 min-w-0">
                <div className="flex items-center justify-between">
                  <span className="font-bold text-[15px] text-slate-900 group-hover:text-[#1d64ec] transition-colors">
                    🛍️ Jual Barang / Jasa
                  </span>
                  <span className="text-[11px] font-bold px-2 py-0.5 rounded-md bg-blue-100 text-[#1d64ec]">
                    Marketplace
                  </span>
                </div>
                <p className="text-[12.5px] text-neutral-500 leading-snug mt-0.5">
                  Jual barang bekas/preloved, makanan kantin, atau buka jasa DKV/PPLG dengan tombol order WhatsApp & harga Rp.
                </p>
              </div>
            </button>
          </div>
        </motion.div>
      </div>
    </AnimatePresence>
  );
};
