import React from 'react';
import { Download, Sparkles, X, ShieldCheck, Zap, Star } from 'lucide-react';
import { ButtonPrimary } from '@/ui/components/ui/ButtonPrimary';
import personLoginBgSvg from '@/assets/new-market-asset/person-login-bg.svg';

interface CustomPwaInstallModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConfirmInstall: () => void;
}

export const CustomPwaInstallModal: React.FC<CustomPwaInstallModalProps> = ({
  isOpen,
  onClose,
  onConfirmInstall,
}) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/60 backdrop-blur-xs p-4 animate-in fade-in duration-200 font-gt-standard select-none">
      {/* Custom Premium PWA App Store Style Bottom Sheet / Card */}
      <div className="relative w-full max-w-sm bg-white rounded-[32px] p-6 shadow-2xl space-y-5 animate-in slide-in-from-bottom-6 duration-250 border border-neutral-100 overflow-hidden">
        {/* Decorative Top Accent Glow */}
        <div className="absolute top-0 left-0 right-0 h-2 bg-gradient-to-r from-blue-500 via-indigo-500 to-emerald-400" />
        
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-4 right-4 p-1.5 rounded-full text-neutral-400 hover:text-slate-900 hover:bg-neutral-100 transition-colors cursor-pointer"
          aria-label="Tutup Modal"
        >
          <X className="h-5 w-5" />
        </button>

        {/* App Header & Rating Row */}
        <div className="flex items-center gap-3.5 pt-1">
          <div className="relative flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl bg-[#1d64ec] text-white shadow-lg shadow-blue-500/25 border border-blue-400/30">
            <span className="text-2xl font-black font-shopify-sans">S8</span>
            <div className="absolute -bottom-1 -right-1 h-5 w-5 rounded-full bg-emerald-500 border-2 border-white flex items-center justify-center text-white">
              <ShieldCheck className="h-3 w-3" />
            </div>
          </div>

          <div className="space-y-1">
            <div className="flex items-center gap-1.5">
              <h3 className="text-lg font-extrabold text-slate-900 font-shopify-sans leading-tight">
                Snapan Market
              </h3>
              <span className="text-[10px] font-bold text-emerald-700 bg-emerald-50 px-2 py-0.5 rounded-full border border-emerald-200">
                Resmi
              </span>
            </div>

            <p className="text-xs text-neutral-500 font-medium">
              Aplikasi PWA SMKN 8 Semarang
            </p>

            <div className="flex items-center gap-2 text-xs">
              <div className="flex items-center text-amber-500 font-bold gap-0.5">
                <Star className="h-3.5 w-3.5 fill-amber-400" />
                <span>4.9</span>
              </div>
              <span className="text-neutral-300">•</span>
              <span className="text-neutral-500 font-semibold">500+ Siswa</span>
              <span className="text-neutral-300">•</span>
              <span className="text-neutral-500 font-semibold">&lt; 3MB</span>
            </div>
          </div>
        </div>

        {/* Center Graphic & Preview */}
        <div className="relative rounded-2xl bg-gradient-to-br from-blue-50/80 to-indigo-50/60 p-4 border border-blue-100 flex items-center justify-between overflow-hidden">
          <div className="space-y-1.5 max-w-[60%]">
            <div className="inline-flex items-center gap-1 text-[10px] font-bold text-blue-700 bg-blue-100/80 px-2 py-0.5 rounded-md">
              <Sparkles className="h-3 w-3 text-blue-600" />
              <span>Instalasi 1-Klik</span>
            </div>
            <p className="text-xs font-bold text-slate-900 leading-snug">
              Pasang langsung di layar utama HP kamu!
            </p>
            <div className="flex items-center gap-2 text-[10px] text-neutral-600 font-medium pt-0.5">
              <span className="flex items-center gap-0.5 text-amber-600 font-bold"><Zap className="h-3 w-3" /> Cepat</span>
              <span>•</span>
              <span>Hemat Memori</span>
            </div>
          </div>

          <img
            src={personLoginBgSvg}
            alt="3D Character Preview"
            className="w-24 h-24 object-contain drop-shadow-md shrink-0 -mr-2"
          />
        </div>

        {/* CTA Buttons */}
        <div className="space-y-2 pt-1">
          <ButtonPrimary
            size="lg"
            onClick={onConfirmInstall}
            className="w-full justify-center font-bold h-14 text-base rounded-full bg-[#1d64ec] hover:bg-blue-600 shadow-md shadow-blue-500/25 text-white active:scale-[0.98] cursor-pointer"
            iconLeft={<Download className="h-5 w-5 text-white" />}
          >
            Pasang Aplikasi Sekarang
          </ButtonPrimary>

          <button
            type="button"
            onClick={onClose}
            className="w-full text-center text-xs font-bold text-neutral-500 hover:text-slate-900 py-2 cursor-pointer transition-colors"
          >
            Nanti Saja
          </button>
        </div>
      </div>
    </div>
  );
};
