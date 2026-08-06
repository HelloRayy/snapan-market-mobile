import React from 'react';
import { Smartphone, Plus, Bell, Star, Tag, CheckCircle2 } from 'lucide-react';

export const Slide2Visual: React.FC = () => {
  return (
    <div className="relative w-full aspect-[4/5] rounded-[32px] bg-gradient-to-b from-blue-50/80 via-sky-50/40 to-slate-50 border border-neutral-200/80 p-5 flex flex-col justify-between overflow-hidden shadow-lg select-none">
      {/* Background Glow */}
      <div className="absolute -top-10 -left-10 w-40 h-40 bg-blue-500/10 rounded-full blur-2xl pointer-events-none" />
      <div className="absolute -bottom-10 -right-10 w-36 h-36 bg-[#1d64ec]/10 rounded-full blur-2xl pointer-events-none" />

      {/* Top Status Pill */}
      <div className="flex items-center justify-between z-10">
        <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white/90 backdrop-blur-md border border-neutral-200/80 shadow-2xs">
          <Smartphone className="w-3.5 h-3.5 text-[#1d64ec]" />
          <span className="text-[11px] font-extrabold text-slate-900 tracking-tight">
            Lapak Siswa Active
          </span>
          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
        </div>
        <div className="flex items-center gap-1 px-2.5 py-1 rounded-full bg-amber-500/10 text-amber-700 font-bold text-[10px] border border-amber-300/40">
          <Star className="w-3 h-3 fill-amber-400 text-amber-400" />
          <span>4.9 Seller Rate</span>
        </div>
      </div>

      {/* Center 3D Smartphone & Floating Elements Showcase */}
      <div className="relative flex-1 my-3 flex items-center justify-center z-10">
        {/* Floating Notification Badge 1 (Top Left) */}
        <div className="absolute top-2 -left-1 z-20 flex items-center gap-2 px-3 py-2 rounded-2xl bg-white/95 backdrop-blur-sm border border-neutral-200/90 shadow-md animate-bounce duration-1000">
          <div className="w-7 h-7 rounded-xl bg-blue-100 flex items-center justify-center text-[#1d64ec]">
            <Bell className="w-3.5 h-3.5" />
          </div>
          <div>
            <p className="text-[10px] font-extrabold text-slate-900 leading-none">Pesanan Baru!</p>
            <p className="text-[9px] text-slate-500 font-medium">1x Risol Mayo & Teh</p>
          </div>
        </div>

        {/* 3D Angled Smartphone Frame Representation */}
        <div className="w-44 h-56 rounded-[28px] bg-gradient-to-tr from-slate-900 via-slate-800 to-slate-900 border-4 border-slate-700 p-2 shadow-xl transform rotate-[-6deg] hover:rotate-0 transition-transform duration-300 flex flex-col justify-between">
          {/* Phone Screen Mockup */}
          <div className="w-full h-full rounded-[20px] bg-white p-2.5 flex flex-col justify-between">
            {/* Top App Header */}
            <div className="flex items-center justify-between pb-1 border-b border-neutral-100">
              <span className="text-[9px] font-black text-slate-900">Kelola Produk</span>
              <span className="text-[8px] font-bold text-[#1d64ec]">SMKN 8</span>
            </div>

            {/* Product Card Inside Phone Screen */}
            <div className="p-2 rounded-xl bg-blue-50/60 border border-blue-100 my-auto space-y-1">
              <div className="flex items-center justify-between">
                <span className="text-[9px] font-extrabold text-slate-900">Hoodie Preloved</span>
                <CheckCircle2 className="w-3 h-3 text-emerald-500" />
              </div>
              <p className="text-[8px] text-slate-500 font-medium">Stok: 1 • Siap Kirim</p>
              <div className="text-[10px] font-black text-[#1d64ec]">Rp 35.000</div>
            </div>

            {/* Quick Add Product Button */}
            <div className="w-full py-1.5 rounded-xl bg-[#1d64ec] text-white flex items-center justify-center gap-1 font-bold text-[9px] shadow-2xs">
              <Plus className="w-3 h-3" />
              <span>Tambah Produk</span>
            </div>
          </div>
        </div>

        {/* Floating Price Tag Badge 2 (Bottom Right) */}
        <div className="absolute bottom-2 -right-1 z-20 flex items-center gap-2 px-3 py-2 rounded-2xl bg-white/95 backdrop-blur-sm border border-neutral-200/90 shadow-md">
          <div className="w-7 h-7 rounded-xl bg-amber-100 flex items-center justify-center text-amber-600">
            <Tag className="w-3.5 h-3.5" />
          </div>
          <div>
            <p className="text-[10px] font-extrabold text-slate-900 leading-none">Harga Diskon</p>
            <p className="text-[9px] font-black text-[#1d64ec]">Rp 15.000</p>
          </div>
        </div>
      </div>

      {/* Floating Action Badge */}
      <div className="z-10 flex items-center justify-center">
        <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[#1d64ec] text-white shadow-lg shadow-blue-500/25 border border-blue-400/30 font-extrabold text-xs">
          <Plus className="w-4 h-4" />
          <span>Upload & Jual Produkmu Sekarang</span>
        </div>
      </div>
    </div>
  );
};
