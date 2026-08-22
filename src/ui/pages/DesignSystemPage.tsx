import React, { useState } from 'react';
import {
  Copy,
  Check,
  ArrowLeft,
  Search,
  Heart,
  Repeat2,
  Send,
  MoreHorizontal,
  Bookmark,
  BookmarkCheck,
  UserPlus,
  UserCheck,
  Box,
  Star,
  ChevronRight,
  PartyPopper,
  X,
  Vibrate,
  Palette,
  Type,
  MousePointerClick,
  SlidersHorizontal,
  Tag,
  CreditCard,
  Loader2,
  RefreshCw,
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { triggerHaptic, HapticType } from '@/utils/haptics';
import { ClickableVerifiedBadge } from '@/ui/components/marketplace/VerifiedBadgeModal';
import { FormattedText } from '@/ui/components/ui/FormattedText';
import { QuantitySelector } from '@/ui/components/marketplace/QuantitySelector';
import { ProgressiveImage } from '@/ui/components/ui/ProgressiveImage';
import { MarketPostCard } from '@/ui/components/marketplace/MarketPostCard';
import { MOCK_MARKET_POSTS } from '@/data/mockMarketData';

interface DesignSystemPageProps {
  onBack?: () => void;
}

// ---------------------------------------------------------------------------
// 🧩 Interactive Component Showcase Card with Live State Controller & Copy JSX
// ---------------------------------------------------------------------------
interface ShowcaseCardProps {
  id: string;
  title: string;
  category: string;
  description: string;
  codeSnippet: string;
  availableStates?: ('default' | 'hover' | 'active' | 'focus' | 'loading' | 'disabled')[];
  children: (currentState: string) => React.ReactNode;
}

const ShowcaseCard: React.FC<ShowcaseCardProps> = ({
  id,
  title,
  category,
  description,
  codeSnippet,
  availableStates = ['default', 'hover', 'active', 'disabled'],
  children,
}) => {
  const [activeState, setActiveState] = useState<string>('default');
  const [copied, setCopied] = useState(false);

  const handleCopyCode = async () => {
    try {
      await navigator.clipboard.writeText(codeSnippet);
      triggerHaptic('light');
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      // ignore
    }
  };

  return (
    <div
      id={id}
      className="bg-white rounded-2xl border border-neutral-200/90 shadow-sm overflow-hidden flex flex-col transition-all hover:border-neutral-300"
    >
      {/* Card Header: Title, Category Badge, State Switcher & Copy Button */}
      <div className="px-5 py-4 border-b border-neutral-100 bg-neutral-50/50 flex flex-wrap items-center justify-between gap-3">
        <div>
          <div className="flex items-center gap-2">
            <h3 className="font-bold text-[15px] text-slate-900">{title}</h3>
            <span className="text-[11px] font-semibold px-2 py-0.5 rounded-full bg-neutral-200/70 text-slate-700">
              {category}
            </span>
          </div>
          <p className="text-xs text-slate-500 mt-0.5">{description}</p>
        </div>

        <div className="flex items-center gap-2 ml-auto">
          {/* State Controller Segmented Pills */}
          {availableStates.length > 1 && (
            <div className="flex items-center bg-neutral-200/70 p-1 rounded-xl gap-0.5 text-xs">
              {availableStates.map((st) => (
                <button
                  key={st}
                  type="button"
                  onClick={() => {
                    triggerHaptic('selection');
                    setActiveState(st);
                  }}
                  className={`px-2.5 py-1 rounded-lg font-medium capitalize transition-all cursor-pointer ${
                    activeState === st
                      ? 'bg-white text-slate-900 shadow-2xs font-semibold'
                      : 'text-slate-600 hover:text-slate-900'
                  }`}
                >
                  {st}
                </button>
              ))}
            </div>
          )}

          {/* 1-Click Copy Code Button */}
          <button
            type="button"
            onClick={handleCopyCode}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl border border-neutral-300/80 bg-white hover:bg-neutral-50 text-slate-700 text-xs font-semibold shadow-2xs transition-all active:scale-95 cursor-pointer"
            title="Salin kode JSX"
          >
            {copied ? (
              <>
                <Check className="w-3.5 h-3.5 text-emerald-600 stroke-[2.5]" />
                <span className="text-emerald-700">Tersalin!</span>
              </>
            ) : (
              <>
                <Copy className="w-3.5 h-3.5 text-slate-600 stroke-[2]" />
                <span>Salin JSX</span>
              </>
            )}
          </button>
        </div>
      </div>

      {/* Live Preview Canvas */}
      <div className="p-6 flex-1 flex items-center justify-center bg-white min-h-[140px] overflow-x-auto">
        {children(activeState)}
      </div>

      {/* Code Snippet Drawer Bar */}
      <div className="px-5 py-2.5 bg-neutral-900 text-neutral-300 font-mono text-[11px] overflow-x-auto border-t border-neutral-800 flex items-center justify-between">
        <span className="truncate pr-4">{codeSnippet.split('\n')[0]}</span>
        <span className="text-neutral-500 shrink-0 select-none">JSX Component</span>
      </div>
    </div>
  );
};

// ---------------------------------------------------------------------------
// 🎨 Main Design System Dashboard Page Component
// ---------------------------------------------------------------------------
export const DesignSystemPage: React.FC<DesignSystemPageProps> = ({ onBack }) => {
  const [activeSection, setActiveSection] = useState<'tokens' | 'buttons' | 'inputs' | 'badges' | 'cards'>('tokens');
  const [searchQuery, setSearchQuery] = useState('');
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  // Demo interactive state helpers
  const [demoLike, setDemoLike] = useState(false);
  const [demoLikeCount, setDemoLikeCount] = useState(42);
  const [demoRepost, setDemoRepost] = useState(false);
  const [demoRepostCount, setDemoRepostCount] = useState(5);
  const [demoBookmark, setDemoBookmark] = useState(false);
  const [demoFollow, setDemoFollow] = useState(false);
  const [demoQuantity, setDemoQuantity] = useState(2);
  const [demoTab2, setDemoTab2] = useState<'for-you' | 'latest'>('for-you');
  const [demoTab3, setDemoTab3] = useState<'threads' | 'replies' | 'media'>('threads');
  const [demoSearch, setDemoSearch] = useState('Snapan Market');
  const [imageReloadKey, setImageReloadKey] = useState(1);

  const showToast = (msg: string) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(null), 2500);
  };

  const copyToClipboard = async (text: string, label: string) => {
    try {
      await navigator.clipboard.writeText(text);
      triggerHaptic('light');
      showToast(`${label} berhasil disalin ke papan klip!`);
    } catch {
      // ignore
    }
  };

  // Nav Items
  const navItems = [
    { id: 'tokens', label: 'Design Tokens', icon: Palette, count: 24 },
    { id: 'buttons', label: 'Buttons & Actions', icon: MousePointerClick, count: 8 },
    { id: 'inputs', label: 'Forms & Inputs', icon: SlidersHorizontal, count: 6 },
    { id: 'badges', label: 'Badges & Indicators', icon: Tag, count: 7 },
    { id: 'cards', label: 'Cards & Feeds', icon: CreditCard, count: 3 },
  ] as const;

  return (
    <div className="min-h-screen bg-neutral-100/70 text-slate-900 flex font-gt-standard">
      {/* Toast Notification */}
      <AnimatePresence>
        {toastMessage && (
          <motion.div
            initial={{ opacity: 0, y: -20, scale: 0.95 }}
            animate={{ opacity: 1, y: 0, scale: 1 }}
            exit={{ opacity: 0, y: -20, scale: 0.95 }}
            className="fixed top-5 left-1/2 -translate-x-1/2 z-50 bg-slate-900 text-white text-xs font-semibold px-4 py-2.5 rounded-full shadow-xl flex items-center gap-2 border border-slate-700"
          >
            <Check className="w-3.5 h-3.5 text-emerald-400 stroke-[3]" />
            <span>{toastMessage}</span>
          </motion.div>
        )}
      </AnimatePresence>

      {/* ===================================================================== */}
      {/* 🧭 DESKTOP DEVELOPER SIDEBAR                                           */}
      {/* ===================================================================== */}
      <aside className="w-72 bg-white border-r border-neutral-200/90 flex flex-col shrink-0 sticky top-0 h-screen select-none">
        {/* Sidebar Header */}
        <div className="p-5 border-b border-neutral-100 flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-xl bg-slate-900 flex items-center justify-center text-white font-bold text-sm shadow-md">
              S
            </div>
            <div>
              <h1 className="font-bold text-sm text-slate-900 leading-tight">Snapan Market</h1>
              <div className="flex items-center gap-1.5 mt-0.5">
                <span className="text-[10px] font-bold px-1.5 py-0.5 rounded bg-blue-50 text-blue-700 border border-blue-200">
                  DESIGN SYSTEM
                </span>
                <span className="text-[10px] text-neutral-400 font-mono">v1.0.0</span>
              </div>
            </div>
          </div>
        </div>

        {/* Back to App Link */}
        <div className="p-3 border-b border-neutral-100">
          <button
            type="button"
            onClick={() => {
              triggerHaptic('light');
              if (onBack) {
                onBack();
              } else {
                window.location.href = '/';
              }
            }}
            className="w-full flex items-center gap-2 px-3 py-2 rounded-xl text-xs font-semibold text-slate-700 hover:text-slate-900 hover:bg-neutral-100/80 active:bg-neutral-200/80 transition-colors cursor-pointer"
          >
            <ArrowLeft className="w-4 h-4 stroke-[2.2]" />
            <span>Kembali ke Aplikasi Snapan</span>
          </button>
        </div>

        {/* Search Filter */}
        <div className="p-3">
          <div className="relative">
            <Search className="w-3.5 h-3.5 text-neutral-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Cari komponen & token..."
              className="w-full pl-8 pr-3 py-1.5 text-xs rounded-xl bg-neutral-100 border border-neutral-200/80 focus:bg-white focus:outline-none focus:ring-2 focus:ring-slate-900/10 placeholder:text-neutral-400"
            />
          </div>
        </div>

        {/* Navigation Categories */}
        <nav className="flex-1 overflow-y-auto p-3 space-y-1">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeSection === item.id;
            return (
              <button
                key={item.id}
                type="button"
                onClick={() => {
                  triggerHaptic('selection');
                  setActiveSection(item.id);
                }}
                className={`w-full flex items-center justify-between px-3 py-2.5 rounded-xl text-xs font-semibold transition-all cursor-pointer ${
                  isActive
                    ? 'bg-slate-900 text-white shadow-md shadow-slate-900/10'
                    : 'text-slate-600 hover:bg-neutral-100 hover:text-slate-900'
                }`}
              >
                <div className="flex items-center gap-2.5">
                  <Icon className={`w-4 h-4 ${isActive ? 'text-white' : 'text-slate-500'}`} />
                  <span>{item.label}</span>
                </div>
                <span
                  className={`text-[11px] font-mono px-2 py-0.5 rounded-full ${
                    isActive ? 'bg-white/20 text-white' : 'bg-neutral-200/80 text-slate-700'
                  }`}
                >
                  {item.count}
                </span>
              </button>
            );
          })}
        </nav>

        {/* Sidebar Footer */}
        <div className="p-4 border-t border-neutral-100 text-[11px] text-neutral-400 flex items-center justify-between">
          <span>Tailwind v4 + React 18</span>
          <span className="font-mono text-slate-700 font-bold">120 FPS</span>
        </div>
      </aside>

      {/* ===================================================================== */}
      {/* 🖥️ MAIN STUDIO CONTENT CANVAS                                         */}
      {/* ===================================================================== */}
      <main className="flex-1 min-w-0 overflow-y-auto">
        {/* Sticky Top Header */}
        <header className="sticky top-0 z-30 bg-white/95 backdrop-blur-md border-b border-neutral-200/80 px-8 py-4 flex items-center justify-between select-none">
          <div>
            <h2 className="text-lg font-bold text-slate-900 capitalize">
              {navItems.find((n) => n.id === activeSection)?.label}
            </h2>
            <p className="text-xs text-neutral-500">
              Koleksi komponen & design tokens resmi Snapan Market Mobile PWA
            </p>
          </div>

          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={() => copyToClipboard(':root {\n  --color-pure-white: #ffffff;\n  --color-ink-black: #000000;\n  --color-shop-violet: #5433eb;\n}', 'Global Tokens CSS')}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl border border-neutral-300 bg-white hover:bg-neutral-50 text-slate-700 text-xs font-semibold shadow-2xs transition-all active:scale-95 cursor-pointer"
            >
              <Copy className="w-3.5 h-3.5 text-slate-600" />
              <span>Salin Root Tokens</span>
            </button>
          </div>
        </header>

        {/* Content Container */}
        <div className="max-w-6xl mx-auto p-8 space-y-10">
          {/* ================================================================= */}
          {/* SECTION 1: 🎨 DESIGN TOKENS                                       */}
          {/* ================================================================= */}
          {activeSection === 'tokens' && (
            <div className="space-y-10">
              {/* 1.1 Color Palette Tokens */}
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
                    <Palette className="w-4 h-4 text-purple-600" />
                    <span>Brand & Semantic Color Palette</span>
                  </h3>
                  <span className="text-xs text-neutral-500">Klik warna untuk menyalin nilai HEX</span>
                </div>

                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3.5">
                  {[
                    { name: 'Canvas Mist', varName: '--color-canvas-mist', hex: '#f2f4f5', desc: 'Background utama abu halus' },
                    { name: 'Pure White', varName: '--color-pure-white', hex: '#ffffff', desc: 'Background card & modal' },
                    { name: 'Ink Black', varName: '--color-ink-black', hex: '#000000', desc: 'Heading utama & teks pekat' },
                    { name: 'Slate Ink', varName: '--color-slate-ink', hex: '#332f2d', desc: 'Body text standar' },
                    { name: 'Muted Gray', varName: '--color-muted-gray', hex: '#787574', desc: 'Subteks & keterangan secondary' },
                    { name: 'Faint Border', varName: '--color-faint-border', hex: '#ebebeb', desc: 'Garis pemisah border halus' },
                    { name: 'Shop Violet', varName: '--color-shop-violet', hex: '#5433eb', desc: 'Warna aksen marketplace' },
                    { name: 'Threads Blue', varName: '--color-threads-blue', hex: '#1d64ec', desc: 'Aksen verified badge & topic' },
                  ].map((col) => (
                    <div
                      key={col.name}
                      onClick={() => copyToClipboard(col.hex, col.name)}
                      className="bg-white p-3.5 rounded-2xl border border-neutral-200/80 shadow-2xs hover:border-slate-400 transition-all cursor-pointer group"
                    >
                      <div
                        className="w-full h-16 rounded-xl border border-black/10 shadow-inner mb-3 transition-transform group-hover:scale-[1.02]"
                        style={{ backgroundColor: col.hex }}
                      />
                      <div className="flex items-center justify-between">
                        <span className="font-bold text-xs text-slate-900">{col.name}</span>
                        <span className="font-mono text-[10px] text-neutral-400 uppercase">{col.hex}</span>
                      </div>
                      <p className="text-[11px] text-neutral-500 font-mono mt-0.5">{col.varName}</p>
                      <p className="text-[10px] text-neutral-400 mt-1">{col.desc}</p>
                    </div>
                  ))}
                </div>
              </div>

              {/* 1.2 Typography Tokens Scale */}
              <div className="space-y-4">
                <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
                  <Type className="w-4 h-4 text-blue-600" />
                  <span>Typography Scale (Inter / GT Standard)</span>
                </h3>

                <div className="bg-white rounded-2xl border border-neutral-200/80 p-5 divide-y divide-neutral-100 shadow-2xs">
                  {[
                    { label: 'text-2xl (24px)', weight: 'font-bold', sample: 'Snapan Market Mobile PWA' },
                    { label: 'text-xl (20px)', weight: 'font-bold', sample: 'Kantin Belakang & Ruang Praktik' },
                    { label: 'text-lg (18px)', weight: 'font-semibold', sample: 'Detail Postingan & Komentar' },
                    { label: 'text-base (16px)', weight: 'font-normal', sample: 'Teks Deskripsi & Caption Feed Produk' },
                    { label: 'text-[14.5px]', weight: 'font-medium', sample: 'Nama Siswa, Kelas & Username Threads' },
                    { label: 'text-xs (12px)', weight: 'font-normal', sample: 'Timestamp Cerdas · 2j lalu · 15 terjual' },
                  ].map((typo, idx) => (
                    <div key={idx} className="py-3.5 flex items-center justify-between gap-4">
                      <div className="w-36 shrink-0">
                        <span className="font-mono text-xs text-blue-600 font-semibold">{typo.label}</span>
                        <p className="text-[10px] text-neutral-400">{typo.weight}</p>
                      </div>
                      <p className={`flex-1 text-slate-900 ${typo.label.split(' ')[0]} ${typo.weight}`}>
                        {typo.sample}
                      </p>
                    </div>
                  ))}
                </div>
              </div>

              {/* 1.3 Haptic Vibration Feedback Playground */}
              <div className="space-y-4">
                <h3 className="text-base font-bold text-slate-900 flex items-center gap-2">
                  <Vibrate className="w-4 h-4 text-emerald-600" />
                  <span>Web Haptics Feedback Tester (Taptic Engine)</span>
                </h3>

                <div className="bg-white rounded-2xl border border-neutral-200/80 p-6 shadow-2xs">
                  <p className="text-xs text-neutral-500 mb-4">
                    Uji coba respon getaran mikro perangkat keras HP Anda saat menekan tombol interaktif:
                  </p>

                  <div className="flex flex-wrap gap-2.5">
                    {[
                      { type: 'selection' as HapticType, label: 'Selection (6ms)', desc: 'Tab & navigation switch' },
                      { type: 'light' as HapticType, label: 'Light (10ms)', desc: 'Header search & icon click' },
                      { type: 'medium' as HapticType, label: 'Medium (20ms)', desc: 'Like heart & Repost toggle' },
                      { type: 'heavy' as HapticType, label: 'Heavy (35ms)', desc: 'Delete action / alert' },
                      { type: 'success' as HapticType, label: 'Success ([12, 40, 20]ms)', desc: 'Post created successfully' },
                      { type: 'error' as HapticType, label: 'Error (Pattern)', desc: 'Form error / validation alert' },
                    ].map((hap) => (
                      <button
                        key={hap.type}
                        type="button"
                        onClick={() => {
                          triggerHaptic(hap.type);
                          showToast(`Haptic "${hap.type}" terpicu! 📳`);
                        }}
                        className="px-4 py-2.5 rounded-xl border border-neutral-300 bg-white hover:bg-neutral-50 active:scale-95 text-xs font-bold text-slate-800 shadow-2xs transition-all cursor-pointer flex items-center gap-2"
                      >
                        <Vibrate className="w-3.5 h-3.5 text-slate-600" />
                        <span>{hap.label}</span>
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* ================================================================= */}
          {/* SECTION 2: 🔘 BUTTONS & CTAS                                      */}
          {/* ================================================================= */}
          {activeSection === 'buttons' && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* 2.1 Primary Black Button */}
              <ShowcaseCard
                id="btn-primary"
                title="Primary CTA Button"
                category="Buttons"
                description="Tombol aksi utama bernuansa hitam pekat dengan inner top white gradient shimmer."
                codeSnippet={`<button className="relative flex items-center justify-center h-10 px-5 rounded-xl font-bold text-[14px] bg-[#101010] text-white border border-black shadow-md hover:bg-black active:scale-[0.96] cursor-pointer">
  <span className="absolute inset-0 rounded-xl bg-gradient-to-b from-white/20 to-transparent pointer-events-none" />
  <span className="relative z-10">Beli Sekarang</span>
</button>`}
                availableStates={['default', 'hover', 'active', 'loading', 'disabled']}
              >
                {(st) => (
                  <button
                    type="button"
                    disabled={st === 'disabled'}
                    className={`relative flex items-center justify-center h-10 px-6 rounded-xl font-bold text-[14px] transition-all overflow-hidden select-none cursor-pointer ${
                      st === 'disabled'
                        ? 'bg-neutral-300 text-neutral-500 border border-neutral-300 cursor-not-allowed opacity-60'
                        : st === 'active'
                        ? 'bg-black text-white scale-[0.96]'
                        : st === 'hover'
                        ? 'bg-black text-white shadow-lg'
                        : 'bg-[#101010] text-white border border-black shadow-md shadow-black/10'
                    }`}
                  >
                    <span className="absolute inset-0 rounded-xl bg-gradient-to-b from-white/20 to-transparent pointer-events-none" />
                    <span className="relative z-10 flex items-center gap-2">
                      {st === 'loading' ? (
                        <>
                          <Loader2 className="w-4 h-4 animate-spin text-white" />
                          <span>Memproses...</span>
                        </>
                      ) : (
                        <span>Beli Sekarang</span>
                      )}
                    </span>
                  </button>
                )}
              </ShowcaseCard>

              {/* 2.2 Secondary Outline Button */}
              <ShowcaseCard
                id="btn-secondary"
                title="Secondary Outline Button"
                category="Buttons"
                description="Tombol aksi sekunder dengan border abu halus, bg putih, dan hover neutral-50."
                codeSnippet={`<button className="h-10 px-5 rounded-xl border border-neutral-300 bg-white font-bold text-[13.5px] text-slate-900 hover:bg-neutral-50 active:scale-[0.98] shadow-2xs cursor-pointer">
  Edit Profil
</button>`}
                availableStates={['default', 'hover', 'active', 'disabled']}
              >
                {(st) => (
                  <button
                    type="button"
                    disabled={st === 'disabled'}
                    className={`h-10 px-6 rounded-xl border font-bold text-[13.5px] transition-all shadow-2xs cursor-pointer ${
                      st === 'disabled'
                        ? 'border-neutral-200 bg-neutral-100 text-neutral-400 cursor-not-allowed'
                        : st === 'active'
                        ? 'border-neutral-400 bg-neutral-100 text-slate-900 scale-[0.97]'
                        : st === 'hover'
                        ? 'border-neutral-400 bg-neutral-50 text-slate-900'
                        : 'border-neutral-300 bg-white text-slate-900 hover:bg-neutral-50'
                    }`}
                  >
                    Edit Profil
                  </button>
                )}
              </ShowcaseCard>

              {/* 2.3 Like Button with Elastic Heart Burst */}
              <ShowcaseCard
                id="btn-like"
                title="Heart Like Button with Burst Pop"
                category="Social Actions"
                description="Tombol like dengan micro-animasi elastic pop, getaran haptik, dan counter otomatis."
                codeSnippet={`<motion.button
  whileTap={{ scale: 0.94 }}
  onClick={() => setIsLiked(!isLiked)}
  className="flex items-center gap-1.5 px-2.5 py-1 rounded-full border border-slate-900 bg-neutral-100/90 text-slate-900 shadow-2xs"
>
  <motion.div animate={isLiked ? { scale: [1, 1.35, 0.95, 1] } : { scale: 1 }}>
    <Heart className="w-4 h-4 fill-rose-500 text-rose-500" />
  </motion.div>
  <span className="font-medium text-[13px]">{likesCount}</span>
</motion.button>`}
                availableStates={['default']}
              >
                {() => (
                  <motion.button
                    type="button"
                    whileTap={{ scale: 0.94 }}
                    onClick={() => {
                      triggerHaptic(demoLike ? 'light' : 'medium');
                      setDemoLike(!demoLike);
                      setDemoLikeCount((prev) => (demoLike ? prev - 1 : prev + 1));
                    }}
                    className={`flex items-center justify-center gap-1.5 px-3 py-1.5 min-h-[32px] rounded-full transition-colors cursor-pointer select-none ${
                      demoLike
                        ? 'border border-slate-900 bg-neutral-100/90 text-slate-900 shadow-2xs'
                        : 'hover:bg-neutral-100/80 active:bg-neutral-200/80 text-slate-700 hover:text-slate-900 border border-transparent'
                    }`}
                  >
                    <motion.div
                      animate={demoLike ? { scale: [1, 1.35, 0.95, 1], rotate: [0, -10, 10, 0] } : { scale: 1, rotate: 0 }}
                      transition={{ duration: 0.25, ease: 'easeOut' }}
                    >
                      <Heart
                        className={`w-4 h-4 stroke-[1.8] ${
                          demoLike ? 'fill-rose-500 text-rose-500 stroke-rose-500' : 'text-slate-700'
                        }`}
                      />
                    </motion.div>
                    <span className="font-medium text-[13px] tabular-nums">{demoLikeCount}</span>
                  </motion.button>
                )}
              </ShowcaseCard>

              {/* 2.4 Repost / Share Social Actions */}
              <ShowcaseCard
                id="btn-social-repost"
                title="Repost & Social Action Pills"
                category="Social Actions"
                description="Koleksi tombol interaksi sosial (Posting Ulang, Kirim/Share, dan Markah/Bookmark)."
                codeSnippet={`<div className="flex items-center gap-2">
  <button onClick={handleRepost} className="flex items-center gap-1 px-2.5 py-1 rounded-full hover:bg-neutral-100 text-slate-700">
    <Repeat2 className="w-4 h-4" />
    <span>{repostsCount}</span>
  </button>
</div>`}
                availableStates={['default']}
              >
                {() => (
                  <div className="flex items-center gap-3">
                    {/* Repost Button */}
                    <button
                      type="button"
                      onClick={() => {
                        triggerHaptic('medium');
                        setDemoRepost(!demoRepost);
                        setDemoRepostCount((prev) => (demoRepost ? prev - 1 : prev + 1));
                      }}
                      className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full transition-all cursor-pointer ${
                        demoRepost
                          ? 'border border-emerald-600 bg-emerald-50 text-emerald-700 font-semibold'
                          : 'hover:bg-neutral-100 text-slate-700 hover:text-slate-900'
                      }`}
                    >
                      <Repeat2 className="w-4 h-4 stroke-[1.8]" />
                      <span className="text-xs font-medium tabular-nums">{demoRepostCount}</span>
                    </button>

                    {/* Bookmark Button */}
                    <button
                      type="button"
                      onClick={() => {
                        triggerHaptic('light');
                        setDemoBookmark(!demoBookmark);
                        showToast(demoBookmark ? 'Dihapus dari Markah' : 'Disimpan ke Markah');
                      }}
                      className={`p-2 rounded-full transition-all cursor-pointer ${
                        demoBookmark
                          ? 'bg-blue-50 text-blue-600'
                          : 'hover:bg-neutral-100 text-slate-700'
                      }`}
                    >
                      {demoBookmark ? <BookmarkCheck className="w-4 h-4 stroke-[2]" /> : <Bookmark className="w-4 h-4 stroke-[1.8]" />}
                    </button>

                    {/* Share Button */}
                    <button
                      type="button"
                      onClick={() => {
                        triggerHaptic('light');
                        showToast('Native Share Sheet terbuka 📲');
                      }}
                      className="p-2 rounded-full hover:bg-neutral-100 text-slate-700 cursor-pointer"
                    >
                      <Send className="w-4 h-4 stroke-[1.8]" />
                    </button>

                    {/* More Options Button */}
                    <button
                      type="button"
                      onClick={() => {
                        triggerHaptic('light');
                        showToast('Modal Opsi dibuka');
                      }}
                      className="p-2 rounded-full hover:bg-neutral-100 text-slate-700 cursor-pointer"
                    >
                      <MoreHorizontal className="w-4 h-4 stroke-[1.8]" />
                    </button>
                  </div>
                )}
              </ShowcaseCard>

              {/* 2.5 Follow / Unfollow CTA Toggle */}
              <ShowcaseCard
                id="btn-follow"
                title="Follow / Unfollow Toggle CTA"
                category="Buttons"
                description="Tombol status mengikuti siswa atau penjual dengan transisi warna halus."
                codeSnippet={`<button
  onClick={() => setIsFollowing(!isFollowing)}
  className="relative flex items-center justify-center h-10 px-5 rounded-xl font-bold text-[14px]"
>
  {isFollowing ? 'Mengikuti' : 'Ikuti'}
</button>`}
                availableStates={['default']}
              >
                {() => (
                  <button
                    type="button"
                    onClick={() => {
                      triggerHaptic('medium');
                      setDemoFollow(!demoFollow);
                    }}
                    className={`relative flex items-center justify-center h-10 px-6 rounded-xl font-bold text-[14px] transition-all cursor-pointer select-none active:scale-95 ${
                      demoFollow
                        ? 'bg-white text-slate-800 border border-neutral-300 shadow-2xs hover:bg-neutral-50'
                        : 'bg-[#101010] text-white border border-black shadow-md shadow-black/20 hover:bg-black'
                    }`}
                  >
                    <span className="relative z-10 flex items-center gap-1.5">
                      {demoFollow ? <UserCheck className="w-4 h-4 stroke-[2.2]" /> : <UserPlus className="w-4 h-4 stroke-[2.2]" />}
                      <span>{demoFollow ? 'Mengikuti' : 'Ikuti'}</span>
                    </span>
                  </button>
                )}
              </ShowcaseCard>
            </div>
          )}

          {/* ================================================================= */}
          {/* SECTION 3: 📝 FORMS & INPUTS                                      */}
          {/* ================================================================= */}
          {activeSection === 'inputs' && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* 3.1 Search Input Bar */}
              <ShowcaseCard
                id="input-search"
                title="Modern Search Input"
                category="Forms"
                description="Kolom pencarian responsif dengan ikon kaca pembesar dan tombol reset cepat."
                codeSnippet={`<div className="relative w-full">
  <Search className="w-4 h-4 text-neutral-400 absolute left-3.5 top-1/2 -translate-y-1/2" />
  <input
    type="text"
    placeholder="Cari produk atau akun siswa..."
    className="w-full pl-10 pr-9 py-2 rounded-xl bg-neutral-100 border border-neutral-200/80 text-sm focus:bg-white focus:outline-none focus:ring-2 focus:ring-slate-900/10"
  />
</div>`}
                availableStates={['default', 'focus', 'disabled']}
              >
                {(st) => (
                  <div className="relative w-full max-w-sm">
                    <Search className="w-4 h-4 text-neutral-400 absolute left-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
                    <input
                      type="text"
                      disabled={st === 'disabled'}
                      value={demoSearch}
                      onChange={(e) => setDemoSearch(e.target.value)}
                      placeholder="Cari produk atau akun siswa..."
                      className={`w-full pl-10 pr-9 py-2 text-sm rounded-xl transition-all ${
                        st === 'disabled'
                          ? 'bg-neutral-100 text-neutral-400 border border-neutral-200 cursor-not-allowed'
                          : st === 'focus'
                          ? 'bg-white border-slate-900 ring-2 ring-slate-900/10'
                          : 'bg-neutral-100/90 border border-neutral-200/80 focus:bg-white focus:outline-none focus:ring-2 focus:ring-slate-900/10'
                      }`}
                    />
                    {demoSearch.length > 0 && st !== 'disabled' && (
                      <button
                        type="button"
                        onClick={() => setDemoSearch('')}
                        className="absolute right-3 top-1/2 -translate-y-1/2 text-neutral-400 hover:text-slate-600 p-0.5 cursor-pointer"
                      >
                        <X className="w-3.5 h-3.5" />
                      </button>
                    )}
                  </div>
                )}
              </ShowcaseCard>

              {/* 3.2 Quantity Selector */}
              <ShowcaseCard
                id="input-quantity"
                title="Product Quantity Selector"
                category="Forms"
                description="Kontrol penambah dan pengurang jumlah barang dengan proteksi batas stok."
                codeSnippet={`<QuantitySelector
  quantity={quantity}
  max={10}
  onDecrease={() => setQuantity(q => Math.max(1, q - 1))}
  onIncrease={() => setQuantity(q => Math.min(10, q + 1))}
/>`}
                availableStates={['default']}
              >
                {() => (
                  <QuantitySelector
                    quantity={demoQuantity}
                    max={10}
                    onDecrease={() => {
                      triggerHaptic('selection');
                      setDemoQuantity((q) => Math.max(1, q - 1));
                    }}
                    onIncrease={() => {
                      triggerHaptic('selection');
                      setDemoQuantity((q) => Math.min(10, q + 1));
                    }}
                  />
                )}
              </ShowcaseCard>

              {/* 3.3 FormattedText Auto Hashtag & URL Highlighter */}
              <ShowcaseCard
                id="input-formatted-text"
                title="FormattedText (Hashtags & Mentions)"
                category="Typography & Input"
                description="Parser teks yang secara otomatis mewarnai hashtag #snapan dan mention @user."
                codeSnippet={`<FormattedText text="Halo semua! Cek produk kami di #snapan @radityarayhannnn" />`}
                availableStates={['default']}
              >
                {() => (
                  <div className="p-4 rounded-xl bg-neutral-50 border border-neutral-200/80 text-sm max-w-sm">
                    <FormattedText text="Ready stok Hoodie XII PPLG 1! Hubungi @radityarayhannnn di #KantinBelakang #SnapanMarket 🔥" />
                  </div>
                )}
              </ShowcaseCard>

              {/* 3.4 2-Tab Sliding Switcher */}
              <ShowcaseCard
                id="tab-switcher-2"
                title="2-Tab Sliding Switcher (Feed)"
                category="Navigation"
                description="Tab pengalih 'Untuk Anda' & 'Terbaru' dengan sliding underline bar."
                codeSnippet={`<div className="max-w-xl mx-auto flex items-center relative border-b border-neutral-200/80">
  <div className="absolute bottom-0 left-0 w-1/2 h-[2px] bg-slate-900 transition-transform duration-200" />
  <button onClick={() => setTab('for-you')}>Untuk Anda</button>
  <button onClick={() => setTab('latest')}>Terbaru</button>
</div>`}
                availableStates={['default']}
              >
                {() => (
                  <div className="w-full max-w-sm border-b border-neutral-200/80 bg-white select-none">
                    <div className="flex items-center relative">
                      <div
                        className={`absolute bottom-0 left-0 w-1/2 h-[2px] bg-slate-900 transition-transform duration-200 ${
                          demoTab2 === 'for-you' ? 'translate-x-0' : 'translate-x-full'
                        }`}
                      />
                      <button
                        type="button"
                        onClick={() => {
                          triggerHaptic('selection');
                          setDemoTab2('for-you');
                        }}
                        className={`flex-1 py-2.5 text-xs text-center cursor-pointer transition-colors ${
                          demoTab2 === 'for-you' ? 'text-slate-900 font-bold' : 'text-neutral-400 font-medium'
                        }`}
                      >
                        Untuk Anda
                      </button>
                      <button
                        type="button"
                        onClick={() => {
                          triggerHaptic('selection');
                          setDemoTab2('latest');
                        }}
                        className={`flex-1 py-2.5 text-xs text-center cursor-pointer transition-colors ${
                          demoTab2 === 'latest' ? 'text-slate-900 font-bold' : 'text-neutral-400 font-medium'
                        }`}
                      >
                        Terbaru
                      </button>
                    </div>
                  </div>
                )}
              </ShowcaseCard>

              {/* 3.5 3-Tab Sliding Switcher */}
              <ShowcaseCard
                id="tab-switcher-3"
                title="3-Tab Sliding Switcher (Profile)"
                category="Navigation"
                description="Tab pengalih profil 'Utas', 'Balasan', dan 'Media' dengan smooth sliding bar."
                codeSnippet={`<div className="w-full flex items-center relative border-b">
  <div className="absolute bottom-0 w-1/3 h-[2px] bg-slate-900 transition-transform" />
  <button onClick={() => setTab('threads')}>Utas</button>
  <button onClick={() => setTab('replies')}>Balasan</button>
  <button onClick={() => setTab('media')}>Media</button>
</div>`}
                availableStates={['default']}
              >
                {() => (
                  <div className="w-full max-w-sm border-b border-neutral-200/80 bg-white select-none">
                    <div className="flex items-center relative">
                      <div
                        className={`absolute bottom-0 left-0 w-1/3 h-[2px] bg-slate-900 transition-transform duration-200 ${
                          demoTab3 === 'threads'
                            ? 'translate-x-0'
                            : demoTab3 === 'replies'
                            ? 'translate-x-full'
                            : 'translate-x-[200%]'
                        }`}
                      />
                      <button
                        type="button"
                        onClick={() => {
                          triggerHaptic('selection');
                          setDemoTab3('threads');
                        }}
                        className={`flex-1 py-2.5 text-xs text-center cursor-pointer transition-colors ${
                          demoTab3 === 'threads' ? 'text-slate-900 font-bold' : 'text-neutral-400 font-medium'
                        }`}
                      >
                        Utas
                      </button>
                      <button
                        type="button"
                        onClick={() => {
                          triggerHaptic('selection');
                          setDemoTab3('replies');
                        }}
                        className={`flex-1 py-2.5 text-xs text-center cursor-pointer transition-colors ${
                          demoTab3 === 'replies' ? 'text-slate-900 font-bold' : 'text-neutral-400 font-medium'
                        }`}
                      >
                        Balasan
                      </button>
                      <button
                        type="button"
                        onClick={() => {
                          triggerHaptic('selection');
                          setDemoTab3('media');
                        }}
                        className={`flex-1 py-2.5 text-xs text-center cursor-pointer transition-colors ${
                          demoTab3 === 'media' ? 'text-slate-900 font-bold' : 'text-neutral-400 font-medium'
                        }`}
                      >
                        Media
                      </button>
                    </div>
                  </div>
                )}
              </ShowcaseCard>
            </div>
          )}

          {/* ================================================================= */}
          {/* SECTION 4: 🏷️ BADGES & INDICATORS                                 */}
          {/* ================================================================= */}
          {activeSection === 'badges' && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* 4.1 Verified Seller Badge */}
              <ShowcaseCard
                id="badge-verified"
                title="Clickable Verified Seller Badge"
                category="Badges"
                description="Lencana centang biru resmi yang dapat diklik untuk membuka modal verifikasi penjual."
                codeSnippet={`<ClickableVerifiedBadge sellerName="Raditya Rayhan" className="w-5 h-5" />`}
                availableStates={['default']}
              >
                {() => (
                  <div className="flex items-center gap-3">
                    <ClickableVerifiedBadge sellerName="Raditya Rayhan" className="w-5 h-5" />
                    <span className="text-xs font-semibold text-slate-900">Penjual Terverifikasi Snapan</span>
                  </div>
                )}
              </ShowcaseCard>

              {/* 4.2 Official Topic Pill Tag */}
              <ShowcaseCard
                id="badge-topic"
                title="Official Topic Pill Tag"
                category="Badges"
                description="Tag topik resmi Threads dengan chevron arrow dan icon khusus party-popper."
                codeSnippet={`<div className="flex items-center gap-1 text-[#1d64ec] font-semibold text-sm">
  <ChevronRight className="w-3.5 h-3.5 text-neutral-400" />
  <PartyPopper className="w-3.5 h-3.5" />
  <span>Pentas Seni 2026</span>
</div>`}
                availableStates={['default']}
              >
                {() => (
                  <div className="flex items-center gap-1 text-[#1d64ec] font-semibold text-xs bg-blue-50/80 px-3 py-1.5 rounded-full border border-blue-200">
                    <ChevronRight className="w-3.5 h-3.5 text-blue-400 stroke-[2]" />
                    <PartyPopper className="w-3.5 h-3.5 stroke-[2.2]" />
                    <span>Pentas Seni 2026</span>
                  </div>
                )}
              </ShowcaseCard>

              {/* 4.3 Stock Counter Pill */}
              <ShowcaseCard
                id="badge-stock"
                title="Stock Counter Pill"
                category="Badges"
                description="Lencana penunjuk sisa stok produk toko sekolah."
                codeSnippet={`<div className="inline-flex items-center gap-1 px-2.5 py-1 text-neutral-600 bg-neutral-100 border border-neutral-200/60 rounded-full text-xs font-semibold">
  <Box className="w-3.5 h-3.5 text-neutral-500" />
  <span>5 item</span>
</div>`}
                availableStates={['default']}
              >
                {() => (
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 text-neutral-700 bg-neutral-100 border border-neutral-200/80 rounded-full text-xs font-semibold">
                    <Box className="w-3.5 h-3.5 text-neutral-500 stroke-[2]" />
                    <span>Sisa 5 item</span>
                  </div>
                )}
              </ShowcaseCard>

              {/* 4.4 Star Rating Stars */}
              <ShowcaseCard
                id="badge-rating"
                title="Star Rating Component"
                category="Badges"
                description="Indikator bintang kepuasan pembeli dan ulasan produk."
                codeSnippet={`<div className="flex items-center gap-1 text-amber-500 text-xs font-bold">
  <Star className="w-4 h-4 fill-amber-400 text-amber-400" />
  <span className="text-slate-900">4.9</span>
  <span className="text-neutral-400 font-normal">(18 ulasan)</span>
</div>`}
                availableStates={['default']}
              >
                {() => (
                  <div className="flex items-center gap-1.5 text-amber-500 text-sm font-bold">
                    <Star className="w-4 h-4 fill-amber-400 text-amber-400" />
                    <span className="text-slate-900 font-bold">4.9</span>
                    <span className="text-neutral-400 font-normal text-xs">(18 ulasan)</span>
                  </div>
                )}
              </ShowcaseCard>

              {/* 4.5 Topic & Interest Badges */}
              <ShowcaseCard
                id="badge-tags"
                title="Interest & Skill Tags"
                category="Badges"
                description="Pill label minat kejuruan siswa (PPLG, Desain Grafis, Animasi)."
                codeSnippet={`<div className="inline-flex items-center py-1 px-3 bg-neutral-100 text-slate-800 text-[13px] font-medium rounded-full border border-neutral-200 shadow-2xs">
  <span>PPLG</span>
</div>`}
                availableStates={['default']}
              >
                {() => (
                  <div className="flex flex-wrap gap-2">
                    {['PPLG', 'Desain Grafis', 'UI/UX', 'Animasi 3D'].map((t) => (
                      <span
                        key={t}
                        className="inline-flex items-center py-1 px-3 bg-neutral-100 hover:bg-neutral-200/70 text-slate-800 text-xs font-medium rounded-full border border-neutral-200/80 shadow-2xs cursor-pointer"
                      >
                        {t}
                      </span>
                    ))}
                  </div>
                )}
              </ShowcaseCard>
            </div>
          )}

          {/* ================================================================= */}
          {/* SECTION 5: 🃏 CARDS & FEEDS                                       */}
          {/* ================================================================= */}
          {activeSection === 'cards' && (
            <div className="space-y-8">
              {/* 5.1 ProgressiveImage Shimmer Simulator */}
              <ShowcaseCard
                id="card-progressive-image"
                title="ProgressiveImage (Anti-Layout Shift & Fade-In)"
                category="Media"
                description="Komponen gambar dengan placeholder gradien shimmer dan animasi fade-in 300ms."
                codeSnippet={`<ProgressiveImage
  src="https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=600&q=80"
  alt="Sample Preview"
  className="w-full h-full object-cover"
  containerClassName="w-64 h-48 rounded-[18px]"
/>`}
                availableStates={['default']}
              >
                {() => (
                  <div className="flex flex-col items-center gap-3">
                    <div className="w-64 h-48 rounded-[18px] overflow-hidden border border-black/10 shadow-2xs">
                      <ProgressiveImage
                        key={imageReloadKey}
                        src="https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=600&q=80"
                        alt="Laptop coding"
                        className="w-full h-full object-cover"
                      />
                    </div>
                    <button
                      type="button"
                      onClick={() => {
                        triggerHaptic('light');
                        setImageReloadKey((k) => k + 1);
                      }}
                      className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl border border-neutral-300 bg-white hover:bg-neutral-50 text-slate-700 text-xs font-semibold shadow-2xs cursor-pointer"
                    >
                      <RefreshCw className="w-3.5 h-3.5" />
                      <span>Uji Ulang Animasi Shimmer</span>
                    </button>
                  </div>
                )}
              </ShowcaseCard>

              {/* 5.2 MarketPostCard Live Feed Item */}
              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <h4 className="font-bold text-sm text-slate-900">
                    Live Feed Post Card (`MarketPostCard`)
                  </h4>
                  <span className="text-xs text-neutral-500 font-mono">Mobile Viewport Simulation (390px)</span>
                </div>
                <div className="max-w-[420px] mx-auto bg-white rounded-3xl border border-neutral-200 shadow-xl overflow-hidden">
                  <MarketPostCard item={MOCK_MARKET_POSTS[0]} />
                </div>
              </div>
            </div>
          )}
        </div>
      </main>
    </div>
  );
};
