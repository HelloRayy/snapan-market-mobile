import React, { useState } from 'react';
import { Download, Share, CheckCircle2, ArrowRight, ShieldCheck, Zap, WifiOff, Smartphone, PlusSquare, X } from 'lucide-react';
import { usePWA } from '@/ui/hooks/usePWA';
import { ButtonPrimary } from '../ui/ButtonPrimary';
import { ButtonSecondary } from '../ui/ButtonSecondary';
import personLoginBgSvg from '@/assets/new-market-asset/person-login-bg.svg';

interface PwaLandingPageProps {
  onProceedToWeb?: () => void;
}

export const PwaLandingPage: React.FC<PwaLandingPageProps> = ({ onProceedToWeb }) => {
  const { isInstalled, promptInstall } = usePWA();
  const [copied, setCopied] = useState(false);
  const [showGuideModal, setShowGuideModal] = useState(false);

  const handleInstallClick = async () => {
    const success = await promptInstall();
    if (!success) {
      // Browser didn't trigger native prompt (e.g. desktop/iOS Safari) -> open interactive guide modal
      setShowGuideModal(true);
    }
  };

  const handleShareLink = () => {
    const downloadUrl = `${window.location.origin}/download`;
    if (navigator.share) {
      navigator.share({
        title: 'Snapan Market Mobile PWA',
        text: 'Download & Pasang Aplikasi PWA Snapan Market SMKN 8 Semarang!',
        url: downloadUrl,
      }).catch(() => {});
    } else {
      navigator.clipboard.writeText(downloadUrl);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex flex-col justify-between bg-gradient-to-b from-[#f8fafc] via-pure-white to-[#f1f5f9] text-slate-ink select-none overflow-y-auto no-scrollbar font-gt-standard p-5">
      {/* Top Header Bar */}
      <div className="w-full max-w-sm mx-auto flex items-center justify-between pt-2 pb-3">
        <div className="flex items-center gap-2">
          <div className="h-9 w-9 rounded-2xl bg-[#1d64ec] text-white flex items-center justify-center font-extrabold text-sm shadow-md shadow-blue-500/20">
            S8
          </div>
          <div>
            <h1 className="text-sm font-extrabold text-slate-900 leading-tight font-shopify-sans">
              Snapan Market
            </h1>
            <span className="text-[10px] font-bold text-blue-600 bg-blue-50 px-1.5 py-0.5 rounded-md border border-blue-100">
              SMKN 8 Mobile PWA
            </span>
          </div>
        </div>

        <button
          onClick={handleShareLink}
          className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white border border-neutral-200 text-xs font-bold text-slate-700 shadow-2xs hover:bg-neutral-50 active:scale-95 transition-all cursor-pointer"
        >
          <Share className="h-3.5 w-3.5 text-blue-600" />
          <span>{copied ? 'Tersalin!' : 'Bagikan'}</span>
        </button>
      </div>

      {/* Main Hero Visual Card */}
      <div className="w-full max-w-sm mx-auto my-auto py-2 space-y-5 text-center">
        {/* 3D Character Illustration */}
        <div className="relative w-full flex flex-col items-center justify-center">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 bg-blue-400/10 rounded-full blur-3xl pointer-events-none" />
          
          <img
            src={personLoginBgSvg}
            alt="Snapan Market PWA App"
            className="w-52 sm:w-60 h-auto object-contain drop-shadow-xl animate-in fade-in zoom-in-95 duration-300"
          />

          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs font-bold shadow-2xs -mt-2 z-10">
            <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600" />
            <span>Aplikasi Resmi Warga SMKN 8</span>
          </div>
        </div>

        {/* Hero Title & Subtitle */}
        <div className="space-y-2">
          <h2 className="text-2xl font-extrabold tracking-tight text-slate-900 font-shopify-sans leading-tight">
            Pasang Aplikasi Snapan Market di HP Kamu
          </h2>
          <p className="text-xs text-slate-600 font-medium leading-relaxed max-w-xs mx-auto">
            Nikmati pengalaman jual beli online antar siswa & guru SMKN 8 yang cepat, tanpa antre, dan install hemat memori (&lt;3MB).
          </p>
        </div>

        {/* Feature Badges Grid */}
        <div className="grid grid-cols-3 gap-2 text-left pt-1">
          <div className="p-2.5 rounded-2xl bg-white border border-neutral-200/80 shadow-2xs space-y-1">
            <Zap className="h-4 w-4 text-amber-500" />
            <div className="text-[11px] font-bold text-slate-900">Cepat 60fps</div>
            <div className="text-[9px] text-neutral-500">Tanpa Loading</div>
          </div>
          <div className="p-2.5 rounded-2xl bg-white border border-neutral-200/80 shadow-2xs space-y-1">
            <WifiOff className="h-4 w-4 text-blue-500" />
            <div className="text-[11px] font-bold text-slate-900">Hemat Kuota</div>
            <div className="text-[9px] text-neutral-500">Akses Offline</div>
          </div>
          <div className="p-2.5 rounded-2xl bg-white border border-neutral-200/80 shadow-2xs space-y-1">
            <ShieldCheck className="h-4 w-4 text-emerald-500" />
            <div className="text-[11px] font-bold text-slate-900">Hemat RAM</div>
            <div className="text-[9px] text-neutral-500">Ukuran &lt; 3MB</div>
          </div>
        </div>
      </div>

      {/* Bottom CTA Action Bar */}
      <div className="w-full max-w-sm mx-auto space-y-2.5 pb-4">
        {isInstalled ? (
          <div className="p-3 rounded-2xl bg-emerald-50 border border-emerald-200 text-center space-y-1">
            <div className="inline-flex items-center gap-1.5 text-xs font-bold text-emerald-800">
              <CheckCircle2 className="h-4 w-4 text-emerald-600" />
              <span>Aplikasi PWA Sudah Terpasang!</span>
            </div>
            <p className="text-[11px] text-emerald-700 font-medium">
              Buka ikon "Snapan Market" di layar utama HP kamu.
            </p>
          </div>
        ) : (
          <ButtonPrimary
            size="lg"
            onClick={handleInstallClick}
            className="w-full justify-center font-bold h-14 text-base rounded-full bg-[#1d64ec] hover:bg-blue-600 shadow-md shadow-blue-500/25 text-white active:scale-[0.98] cursor-pointer"
            iconLeft={<Download className="h-5 w-5 text-white" />}
          >
            Pasang Aplikasi PWA (1-Klik)
          </ButtonPrimary>
        )}

        {/* Secondary Option: Open Web Catalog */}
        <ButtonSecondary
          size="lg"
          onClick={onProceedToWeb}
          className="w-full justify-center font-bold h-12 text-sm rounded-full border border-neutral-200 text-slate-700 bg-white hover:bg-neutral-50 cursor-pointer"
          iconRight={<ArrowRight className="h-4 w-4 text-slate-600" />}
        >
          Lanjut Versi Web Browser
        </ButtonSecondary>
      </div>

      {/* Interactive Installation Guide Modal */}
      {showGuideModal && (
        <div className="fixed inset-0 z-50 flex items-end sm:items-center justify-center bg-black/50 backdrop-blur-xs p-4 animate-in fade-in duration-200">
          <div className="w-full max-w-sm bg-white rounded-3xl p-5 space-y-4 shadow-2xl animate-in slide-in-from-bottom-6 duration-200">
            <div className="flex items-center justify-between border-b border-neutral-100 pb-3">
              <div className="flex items-center gap-2 font-bold text-sm text-slate-900">
                <Smartphone className="h-5 w-5 text-[#1d64ec]" />
                <span>Petunjuk Memasang Aplikasi PWA</span>
              </div>
              <button
                onClick={() => setShowGuideModal(false)}
                className="p-1 rounded-full text-neutral-400 hover:text-slate-900 hover:bg-neutral-100 transition-colors cursor-pointer"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="space-y-2.5 text-xs text-slate-700">
              <div className="flex items-start gap-3 bg-neutral-50 p-3 rounded-2xl border border-neutral-200/80">
                <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-[#1d64ec] text-white text-xs font-bold">1</span>
                <div>
                  Buka menu browser HP kamu (tombol titik 3 <span className="font-bold text-slate-900">⋮</span> di Android atau tombol <span className="font-bold text-slate-900">Share 📤</span> di iPhone).
                </div>
              </div>

              <div className="flex items-start gap-3 bg-neutral-50 p-3 rounded-2xl border border-neutral-200/80">
                <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-[#1d64ec] text-white text-xs font-bold">2</span>
                <div>
                  Pilih menu <span className="font-bold text-slate-900">'Tambahkan ke Layar Utama'</span> (<PlusSquare className="inline h-3.5 w-3.5 text-blue-600" />) atau <span className="font-bold text-slate-900">'Install App'</span>.
                </div>
              </div>
            </div>

            <ButtonPrimary
              size="lg"
              onClick={() => setShowGuideModal(false)}
              className="w-full justify-center font-bold h-12 text-sm rounded-full bg-[#1d64ec] text-white cursor-pointer mt-2"
            >
              Saya Mengerti
            </ButtonPrimary>
          </div>
        </div>
      )}
    </div>
  );
};
