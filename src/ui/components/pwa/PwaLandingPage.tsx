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
  ChevronUp,
  Star,
  Check,
  Globe,
  Plus,
  Users,
  Search,
  ArrowUpRight,
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
  const [claimUsername, setClaimUsername] = useState('');
  const [showCustomInstallModal, setShowCustomInstallModal] = useState(false);
  const [activePlatform, setActivePlatform] = useState<'android' | 'ios' | 'desktop'>('android');
  const [openFaqIndex, setOpenFaqIndex] = useState<number | null>(null);

  const handleInstallClick = () => {
    triggerHaptic('medium');
    setShowCustomInstallModal(true);
  };

  const handleConfirmInstallFromCustomModal = async () => {
    setShowCustomInstallModal(false);
    await promptInstall();
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

  const handleClaim = (e: React.FormEvent) => {
    e.preventDefault();
    triggerHaptic('medium');
    handleInstallClick();
  };

  const faqs = [
    {
      q: 'Apakah aplikasi Snapan Market ini berbayar?',
      a: 'Tidak sama sekali. 100% gratis untuk seluruh siswa, guru, dan staff SMKN 8 Jakarta tanpa biaya admin, potongan transaksi, atau langganan.',
    },
    {
      q: 'Bagaimana cara transaksi COD di sekolah?',
      a: 'Saat memesan barang, Anda dan penjual memilih Titik Temu COD resmi (Kantin Belakang, Lab Komputer, Lapangan, atau Perpustakaan) pada jam istirahat atau sepulang sekolah.',
    },
    {
      q: 'Kenapa menggunakan teknologi Progressive Web App (PWA)?',
      a: 'PWA memberikan pengalaman aplikasi native yang sangat ringan (< 3MB), tidak memakan memori HP, dapat dipasang langsung tanpa ribet buka Play Store, dan tetap bisa dibuka offline.',
    },
    {
      q: 'Siapa saja yang bisa memajang produk atau jasa?',
      a: 'Seluruh warga SMKN 8 Jakarta! Mulai dari jual barang preloved (seragam, buku, kalkulator), jasa joki coding/desain, hingga produk makanan & kue buatan siswa Kuliner.',
    },
  ];

  return (
    <div className="min-h-screen w-full bg-[#fafafc] text-slate-900 font-gt-standard select-none overflow-x-hidden antialiased selection:bg-[#1d64ec] selection:text-white">
      
      {/* =========================================================================
          1. FLOATING PILL HEADER NAVBAR (Exact pop.site layout)
      ========================================================================= */}
      <div className="fixed top-3 sm:top-5 inset-x-0 z-50 flex justify-center px-3 pointer-events-none">
        <header className="pointer-events-auto w-full max-w-4xl bg-white/90 backdrop-blur-xl border border-neutral-200/80 rounded-full px-3.5 sm:px-5 py-2.5 shadow-[0_8px_30px_rgba(0,0,0,0.06)] flex items-center justify-between transition-all">
          {/* Logo & Brand Tag */}
          <div className="flex items-center gap-2.5 cursor-pointer" onClick={handleProceed}>
            <div className="h-7 w-7 rounded-lg bg-[#000000] text-white flex items-center justify-center font-black text-xs shadow-xs">
              S8
            </div>
            <div className="flex items-center gap-1.5">
              <span className="font-extrabold text-sm text-slate-950 tracking-tight">
                snapan.site
              </span>
              <span className="hidden md:inline-block text-[11px] font-semibold text-[#1d64ec] bg-blue-50 px-2 py-0.5 rounded-full border border-blue-100/70">
                SMKN 8
              </span>
            </div>
          </div>

          {/* Desktop Navigation Links */}
          <nav className="hidden md:flex items-center gap-6 text-[13px] font-semibold text-neutral-600">
            <a href="#fitur" className="hover:text-slate-950 transition-colors">Fitur COD</a>
            <a href="#vokasi" className="hover:text-slate-950 transition-colors">Karya Vokasi</a>
            <a href="#testimoni" className="hover:text-slate-950 transition-colors">Testimoni</a>
            <a href="#panduan" className="hover:text-slate-950 transition-colors">Cara Pasang</a>
            <a href="#faq" className="hover:text-slate-950 transition-colors">FAQ</a>
          </nav>

          {/* Right Action Buttons */}
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={handleShareLink}
              className="flex items-center gap-1 px-3 py-1.5 rounded-full bg-neutral-100/80 hover:bg-neutral-200/70 text-xs font-semibold text-slate-800 transition-all cursor-pointer active:scale-95"
            >
              <Share2 className="w-3.5 h-3.5 text-[#1d64ec]" />
              <span className="hidden sm:inline">{copied ? 'Tersalin!' : 'Bagikan'}</span>
            </button>

            <button
              type="button"
              onClick={handleProceed}
              className="hidden sm:flex items-center px-3.5 py-1.5 text-xs font-semibold text-neutral-700 hover:text-slate-950 transition-colors cursor-pointer"
            >
              Buka Web
            </button>

            <button
              type="button"
              onClick={handleInstallClick}
              className="flex items-center gap-1.5 px-4 py-1.5 rounded-full bg-[#000000] hover:bg-[#1a1a1a] active:scale-95 text-white text-xs font-bold shadow-xs transition-all cursor-pointer"
            >
              <Download className="w-3.5 h-3.5" />
              <span>Pasang</span>
            </button>
          </div>
        </header>
      </div>

      {/* =========================================================================
          2. HERO SECTION (Exact pop.site Typography & Claim Input Bar)
      ========================================================================= */}
      <section className="pt-28 sm:pt-36 pb-16 px-4 sm:px-6 max-w-4xl mx-auto text-center space-y-7">
        
        {/* Social Proof Pill Badge */}
        <div className="inline-flex items-center gap-2.5 px-4 py-1.5 rounded-full bg-white border border-neutral-200 shadow-2xs text-xs font-semibold text-slate-800 animate-in fade-in zoom-in-95 duration-500">
          <div className="flex -space-x-1.5 items-center">
            <img src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=60&q=80" alt="Avatar" className="w-5 h-5 rounded-full border border-white object-cover" />
            <img src="https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=60&q=80" alt="Avatar" className="w-5 h-5 rounded-full border border-white object-cover" />
            <img src="https://images.unsplash.com/photo-1517841905240-472988babdf9?w=60&q=80" alt="Avatar" className="w-5 h-5 rounded-full border border-white object-cover" />
          </div>
          <span>Bergabung dengan 1.200+ Siswa SMKN 8</span>
        </div>

        {/* Master Headline (Large font with Serif Accent) */}
        <div className="space-y-3 max-w-3xl mx-auto">
          <h1 className="text-4xl sm:text-6xl md:text-7xl font-black text-slate-950 tracking-tight leading-[1.08]">
            Pasar sekolah dengan <br className="hidden sm:inline" />
            <span className="font-serif italic font-normal text-[#1d64ec]">zero ribet & zero fee.</span>
          </h1>
          <p className="text-base sm:text-lg text-slate-600 font-normal leading-relaxed max-w-xl mx-auto pt-1">
            Jual beli perlengkapan sekolah, karya vokasi PPLG/DKV/Kuliner, dan diskusi akademik langsung dari HP atau laptop Anda.
          </p>
        </div>

        {/* Interactive Claim & Install Input Bar (Exact pop.site claim bar) */}
        <div className="pt-2 max-w-lg mx-auto">
          <form onSubmit={handleClaim} className="flex items-center bg-white border border-neutral-200/90 rounded-2xl sm:rounded-full p-1.5 shadow-[0_10px_30px_rgba(0,0,0,0.05)] focus-within:border-[#1d64ec] focus-within:ring-2 focus-within:ring-blue-100 transition-all">
            <div className="flex items-center pl-3.5 pr-1 flex-1 min-w-0 text-slate-900">
              <span className="text-neutral-400 font-semibold text-sm">@</span>
              <input
                type="text"
                value={claimUsername}
                onChange={(e) => setClaimUsername(e.target.value)}
                placeholder="nama-kamu"
                className="w-full bg-transparent px-1.5 py-2 text-sm font-semibold text-slate-900 placeholder:text-neutral-300 focus:outline-none"
              />
              <span className="text-xs font-mono text-neutral-400 font-medium hidden sm:inline">.snapan.site</span>
            </div>

            <button
              type="submit"
              className="h-10 sm:h-11 px-5 sm:px-6 rounded-xl sm:rounded-full bg-[#000000] hover:bg-[#1a1a1a] active:scale-95 text-white font-bold text-xs sm:text-sm shadow-xs flex items-center justify-center gap-1.5 transition-all shrink-0 cursor-pointer"
            >
              <span>Klaim & Pasang</span>
              <ArrowRight className="w-3.5 h-3.5" />
            </button>
          </form>

          {/* Micro Guarantee Copy */}
          <div className="pt-3 flex items-center justify-center gap-4 text-xs text-neutral-500 font-medium">
            <span>⚡ 1-Tap Install PWA</span>
            <span>·</span>
            <span>💾 Sangat Ringan (&lt;3MB)</span>
            <span>·</span>
            <span>🛡️ 100% Gratis</span>
          </div>
        </div>

        {/* =========================================================================
            3. HERO SHOWCASE MOCKUP CARDS (pop.site live showcase card)
        ========================================================================= */}
        <div className="pt-8 max-w-3xl mx-auto">
          <div className="relative bg-white border border-neutral-200/90 rounded-3xl p-4 sm:p-7 shadow-[0_24px_60px_rgba(0,0,0,0.06)] overflow-hidden text-left space-y-4">
            
            {/* Top Device Bar */}
            <div className="flex items-center justify-between pb-3 border-b border-neutral-100">
              <div className="flex items-center gap-1.5">
                <span className="w-2.5 h-2.5 rounded-full bg-neutral-200" />
                <span className="w-2.5 h-2.5 rounded-full bg-neutral-200" />
                <span className="w-2.5 h-2.5 rounded-full bg-neutral-200" />
              </div>
              <div className="flex items-center gap-1 px-3 py-0.5 rounded-md bg-neutral-50 text-[11px] font-mono text-neutral-400 border border-neutral-100">
                <span>app.snapan.id</span>
              </div>
              <span className="text-[11px] font-semibold text-emerald-600 bg-emerald-50 px-2 py-0.5 rounded-full">
                ● Live Feed
              </span>
            </div>

            {/* Profile Bar Showcase */}
            <div className="flex items-center justify-between p-3.5 rounded-2xl bg-neutral-50/70 border border-neutral-100">
              <div className="flex items-center gap-3">
                <img
                  src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=120&q=80"
                  alt="Profile"
                  className="w-11 h-11 rounded-full object-cover ring-2 ring-white"
                />
                <div>
                  <div className="flex items-center gap-1.5">
                    <h3 className="text-sm font-bold text-slate-900">Sarah Anastasya</h3>
                    <span className="w-3.5 h-3.5 rounded-full bg-[#1d64ec] text-white flex items-center justify-center text-[8px] font-bold">✓</span>
                  </div>
                  <p className="text-xs text-neutral-500">@sarahanas · XII PPLG 1</p>
                </div>
              </div>
              <div className="text-right">
                <span className="text-xs font-bold text-slate-900">142</span>
                <span className="text-xs text-neutral-400 font-normal"> pengikut</span>
                <span className="mx-1.5 text-neutral-300">·</span>
                <span className="text-xs font-bold text-slate-900">⭐ 4.9</span>
              </div>
            </div>

            {/* Live Feed Item Grid */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5 pt-1">
              {/* Product 1 */}
              <div className="p-4 rounded-2xl bg-white border border-neutral-100 shadow-2xs space-y-2.5">
                <div className="flex items-center justify-between">
                  <span className="px-2 py-0.5 rounded-md bg-blue-50 text-[#1d64ec] text-[10.5px] font-bold">
                    Alat Belajar
                  </span>
                  <span className="text-[11px] text-neutral-400">10m lalu</span>
                </div>
                <h4 className="text-xs font-bold text-slate-900 line-clamp-1">
                  Kalkulator Casio FX-991EX Original
                </h4>
                <p className="text-[11.5px] text-slate-600 line-clamp-2 leading-relaxed">
                  Masih mulus 99%, tombol empuk. Siap COD di kantin belakang jam istirahat kedua.
                </p>
                <div className="flex items-center justify-between pt-2 border-t border-neutral-100">
                  <span className="text-sm font-black text-slate-950">Rp 185.000</span>
                  <span className="text-[11px] font-medium text-slate-500">📍 Kantin Belakang</span>
                </div>
              </div>

              {/* Product 2 */}
              <div className="p-4 rounded-2xl bg-white border border-neutral-100 shadow-2xs space-y-2.5">
                <div className="flex items-center justify-between">
                  <span className="px-2 py-0.5 rounded-md bg-emerald-50 text-emerald-700 text-[10.5px] font-bold">
                    Karya PPLG
                  </span>
                  <span className="text-[11px] text-neutral-400">25m lalu</span>
                </div>
                <h4 className="text-xs font-bold text-slate-900 line-clamp-1">
                  Source Code Landing Page Portofolio
                </h4>
                <p className="text-[11.5px] text-slate-600 line-clamp-2 leading-relaxed">
                  Template portofolio siap pakai untuk tugas akhir PJBL. Responsive dan clean code.
                </p>
                <div className="flex items-center justify-between pt-2 border-t border-neutral-100">
                  <span className="text-sm font-black text-slate-950">Rp 35.000</span>
                  <span className="text-[11px] font-medium text-slate-500">📍 Lab PPLG</span>
                </div>
              </div>
            </div>

          </div>
        </div>
      </section>

      {/* =========================================================================
          4. FEATURE HIGHLIGHTS / TESTIMONIAL QUOTE (Exact pop.site block)
      ========================================================================= */}
      <section id="testimoni" className="py-16 px-4 sm:px-6 max-w-4xl mx-auto">
        <div className="p-8 sm:p-12 rounded-3xl bg-[#000000] text-white text-left space-y-6 relative overflow-hidden">
          {/* Subtle Ambient light */}
          <div className="absolute top-0 right-0 w-80 h-80 bg-blue-500/15 rounded-full blur-3xl pointer-events-none" />

          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/10 text-xs font-semibold text-blue-200 border border-white/10">
            <Sparkles className="w-3.5 h-3.5 text-[#1d64ec]" />
            <span>Pengalaman Warga SMKN 8</span>
          </div>

          <blockquote className="text-xl sm:text-3xl font-serif italic text-white/95 leading-snug max-w-2xl">
            "Kalkulator dan seragam jurusan saya langsung laku sebelum jam istirahat pertama selesai. COD-nya aman langsung di kantin sekolah."
          </blockquote>

          <div className="flex items-center gap-3 pt-2">
            <img
              src="https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=100&q=80"
              alt="Dimas"
              className="w-10 h-10 rounded-full object-cover border border-white/20"
            />
            <div>
              <p className="text-sm font-bold text-white">Dimas Wicaksono</p>
              <p className="text-xs text-neutral-400 font-mono">dimas.snapan.site · XII DKV 2</p>
            </div>
          </div>
        </div>
      </section>

      {/* =========================================================================
          5. BENTO GRID FEATURES (Exact pop.site Bento styling)
      ========================================================================= */}
      <section id="fitur" className="py-12 px-4 sm:px-6 max-w-4xl mx-auto space-y-10">
        <div className="text-center space-y-2 max-w-lg mx-auto">
          <span className="text-xs font-bold text-[#1d64ec] uppercase tracking-wider">Fitur Utama</span>
          <h2 className="text-3xl sm:text-4xl font-black text-slate-950 tracking-tight">
            Dibuat Khusus untuk Kebutuhan SMKN 8.
          </h2>
          <p className="text-sm text-slate-600">
            Setiap fitur dirancang untuk kemudahan transaksi dan interaksi siswa sehari-hari.
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {/* Card 1 */}
          <div className="p-7 rounded-3xl bg-white border border-neutral-200/80 shadow-2xs hover:shadow-md transition-all space-y-3">
            <div className="w-10 h-10 rounded-2xl bg-blue-50 text-[#1d64ec] flex items-center justify-center">
              <MapPin className="w-5 h-5" />
            </div>
            <h3 className="text-lg font-bold text-slate-950 tracking-tight">
              Titik Temu COD Kampus Resmi
            </h3>
            <p className="text-xs sm:text-sm text-slate-600 font-normal leading-relaxed">
              Pilih lokasi pertemuan aman di lingkungan sekolah seperti Kantin Belakang, Lab PPLG, Lab DKV, Perpustakaan, atau Lapangan Upacara.
            </p>
          </div>

          {/* Card 2 */}
          <div id="vokasi" className="p-7 rounded-3xl bg-white border border-neutral-200/80 shadow-2xs hover:shadow-md transition-all space-y-3">
            <div className="w-10 h-10 rounded-2xl bg-purple-50 text-purple-600 flex items-center justify-center">
              <ShoppingBag className="w-5 h-5" />
            </div>
            <h3 className="text-lg font-bold text-slate-950 tracking-tight">
              Komersialisasi Karya Vokasi
            </h3>
            <p className="text-xs sm:text-sm text-slate-600 font-normal leading-relaxed">
              Monetisasi hasil karya jurusan: Jasa pembuatan web/aplikasi (PPLG), merchandise & desain grafis (DKV), serta kue & catering (Kuliner).
            </p>
          </div>

          {/* Card 3 */}
          <div className="p-7 rounded-3xl bg-white border border-neutral-200/80 shadow-2xs hover:shadow-md transition-all space-y-3">
            <div className="w-10 h-10 rounded-2xl bg-amber-50 text-amber-600 flex items-center justify-center">
              <MessageSquare className="w-5 h-5" />
            </div>
            <h3 className="text-lg font-bold text-slate-950 tracking-tight">
              Threads & Forum Diskusi Sekolah
            </h3>
            <p className="text-xs sm:text-sm text-slate-600 font-normal leading-relaxed">
              Bukan cuma jual beli, tapi juga ruang berbagi info tugas, tips ujian kejuruan, pengumuman OSIS, dan diskusi antar kelas.
            </p>
          </div>

          {/* Card 4 */}
          <div className="p-7 rounded-3xl bg-white border border-neutral-200/80 shadow-2xs hover:shadow-md transition-all space-y-3">
            <div className="w-10 h-10 rounded-2xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <Zap className="w-5 h-5" />
            </div>
            <h3 className="text-lg font-bold text-slate-950 tracking-tight">
              PWA 0ms Fast Feed Cache
            </h3>
            <p className="text-xs sm:text-sm text-slate-600 font-normal leading-relaxed">
              Arsitektur in-memory cache instan. Feed langsung terbuka tanpa loading berputar, hemat kuota internet, dan mulus 120 FPS.
            </p>
          </div>
        </div>
      </section>

      {/* =========================================================================
          6. INSTALLATION GUIDE TABS (Exact pop.site step guide)
      ========================================================================= */}
      <section id="panduan" className="py-12 px-4 sm:px-6 max-w-4xl mx-auto">
        <div className="p-7 sm:p-10 rounded-3xl bg-white border border-neutral-200/90 shadow-2xs space-y-8">
          <div className="text-center space-y-2 max-w-md mx-auto">
            <h2 className="text-2xl sm:text-3xl font-black text-slate-950 tracking-tight">
              Cara Pasang dalam 3 Detik
            </h2>
            <p className="text-xs sm:text-sm text-slate-600">
              Pilih perangkat yang Anda gunakan sekarang:
            </p>
          </div>

          {/* Platform Pills */}
          <div className="flex items-center justify-center gap-2">
            <button
              type="button"
              onClick={() => setActivePlatform('android')}
              className={`px-4 py-2 rounded-full text-xs font-bold transition-all cursor-pointer ${
                activePlatform === 'android'
                  ? 'bg-[#000000] text-white shadow-xs'
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
                  ? 'bg-[#000000] text-white shadow-xs'
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
                  ? 'bg-[#000000] text-white shadow-xs'
                  : 'bg-neutral-100 text-neutral-600 hover:bg-neutral-200/60'
              }`}
            >
              Laptop / PC
            </button>
          </div>

          {/* Steps Grid */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            {activePlatform === 'android' && (
              <>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-2">
                  <span className="w-6 h-6 rounded-full bg-[#000000] text-white text-xs font-bold flex items-center justify-center">1</span>
                  <h4 className="text-xs font-bold text-slate-950">Buka di Chrome</h4>
                  <p className="text-xs text-neutral-500 font-normal leading-relaxed">
                    Buka situs ini di browser Google Chrome pada ponsel Android Anda.
                  </p>
                </div>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-2">
                  <span className="w-6 h-6 rounded-full bg-[#000000] text-white text-xs font-bold flex items-center justify-center">2</span>
                  <h4 className="text-xs font-bold text-slate-950">Tap Pasang</h4>
                  <p className="text-xs text-neutral-500 font-normal leading-relaxed">
                    Klik tombol "Pasang" di atas atau banner instalasi otomatis.
                  </p>
                </div>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-2">
                  <span className="w-6 h-6 rounded-full bg-[#000000] text-white text-xs font-bold flex items-center justify-center">3</span>
                  <h4 className="text-xs font-bold text-slate-950">Icon Siap di HP</h4>
                  <p className="text-xs text-neutral-500 font-normal leading-relaxed">
                    Aplikasi langsung terpasang di homescreen HP tanpa lewat PlayStore.
                  </p>
                </div>
              </>
            )}

            {activePlatform === 'ios' && (
              <>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-2">
                  <span className="w-6 h-6 rounded-full bg-[#000000] text-white text-xs font-bold flex items-center justify-center">1</span>
                  <h4 className="text-xs font-bold text-slate-950">Buka di Safari</h4>
                  <p className="text-xs text-neutral-500 font-normal leading-relaxed">
                    Pastikan Anda membuka halaman ini di browser Safari iPhone.
                  </p>
                </div>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-2">
                  <span className="w-6 h-6 rounded-full bg-[#000000] text-white text-xs font-bold flex items-center justify-center">2</span>
                  <h4 className="text-xs font-bold text-slate-950">Tap Tombol Share</h4>
                  <p className="text-xs text-neutral-500 font-normal leading-relaxed">
                    Tekan icon Bagikan (kotak panah ke atas) di bar bawah Safari.
                  </p>
                </div>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-2">
                  <span className="w-6 h-6 rounded-full bg-[#000000] text-white text-xs font-bold flex items-center justify-center">3</span>
                  <h4 className="text-xs font-bold text-slate-950">Add to Home Screen</h4>
                  <p className="text-xs text-neutral-500 font-normal leading-relaxed">
                    Pilih "Tambah ke Layar Utama" (Add to Home Screen) dan tap Simpan.
                  </p>
                </div>
              </>
            )}

            {activePlatform === 'desktop' && (
              <>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-2">
                  <span className="w-6 h-6 rounded-full bg-[#000000] text-white text-xs font-bold flex items-center justify-center">1</span>
                  <h4 className="text-xs font-bold text-slate-950">Address Bar Chrome</h4>
                  <p className="text-xs text-neutral-500 font-normal leading-relaxed">
                    Lihat icon Install (komputer panah bawah) di kanan address bar browser.
                  </p>
                </div>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-2">
                  <span className="w-6 h-6 rounded-full bg-[#000000] text-white text-xs font-bold flex items-center justify-center">2</span>
                  <h4 className="text-xs font-bold text-slate-950">Klik Install</h4>
                  <p className="text-xs text-neutral-500 font-normal leading-relaxed">
                    Klik pasang untuk membuat shortcut aplikasi standalone di desktop.
                  </p>
                </div>
                <div className="p-4 rounded-2xl bg-neutral-50 border border-neutral-100 space-y-2">
                  <span className="w-6 h-6 rounded-full bg-[#000000] text-white text-xs font-bold flex items-center justify-center">3</span>
                  <h4 className="text-xs font-bold text-slate-950">Window Terpisah</h4>
                  <p className="text-xs text-neutral-500 font-normal leading-relaxed">
                    Snapan Market terbuka rapi tanpa tab browser seperti app native.
                  </p>
                </div>
              </>
            )}
          </div>
        </div>
      </section>

      {/* =========================================================================
          7. FAQ ACCORDION (Exact pop.site accordion style)
      ========================================================================= */}
      <section id="faq" className="py-12 px-4 sm:px-6 max-w-3xl mx-auto space-y-6">
        <div className="text-center space-y-2">
          <h2 className="text-2xl sm:text-3xl font-black text-slate-950 tracking-tight">
            Pertanyaan Umum (FAQ)
          </h2>
          <p className="text-xs sm:text-sm text-slate-600">
            Hal yang sering ditanyakan oleh siswa & guru SMKN 8.
          </p>
        </div>

        <div className="space-y-2.5">
          {faqs.map((faq, idx) => {
            const isOpen = openFaqIndex === idx;
            return (
              <div
                key={idx}
                className="rounded-2xl bg-white border border-neutral-200/80 shadow-2xs overflow-hidden transition-all"
              >
                <button
                  type="button"
                  onClick={() => setOpenFaqIndex(isOpen ? null : idx)}
                  className="w-full px-5 py-4 flex items-center justify-between text-left font-bold text-sm text-slate-900 hover:text-[#1d64ec] transition-colors cursor-pointer"
                >
                  <span>{faq.q}</span>
                  {isOpen ? (
                    <ChevronUp className="w-4 h-4 text-neutral-400 shrink-0" />
                  ) : (
                    <ChevronDown className="w-4 h-4 text-neutral-400 shrink-0" />
                  )}
                </button>
                {isOpen && (
                  <div className="px-5 pb-4 text-xs sm:text-sm text-slate-600 font-normal leading-relaxed border-t border-neutral-100 pt-3">
                    {faq.a}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </section>

      {/* =========================================================================
          8. BOTTOM FINAL CALL TO ACTION (Exact pop.site dark banner)
      ========================================================================= */}
      <section className="py-12 px-4 sm:px-6 max-w-4xl mx-auto">
        <div className="p-8 sm:p-14 rounded-3xl bg-[#000000] text-white text-center space-y-6 shadow-xl relative overflow-hidden">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-blue-600/20 rounded-full blur-3xl pointer-events-none" />

          <div className="relative space-y-2 max-w-lg mx-auto">
            <h2 className="text-3xl sm:text-4xl font-black tracking-tight leading-tight">
              Mulai Pakai Snapan Market Hari Ini.
            </h2>
            <p className="text-xs sm:text-sm text-neutral-300 font-normal leading-relaxed">
              Pasang aplikasinya dalam hitungan detik atau buka langsung dari browser Anda.
            </p>
          </div>

          <div className="relative flex flex-col sm:flex-row items-center justify-center gap-3 max-w-sm mx-auto">
            <button
              type="button"
              onClick={handleInstallClick}
              className="w-full sm:w-auto flex-1 h-12 px-7 rounded-full bg-white hover:bg-neutral-100 active:scale-95 text-slate-950 font-bold text-sm shadow-md transition-all cursor-pointer"
            >
              Pasang Sekarang
            </button>
            <button
              type="button"
              onClick={handleProceed}
              className="w-full sm:w-auto flex-1 h-12 px-7 rounded-full bg-white/10 hover:bg-white/20 active:scale-95 text-white border border-white/20 font-bold text-sm transition-all cursor-pointer"
            >
              Buka Versi Web
            </button>
          </div>
        </div>
      </section>

      {/* =========================================================================
          9. MULTI-COLUMN FOOTER (Exact pop.site footer layout)
      ========================================================================= */}
      <footer className="border-t border-neutral-200/80 pt-12 pb-16 px-4 sm:px-6 max-w-4xl mx-auto text-xs text-neutral-500 space-y-8">
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-6 text-left">
          {/* Col 1 */}
          <div className="space-y-2 col-span-2 sm:col-span-1">
            <div className="flex items-center gap-2">
              <div className="h-6 w-6 rounded-md bg-black text-white flex items-center justify-center font-bold text-xs">
                S8
              </div>
              <span className="font-extrabold text-sm text-slate-950">snapan.site</span>
            </div>
            <p className="text-[11.5px] text-neutral-400 leading-relaxed">
              Marketplace & Komunitas Resmi SMKN 8 Jakarta.
            </p>
          </div>

          {/* Col 2 */}
          <div className="space-y-2">
            <h4 className="font-bold text-slate-900 text-xs">Jurusan</h4>
            <ul className="space-y-1.5 text-[11.5px]">
              <li><a href="#" className="hover:text-slate-950 transition-colors">PPLG (Software)</a></li>
              <li><a href="#" className="hover:text-slate-950 transition-colors">DKV (Desain)</a></li>
              <li><a href="#" className="hover:text-slate-950 transition-colors">Kuliner (Food & Pastry)</a></li>
            </ul>
          </div>

          {/* Col 3 */}
          <div className="space-y-2">
            <h4 className="font-bold text-slate-900 text-xs">Titik COD</h4>
            <ul className="space-y-1.5 text-[11.5px]">
              <li><span className="text-neutral-500">Kantin Belakang</span></li>
              <li><span className="text-neutral-500">Lab Komputer</span></li>
              <li><span className="text-neutral-500">Lapangan Upacara</span></li>
            </ul>
          </div>

          {/* Col 4 */}
          <div className="space-y-2">
            <h4 className="font-bold text-slate-900 text-xs">Informasi</h4>
            <ul className="space-y-1.5 text-[11.5px]">
              <li><span className="text-emerald-600 font-semibold">● Sistem Aktif</span></li>
              <li><span>PWA Versi 2.4</span></li>
              <li><span>100% Khusus SMKN 8</span></li>
            </ul>
          </div>
        </div>

        <div className="pt-6 border-t border-neutral-100 flex flex-col sm:flex-row items-center justify-between gap-3 text-[11px] text-neutral-400">
          <p>© 2026 Snapan Market. Hak Cipta Dilindungi Warga SMKN 8 Jakarta.</p>
          <p>Dirancang & dibangun oleh siswa SMKN 8 Jakarta.</p>
        </div>
      </footer>

      {/* CUSTOM PWA INSTALL MODAL */}
      <CustomPwaInstallModal
        isOpen={showCustomInstallModal}
        onClose={() => setShowCustomInstallModal(false)}
        onConfirmInstall={handleConfirmInstallFromCustomModal}
      />
    </div>
  );
};
