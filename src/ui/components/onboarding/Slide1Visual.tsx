import React from 'react';
import { Shirt, Utensils, Palette, PlusCircle, Sparkles, Store } from 'lucide-react';

export const Slide1Visual: React.FC = () => {
  return (
    <div className="relative w-full aspect-[4/5] rounded-[32px] bg-gradient-to-b from-blue-50/80 via-purple-50/40 to-slate-50 border border-neutral-200/80 p-5 flex flex-col justify-between overflow-hidden shadow-lg select-none">
      {/* Background Decorative Glow Bubbles */}
      <div className="absolute -top-12 -right-12 w-40 h-40 bg-blue-500/10 rounded-full blur-2xl pointer-events-none" />
      <div className="absolute -bottom-10 -left-10 w-36 h-36 bg-indigo-500/10 rounded-full blur-2xl pointer-events-none" />

      {/* Top Header Badge */}
      <div className="flex items-center justify-between z-10">
        <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white/90 backdrop-blur-md border border-neutral-200/80 shadow-2xs">
          <Store className="w-3.5 h-3.5 text-[#1d64ec]" />
          <span className="text-[11px] font-extrabold text-slate-900 tracking-tight">
            SMKN 8 Semarang
          </span>
          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
        </div>
        <div className="flex items-center gap-1 px-2.5 py-1 rounded-full bg-blue-600/10 text-[#1d64ec] font-bold text-[10px]">
          <Sparkles className="w-3 h-3" />
          <span>Marketplace</span>
        </div>
      </div>

      {/* Stacked Showcase Cards Grid (Preloved, Kantin, Karya Siswa) */}
      <div className="relative flex-1 my-3 flex flex-col justify-center gap-2.5 z-10">
        {/* Card 1: Barang Preloved */}
        <div className="flex items-center justify-between p-3 rounded-2xl bg-white/95 backdrop-blur-sm border border-neutral-200/90 shadow-md shadow-slate-900/5 transform transition-all hover:scale-[1.02] duration-200">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-purple-100/80 border border-purple-200/60 flex items-center justify-center text-purple-600 shrink-0">
              <Shirt className="w-5 h-5" />
            </div>
            <div>
              <p className="text-xs font-extrabold text-slate-900 leading-snug">
                Hoodie Oversize Vintage
              </p>
              <p className="text-[10px] text-slate-500 font-medium">Preloved • Size L</p>
            </div>
          </div>
          <div className="text-right shrink-0">
            <span className="text-xs font-black text-[#1d64ec] block">Rp 35.000</span>
            <span className="inline-block px-1.5 py-0.5 rounded-md bg-purple-50 text-purple-700 border border-purple-200/60 text-[9px] font-extrabold">
              Preloved
            </span>
          </div>
        </div>

        {/* Card 2: Jajanan Kantin */}
        <div className="flex items-center justify-between p-3 rounded-2xl bg-white/95 backdrop-blur-sm border border-neutral-200/90 shadow-md shadow-slate-900/5 transform transition-all hover:scale-[1.02] duration-200 ml-2">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-emerald-100/80 border border-emerald-200/60 flex items-center justify-center text-emerald-600 shrink-0">
              <Utensils className="w-5 h-5" />
            </div>
            <div>
              <p className="text-xs font-extrabold text-slate-900 leading-snug">
                Risol Mayo Melty
              </p>
              <p className="text-[10px] text-slate-500 font-medium">Kantin Bu Sri</p>
            </div>
          </div>
          <div className="text-right shrink-0">
            <span className="text-xs font-black text-emerald-600 block">Rp 5.000</span>
            <span className="inline-block px-1.5 py-0.5 rounded-md bg-emerald-50 text-emerald-700 border border-emerald-200/60 text-[9px] font-extrabold">
              Kuliner
            </span>
          </div>
        </div>

        {/* Card 3: Karya Siswa */}
        <div className="flex items-center justify-between p-3 rounded-2xl bg-white/95 backdrop-blur-sm border border-neutral-200/90 shadow-md shadow-slate-900/5 transform transition-all hover:scale-[1.02] duration-200 mr-1">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-amber-100/80 border border-amber-200/60 flex items-center justify-center text-amber-600 shrink-0">
              <Palette className="w-5 h-5" />
            </div>
            <div>
              <p className="text-xs font-extrabold text-slate-900 leading-snug">
                Sticker Pack & Keychain DKV
              </p>
              <p className="text-[10px] text-slate-500 font-medium">Handicraft Siswa</p>
            </div>
          </div>
          <div className="text-right shrink-0">
            <span className="text-xs font-black text-amber-600 block">Rp 12.000</span>
            <span className="inline-block px-1.5 py-0.5 rounded-md bg-amber-50 text-amber-700 border border-amber-200/60 text-[9px] font-extrabold">
              Handmade
            </span>
          </div>
        </div>
      </div>

      {/* Floating Action Badge */}
      <div className="z-10 flex items-center justify-center">
        <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[#1d64ec] text-white shadow-lg shadow-blue-500/25 border border-blue-400/30 font-extrabold text-xs">
          <PlusCircle className="w-4 h-4" />
          <span>Buka Lapak Jualanmu Sekarang</span>
        </div>
      </div>
    </div>
  );
};
