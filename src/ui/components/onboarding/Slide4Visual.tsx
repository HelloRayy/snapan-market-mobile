import React from 'react';
import { ShoppingBag, Sparkles, Store, CheckCircle2 } from 'lucide-react';

export const Slide4Visual: React.FC = () => {
  return (
    <div className="relative w-full aspect-[4/3] rounded-3xl bg-gradient-to-br from-[#eff6ff] via-[#f0f9ff] to-[#e0f2fe] border border-blue-100 p-6 flex flex-col justify-between overflow-hidden shadow-sm font-gt-standard select-none">
      {/* Decorative Floating Sparkles Background */}
      <div className="absolute top-4 right-4 h-24 w-24 rounded-full bg-blue-400/10 blur-2xl pointer-events-none" />
      <div className="absolute bottom-2 left-4 h-28 w-28 rounded-full bg-emerald-400/10 blur-2xl pointer-events-none" />

      {/* Top Badge */}
      <div className="relative z-10 flex items-center justify-between">
        <div className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white/80 backdrop-blur-md border border-blue-200/60 shadow-2xs">
          <Sparkles className="h-3.5 w-3.5 text-blue-600 animate-pulse" />
          <span className="text-xs font-bold text-slate-800">Ready to Launch</span>
        </div>
        <div className="h-7 w-7 rounded-full bg-emerald-100 border border-emerald-200 flex items-center justify-center">
          <CheckCircle2 className="h-4 w-4 text-emerald-700" />
        </div>
      </div>

      {/* Center Hero Icon Illustration */}
      <div className="relative z-10 my-auto flex flex-col items-center justify-center space-y-3 text-center">
        <div className="relative flex h-20 w-20 items-center justify-center rounded-3xl bg-white shadow-xl shadow-blue-500/10 border border-blue-100/80 group">
          <div className="absolute -inset-1 rounded-[28px] bg-gradient-to-tr from-blue-500 to-emerald-400 opacity-20 blur-sm" />
          <ShoppingBag className="relative h-10 w-10 text-[#1d64ec]" />
        </div>

        <div className="space-y-1">
          <div className="inline-flex items-center gap-1.5 text-xs font-bold text-emerald-800 bg-emerald-50 px-2.5 py-0.5 rounded-full border border-emerald-200/50">
            <Store className="h-3 w-3" />
            <span>SMKN 8 Community Marketplace</span>
          </div>
        </div>
      </div>

      {/* Bottom Floating Stats Mini Card */}
      <div className="relative z-10 flex items-center justify-between bg-white/90 backdrop-blur-md rounded-2xl p-3 border border-blue-100 shadow-2xs">
        <div className="flex items-center gap-2.5">
          <div className="flex -space-x-2 overflow-hidden">
            <div className="inline-block h-6 w-6 rounded-full ring-2 ring-white bg-blue-500 text-white text-[10px] font-bold flex items-center justify-center">R</div>
            <div className="inline-block h-6 w-6 rounded-full ring-2 ring-white bg-emerald-500 text-white text-[10px] font-bold flex items-center justify-center">T</div>
            <div className="inline-block h-6 w-6 rounded-full ring-2 ring-white bg-purple-500 text-white text-[10px] font-bold flex items-center justify-center">D</div>
          </div>
          <span className="text-xs font-bold text-slate-800">500+ Warga & Produk</span>
        </div>
        <span className="text-[10px] font-bold text-blue-600 bg-blue-50 px-2 py-0.5 rounded-md">Aktif</span>
      </div>
    </div>
  );
};
