import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  ArrowRight,
  ShieldCheck,
  Zap,
  ChevronDown,
  ChevronUp,
  Star,
  Globe,
  Search,
  ArrowUpRight,
  CheckCircle2,
  ShoppingBag,
  Layers,
  Sparkles,
  Smartphone,
  Video,
  Image as ImageIcon,
  BarChart3,
  FileText,
  MessageSquare,
  Cpu,
  Share2,
  Code2,
  Palette,
  Database,
  MapPin,
} from 'lucide-react';
import { usePWA } from '@/ui/hooks/usePWA';
import { CustomPwaInstallModal } from './CustomPwaInstallModal';
import { triggerHaptic } from '@/utils/haptics';

interface PwaLandingPageProps {
  onProceedToWeb?: () => void;
}

const TRANSITION_EASE = [0.16, 1, 0.3, 1] as const;

const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.08,
      delayChildren: 0.1,
    },
  },
};

const itemFadeUpVariants = {
  hidden: { opacity: 0, y: 24 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.65,
      ease: TRANSITION_EASE,
    },
  },
};

const scrollSectionVariants = {
  hidden: { opacity: 0, y: 32 },
  visible: {
    opacity: 1,
    y: 0,
    transition: {
      duration: 0.7,
      ease: TRANSITION_EASE,
    },
  },
};

export const PwaLandingPage: React.FC<PwaLandingPageProps> = ({ onProceedToWeb }) => {
  const { promptInstall } = usePWA();
  const [claimUsername, setClaimUsername] = useState('');
  const [bottomClaimUsername, setBottomClaimUsername] = useState('');
  const [showCustomInstallModal, setShowCustomInstallModal] = useState(false);
  const [openFaqIndex, setOpenFaqIndex] = useState<number | null>(0);

  const handleInstallClick = () => {
    triggerHaptic('medium');
    setShowCustomInstallModal(true);
  };

  const handleConfirmInstallFromCustomModal = async () => {
    setShowCustomInstallModal(false);
    await promptInstall();
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

  const developerProfiles = [
    {
      role: 'UI/UX Designer',
      name: 'Rifki Pratama',
      handle: 'rifki.design',
      major: 'DKV SMKN 8 Jakarta',
      followers: '1.4K Siswa',
      badge: '🎨 Design Lead',
      bio: 'Merancang design system, wireframe, micro-interaction, dan estetika antarmuka Snapan Market.',
      avatar: '/pop-assets/avatar-1.png',
      products: [
        { name: 'Figma UI Kit & Tokens SMKN 8', price: 'Gratis', icon: Palette, color: 'text-[#1d64ec]' },
        { name: 'Icon Pack & Illustration Kit', price: 'Rp 15.000', icon: Sparkles, color: 'text-purple-600' },
      ],
      quote: '"Desain bukan cuma tampilan visual, tapi bagaimana warga sekolah bisa bertransaksi dengan 0 friction."',
    },
    {
      role: 'Frontend Developer',
      name: 'Rayhan Surya',
      handle: 'rayhan.dev',
      major: 'PPLG SMKN 8 Jakarta',
      followers: '2.8K Siswa',
      badge: '⚡ Web Specialist',
      bio: 'Mengembangkan arsitektur React 18, Tailwind v4, PWA Offline Sync, dan animasi 120 FPS.',
      avatar: '/pop-assets/avatar-2.png',
      products: [
        { name: 'PWA Mobile Template Engine', price: 'Open Source', icon: Code2, color: 'text-emerald-600' },
        { name: 'Source Code E-Commerce PPLG', price: 'Rp 25.000', icon: Zap, color: 'text-amber-600' },
      ],
      quote: '"Performa 120 FPS dan 0ms initial render adalah standar wajib untuk kenyamanan mobile di sekolah."',
    },
    {
      role: 'Backend Developer',
      name: 'Fadhil Al-Ghifari',
      handle: 'fadhil.core',
      major: 'PPLG SMKN 8 Jakarta',
      followers: '1.9K Siswa',
      badge: '🛠️ API Architect',
      bio: 'Mengelola database Supabase PostgreSQL, Row Level Security, Realtime Chat, dan Cloud Functions.',
      avatar: '/pop-assets/avatar-3.png',
      products: [
        { name: 'Database Schema & RLS Policies', price: 'Dokumentasi', icon: Database, color: 'text-indigo-600' },
        { name: 'Realtime Chat Webhook Service', price: 'Rp 20.000', icon: ShieldCheck, color: 'text-blue-600' },
      ],
      quote: '"Keamanan data siswa dan kecepatan transaksi realtime adalah pondasi utama platform ini."',
    },
  ];

  const themes = [
    { name: 'Karya Software & Web PPLG', img: '/pop-assets/theme-1.jpg', tag: 'PPLG' },
    { name: 'Desain Grafis & Merch DKV', img: '/pop-assets/theme-2.jpg', tag: 'DKV' },
    { name: 'Katering & Bakery Kuliner', img: '/pop-assets/theme-3.jpg', tag: 'Kuliner' },
    { name: 'Perlengkapan & Seragam Preloved', img: '/pop-assets/theme-4.jpg', tag: 'Preloved' },
    { name: 'Buku & Modul Pelajaran Sekolah', img: '/pop-assets/theme-5.jpg', tag: 'Akademik' },
    { name: 'Jasa Tutor & Coding Mentorship', img: '/pop-assets/theme-6.jpg', tag: 'Jasa Siswa' },
  ];

  const prebuiltFeatures = [
    { title: 'Katalog Karya Vokasi', desc: 'Pamerkan dan jual template coding PPLG, artwork DKV, hingga snack Kuliner ke seluruh sekolah.', icon: Globe },
    { title: 'COD Titik Temu Kampus', desc: 'Pilih lokasi serah terima resmi yang aman seperti Gazebo, Kantin Utama, atau Lapangan Depan.', icon: MapPin },
    { title: 'Verifikasi Akun Siswa & Guru', desc: 'Transaksi terpercaya khusus komunitas warga SMKN 8 Jakarta dengan NIS/NIP terverifikasi.', icon: ShieldCheck },
    { title: 'Forum & Diskusi Thread', desc: 'Interaksi sosial gaya Threads untuk diskusi pelajaran, tugas kelompok, dan info sekolah.', icon: MessageSquare },
    { title: 'PWA Ringan & Hemat Kuota', desc: 'Pasang langsung di layar utama tanpa App Store / Play Store dengan ukuran di bawah 2MB.', icon: Smartphone },
    { title: 'Toko Digital Instan', desc: 'Buat lapak tokomu sendiri dalam 1 menit tanpa perlu belajar konfigurasi web rumit.', icon: ShoppingBag },
    { title: 'Order Langsung via Chat', desc: 'Komunikasi langsung penjual dan pembeli secara realtime dengan notifikasi instan.', icon: Zap },
    { title: 'Statistik & Riwayat Penjualan', desc: 'Pantau omset harian, jumlah pengunjung lapak, dan ulasan pembeli secara transparan.', icon: BarChart3 },
    { title: 'Pencarian Cepat & Filter Jurusan', desc: 'Cari perlengkapan sekolah atau jasa teman sekelas berdasarkan jurusan dan kategori.', icon: Search },
    { title: 'Bagikan Tautan Toko', desc: 'Bagikan URL tokomu ke status WhatsApp dan Instagram dengan kartu preview otomatis.', icon: Share2 },
    { title: 'Bookmark & Wishlist', desc: 'Simpan produk impian dan pantau saat harga turun atau stok kembali tersedia.', icon: Star },
    { title: 'Bebas Biaya Admin', desc: '100% hasil penjualan masuk ke kantong siswa tanpa potongan komisi platform.', icon: CheckCircle2 },
  ];

  const faqs = [
    {
      q: 'Apakah Snapan Market gratis untuk seluruh siswa SMKN 8 Jakarta?',
      a: 'Ya, 100% gratis tanpa biaya langganan dan tanpa potongan komisi transaksi. Dibuat khusus untuk mendukung kewirausahaan siswa.',
    },
    {
      q: 'Bagaimana cara melakukan transaksi COD di sekolah?',
      a: 'Saat checkout, pembeli dan penjual memilih salah satu titik temu kampus (Kantin, Lapangan Depan, Gazebo, atau Perpustakaan) dan membuat janji saat jam istirahat/pulang sekolah.',
    },
    {
      q: 'Apakah produk non-fisik (karya PPLG & DKV) bisa dijual?',
      a: 'Tentu saja! Siswa PPLG bisa menjual template web/aplikasi, siswa DKV bisa menjual desain logo/merchandise, dan siswa Kuliner bisa menjual kue basah & snack.',
    },
    {
      q: 'Bagaimana cara memasang aplikasi ini di HP Android / iPhone?',
      a: 'Cukup tekan tombol "Pasang Aplikasi" di atas, lalu pilih "Add to Home Screen" di browser Chrome (Android) atau Safari (iOS).',
    },
  ];

  return (
    <div className="min-h-screen w-full bg-[#fafafc] text-slate-950 font-gt-standard select-none overflow-x-clip antialiased selection:bg-[#1d64ec] selection:text-white">
      
      {/* =========================================================================
          1. FLOATING PILL NAVBAR WITH KUMO UI BUTTONS
      ========================================================================= */}
      <motion.div
        initial={{ y: -30, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.6, ease: TRANSITION_EASE }}
        className="fixed top-3 sm:top-5 inset-x-0 z-50 flex justify-center px-3 pointer-events-none"
      >
        <header className="pointer-events-auto w-full max-w-5xl bg-white/85 backdrop-blur-xl border border-neutral-200/80 rounded-full px-4 sm:px-6 py-2.5 shadow-[0_8px_30px_rgba(0,0,0,0.06)] flex items-center justify-between transition-all">
          {/* Logo & Brand Tag */}
          <div className="flex items-center gap-2.5 cursor-pointer" onClick={handleProceed}>
            <motion.div
              whileHover={{ rotate: 5, scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              className="h-7 w-7 rounded-lg bg-[#1d64ec] text-white flex items-center justify-center font-black text-xs shadow-sm shadow-blue-500/20"
            >
              S8
            </motion.div>
            <div className="flex items-center gap-1.5">
              <span className="font-extrabold text-[15px] text-slate-950 tracking-tight">
                Snapan Market
              </span>
              <span className="text-[10px] font-bold text-[#1d64ec] bg-blue-50 px-2 py-0.5 rounded-full border border-blue-100/70">
                SMKN 8
              </span>
            </div>
          </div>

          {/* Desktop Navigation Links */}
          <nav className="hidden md:flex items-center gap-7 text-[13px] font-semibold text-neutral-600">
            <a href="#kategori" className="hover:text-[#1d64ec] transition-colors">Kategori</a>
            <a href="#developers" className="hover:text-[#1d64ec] transition-colors">Developer</a>
            <a href="#fitur" className="hover:text-[#1d64ec] transition-colors">Fitur</a>
            <a href="#faq" className="hover:text-[#1d64ec] transition-colors">FAQ</a>
          </nav>

          {/* Right Action Buttons (Cloudflare Kumo UI Style) */}
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={handleProceed}
              className="px-3.5 py-1.5 rounded-full text-xs font-semibold text-neutral-700 bg-white ring-1 ring-inset ring-neutral-200 hover:bg-neutral-50 active:scale-97 transition-all cursor-pointer shadow-2xs"
            >
              Buka Web
            </button>

            {/* Kumo UI Primary Button */}
            <motion.button
              type="button"
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.96 }}
              onClick={handleInstallClick}
              className="group relative inline-flex items-center justify-center font-semibold select-none border-0 focus:outline-none cursor-pointer tracking-tight overflow-hidden transition-all px-4 py-1.5 rounded-full bg-[#1d64ec] text-white text-xs shadow-md shadow-blue-500/20 border border-[#154ec1]"
            >
              <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-[#3b82f6] to-[#1d64ec] shadow-[inset_0_1px_0_0_rgba(255,255,255,0.35)] group-hover:from-[#2563eb] pointer-events-none" />
              <span className="relative z-10 flex items-center gap-1.5">
                <span>Pasang Aplikasi</span>
              </span>
            </motion.button>
          </div>
        </header>
      </motion.div>

      {/* =========================================================================
          2. HERO SECTION WITH KUMO UI CLAIM INPUT (Gambar 1)
      ========================================================================= */}
      <motion.section
        variants={containerVariants}
        initial="hidden"
        animate="visible"
        className="pt-28 sm:pt-36 pb-16 px-4 sm:px-6 max-w-5xl mx-auto text-center space-y-7"
      >
        {/* Social Proof Pill Badge */}
        <motion.div
          variants={itemFadeUpVariants}
          className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white border border-neutral-200 shadow-2xs text-xs font-semibold text-slate-800"
        >
          <div className="flex -space-x-1.5 items-center">
            <img src="/pop-assets/avatar-1.png" alt="Avatar" className="w-5 h-5 rounded-full border border-white object-cover" />
            <img src="/pop-assets/avatar-2.png" alt="Avatar" className="w-5 h-5 rounded-full border border-white object-cover" />
            <img src="/pop-assets/avatar-3.png" alt="Avatar" className="w-5 h-5 rounded-full border border-white object-cover" />
          </div>
          <span>Bergabung dengan 1.200+ Siswa & Guru SMKN 8</span>
        </motion.div>

        {/* Master Headline (Satoshi + Instrument Serif Italic) */}
        <motion.div variants={itemFadeUpVariants} className="space-y-3 max-w-3xl mx-auto">
          <h1 className="text-4xl sm:text-6xl md:text-7xl font-black text-slate-950 tracking-tight leading-[1.06]">
            Pasar digital & forum resmi <br className="hidden sm:inline" />
            <span className="font-serif italic font-normal text-[#1d64ec]">warga SMKN 8 Jakarta.</span>
          </h1>
          <p className="text-base sm:text-lg text-slate-600 font-normal leading-relaxed max-w-xl mx-auto pt-1">
            Sirkulasi perlengkapan sekolah, komersialisasi karya vokasi (PPLG, DKV, Kuliner), dan COD titik temu kampus.
          </p>
        </motion.div>

        {/* Interactive Claim & Install Input Bar (Gambar 1 - Kumo UI Style) */}
        <motion.div variants={itemFadeUpVariants} className="pt-2 max-w-lg mx-auto">
          <form onSubmit={handleClaim} className="flex items-center bg-white border border-neutral-200/90 rounded-full p-1.5 shadow-[0_10px_30px_rgba(0,0,0,0.05)] focus-within:border-[#1d64ec] focus-within:ring-2 focus-within:ring-blue-100 transition-all">
            <div className="flex items-center pl-4 pr-2 flex-1 min-w-0 text-slate-900">
              <input
                type="text"
                value={claimUsername}
                onChange={(e) => setClaimUsername(e.target.value)}
                placeholder="namakamu"
                className="w-full bg-transparent px-1 py-2 text-sm font-semibold text-slate-900 placeholder:text-neutral-400 focus:outline-none"
              />
              <span className="text-xs font-mono text-neutral-400 font-medium shrink-0">.snapan.site</span>
            </div>

            {/* Kumo UI Primary Action Button */}
            <motion.button
              type="submit"
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.96 }}
              className="group relative inline-flex items-center justify-center font-semibold select-none border-0 focus:outline-none cursor-pointer tracking-tight overflow-hidden transition-all h-10 sm:h-11 px-5 sm:px-6 rounded-full bg-[#1d64ec] text-white text-xs sm:text-sm shadow-md shadow-blue-500/20 border border-[#154ec1] shrink-0"
            >
              <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-[#3b82f6] to-[#1d64ec] shadow-[inset_0_1px_0_0_rgba(255,255,255,0.35)] group-hover:from-[#2563eb] pointer-events-none" />
              <span className="relative z-10 flex items-center gap-1.5 font-bold">
                <span>Klaim Toko Kamu</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </span>
            </motion.button>
          </form>

          {/* Micro Guarantee Copy */}
          <div className="pt-3 flex items-center justify-center gap-3 sm:gap-4 text-[11px] sm:text-xs text-neutral-500 font-medium">
            <span>100% Gratis Siswa & Guru</span>
            <span>·</span>
            <span>Tanpa Biaya Admin</span>
            <span>·</span>
            <span>COD Titik Temu Resmi Kampus</span>
          </div>
        </motion.div>
      </motion.section>

      {/* =========================================================================
          3. 5-PHONE MOCKUP SHOWCASE (Gambar 2 - 120 FPS Staggered Fan-Out Physics)
      ========================================================================= */}
      <motion.section
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: '-60px' }}
        variants={scrollSectionVariants}
        className="py-12 px-4 max-w-6xl mx-auto overflow-hidden"
      >
        <div className="text-center space-y-2 pb-8">
          <span className="text-xs font-bold text-[#1d64ec] uppercase tracking-wider bg-blue-50 px-3 py-1 rounded-full border border-blue-100">
            Preview Ekosistem Aplikasi
          </span>
          <h2 className="text-2xl sm:text-4xl font-black text-slate-950 tracking-tight">
            Satu platform untuk seluruh kebutuhan kampus.
          </h2>
        </div>

        {/* 5-Phone Fan-Out Mockup Grid */}
        <div className="flex items-end justify-center gap-2 sm:gap-4 max-w-5xl mx-auto pt-6 px-2 overflow-x-auto no-scrollbar pb-6">
          
          {/* Phone 1: Outer Left (John Richardson / Preloved) */}
          <motion.div
            whileHover={{ y: -8, scale: 1.02 }}
            transition={{ duration: 0.35, ease: TRANSITION_EASE }}
            className="w-[180px] sm:w-[220px] shrink-0 rounded-[32px] p-2 bg-neutral-900 border-4 border-neutral-800 shadow-xl"
          >
            <div className="rounded-[24px] overflow-hidden bg-white aspect-[9/18.5] p-3 text-left space-y-2.5 text-xs">
              <div className="w-12 h-3 bg-neutral-900 rounded-full mx-auto" />
              <div className="flex items-center gap-2 pt-1">
                <img src="/pop-assets/avatar-1.png" alt="Avatar" className="w-6 h-6 rounded-full object-cover" />
                <span className="font-bold text-[11px]">Bursa Preloved</span>
              </div>
              <p className="text-[10px] text-neutral-500 leading-tight">Seragam Praktik & Modul SMK Bekas Layak Pakai</p>
              <div className="p-2 bg-neutral-50 rounded-lg border border-neutral-100 space-y-1">
                <span className="text-[9px] font-bold text-neutral-800">Jas Lab PPLG (Size L)</span>
                <p className="text-[9px] text-[#1d64ec] font-bold">Rp 35.000</p>
              </div>
            </div>
          </motion.div>

          {/* Phone 2: Inner Left (Shape Studio / DKV) */}
          <motion.div
            whileHover={{ y: -10, scale: 1.025 }}
            transition={{ duration: 0.35, ease: TRANSITION_EASE }}
            className="w-[190px] sm:w-[240px] shrink-0 rounded-[36px] p-2.5 bg-neutral-900 border-4 border-neutral-800 shadow-2xl mb-4"
          >
            <div className="rounded-[26px] overflow-hidden bg-white aspect-[9/18.5] p-3 text-left space-y-2.5 text-xs">
              <div className="w-14 h-3.5 bg-neutral-900 rounded-full mx-auto" />
              <div className="flex items-center gap-2 pt-1">
                <div className="w-6 h-6 rounded-full bg-[#1d64ec] text-white flex items-center justify-center font-bold text-[10px]">DKV</div>
                <span className="font-bold text-[11px]">Studio DKV 8</span>
              </div>
              <p className="text-[10px] text-neutral-500 leading-tight">Jasa Desain Logo, Banner & Kaos Kelas</p>
              <div className="p-2 bg-blue-50/60 rounded-lg border border-blue-100 space-y-1">
                <span className="text-[9px] font-bold text-slate-900">Custom Merchandise</span>
                <p className="text-[9px] text-[#1d64ec] font-bold">Mulai Rp 20.000</p>
              </div>
            </div>
          </motion.div>

          {/* Phone 3: Centerpiece Hero (Sofia Delgado / PPLG Tech) */}
          <motion.div
            whileHover={{ y: -12, scale: 1.03 }}
            transition={{ duration: 0.35, ease: TRANSITION_EASE }}
            className="w-[210px] sm:w-[260px] shrink-0 rounded-[40px] p-3 bg-neutral-950 border-4 border-neutral-800 shadow-[0_32px_64px_-12px_rgba(0,0,0,0.22)] mb-8 z-10"
          >
            <div className="rounded-[28px] overflow-hidden bg-gradient-to-b from-blue-50/50 to-white aspect-[9/18.5] p-3.5 text-left space-y-3 text-xs">
              <div className="w-16 h-4 bg-neutral-950 rounded-full mx-auto" />
              <div className="flex items-center gap-2 pt-1">
                <img src="/pop-assets/avatar-2.png" alt="Avatar" className="w-7 h-7 rounded-full object-cover ring-2 ring-[#1d64ec]" />
                <div>
                  <span className="font-bold text-xs block leading-tight">Software PPLG</span>
                  <span className="text-[9px] text-[#1d64ec] font-mono">pplg.snapan.site</span>
                </div>
              </div>
              <p className="text-[10.5px] text-slate-700 font-medium leading-snug">Jual Template Website, Bot WhatsApp & Portofolio</p>
              <div className="p-2.5 bg-white rounded-xl border border-neutral-200/80 shadow-2xs space-y-1.5">
                <span className="text-[10px] font-bold text-slate-900 block">Source Code Tugas Akhir</span>
                <div className="flex justify-between items-center">
                  <span className="text-[10px] text-[#1d64ec] font-bold">Rp 50.000</span>
                  <span className="text-[8px] bg-blue-100 text-[#1d64ec] px-1.5 py-0.5 rounded-full font-bold">Instant</span>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Phone 4: Inner Right (Kuliner / Catering) */}
          <motion.div
            whileHover={{ y: -10, scale: 1.025 }}
            transition={{ duration: 0.35, ease: TRANSITION_EASE }}
            className="w-[190px] sm:w-[240px] shrink-0 rounded-[36px] p-2.5 bg-neutral-900 border-4 border-neutral-800 shadow-2xl mb-4"
          >
            <div className="rounded-[26px] overflow-hidden bg-white aspect-[9/18.5] p-3 text-left space-y-2.5 text-xs">
              <div className="w-14 h-3.5 bg-neutral-900 rounded-full mx-auto" />
              <div className="flex items-center gap-2 pt-1">
                <img src="/pop-assets/avatar-3.png" alt="Avatar" className="w-6 h-6 rounded-full object-cover" />
                <span className="font-bold text-[11px]">Kuliner SMKN 8</span>
              </div>
              <p className="text-[10px] text-neutral-500 leading-tight">Bakery, Snack & Pre-Order Makan Siang</p>
              <div className="p-2 bg-emerald-50/60 rounded-lg border border-emerald-100 space-y-1">
                <span className="text-[9px] font-bold text-slate-900">Roti Panggang & Pastry</span>
                <p className="text-[9px] text-emerald-600 font-bold">Rp 10.000</p>
              </div>
            </div>
          </motion.div>

          {/* Phone 5: Outer Right (Forum Threads / Akademik) */}
          <motion.div
            whileHover={{ y: -8, scale: 1.02 }}
            transition={{ duration: 0.35, ease: TRANSITION_EASE }}
            className="w-[180px] sm:w-[220px] shrink-0 rounded-[32px] p-2 bg-neutral-900 border-4 border-neutral-800 shadow-xl"
          >
            <div className="rounded-[24px] overflow-hidden bg-white aspect-[9/18.5] p-3 text-left space-y-2.5 text-xs">
              <div className="w-12 h-3 bg-neutral-900 rounded-full mx-auto" />
              <div className="flex items-center gap-2 pt-1">
                <div className="w-6 h-6 rounded-full bg-purple-600 text-white flex items-center justify-center font-bold text-[10px]">Forum</div>
                <span className="font-bold text-[11px]">Thread Akademik</span>
              </div>
              <p className="text-[10px] text-neutral-500 leading-tight">Diskusi Ujian & Info Kegiatan Sekolah</p>
              <div className="p-2 bg-purple-50/60 rounded-lg border border-purple-100 space-y-1">
                <span className="text-[9px] font-bold text-slate-900">Jadwal Uji Kompetensi</span>
                <p className="text-[9px] text-purple-600 font-bold">128 Diskusi</p>
              </div>
            </div>
          </motion.div>

        </div>
      </motion.section>

      {/* =========================================================================
          4. 3 DEVELOPER PROFILE CARDS (Gambar 3 Replacement)
      ========================================================================= */}
      <motion.section
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: '-80px' }}
        variants={scrollSectionVariants}
        id="developers"
        className="py-16 px-4 sm:px-6 max-w-5xl mx-auto space-y-10"
      >
        <div className="text-center space-y-2 max-w-2xl mx-auto">
          <span className="text-xs font-bold text-[#1d64ec] uppercase tracking-wider bg-blue-50 px-3 py-1 rounded-full border border-blue-100">
            Tim Pengembang Siswa
          </span>
          <h2 className="text-3xl sm:text-5xl font-black text-slate-950 tracking-tight">
            Karya nyata developer & desainer <br />
            <span className="font-serif italic font-normal text-[#1d64ec]">SMKN 8 Jakarta.</span>
          </h2>
          <p className="text-sm sm:text-base text-slate-600">
            Platform ini dibangun langsung oleh talenta muda PPLG dan DKV untuk melayani seluruh ekosistem sekolah.
          </p>
        </div>

        {/* 3 Developer Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {developerProfiles.map((dev, i) => (
            <motion.div
              key={i}
              whileHover={{ y: -6, scale: 1.02 }}
              transition={{ duration: 0.35, ease: TRANSITION_EASE }}
              className="p-6 sm:p-7 rounded-3xl bg-white border border-neutral-200/90 shadow-2xs space-y-5 text-left flex flex-col justify-between"
            >
              <div className="space-y-4">
                {/* Header Profil */}
                <div className="flex items-center gap-3.5">
                  <img
                    src={dev.avatar}
                    alt={dev.name}
                    className="w-14 h-14 rounded-2xl object-cover ring-2 ring-blue-100 shadow-2xs"
                  />
                  <div>
                    <div className="flex items-center gap-1.5">
                      <h3 className="text-base font-bold text-slate-950">{dev.name}</h3>
                      <span className="w-4 h-4 rounded-full bg-[#1d64ec] text-white flex items-center justify-center text-[9px] font-bold">✓</span>
                    </div>
                    <p className="text-xs text-neutral-500 font-mono">{dev.handle}</p>
                    <span className="inline-block mt-1 text-[10px] font-bold text-[#1d64ec] bg-blue-50 px-2 py-0.5 rounded-full border border-blue-100">
                      {dev.badge}
                    </span>
                  </div>
                </div>

                <p className="text-xs text-slate-600 leading-relaxed">
                  {dev.bio}
                </p>

                {/* Showcase Karya / Produk */}
                <div className="space-y-2 pt-1">
                  {dev.products.map((prod, pIdx) => {
                    const Icon = prod.icon;
                    return (
                      <div
                        key={pIdx}
                        className="p-3 rounded-xl bg-neutral-50 border border-neutral-200/60 flex items-center justify-between text-xs font-bold text-slate-900 hover:border-neutral-300 transition-colors cursor-pointer"
                      >
                        <div className="flex items-center gap-2">
                          <Icon className={`w-4 h-4 ${prod.color}`} />
                          <span className="truncate max-w-[150px]">{prod.name}</span>
                        </div>
                        <span className="text-[#1d64ec] font-mono text-[11px] shrink-0">{prod.price}</span>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Kutipan Developer */}
              <div className="pt-3 border-t border-neutral-100">
                <blockquote className="text-xs font-serif italic text-slate-600 leading-relaxed">
                  {dev.quote}
                </blockquote>
              </div>
            </motion.div>
          ))}
        </div>
      </motion.section>

      {/* =========================================================================
          5. KATEGORI KARYA VOKASI (Themes Showcase)
      ========================================================================= */}
      <motion.section
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: '-80px' }}
        variants={scrollSectionVariants}
        id="kategori"
        className="py-16 px-4 sm:px-6 max-w-5xl mx-auto space-y-10"
      >
        <div className="text-center space-y-2 max-w-2xl mx-auto">
          <span className="text-xs font-bold text-[#1d64ec] uppercase tracking-wider bg-blue-50 px-3 py-1 rounded-full border border-blue-100">
            Kategori Unggulan
          </span>
          <h2 className="text-3xl sm:text-5xl font-black text-slate-950 tracking-tight">
            Etalase karya & produk <br />
            <span className="font-serif italic font-normal text-[#1d64ec]">jurusan vokasi.</span>
          </h2>
          <p className="text-sm sm:text-base text-slate-600">
            Jual dan beli karya kreatif dari berbagai keahlian di SMKN 8 Jakarta.
          </p>
        </div>

        {/* Gallery Grid */}
        <div className="grid grid-cols-2 md:grid-cols-3 gap-4 sm:gap-6">
          {themes.map((theme, i) => (
            <motion.div
              key={i}
              whileHover={{ y: -6, scale: 1.025 }}
              transition={{ duration: 0.35, ease: TRANSITION_EASE }}
              className="rounded-2xl overflow-hidden border border-neutral-200/90 bg-white shadow-2xs hover:shadow-lg transition-shadow group cursor-pointer"
            >
              <div className="overflow-hidden">
                <img
                  src={theme.img}
                  alt={theme.name}
                  className="w-full h-44 sm:h-56 object-cover group-hover:scale-106 transition-transform duration-500 ease-out"
                />
              </div>
              <div className="p-3.5 text-xs font-bold text-slate-900 flex justify-between items-center bg-white">
                <div>
                  <p className="truncate max-w-[170px]">{theme.name}</p>
                  <span className="text-[10px] text-[#1d64ec] font-bold">{theme.tag}</span>
                </div>
                <ArrowUpRight className="w-4 h-4 text-neutral-400 group-hover:text-[#1d64ec] transition-colors" />
              </div>
            </motion.div>
          ))}
        </div>
      </motion.section>

      {/* =========================================================================
          6. FITUR LENGKAP SEKOLAH (15 Pre-Built Blocks)
      ========================================================================= */}
      <motion.section
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: '-80px' }}
        variants={scrollSectionVariants}
        id="fitur"
        className="py-16 px-4 sm:px-6 max-w-5xl mx-auto space-y-10"
      >
        <div className="text-center space-y-2 max-w-2xl mx-auto">
          <h2 className="text-3xl sm:text-5xl font-black text-slate-950 tracking-tight">
            Fitur lengkap dirancang untuk <br />
            <span className="font-serif italic font-normal text-[#1d64ec]">ekosistem sekolah.</span>
          </h2>
          <p className="text-sm sm:text-base text-slate-600">
            Kemudahan transaksi COD kampus, verifikasi siswa, dan forum akademik.
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-4 sm:gap-5">
          {prebuiltFeatures.map((feat, i) => {
            const Icon = feat.icon;
            return (
              <motion.div
                key={i}
                whileHover={{ y: -4, scale: 1.015 }}
                transition={{ duration: 0.3, ease: TRANSITION_EASE }}
                className="p-6 rounded-2xl bg-white border border-neutral-200/80 shadow-2xs space-y-2.5 text-left"
              >
                <div className="w-9 h-9 rounded-xl bg-blue-50 text-[#1d64ec] flex items-center justify-center">
                  <Icon className="w-4 h-4" />
                </div>
                <h3 className="text-sm font-bold text-slate-950">{feat.title}</h3>
                <p className="text-xs text-slate-600 leading-relaxed font-normal">{feat.desc}</p>
              </motion.div>
            );
          })}
        </div>
      </motion.section>

      {/* =========================================================================
          7. FAQ ACCORDION (Tanya Jawab Sekolah)
      ========================================================================= */}
      <motion.section
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: '-80px' }}
        variants={scrollSectionVariants}
        id="faq"
        className="py-16 px-4 sm:px-6 max-w-3xl mx-auto space-y-8"
      >
        <div className="text-center space-y-2">
          <h2 className="text-3xl sm:text-4xl font-black text-slate-950 tracking-tight">
            Pertanyaan Umum (FAQ)
          </h2>
          <p className="text-sm text-slate-600">
            Hal-hal yang sering ditanyakan seputar Snapan Market.
          </p>
        </div>

        <div className="space-y-3">
          {faqs.map((faq, idx) => {
            const isOpen = openFaqIndex === idx;
            return (
              <motion.div
                key={idx}
                className="rounded-2xl bg-white border border-neutral-200/80 shadow-2xs overflow-hidden transition-colors"
              >
                <button
                  type="button"
                  onClick={() => setOpenFaqIndex(isOpen ? null : idx)}
                  className="w-full px-6 py-5 flex items-center justify-between text-left font-bold text-sm text-slate-950 hover:text-[#1d64ec] transition-colors cursor-pointer"
                >
                  <span>{faq.q}</span>
                  {isOpen ? (
                    <ChevronUp className="w-4 h-4 text-neutral-400 shrink-0" />
                  ) : (
                    <ChevronDown className="w-4 h-4 text-neutral-400 shrink-0" />
                  )}
                </button>
                <AnimatePresence>
                  {isOpen && (
                    <motion.div
                      initial={{ height: 0, opacity: 0 }}
                      animate={{ height: 'auto', opacity: 1 }}
                      exit={{ height: 0, opacity: 0 }}
                      transition={{ duration: 0.35, ease: TRANSITION_EASE }}
                    >
                      <div className="px-6 pb-5 text-xs sm:text-sm text-slate-600 font-normal leading-relaxed border-t border-neutral-100 pt-4">
                        {faq.a}
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            );
          })}
        </div>
      </motion.section>

      {/* =========================================================================
          8. FINAL CALL TO ACTION BANNER (Gambar 5 - Kumo UI Style)
      ========================================================================= */}
      <motion.section
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: '-80px' }}
        variants={scrollSectionVariants}
        className="py-16 px-4 sm:px-6 max-w-5xl mx-auto"
      >
        <div className="p-8 sm:p-16 rounded-3xl bg-[#000000] text-white text-center space-y-7 shadow-2xl relative overflow-hidden">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-blue-600/20 rounded-full blur-3xl pointer-events-none" />

          <div className="relative space-y-3 max-w-lg mx-auto">
            <h2 className="text-3xl sm:text-5xl font-black tracking-tight leading-tight">
              Mulai jual karya & perlengkapan <br />
              <span className="font-serif italic font-normal text-blue-400">sekolahmu hari ini.</span>
            </h2>
            <p className="text-xs sm:text-sm text-neutral-300 font-normal leading-relaxed">
              Buka toko digital siswa dalam hitungan menit. 100% gratis tanpa biaya admin.
            </p>
          </div>

          <div className="relative max-w-md mx-auto">
            <form onSubmit={handleClaim} className="flex items-center bg-white/10 backdrop-blur-md border border-white/20 rounded-full p-1.5 focus-within:border-white transition-all">
              <div className="flex items-center pl-4 pr-2 flex-1 min-w-0 text-white">
                <input
                  type="text"
                  value={bottomClaimUsername}
                  onChange={(e) => setBottomClaimUsername(e.target.value)}
                  placeholder="namakamu"
                  className="w-full bg-transparent px-1 py-2 text-sm font-semibold text-white placeholder:text-neutral-400 focus:outline-none"
                />
                <span className="text-xs font-mono text-neutral-300 font-medium shrink-0">.snapan.site</span>
              </div>

              {/* Kumo UI Primary Button inside Dark Banner */}
              <motion.button
                type="submit"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.96 }}
                className="group relative inline-flex items-center justify-center font-semibold select-none border-0 focus:outline-none cursor-pointer tracking-tight overflow-hidden transition-all h-10 sm:h-11 px-5 sm:px-6 rounded-full bg-[#1d64ec] text-white text-xs sm:text-sm shadow-md shadow-blue-500/30 border border-[#154ec1] shrink-0"
              >
                <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-[#3b82f6] to-[#1d64ec] shadow-[inset_0_1px_0_0_rgba(255,255,255,0.35)] group-hover:from-[#2563eb] pointer-events-none" />
                <span className="relative z-10 flex items-center gap-1.5 font-bold">
                  <span>Klaim</span>
                  <ArrowRight className="w-3.5 h-3.5" />
                </span>
              </motion.button>
            </form>
          </div>
        </div>
      </motion.section>

      {/* =========================================================================
          9. 4-COLUMN FOOTER
      ========================================================================= */}
      <footer className="border-t border-neutral-200/80 pt-12 pb-16 px-4 sm:px-6 max-w-5xl mx-auto text-xs text-neutral-500 space-y-8">
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-8 text-left">
          {/* Col 1 */}
          <div className="space-y-2 col-span-2 sm:col-span-1">
            <div className="flex items-center gap-2">
              <div className="h-6 w-6 rounded-md bg-[#1d64ec] text-white flex items-center justify-center font-bold text-xs">
                S8
              </div>
              <span className="font-extrabold text-sm text-slate-950">Snapan Market</span>
            </div>
            <p className="text-[11.5px] text-neutral-400 leading-relaxed">
              Platform e-commerce & forum komunitas resmi warga SMKN 8 Jakarta.
            </p>
          </div>

          {/* Col 2 */}
          <div className="space-y-2">
            <h4 className="font-bold text-slate-900 text-xs">Menu Utama</h4>
            <ul className="space-y-1.5 text-[11.5px]">
              <li><a href="#kategori" className="hover:text-[#1d64ec] transition-colors">Kategori Vokasi</a></li>
              <li><a href="#developers" className="hover:text-[#1d64ec] transition-colors">Tim Developer</a></li>
              <li><a href="#fitur" className="hover:text-[#1d64ec] transition-colors">Fitur Kampus</a></li>
              <li><a href="#faq" className="hover:text-[#1d64ec] transition-colors">Tanya Jawab (FAQ)</a></li>
            </ul>
          </div>

          {/* Col 3 */}
          <div className="space-y-2">
            <h4 className="font-bold text-slate-900 text-xs">Jurusan Vokasi</h4>
            <ul className="space-y-1.5 text-[11.5px]">
              <li><span className="text-neutral-500">PPLG (Rekayasa Perangkat Lunak)</span></li>
              <li><span className="text-neutral-500">DKV (Desain Komunikasi Visual)</span></li>
              <li><span className="text-neutral-500">Kuliner (Tata Boga & Bakery)</span></li>
              <li><span className="text-neutral-500">Manajemen Perkantoran & Bisnis</span></li>
            </ul>
          </div>

          {/* Col 4 */}
          <div className="space-y-2">
            <h4 className="font-bold text-slate-900 text-xs">Status Sistem</h4>
            <ul className="space-y-1.5 text-[11.5px]">
              <li><span className="text-emerald-600 font-semibold">● Sistem Operasional Normal</span></li>
              <li><span>PWA Engine v2.4 (120 FPS)</span></li>
              <li><span>SMKN 8 Jakarta Official</span></li>
            </ul>
          </div>
        </div>

        <div className="pt-6 border-t border-neutral-100 flex flex-col sm:flex-row items-center justify-between gap-3 text-[11px] text-neutral-400">
          <p>© 2026 Snapan Market · SMKN 8 Jakarta. All rights reserved.</p>
          <p>Dibuat dengan bangga oleh siswa PPLG & DKV SMKN 8 Jakarta.</p>
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
