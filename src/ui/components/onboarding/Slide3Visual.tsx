import React from 'react';
import { PackageCheck, Users, Banknote, ShieldCheck, MapPin, Sparkles } from 'lucide-react';

export const Slide3Visual: React.FC = () => {
  return (
    <div className="relative w-full aspect-[4/5] rounded-[32px] bg-gradient-to-b from-blue-50/80 via-emerald-50/40 to-slate-50 border border-neutral-200/80 p-5 flex flex-col justify-between overflow-hidden shadow-lg select-none">
      {/* Background Glow */}
      <div className="absolute -top-10 -right-10 w-40 h-40 bg-emerald-500/10 rounded-full blur-2xl pointer-events-none" />
      <div className="absolute -bottom-10 -left-10 w-36 h-36 bg-blue-500/10 rounded-full blur-2xl pointer-events-none" />

      {/* Top Status Pill */}
      <div className="flex items-center justify-between z-10">
        <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white/90 backdrop-blur-md border border-neutral-200/80 shadow-2xs">
          <MapPin className="w-3.5 h-3.5 text-emerald-600" />
          <span className="text-[11px] font-extrabold text-slate-900 tracking-tight">
            COD di Area SMKN 8
          </span>
          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
        </div>
        <div className="flex items-center gap-1 px-2.5 py-1 rounded-full bg-emerald-600/10 text-emerald-700 font-bold text-[10px] border border-emerald-300/40">
          <ShieldCheck className="w-3 h-3" />
          <span>Aman & Praktis</span>
        </div>
      </div>

      {/* Center 3D COD Handover Scene Representation */}
      <div className="relative flex-1 my-3 flex flex-col items-center justify-center gap-3 z-10">
        {/* Main Floating Card Showcase */}
        <div className="w-full max-w-[280px] p-4 rounded-2xl bg-white/95 backdrop-blur-sm border border-neutral-200/90 shadow-md flex flex-col items-center gap-3 text-center">
          {/* Avatar Pair Representation */}
          <div className="flex items-center gap-2">
            <div className="w-11 h-11 rounded-2xl bg-blue-100 border border-blue-200 flex items-center justify-center text-[#1d64ec] font-extrabold text-sm shadow-2xs">
              Siswa A
            </div>
            <div className="w-8 h-8 rounded-full bg-emerald-50 flex items-center justify-center text-emerald-600 border border-emerald-200">
              <PackageCheck className="w-4 h-4 animate-bounce" />
            </div>
            <div className="w-11 h-11 rounded-2xl bg-emerald-100 border border-emerald-200 flex items-center justify-center text-emerald-700 font-extrabold text-sm shadow-2xs">
              Siswa B
            </div>
          </div>

          <div>
            <p className="text-xs font-black text-slate-900">Serah Terima Paket COD</p>
            <p className="text-[10px] text-slate-500 font-medium mt-0.5">
              Bayar Tunai di Tempat • Tanpa Tamabahan Biaya
            </p>
          </div>

          {/* Floating Pill Badges */}
          <div className="flex items-center gap-2 pt-1">
            <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-blue-50 text-[#1d64ec] border border-blue-200/60 text-[10px] font-extrabold">
              <Banknote className="w-3 h-3" />
              Bayar Pas COD
            </span>
            <span className="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-200/60 text-[10px] font-extrabold">
              <Users className="w-3 h-3" />
              Warga SMKN 8
            </span>
          </div>
        </div>
      </div>

      {/* Floating Action Badge */}
      <div className="z-10 flex items-center justify-center">
        <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[#1d64ec] text-white shadow-lg shadow-blue-500/25 border border-blue-400/30 font-extrabold text-xs">
          <Sparkles className="w-4 h-4" />
          <span>Jual Beli COD Cepat & Bebas Khawatir</span>
        </div>
      </div>
    </div>
  );
};
