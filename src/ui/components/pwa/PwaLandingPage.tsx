import React, { useState } from 'react';
import {
  Download,
  Share2,
  CheckCircle2,
  ArrowRight,
  ShieldCheck,
  Zap,
  Smartphone,
  Sparkles,
  MapPin,
  MessageSquare,
  ShoppingBag,
  ExternalLink,
  ChevronDown,
  Layers,
  Heart,
  Globe,
  PlusSquare,
  Share,
} from 'lucide-react';
import { usePWA } from '@/ui/hooks/usePWA';
import { CustomPwaInstallModal } from './CustomPwaInstallModal';
import { triggerHaptic } from '@/utils/haptics';

interface PwaLandingPageProps {
  onProceedToWeb?: () => void;
}

export const PwaLandingPage: React.FC<PwaLandingPageProps> = ({ onProceedToWeb }) => {
  const { isInstalled, promptInstall } = usePWA();
  const [copied, setCopied] = useState(false);
  const [showCustomInstallModal, setShowCustomInstallModal] = useState(false);
  const [showGuideModal, setShowGuideModal] = useState(false);
  const [activePlatform, setActivePlatform] = useState<'android' | 'ios' | 'desktop'>('android');
  const [openFaq, setOpenFaq] = useState<number | null>(null);

  const handleInstallClick = () => {
    triggerHaptic('medium');
    setShowCustomInstallModal(true);
  };

  const handleConfirmInstallFromCustomModal = async () => {
    setShowCustomInstallModal(false);
    const success = await promptInstall();
    if (!success) {
      // Browser didn't trigger native prompt (e.g. desktop/iOS Safari) -> open interactive guide modal
      setShowGuideModal(true);
    }
  };

  const handleShareLink = () => {
    triggerHaptic('selection');
    const downloadUrl = `${window.location.origin}/download`;
    if (navigator.share) {
      navigator.share({
        title: 'Snapan Market Mobile PWA',
        text: 'Pasang aplikasi Snapan Market — Marketplace & Forum Resmi Warga SMKN 8 Jakarta!',
        url: downloadUrl,
      }).catch(() => {});
    } else {
      navigator.clipboard.writeText(downloadUrl);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  const handleProceed = () => {
    triggerHaptic('selection');
    if (onProceedToWeb) {
      onProceedToWeb();
    } else {
      window.location.href = '/';
    }
  };

  return (
    <div className="min-h-screen w-full bg-[#fafafc] text-slate-900 font-gt-standard select-none overflow-x-hidden antialiased">
      {/* 1. TOP STICKY NAVBAR */}
      <header className="sticky top-0 z-40 w-full bg-white/85 backdrop-blur-xl border-b border-neutral-200/70 transition-all">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 h-14 flex items-center justify-between">
          {/* Brand Logo & Name */}
          <div className="flex items-center gap-2.5 cursor-pointer" onClick={handleProceed}>
            <div className="h-8 w-8 rounded-xl bg-[#1d64ec] text-white flex items-center justify-center font-black text-sm shadow-md shadow-blue-500/20">
              S8
            </div>
            <div className="flex items-center gap-1.5">
              <span className="font-bold text-[15px] text-slate-900 tracking-tight">
                Snapan Market
              </span>
              <span className="hidden sm:inline-flex items-center px-2 py-0.5 rounded-full text-[10.5px] font-semibold bg-blue-50 text-[#1d64ec] border border-blue-100/80">
                PWA v2.4
              </span>
            </div>
          </div>

          {/* Right Action Buttons */}
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={handleShareLink}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-white hover:bg-neutral-50 active:bg-neutral-100 border border-neutral-200 text-xs font-semibold text-slate-700 shadow-2xs transition-all cursor-pointer active:scale-95"
            >
              <Share2 className="w-3.5 h-3.5 text-[#1d64ec]" />
              <span>{copied ? 'Tersalin!' : 'Bagikan'}</span>
            </button>

            <button
              type="button"
              onClick={handleProceed}
              className="hidden sm:flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-neutral-100 hover:bg-neutral-200/70 text-xs font-semibold text-slate-800 transition-all cursor-pointer active:scale-95"
            >
              <span>Buka Web</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </button>
          </div>
        </div>
      </header>

      {/* MAIN CONTENT WRAPPER */}
      <main className="max-w-4xl mx-auto px-4 sm:px-6 pt-8 sm:pt-14 pb-20 space-y-16 sm:space-y-24">
        
        {/* 2. HERO SECTION */}
        <section className="text-center space-y-6 max-w-2xl mx-auto">
          {/* Pill Badge */}
          <div className="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-white border border-neutral-200/90 shadow-2xs text-xs font-semibold text-slate-800">
            <span className="flex h-2 w-2 rounded-full bg-[#1d64ec] animate-pulse" />
            <span>Aplikasi Resmi Komunitas SMKN 8 Jakarta</span>
            <span className="text-neutral-300">|</span>
            <span className="text-[#1d64ec] font-bold">100% Gratis</span>
          </div>

          {/* Main Headline */}
          <h1 className="text-3xl sm:text-5xl font-black text-slate-950 tracking-tight leading-[1.12]">
            Pasar Digital & Forum Sekolah dalam Satu Genggaman.
          </h1>

          {/* Subtitle / Copywriting */}
          <p className="text-sm sm:text-base text-slate-600 font-normal leading-relaxed max-w-xl mx-auto">
            Jual beli perlengkapan sekolah preloved, komersialisasi karya vokasi PPLG, DKV, dan Kuliner, serta diskusi akademik. Pasang instan tanpa membebani memori (&lt;3MB).
          </p>

          {/* Dual Action CTAs */}
          <div className="pt-2 flex flex-col sm:flex-row items-center justify-center gap-3 max-w-md mx-auto">
            <button
              type="button"
              onClick={handleInstallClick}
              className="w-full sm:w-auto flex-1 h-12 px-6 rounded-full bg-[#1d64ec] hover:bg-[#154ec1] active:scale-98 text-white font-bold text-[14.5px] shadow-lg shadow-blue-500/25 flex items-center justify-center gap-2 transition-all cursor-pointer"
            >
              <Download className="w-4 h-4 stroke-[2.5]" />
              <span>{isInstalled ? 'Buka Aplikasi Snapan' : 'Pasang Aplikasi di HP'}</span>
            </button>

            <button
              type="button"
              onClick={handleProceed}
              className="w-full sm:w-auto flex-1 h-12 px-6 rounded-full bg-white hover:bg-neutral-50 active:bg-neutral-100 border border-neutral-300/90 text-slate-900 font-bold text-[14.5px] shadow-2xs flex items-center justify-center gap-2 transition-all cursor-pointer"
            >
              <span>Buka di Web Langsung</span>
              <ExternalLink className="w-4 h-4 text-slate-500" />
            </button>
          </div>

          {/* Trust Chips */}
          <div className="pt-2 flex flex-wrap items-center justify-center gap-x-5 gap-y-2 text-xs text-neutral-500 font-medium">
            <div className="flex items-center gap-1.5">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
              <span>Hemat Memori (&lt;3 MB)</span>
            </div>
            <div className="flex items-center gap-1.5">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
              <span>COD Aman di Kantin & Lab</span>
            </div>
            <div className="flex items-center gap-1.5">
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
              <span>Tanpa Iklan Mengganggu</span>
            </div>
          </div>
        </section>

        {/* 3. INTERACTIVE SHOWCASE DEVICE CARD */}
        <section className="relative w-full max-w-3xl mx-auto">
          {/* Subtle Ambient Glow */}
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-72 sm:w-96 h-72 sm:h-96 bg-blue-500/10 rounded-full blur-3xl pointer-events-none" />

          {/* Showcase Outer Container */}
          <div className="relative bg-white border border-neutral-200/90 rounded-3xl p-4 sm:p-7 shadow-[0_20px_50px_rgba(0,0,0,0.06)] overflow-hidden">
            {/* Window Mockup Header */}
            <div className="flex items-center justify-between pb-4 mb-4 border-b border-neutral-100">
              <div className="flex items-center gap-1.5">
                <span className="w-3 h-3 rounded-full bg-red-400/80" />
                <span className="w-3 h-3 rounded-full bg-amber-400/80" />
                <span className="w-3 h-3 rounded-full bg-emerald-400/80" />
              </div>
              <div className="flex items-center gap-1.5 px-3 py-1 rounded-lg bg-neutral-50 text-[11px] font-mono text-neutral-500 border border-neutral-100">
                <span>app.snapan.id</span>
              </div>
              <div className="w-10" />
            </div>

            {/* Simulated Live Feed Grid Preview */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
              {/* Card Preview 1 */}
              <div className="p-4 rounded-2xl bg-neutral-50/80 border border-neutral-100 space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <img
                      src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80"
                      alt="Avatar"
                      className="w-8 h-8 rounded-full object-cover"
                    />
                    <div>
                      <div className="flex items-center gap-1">
                        <span className="text-xs font-bold text-slate-900">Sarah Anastasya</span>
                        <span className="w-3 h-3 rounded-full bg-[#1d64ec] text-white flex items-center justify-center text-[7px] font-bold">✓</span>
                      </div>
                      <span className="text-[10px] text-neutral-400">XII PPLG 1 · 10m</span>
                    </div>
                  </div>
                  <span className="px-2 py-0.5 rounded-md bg-blue-100/70 text-[#1d64ec] text-[10px] font-bold">
                    Produk PJBL
                  </span>
                </div>
                <p className="text-xs text-slate-700 font-normal leading-relaxed">
                  Kalkulator Casio FX-991EX original masih mulus 99%. Siap COD di kantin belakang jam istirahat.
                </p>
                <div className="flex items-center justify-between pt-1 border-t border-neutral-200/50 text-xs">
                  <span className="font-extrabold text-slate-950">Rp 185.000</span>
                  <span className="text-[11px] text-neutral-400 font-medium">📍 Kantin Belakang</span>
                </div>
              </div>

              {/* Card Preview 2 */}
              <div className="p-4 rounded-2xl bg-neutral-50/80 border border-neutral-100 space-y-3">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <img
                      src="https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&q=80"
                      alt="Avatar"
                      className="w-8 h-8 rounded-full object-cover"
                    />
                    <div>
                      <div className="flex items-center gap-1">
                        <span className="text-xs font-bold text-slate-900">Dimas Wicaksono</span>
                      </div>
                      <span className="text-[10px] text-neutral-400">XII DKV 2 · 25m</span>
                    </div>
                  </div>
                  <span className="px-2 py-0.5 rounded-md bg-emerald-100/70 text-emerald-800 text-[10px] font-bold">
                    Jasa Desain
                  </span>
                </div>
                <p className="text-xs text-slate-700 font-normal leading-relaxed">
                  Buka jasa layout banner, mockup kaos, dan poster presentasi tugas akhir. Revisi santai sampai tuntas!
                </p>
                <div className="flex items-center justify-between pt-1 border-t border-neutral-200/50 text-xs">
                  <span className="font-extrabold text-slate-950">Mulai Rp 20.000</span>
                  <span className="text-[11px] text-neutral-400 font-medium">📍 Lab DKV</span>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* 4. BENTO FEATURE PILLARS GRID */}
        <section className="space-y-6">
          <div className="text-center space-y-2 max-w-md mx-auto">
            <h2 className="text-2xl sm:text-3xl font-extrabold text-slate-950 tracking-tight">
              Kenapa Memilih Snapan Market?
            </h2>
            <p className="text-xs sm:text-sm text-slate-600 font-normal">
              Didesain khusus untuk memenuhi ekosistem warga SMKN 8 Jakarta.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {/* Bento Card 1: COD Kampus */}
            <div className="p-6 rounded-3xl bg-white border border-neutral-200/80 shadow-2xs hover:shadow-md transition-all space-y-3">
              <div className="w-10 h-10 rounded-2xl bg-blue-50 text-[#1d64ec] flex items-center justify-center">
                <MapPin className="w-5 h-5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 tracking-tight">
                Titik Temu COD Kampus Terverifikasi
              </h3>
              <p className="text-xs text-slate-600 leading-relaxed font-normal">
                Transaksi langsung di lokasi resmi sekolah yang aman seperti Kantin, Lab Komputer, Perpustakaan, atau Lapangan Utama.
              </p>
            </div>

            {/* Bento Card 2: Karya Vokasi */}
            <div className="p-6 rounded-3xl bg-white border border-neutral-200/80 shadow-2xs hover:shadow-md transition-all space-y-3">
              <div className="w-10 h-10 rounded-2xl bg-purple-50 text-purple-600 flex items-center justify-center">
                <ShoppingBag className="w-5 h-5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 tracking-tight">
                Komersialisasi Karya Jurusan Vokasi
              </h3>
              <p className="text-xs text-slate-600 leading-relaxed font-normal">
                Wadah resmi pamer karya dan monetisasi produk siswa PPLG (aplikasi/web), DKV (desain/merch), dan Kuliner (makanan & bakery).
              </p>
            </div>

            {/* Bento Card 3: Threads & Komunitas */}
            <div className="p-6 rounded-3xl bg-white border border-neutral-200/80 shadow-2xs hover:shadow-md transition-all space-y-3">
              <div className="w-10 h-10 rounded-2xl bg-amber-50 text-amber-600 flex items-center justify-center">
                <MessageSquare className="w-5 h-5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 tracking-tight">
                Forum Sosial & Utas Diskusi Tugas
              </h3>
              <p className="text-xs text-slate-600 leading-relaxed font-normal">
                Format linimasa bergaya Threads untuk saling berdiskusi tugas, sharing materi ujian, info ekskul, hingga event sekolah.
              </p>
            </div>

            {/* Bento Card 4: Ringan & Cepat */}
            <div className="p-6 rounded-3xl bg-white border border-neutral-200/80 shadow-2xs hover:shadow-md transition-all space-y-3">
              <div className="w-10 h-10 rounded-2xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
                <Zap className="w-5 h-5" />
              </div>
              <h3 className="text-base font-bold text-slate-900 tracking-tight">
                Teknologi PWA: Instan & 0ms Cache
              </h3>
              <p className="text-xs text-slate-600 leading-relaxed font-normal">
                Tanpa perlu unduh file APK besar dari PlayStore. Cukup tap pasang, aplikasi siap dibuka secara offline dengan performa 120 FPS.
              </p>
            </div>
          </div>
        </section>

        {/* 5. 3-STEP INSTALLATION GUIDE TABS */}
        <section className="p-6 sm:p-8 rounded-3xl bg-white border border-neutral-200/90 shadow-2xs space-y-6">
          <div className="text-center space-y-2">
            <h2 className="text-xl sm:text-2xl font-extrabold text-slate-950 tracking-tight">
              Panduan Cara Pasang dalam 3 Detik
            </h2>
            <p className="text-xs text-slate-600">
              Pilih perangkat yang sedang Anda gunakan:
            </p>
          </div>

          {/* Platform Switcher Pills */}
          <div className="flex items-center justify-center gap-2">
            <button
              type="button"
              onClick={() => setActivePlatform('android')}
              className={`px-4 py-2 rounded-full text-xs font-bold transition-all cursor-pointer ${
                activePlatform === 'android'
                  ? 'bg-[#1d64ec] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200/60'
              }`}
            >
              Android (Chrome)
            </button>
            <button
              type="button"
              onClick={() => setActivePlatform('ios')}
              className={`px-4 py-2 rounded-full text-xs font-bold transition-all cursor-pointer ${
                activePlatform === 'ios'
                  ? 'bg-[#1d64ec] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200/60'
              }`}
            >
              iPhone (Safari)
            </button>
            <button
              type="button"
              onClick={() => setActivePlatform('desktop')}
              className={`px-4 py-2 rounded-full text-xs font-bold transition-all cursor-pointer ${
                activePlatform === 'desktop'
                  ? 'bg-[#1d64ec] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200/60'
              }`}
            >
              Laptop / PC
            </button>
          </div>

          {/* Platform Step Content */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 pt-2">
            {activePlatform === 'android' && (
              <>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-1.5">
                  <span className="w-6 h-6 rounded-full bg-[#1d64ec] text-white text-xs font-bold flex items-center justify-center">1</span>
                  <h4 className="text-xs font-bold text-slate-900 pt-1">Buka di Chrome</h4>
                  <p className="text-[11.5px] text-neutral-500 font-normal leading-relaxed">
                    Buka halaman ini menggunakan Google Chrome di ponsel Android Anda.
                  </p>
                </div>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-1.5">
                  <span className="w-6 h-6 rounded-full bg-[#1d64ec] text-white text-xs font-bold flex items-center justify-center">2</span>
                  <h4 className="text-xs font-bold text-slate-900 pt-1">Tap Tombol Pasang</h4>
                  <p className="text-[11.5px] text-neutral-500 font-normal leading-relaxed">
                    Klik tombol "Pasang Aplikasi" di halaman ini atau menu titik tiga Chrome.
                  </p>
                </div>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-1.5">
                  <span className="w-6 h-6 rounded-full bg-[#1d64ec] text-white text-xs font-bold flex items-center justify-center">3</span>
                  <h4 className="text-xs font-bold text-slate-900 pt-1">Selesai & Buka</h4>
                  <p className="text-[11.5px] text-neutral-500 font-normal leading-relaxed">
                    Icon Snapan Market akan muncul langsung di layar utama HP Anda!
                  </p>
                </div>
              </>
            )}

            {activePlatform === 'ios' && (
              <>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-1.5">
                  <span className="w-6 h-6 rounded-full bg-[#1d64ec] text-white text-xs font-bold flex items-center justify-center">1</span>
                  <h4 className="text-xs font-bold text-slate-900 pt-1">Buka di Safari</h4>
                  <p className="text-[11.5px] text-neutral-500 font-normal leading-relaxed">
                    Buka tautan ini di browser Safari pada iPhone Anda.
                  </p>
                </div>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-1.5">
                  <span className="w-6 h-6 rounded-full bg-[#1d64ec] text-white text-xs font-bold flex items-center justify-center">2</span>
                  <h4 className="text-xs font-bold text-slate-900 pt-1">Tap Icon Share</h4>
                  <p className="text-[11.5px] text-neutral-500 font-normal leading-relaxed">
                    Tekan tombol Bagikan (Share kotak dengan panah ke atas) di bagian bawah.
                  </p>
                </div>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-1.5">
                  <span className="w-6 h-6 rounded-full bg-[#1d64ec] text-white text-xs font-bold flex items-center justify-center">3</span>
                  <h4 className="text-xs font-bold text-slate-900 pt-1">Add to Home Screen</h4>
                  <p className="text-[11.5px] text-neutral-500 font-normal leading-relaxed">
                    Pilih opsi "Tambah ke Layar Utama" (Add to Home Screen).
                  </p>
                </div>
              </>
            )}

            {activePlatform === 'desktop' && (
              <>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-1.5">
                  <span className="w-6 h-6 rounded-full bg-[#1d64ec] text-white text-xs font-bold flex items-center justify-center">1</span>
                  <h4 className="text-xs font-bold text-slate-900 pt-1">Lihat Address Bar</h4>
                  <p className="text-[11.5px] text-neutral-500 font-normal leading-relaxed">
                    Perhatikan icon install (komputer panah ke bawah) di kanan address bar Chrome/Edge.
                  </p>
                </div>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-1.5">
                  <span className="w-6 h-6 rounded-full bg-[#1d64ec] text-white text-xs font-bold flex items-center justify-center">2</span>
                  <h4 className="text-xs font-bold text-slate-900 pt-1">Klik Install</h4>
                  <p className="text-[11.5px] text-neutral-500 font-normal leading-relaxed">
                    Klik tombol Install untuk memasang aplikasi ke desktop komputer Anda.
                  </p>
                </div>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-1.5">
                  <span className="w-6 h-6 rounded-full bg-[#1d64ec] text-white text-xs font-bold flex items-center justify-center">3</span>
                  <h4 className="text-xs font-bold text-slate-900 pt-1">Buka Sebagai Window</h4>
                  <p className="text-[11.5px] text-neutral-500 font-normal leading-relaxed">
                    Snapan Market kini berjalan sebagai jendela aplikasi terpisah tanpa tab browser.
                  </p>
                </div>
              </>
            )}
          </div>
        </section>

        {/* 6. BOTTOM BANNER CTA */}
        <section className="p-8 sm:p-12 rounded-3xl bg-gradient-to-br from-[#1d64ec] via-[#154ec1] to-[#0f3ba1] text-white text-center space-y-6 shadow-xl shadow-blue-500/20">
          <div className="space-y-2 max-w-lg mx-auto">
            <h2 className="text-2xl sm:text-3xl font-black tracking-tight">
              Siap Bergabung dengan Warga SMKN 8?
            </h2>
            <p className="text-xs sm:text-sm text-blue-100 font-normal leading-relaxed">
              Mulai pasang aplikasinya sekarang atau jelajahi langsung katalog produk dari browser Anda.
            </p>
          </div>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-3 max-w-sm mx-auto">
            <button
              type="button"
              onClick={handleInstallClick}
              className="w-full sm:w-auto flex-1 h-12 px-6 rounded-full bg-white hover:bg-neutral-100 active:scale-98 text-slate-950 font-bold text-sm shadow-md transition-all cursor-pointer"
            >
              Pasang Aplikasi Sekarang
            </button>
            <button
              type="button"
              onClick={handleProceed}
              className="w-full sm:w-auto flex-1 h-12 px-6 rounded-full bg-white/10 hover:bg-white/20 active:scale-98 text-white border border-white/20 font-bold text-sm transition-all cursor-pointer"
            >
              Buka di Web
            </button>
          </div>
        </section>

        {/* 7. FOOTER */}
        <footer className="pt-8 border-t border-neutral-200/80 text-center space-y-2 text-xs text-neutral-400">
          <p>© 2026 Snapan Market · SMKN 8 Jakarta Ecosystem.</p>
          <p className="text-[11px] text-neutral-400">
            Dibuat dengan dedikasi oleh siswa SMKN 8 untuk seluruh warga sekolah.
          </p>
        </footer>
      </main>

      {/* CUSTOM PWA INSTALL MODAL */}
      <CustomPwaInstallModal
        isOpen={showCustomInstallModal}
        onClose={() => setShowCustomInstallModal(false)}
        onConfirmInstall={handleConfirmInstallFromCustomModal}
      />
    </div>
  );
};
