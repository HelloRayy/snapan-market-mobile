import React, { useState } from 'react';
import {
  Download,
  Share2,
  CheckCircle2,
  ArrowRight,
  ShieldCheck,
  Zap,
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
  TrendingUp,
  BarChart3,
  MousePointerClick,
  Smartphone,
  Laptop,
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
      q: 'Is Snapan Market free for all SMKN 8 students?',
      a: 'Yes, 100% free! There are zero subscription fees, zero transaction fees, and zero hidden costs for students and teachers of SMKN 8 Jakarta.',
    },
    {
      q: 'How does campus COD (Cash On Delivery) work?',
      a: 'When ordering an item or service, you and the seller choose an official school meeting point (such as Kantin Belakang, Lab PPLG, Lapangan, or Perpustakaan) during recess or after school.',
    },
    {
      q: 'Why is it delivered as a Progressive Web App (PWA)?',
      a: 'PWAs offer instantaneous 1-tap installation without needing app store downloads, take up virtually zero storage (<3MB), work offline with 0ms cache, and run at a silky smooth 120 FPS.',
    },
    {
      q: 'Can I sell vocational projects and creative work?',
      a: 'Absolutely! PPLG students can sell coding templates & websites, DKV students can offer graphic design & merchandise, and Culinary students can sell bakery & snacks.',
    },
  ];

  return (
    <div className="min-h-screen w-full bg-[#fafafc] text-slate-950 font-gt-standard select-none overflow-x-hidden antialiased selection:bg-[#1d64ec] selection:text-white">
      
      {/* =========================================================================
          1. EXACT POP.SITE FLOATING PILL NAVBAR
      ========================================================================= */}
      <div className="fixed top-3 sm:top-5 inset-x-0 z-50 flex justify-center px-3 pointer-events-none">
        <header className="pointer-events-auto w-full max-w-5xl bg-white/85 backdrop-blur-xl border border-neutral-200/80 rounded-full px-4 sm:px-6 py-2.5 shadow-[0_8px_30px_rgba(0,0,0,0.06)] flex items-center justify-between transition-all">
          {/* Logo & Brand Tag */}
          <div className="flex items-center gap-2.5 cursor-pointer" onClick={handleProceed}>
            <div className="h-7 w-7 rounded-lg bg-[#000000] text-white flex items-center justify-center font-black text-xs shadow-xs">
              S8
            </div>
            <div className="flex items-center gap-1.5">
              <span className="font-extrabold text-[15px] text-slate-950 tracking-tight">
                pop.site
              </span>
              <span className="text-[10.5px] font-semibold text-[#1d64ec] bg-blue-50 px-2 py-0.5 rounded-full border border-blue-100/70">
                snapan.site
              </span>
            </div>
          </div>

          {/* Desktop Navigation Links */}
          <nav className="hidden md:flex items-center gap-7 text-[13px] font-medium text-neutral-600">
            <a href="#features" className="hover:text-slate-950 transition-colors">Pricing</a>
            <a href="#features" className="hover:text-slate-950 transition-colors">Sections</a>
            <a href="#themes" className="hover:text-slate-950 transition-colors">Featured</a>
            <a href="#analytics" className="hover:text-slate-950 transition-colors">Memberships</a>
          </nav>

          {/* Right Action Buttons */}
          <div className="flex items-center gap-2">
            <button
              type="button"
              onClick={handleProceed}
              className="text-xs font-semibold text-neutral-700 hover:text-slate-950 px-3 py-1.5 cursor-pointer transition-colors"
            >
              Log In
            </button>

            <button
              type="button"
              onClick={handleInstallClick}
              className="flex items-center gap-1.5 px-4 py-1.5 rounded-full bg-[#000000] hover:bg-[#1a1a1a] active:scale-95 text-white text-xs font-bold shadow-xs transition-all cursor-pointer"
            >
              <span>Create Account</span>
            </button>
          </div>
        </header>
      </div>

      {/* =========================================================================
          2. EXACT POP.SITE HERO SECTION
      ========================================================================= */}
      <section className="pt-28 sm:pt-36 pb-16 px-4 sm:px-6 max-w-5xl mx-auto text-center space-y-7">
        
        {/* Social Proof Pill Badge */}
        <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white border border-neutral-200 shadow-2xs text-xs font-semibold text-slate-800 animate-in fade-in zoom-in-95 duration-500">
          <div className="flex -space-x-1.5 items-center">
            <img src="https://framerusercontent.com/images/faaNGs13tJFdVwu9AmLhWZQ4iKY.png" alt="Avatar" className="w-5 h-5 rounded-full border border-white object-cover" />
            <img src="https://framerusercontent.com/images/dvasWTfovyZZuh8eTWbsvvQw80U.png" alt="Avatar" className="w-5 h-5 rounded-full border border-white object-cover" />
            <img src="https://framerusercontent.com/images/SOnU8rT2yRS5jR2ov0U1eC6T0.png" alt="Avatar" className="w-5 h-5 rounded-full border border-white object-cover" />
          </div>
          <span>Join 10K+ Site Makers</span>
        </div>

        {/* Master Headline (Satoshi + Instrument Serif Italic) */}
        <div className="space-y-3 max-w-3xl mx-auto">
          <h1 className="text-4xl sm:text-6xl md:text-7xl font-black text-slate-950 tracking-tight leading-[1.06]">
            The site builder with <br className="hidden sm:inline" />
            <span className="font-serif italic font-normal text-[#1d64ec]">zero learning curve.</span>
          </h1>
          <p className="text-base sm:text-lg text-slate-600 font-normal leading-relaxed max-w-xl mx-auto pt-1">
            Launch a site that actually looks pro, from your phone or desktop. Pasar digital & forum resmi warga SMKN 8 Jakarta.
          </p>
        </div>

        {/* Interactive Claim & Install Input Bar */}
        <div className="pt-2 max-w-lg mx-auto">
          <form onSubmit={handleClaim} className="flex items-center bg-white border border-neutral-200/90 rounded-2xl sm:rounded-full p-1.5 shadow-[0_10px_30px_rgba(0,0,0,0.05)] focus-within:border-[#1d64ec] focus-within:ring-2 focus-within:ring-blue-100 transition-all">
            <div className="flex items-center pl-4 pr-1 flex-1 min-w-0 text-slate-900">
              <input
                type="text"
                value={claimUsername}
                onChange={(e) => setClaimUsername(e.target.value)}
                placeholder="yourname"
                className="w-full bg-transparent px-1 py-2 text-sm font-semibold text-slate-900 placeholder:text-neutral-300 focus:outline-none"
              />
              <span className="text-xs font-mono text-neutral-400 font-medium">.pop.site</span>
            </div>

            <button
              type="submit"
              className="h-10 sm:h-11 px-5 sm:px-6 rounded-xl sm:rounded-full bg-[#000000] hover:bg-[#1a1a1a] active:scale-95 text-white font-bold text-xs sm:text-sm shadow-xs flex items-center justify-center gap-1.5 transition-all shrink-0 cursor-pointer"
            >
              <span>Claim your pop.site</span>
            </button>
          </form>

          {/* Micro Guarantee Copy */}
          <div className="pt-3 flex items-center justify-center gap-4 text-xs text-neutral-500 font-medium">
            <span>No credit card required to start</span>
            <span>·</span>
            <span>There's no complex editor to learn</span>
            <span>·</span>
            <span>Go live in minutes, not weeks</span>
          </div>
        </div>

        {/* =========================================================================
            3. EXACT POP.SITE HERO PREVIEW SHOWCASE (Django Degree Testimonial)
        ========================================================================= */}
        <div className="pt-8 max-w-4xl mx-auto">
          <div className="relative bg-white border border-neutral-200/90 rounded-3xl p-4 sm:p-8 shadow-[0_24px_60px_rgba(0,0,0,0.06)] overflow-hidden text-left space-y-6">
            
            {/* Top Browser Bar */}
            <div className="flex items-center justify-between pb-4 border-b border-neutral-100">
              <div className="flex items-center gap-2">
                <span className="w-3 h-3 rounded-full bg-neutral-200" />
                <span className="w-3 h-3 rounded-full bg-neutral-200" />
                <span className="w-3 h-3 rounded-full bg-neutral-200" />
              </div>
              <div className="flex items-center gap-1 px-4 py-1 rounded-md bg-neutral-50 text-xs font-mono text-neutral-400 border border-neutral-100">
                <span>django.pop.site</span>
              </div>
              <div className="w-10" />
            </div>

            {/* Showcase Grid: Left Phone Card, Right Testimonial */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 items-center">
              
              {/* Django Profile Card */}
              <div className="p-6 rounded-2xl bg-neutral-50/80 border border-neutral-100 space-y-4">
                <div className="flex items-center gap-3.5">
                  <img
                    src="https://framerusercontent.com/images/KqkGbSLtwSpCaNdUkG8IFD3kNoA.jpg?width=300&height=300"
                    alt="Django Degree"
                    className="w-14 h-14 rounded-full object-cover ring-2 ring-white shadow-xs"
                  />
                  <div>
                    <div className="flex items-center gap-1.5">
                      <h3 className="text-base font-bold text-slate-950">Django Degree</h3>
                      <span className="w-4 h-4 rounded-full bg-[#1d64ec] text-white flex items-center justify-center text-[9px] font-bold">✓</span>
                    </div>
                    <p className="text-xs text-neutral-500 font-mono">django.pop.site</p>
                    <span className="inline-block mt-1 text-[11px] font-bold text-slate-900 bg-white px-2 py-0.5 rounded-full border border-neutral-200/70">
                      102K Followers
                    </span>
                  </div>
                </div>

                <p className="text-xs text-slate-600 leading-relaxed font-normal">
                  Creator & Product Designer. Sharing daily design insights, templates, and digital school supplies.
                </p>

                {/* Quick Action Buttons */}
                <div className="space-y-2 pt-2">
                  <div className="p-3 rounded-xl bg-white border border-neutral-200/70 flex items-center justify-between text-xs font-bold text-slate-900 hover:border-neutral-300 transition-colors">
                    <div className="flex items-center gap-2">
                      <ShoppingBag className="w-4 h-4 text-[#1d64ec]" />
                      <span>Kalkulator Casio FX-991EX (Preloved)</span>
                    </div>
                    <span>Rp 185K</span>
                  </div>
                  <div className="p-3 rounded-xl bg-white border border-neutral-200/70 flex items-center justify-between text-xs font-bold text-slate-900 hover:border-neutral-300 transition-colors">
                    <div className="flex items-center gap-2">
                      <Zap className="w-4 h-4 text-emerald-600" />
                      <span>Template Landing Page PJBL Vokasi</span>
                    </div>
                    <span>Rp 35K</span>
                  </div>
                </div>
              </div>

              {/* Right Big Quote Card */}
              <div className="p-6 sm:p-8 rounded-2xl bg-[#000000] text-white space-y-4">
                <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/10 text-xs font-semibold text-blue-200">
                  <Star className="w-3.5 h-3.5 fill-blue-400 text-blue-400" />
                  <span>Featured Creator</span>
                </div>
                <blockquote className="text-xl sm:text-2xl font-serif italic text-white/95 leading-snug">
                  "My site was done before I finished my coffee. I now get over 100K visitors a month to my Pop Site."
                </blockquote>
                <p className="text-xs text-neutral-400 font-mono">
                  Django Degree · django.pop.site
                </p>
              </div>

            </div>

          </div>
        </div>
      </section>

      {/* =========================================================================
          4. EXACT POP.SITE SECTION: AUTOMATED SEO, DOMAINS & METADATA
      ========================================================================= */}
      <section id="features" className="py-16 px-4 sm:px-6 max-w-5xl mx-auto space-y-12">
        <div className="text-center space-y-3 max-w-2xl mx-auto">
          <span className="text-xs font-bold text-[#1d64ec] uppercase tracking-wider bg-blue-50 px-3 py-1 rounded-full border border-blue-100">
            New Automated
          </span>
          <h2 className="text-3xl sm:text-5xl font-black text-slate-950 tracking-tight leading-tight">
            SEO automated. Domains included. <br />
            <span className="font-serif italic font-normal text-[#1d64ec]">Metadata handled.</span>
          </h2>
          <p className="text-sm sm:text-base text-slate-600">
            Pop Site automates everything for you. Zero maintenance, zero manual configuration.
          </p>
        </div>

        {/* Bento Grid 3 Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          
          {/* Bento 1: SEO is automated */}
          <div className="p-7 rounded-3xl bg-white border border-neutral-200/90 shadow-2xs space-y-4">
            <div className="w-10 h-10 rounded-2xl bg-blue-50 text-[#1d64ec] flex items-center justify-center">
              <Search className="w-5 h-5" />
            </div>
            <h3 className="text-lg font-bold text-slate-950">SEO is automated</h3>
            <p className="text-xs sm:text-sm text-slate-600 leading-relaxed font-normal">
              Your site's SEO is handled automatically by Pop Site. Structured markup and indexing ready out-of-the-box.
            </p>
          </div>

          {/* Bento 2: Domains are included */}
          <div className="p-7 rounded-3xl bg-white border border-neutral-200/90 shadow-2xs space-y-4">
            <div className="w-10 h-10 rounded-2xl bg-purple-50 text-purple-600 flex items-center justify-center">
              <Globe className="w-5 h-5" />
            </div>
            <h3 className="text-lg font-bold text-slate-950">Domains are included</h3>
            <p className="text-xs sm:text-sm text-slate-600 leading-relaxed font-normal">
              You get a free Pop Site domain, or easily connect your own custom school domain in just one click.
            </p>
          </div>

          {/* Bento 3: Metadata is handled */}
          <div className="p-7 rounded-3xl bg-white border border-neutral-200/90 shadow-2xs space-y-4">
            <div className="w-10 h-10 rounded-2xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <ShieldCheck className="w-5 h-5" />
            </div>
            <h3 className="text-lg font-bold text-slate-950">Metadata is handled</h3>
            <p className="text-xs sm:text-sm text-slate-600 leading-relaxed font-normal">
              Your metadata and OpenGraph social preview tags are automatically created and updated for you.
            </p>
          </div>

        </div>

        {/* Large Responsive Preview Card (Exact Pop.site WYeXLQfd4HWciZeQrD0RgF5V8Dw.png mockup) */}
        <div className="p-6 sm:p-10 rounded-3xl bg-white border border-neutral-200/90 shadow-2xs space-y-6 text-center">
          <div className="max-w-md mx-auto space-y-2">
            <h3 className="text-2xl font-bold text-slate-950">Desktop & mobile views</h3>
            <p className="text-xs sm:text-sm text-slate-600">
              Pop Sites are automatically responsive across all devices with instant PWA capabilities.
            </p>
          </div>

          <div className="relative rounded-2xl overflow-hidden border border-neutral-100 bg-neutral-50 shadow-inner">
            <img
              src="https://framerusercontent.com/images/WYeXLQfd4HWciZeQrD0RgF5V8Dw.png?width=2648&height=1994"
              alt="Desktop and mobile responsive view"
              className="w-full h-auto object-cover max-h-[420px]"
            />
          </div>
        </div>
      </section>

      {/* =========================================================================
          5. EXACT POP.SITE SECTION: BUILT-IN ANALYTICS
      ========================================================================= */}
      <section id="analytics" className="py-16 px-4 sm:px-6 max-w-5xl mx-auto space-y-12">
        <div className="text-center space-y-3 max-w-2xl mx-auto">
          <span className="text-xs font-bold text-[#1d64ec] uppercase tracking-wider bg-blue-50 px-3 py-1 rounded-full border border-blue-100">
            Included on Pro
          </span>
          <h2 className="text-3xl sm:text-5xl font-black text-slate-950 tracking-tight leading-tight">
            Built-in Analytics that go beyond <br />
            <span className="font-serif italic font-normal text-[#1d64ec]">what others offer.</span>
          </h2>
          <p className="text-sm sm:text-base text-slate-600">
            Advanced UTM campaign tracking, live visitor alerts, and device telemetry.
          </p>
        </div>

        {/* Analytics Image Showcase */}
        <div className="relative rounded-3xl bg-[#000000] p-6 sm:p-10 border border-neutral-800 shadow-2xl text-white overflow-hidden space-y-8">
          <div className="absolute top-0 right-0 w-96 h-96 bg-blue-500/20 rounded-full blur-3xl pointer-events-none" />

          {/* Feature List Chips */}
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-6 gap-3 text-center">
            <div className="p-3 rounded-2xl bg-white/5 border border-white/10 text-xs font-semibold">
              Track button clicks
            </div>
            <div className="p-3 rounded-2xl bg-white/5 border border-white/10 text-xs font-semibold">
              Get live alerts
            </div>
            <div className="p-3 rounded-2xl bg-white/5 border border-white/10 text-xs font-semibold">
              UTM tracking
            </div>
            <div className="p-3 rounded-2xl bg-white/5 border border-white/10 text-xs font-semibold">
              Device analytics
            </div>
            <div className="p-3 rounded-2xl bg-white/5 border border-white/10 text-xs font-semibold">
              Referral sources
            </div>
            <div className="p-3 rounded-2xl bg-white/5 border border-white/10 text-xs font-semibold">
              Geo intelligence
            </div>
          </div>

          {/* Exact Analytics Screenshot from Pop.site */}
          <div className="rounded-2xl overflow-hidden border border-white/10 shadow-2xl">
            <img
              src="https://framerusercontent.com/images/pcuazrEIpAoQPBPbCjblc9C1YJY.png?width=1280&height=720"
              alt="Pop Site Analytics Dashboard"
              className="w-full h-auto object-cover"
            />
          </div>
        </div>
      </section>

      {/* =========================================================================
          6. EXACT POP.SITE SECTION: THEMES THAT LOOK DESIGNER-MADE
      ========================================================================= */}
      <section id="themes" className="py-16 px-4 sm:px-6 max-w-5xl mx-auto space-y-12">
        <div className="text-center space-y-3 max-w-2xl mx-auto">
          <span className="text-xs font-bold text-[#1d64ec] uppercase tracking-wider bg-blue-50 px-3 py-1 rounded-full border border-blue-100">
            New Themes
          </span>
          <h2 className="text-3xl sm:text-5xl font-black text-slate-950 tracking-tight leading-tight">
            Themes that look <br />
            <span className="font-serif italic font-normal text-[#1d64ec]">designer-made.</span>
          </h2>
          <p className="text-sm sm:text-base text-slate-600">
            New themes added monthly. Everything is pre-built — just customize and launch.
          </p>
        </div>

        {/* Gallery Grid of Pop.site Themes */}
        <div className="grid grid-cols-2 md:grid-cols-3 gap-4 sm:gap-6">
          <div className="rounded-2xl overflow-hidden border border-neutral-200/90 bg-white shadow-2xs hover:shadow-md transition-all group cursor-pointer">
            <img src="https://framerusercontent.com/images/jvWQK1OAcvujJal5mRbPS1GGzuI.jpg?scale-down-to=512&width=1920&height=1440" alt="Theme 1" className="w-full h-48 sm:h-64 object-cover group-hover:scale-105 transition-transform duration-500" />
            <div className="p-3.5 text-xs font-bold text-slate-900 flex justify-between items-center">
              <span>Minimalist Portfolio</span>
              <ArrowUpRight className="w-3.5 h-3.5 text-neutral-400" />
            </div>
          </div>

          <div className="rounded-2xl overflow-hidden border border-neutral-200/90 bg-white shadow-2xs hover:shadow-md transition-all group cursor-pointer">
            <img src="https://framerusercontent.com/images/4cRxw5WzNfrPAjGUiEtbGYKewQw.jpg?scale-down-to=512&width=1920&height=1440" alt="Theme 2" className="w-full h-48 sm:h-64 object-cover group-hover:scale-105 transition-transform duration-500" />
            <div className="p-3.5 text-xs font-bold text-slate-900 flex justify-between items-center">
              <span>Editorial Magazine</span>
              <ArrowUpRight className="w-3.5 h-3.5 text-neutral-400" />
            </div>
          </div>

          <div className="rounded-2xl overflow-hidden border border-neutral-200/90 bg-white shadow-2xs hover:shadow-md transition-all group cursor-pointer">
            <img src="https://framerusercontent.com/images/00EUntV8RMJM5PyskAclGChN9s8.jpg?scale-down-to=512&width=1920&height=1440" alt="Theme 3" className="w-full h-48 sm:h-64 object-cover group-hover:scale-105 transition-transform duration-500" />
            <div className="p-3.5 text-xs font-bold text-slate-900 flex justify-between items-center">
              <span>Creator Showcase</span>
              <ArrowUpRight className="w-3.5 h-3.5 text-neutral-400" />
            </div>
          </div>

          <div className="rounded-2xl overflow-hidden border border-neutral-200/90 bg-white shadow-2xs hover:shadow-md transition-all group cursor-pointer">
            <img src="https://framerusercontent.com/images/ANN0pcYUTu1irgW2Shitk6Y.jpg?scale-down-to=512&width=1920&height=1440" alt="Theme 4" className="w-full h-48 sm:h-64 object-cover group-hover:scale-105 transition-transform duration-500" />
            <div className="p-3.5 text-xs font-bold text-slate-900 flex justify-between items-center">
              <span>Digital Store</span>
              <ArrowUpRight className="w-3.5 h-3.5 text-neutral-400" />
            </div>
          </div>

          <div className="rounded-2xl overflow-hidden border border-neutral-200/90 bg-white shadow-2xs hover:shadow-md transition-all group cursor-pointer">
            <img src="https://framerusercontent.com/images/U7ONvjSO4tFRexJCBv69x0O7I.jpg?scale-down-to=512&width=1920&height=1440" alt="Theme 5" className="w-full h-48 sm:h-64 object-cover group-hover:scale-105 transition-transform duration-500" />
            <div className="p-3.5 text-xs font-bold text-slate-900 flex justify-between items-center">
              <span>Bento Personal Hub</span>
              <ArrowUpRight className="w-3.5 h-3.5 text-neutral-400" />
            </div>
          </div>

          <div className="rounded-2xl overflow-hidden border border-neutral-200/90 bg-white shadow-2xs hover:shadow-md transition-all group cursor-pointer">
            <img src="https://framerusercontent.com/images/FslHXXxXCDOMyOJzYO89SJJlvXA.jpg?scale-down-to=512&width=1920&height=1440" alt="Theme 6" className="w-full h-48 sm:h-64 object-cover group-hover:scale-105 transition-transform duration-500" />
            <div className="p-3.5 text-xs font-bold text-slate-900 flex justify-between items-center">
              <span>Dark Mode Tech</span>
              <ArrowUpRight className="w-3.5 h-3.5 text-neutral-400" />
            </div>
          </div>
        </div>
      </section>

      {/* =========================================================================
          7. FAQ ACCORDION (Exact pop.site FAQ)
      ========================================================================= */}
      <section className="py-16 px-4 sm:px-6 max-w-3xl mx-auto space-y-8">
        <div className="text-center space-y-2">
          <h2 className="text-3xl sm:text-4xl font-black text-slate-950 tracking-tight">
            Frequently Asked Questions
          </h2>
          <p className="text-sm text-slate-600">
            Everything you need to know about Pop Site & Snapan Market.
          </p>
        </div>

        <div className="space-y-3">
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
                  className="w-full px-6 py-5 flex items-center justify-between text-left font-bold text-sm text-slate-950 hover:text-[#1d64ec] transition-colors cursor-pointer"
                >
                  <span>{faq.q}</span>
                  {isOpen ? (
                    <ChevronUp className="w-4 h-4 text-neutral-400 shrink-0" />
                  ) : (
                    <ChevronDown className="w-4 h-4 text-neutral-400 shrink-0" />
                  )}
                </button>
                {isOpen && (
                  <div className="px-6 pb-5 text-xs sm:text-sm text-slate-600 font-normal leading-relaxed border-t border-neutral-100 pt-4">
                    {faq.a}
                  </div>
                )}
              </div>
            );
          })}
        </div>
      </section>

      {/* =========================================================================
          8. EXACT POP.SITE FINAL CTA CARD
      ========================================================================= */}
      <section className="py-16 px-4 sm:px-6 max-w-5xl mx-auto">
        <div className="p-8 sm:p-16 rounded-3xl bg-[#000000] text-white text-center space-y-7 shadow-2xl relative overflow-hidden">
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-blue-600/20 rounded-full blur-3xl pointer-events-none" />

          <div className="relative space-y-3 max-w-lg mx-auto">
            <h2 className="text-3xl sm:text-5xl font-black tracking-tight leading-tight">
              Get started with your <br />
              <span className="font-serif italic font-normal text-blue-400">Pop Site today.</span>
            </h2>
            <p className="text-xs sm:text-sm text-neutral-300 font-normal leading-relaxed">
              Launch your personal micro-site in minutes. No credit card required.
            </p>
          </div>

          <div className="relative max-w-md mx-auto">
            <form onSubmit={handleClaim} className="flex items-center bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl sm:rounded-full p-1.5 focus-within:border-white transition-all">
              <div className="flex items-center pl-4 pr-1 flex-1 min-w-0 text-white">
                <input
                  type="text"
                  value={claimUsername}
                  onChange={(e) => setClaimUsername(e.target.value)}
                  placeholder="yourname"
                  className="w-full bg-transparent px-1 py-2 text-sm font-semibold text-white placeholder:text-neutral-400 focus:outline-none"
                />
                <span className="text-xs font-mono text-neutral-300 font-medium">.pop.site</span>
              </div>

              <button
                type="submit"
                className="h-10 sm:h-11 px-5 sm:px-6 rounded-xl sm:rounded-full bg-white hover:bg-neutral-100 active:scale-95 text-slate-950 font-bold text-xs sm:text-sm shadow-xs flex items-center justify-center gap-1.5 transition-all shrink-0 cursor-pointer"
              >
                <span>Claim</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </button>
            </form>
          </div>
        </div>
      </section>

      {/* =========================================================================
          9. EXACT POP.SITE FOOTER
      ========================================================================= */}
      <footer className="border-t border-neutral-200/80 pt-12 pb-16 px-4 sm:px-6 max-w-5xl mx-auto text-xs text-neutral-500 space-y-8">
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-8 text-left">
          {/* Col 1 */}
          <div className="space-y-2 col-span-2 sm:col-span-1">
            <div className="flex items-center gap-2">
              <div className="h-6 w-6 rounded-md bg-black text-white flex items-center justify-center font-bold text-xs">
                S8
              </div>
              <span className="font-extrabold text-sm text-slate-950">pop.site</span>
            </div>
            <p className="text-[11.5px] text-neutral-400 leading-relaxed">
              The free personal site builder & linktree alternative.
            </p>
          </div>

          {/* Col 2 */}
          <div className="space-y-2">
            <h4 className="font-bold text-slate-900 text-xs">Product</h4>
            <ul className="space-y-1.5 text-[11.5px]">
              <li><a href="#features" className="hover:text-slate-950 transition-colors">Pricing</a></li>
              <li><a href="#features" className="hover:text-slate-950 transition-colors">Sections</a></li>
              <li><a href="#themes" className="hover:text-slate-950 transition-colors">Featured</a></li>
              <li><a href="#analytics" className="hover:text-slate-950 transition-colors">Memberships</a></li>
            </ul>
          </div>

          {/* Col 3 */}
          <div className="space-y-2">
            <h4 className="font-bold text-slate-900 text-xs">Features</h4>
            <ul className="space-y-1.5 text-[11.5px]">
              <li><span className="text-neutral-500">Automated SEO</span></li>
              <li><span className="text-neutral-500">Domains Included</span></li>
              <li><span className="text-neutral-500">Built-in Analytics</span></li>
              <li><span className="text-neutral-500">Designer Themes</span></li>
            </ul>
          </div>

          {/* Col 4 */}
          <div className="space-y-2">
            <h4 className="font-bold text-slate-900 text-xs">Ecosystem</h4>
            <ul className="space-y-1.5 text-[11.5px]">
              <li><span className="text-emerald-600 font-semibold">● All Systems Normal</span></li>
              <li><span>SMKN 8 Jakarta</span></li>
              <li><span>PWA Version 2.4</span></li>
            </ul>
          </div>
        </div>

        <div className="pt-6 border-t border-neutral-100 flex flex-col sm:flex-row items-center justify-between gap-3 text-[11px] text-neutral-400">
          <p>© 2026 Pop Site. All rights reserved. Powered by Snapan Market SMKN 8.</p>
          <p>Built with love for creators and students.</p>
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
