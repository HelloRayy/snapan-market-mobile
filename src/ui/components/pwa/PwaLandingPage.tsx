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
} from 'lucide-react';
import { usePWA } from '@/ui/hooks/usePWA';
import { CustomPwaInstallModal } from './CustomPwaInstallModal';
import { triggerHaptic } from '@/utils/haptics';

interface PwaLandingPageProps {
  onProceedToWeb?: () => void;
}

// Cubic bezier transition for fluid 120 FPS Framer Motion animations
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

  const themes = [
    { name: 'Minimalist Portfolio', img: '/pop-assets/theme-1.jpg', tag: 'Creator' },
    { name: 'Editorial Magazine', img: '/pop-assets/theme-2.jpg', tag: 'Writer' },
    { name: 'Creator Showcase', img: '/pop-assets/theme-3.jpg', tag: 'Artist' },
    { name: 'Digital Store', img: '/pop-assets/theme-4.jpg', tag: 'E-Commerce' },
    { name: 'Bento Personal Hub', img: '/pop-assets/theme-5.jpg', tag: 'Developer' },
    { name: 'Dark Mode Tech', img: '/pop-assets/theme-6.jpg', tag: 'Startup' },
  ];

  const prebuiltFeatures = [
    { title: 'Showcase links', desc: 'Put all your socials and links in a single place to make it easy for people to discover you.', icon: Globe },
    { title: 'Create Forms', desc: 'Capture inquiries with customizable forms to grow your business.', icon: FileText },
    { title: 'Sell Services', desc: 'Clearly display your services, pricing, and descriptions to attract more clients.', icon: Zap },
    { title: 'Display Your Skills', desc: 'Make it easy for people to see what you\'re skilled at, and why you stand out.', icon: Sparkles },
    { title: 'Share Your Resume', desc: 'Highlight your experience and expertise to win clients and job opportunities.', icon: CheckCircle2 },
    { title: 'Showcase Videos', desc: 'Feature one or more videos to engage visitors and increase conversions.', icon: Video },
    { title: 'Image Gallery', desc: 'Show the world your visual works and even add links to boost engagement.', icon: ImageIcon },
    { title: 'Sell With Shopify', desc: 'Powered by Shopify, connect your existing or new store to power shopping.', icon: ShoppingBag },
    { title: 'Share Socials', desc: 'Link everything in one place so visitors easily connect with your platforms.', icon: Share2 },
    { title: 'Display Projects', desc: 'Answer questions upfront to build trust and save time for you and customers.', icon: Layers },
    { title: 'Display Your Tech Stack', desc: 'Showcase the tools and tech you\'ve mastered and attract opportunities.', icon: Cpu },
    { title: 'Share Your Stats', desc: 'Display key business metrics to establish credibility and showcase success.', icon: BarChart3 },
    { title: 'Share Testimonials', desc: 'Build trust by showcasing real customer feedback and success stories.', icon: MessageSquare },
    { title: 'Create Text-Only Sections', desc: 'A text area to share anything about you, or even use as a title for other sections.', icon: FileText },
    { title: 'Plus tons more', desc: 'Custom buttons, newsletter embeds, Discord links, and rich widgets.', icon: Sparkles },
  ];

  const faqs = [
    {
      q: 'Is Pop Site really free?',
      a: 'Yes, Pop Site is completely free to use. You get a free .pop.site domain, hosting, and all core features without needing a credit card.',
    },
    {
      q: 'Can I connect a custom domain?',
      a: 'Yes! You can connect your own custom domain (e.g. yourname.com) easily through the settings dashboard with automatic SSL.',
    },
    {
      q: 'How does Pop Site compare to Linktree or Framer?',
      a: 'Pop Site is the perfect middle ground: richer and more professional than basic link-tree lists, yet with zero learning curve unlike complex website builders.',
    },
    {
      q: 'Is my site mobile and desktop responsive?',
      a: 'Yes, every Pop Site automatically adapts to mobile phones, tablets, and desktop screens with 120 FPS performance and PWA capabilities.',
    },
    {
      q: 'Can I sell digital products or physical goods?',
      a: 'Yes! Pop Site has built-in e-commerce support as well as deep integration with Shopify, Stripe, and COD meetups.',
    },
  ];

  return (
    <div className="min-h-screen w-full bg-[#fafafc] text-slate-950 font-gt-standard select-none overflow-x-hidden antialiased selection:bg-[#1d64ec] selection:text-white">
      
      {/* =========================================================================
          1. EXACT FLOATING PILL NAVBAR WITH ENTRANCE SPRING
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
              className="h-7 w-7 rounded-lg bg-[#000000] text-white flex items-center justify-center font-black text-xs shadow-xs"
            >
              P
            </motion.div>
            <span className="font-extrabold text-[15px] text-slate-950 tracking-tight">
              pop.site
            </span>
          </div>

          {/* Desktop Navigation Links */}
          <nav className="hidden md:flex items-center gap-7 text-[13px] font-medium text-neutral-600">
            <a href="#pricing" className="hover:text-slate-950 transition-colors">Pricing</a>
            <a href="#sections" className="hover:text-slate-950 transition-colors">Sections</a>
            <a href="#featured" className="hover:text-slate-950 transition-colors">Featured</a>
            <a href="#memberships" className="hover:text-slate-950 transition-colors">Memberships</a>
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

            <motion.button
              type="button"
              whileHover={{ scale: 1.03 }}
              whileTap={{ scale: 0.96 }}
              onClick={handleInstallClick}
              className="flex items-center gap-1.5 px-4 py-1.5 rounded-full bg-[#000000] hover:bg-[#1a1a1a] text-white text-xs font-bold shadow-xs transition-colors cursor-pointer"
            >
              <span>Create Account</span>
            </motion.button>
          </div>
        </header>
      </motion.div>

      {/* =========================================================================
          2. HERO SECTION WITH STAGGERED MOTION REVEALS
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
          <span>Join 10K+ Site Makers</span>
        </motion.div>

        {/* Master Headline (Satoshi + Instrument Serif Italic) */}
        <motion.div variants={itemFadeUpVariants} className="space-y-3 max-w-3xl mx-auto">
          <h1 className="text-4xl sm:text-6xl md:text-7xl font-black text-slate-950 tracking-tight leading-[1.06]">
            The site builder with <br className="hidden sm:inline" />
            <span className="font-serif italic font-normal text-[#1d64ec]">zero learning curve.</span>
          </h1>
          <p className="text-base sm:text-lg text-slate-600 font-normal leading-relaxed max-w-xl mx-auto pt-1">
            Launch a site that actually looks pro, from your phone or desktop.
          </p>
        </motion.div>

        {/* Interactive Claim & Install Input Bar */}
        <motion.div variants={itemFadeUpVariants} className="pt-2 max-w-lg mx-auto">
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

            <motion.button
              type="submit"
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.97 }}
              className="h-10 sm:h-11 px-5 sm:px-6 rounded-xl sm:rounded-full bg-[#000000] hover:bg-[#1a1a1a] text-white font-bold text-xs sm:text-sm shadow-xs flex items-center justify-center gap-1.5 transition-colors shrink-0 cursor-pointer"
            >
              <span>Claim your pop.site</span>
            </motion.button>
          </form>

          {/* Micro Guarantee Copy */}
          <div className="pt-3 flex items-center justify-center gap-3 sm:gap-4 text-[11px] sm:text-xs text-neutral-500 font-medium">
            <span>No credit card required to start</span>
            <span>·</span>
            <span>There's no complex editor to learn</span>
            <span>·</span>
            <span>Go live in minutes, not weeks</span>
          </div>
        </motion.div>

        {/* =========================================================================
            3. HERO PREVIEW SHOWCASE (Django Degree Testimonial)
        ========================================================================= */}
        <motion.div
          variants={itemFadeUpVariants}
          id="featured"
          className="pt-8 max-w-4xl mx-auto"
        >
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
                    src="/pop-assets/django-avatar.jpg"
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
                  Designer and creative director building high-converting brand identities, link hubs, and creator storefronts.
                </p>

                {/* Showcase Action Links */}
                <div className="space-y-2 pt-2">
                  <motion.div
                    whileHover={{ scale: 1.02, x: 2 }}
                    className="p-3 rounded-xl bg-white border border-neutral-200/70 flex items-center justify-between text-xs font-bold text-slate-900 hover:border-neutral-300 transition-all cursor-pointer"
                  >
                    <div className="flex items-center gap-2">
                      <ShoppingBag className="w-4 h-4 text-[#1d64ec]" />
                      <span>Design Systems & Tokens Pack</span>
                    </div>
                    <span>$49</span>
                  </motion.div>
                  <motion.div
                    whileHover={{ scale: 1.02, x: 2 }}
                    className="p-3 rounded-xl bg-white border border-neutral-200/70 flex items-center justify-between text-xs font-bold text-slate-900 hover:border-neutral-300 transition-all cursor-pointer"
                  >
                    <div className="flex items-center gap-2">
                      <Zap className="w-4 h-4 text-emerald-600" />
                      <span>Framer & Figma UI Kit 2026</span>
                    </div>
                    <span>$29</span>
                  </motion.div>
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
        </motion.div>
      </motion.section>

      {/* =========================================================================
          4. AUTOMATED SEO, DOMAINS & METADATA SECTION (Scroll Viewport Reveal)
      ========================================================================= */}
      <motion.section
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: '-80px' }}
        variants={scrollSectionVariants}
        id="sections"
        className="py-16 px-4 sm:px-6 max-w-5xl mx-auto space-y-12"
      >
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

        {/* Bento Grid 3 Cards with Motion Hover */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <motion.div
            whileHover={{ y: -5, scale: 1.015 }}
            transition={{ duration: 0.3, ease: TRANSITION_EASE }}
            className="p-7 rounded-3xl bg-white border border-neutral-200/90 shadow-2xs space-y-4"
          >
            <div className="w-10 h-10 rounded-2xl bg-blue-50 text-[#1d64ec] flex items-center justify-center">
              <Search className="w-5 h-5" />
            </div>
            <h3 className="text-lg font-bold text-slate-950">SEO is automated</h3>
            <p className="text-xs sm:text-sm text-slate-600 leading-relaxed font-normal">
              Your site's SEO is handled automatically by Pop Site. Structured markup and indexing ready out-of-the-box.
            </p>
          </motion.div>

          <motion.div
            whileHover={{ y: -5, scale: 1.015 }}
            transition={{ duration: 0.3, ease: TRANSITION_EASE }}
            className="p-7 rounded-3xl bg-white border border-neutral-200/90 shadow-2xs space-y-4"
          >
            <div className="w-10 h-10 rounded-2xl bg-purple-50 text-purple-600 flex items-center justify-center">
              <Globe className="w-5 h-5" />
            </div>
            <h3 className="text-lg font-bold text-slate-950">Domains are included</h3>
            <p className="text-xs sm:text-sm text-slate-600 leading-relaxed font-normal">
              You get a free Pop Site domain, or easily connect your own custom domain in just one click.
            </p>
          </motion.div>

          <motion.div
            whileHover={{ y: -5, scale: 1.015 }}
            transition={{ duration: 0.3, ease: TRANSITION_EASE }}
            className="p-7 rounded-3xl bg-white border border-neutral-200/90 shadow-2xs space-y-4"
          >
            <div className="w-10 h-10 rounded-2xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <ShieldCheck className="w-5 h-5" />
            </div>
            <h3 className="text-lg font-bold text-slate-950">Metadata is handled</h3>
            <p className="text-xs sm:text-sm text-slate-600 leading-relaxed font-normal">
              Your metadata and OpenGraph social preview tags are automatically created and updated for you.
            </p>
          </motion.div>
        </div>

        {/* Large Responsive Preview Card */}
        <motion.div
          whileHover={{ scale: 1.01 }}
          transition={{ duration: 0.4, ease: TRANSITION_EASE }}
          className="p-6 sm:p-10 rounded-3xl bg-white border border-neutral-200/90 shadow-2xs space-y-6 text-center"
        >
          <div className="max-w-md mx-auto space-y-2">
            <h3 className="text-2xl font-bold text-slate-950">Desktop & mobile views</h3>
            <p className="text-xs sm:text-sm text-slate-600">
              Pop Sites are automatically responsive across all devices with instant PWA capabilities.
            </p>
          </div>

          <div className="relative rounded-2xl overflow-hidden border border-neutral-100 bg-neutral-50 shadow-inner">
            <img
              src="/pop-assets/responsive-mockup.png"
              alt="Desktop and mobile responsive view"
              className="w-full h-auto object-cover max-h-[420px]"
            />
          </div>
        </motion.div>
      </motion.section>

      {/* =========================================================================
          5. BUILT-IN ANALYTICS SECTION (Dark Showcase with Glowing Aura)
      ========================================================================= */}
      <motion.section
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: '-80px' }}
        variants={scrollSectionVariants}
        id="memberships"
        className="py-16 px-4 sm:px-6 max-w-5xl mx-auto space-y-12"
      >
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

        {/* Analytics Dark Container */}
        <div className="relative rounded-3xl bg-[#000000] p-6 sm:p-10 border border-neutral-800 shadow-2xl text-white overflow-hidden space-y-8">
          <div className="absolute top-0 right-0 w-96 h-96 bg-blue-500/20 rounded-full blur-3xl pointer-events-none" />

          {/* Telemetry Chips */}
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-6 gap-3 text-center">
            {['Track button clicks', 'Get live alerts', 'UTM tracking', 'Device analytics', 'Referral sources', 'Geo intelligence'].map((tag, i) => (
              <motion.div
                key={i}
                whileHover={{ scale: 1.05, backgroundColor: 'rgba(255,255,255,0.12)' }}
                className="p-3 rounded-2xl bg-white/5 border border-white/10 text-xs font-semibold cursor-default transition-all"
              >
                {tag}
              </motion.div>
            ))}
          </div>

          {/* Exact Analytics Screenshot */}
          <div className="rounded-2xl overflow-hidden border border-white/10 shadow-2xl">
            <img
              src="/pop-assets/analytics-dashboard.png"
              alt="Pop Site Analytics Dashboard"
              className="w-full h-auto object-cover"
            />
          </div>
        </div>
      </motion.section>

      {/* =========================================================================
          6. THEMES GALLERY SECTION WITH HOVER ZOOM
      ========================================================================= */}
      <motion.section
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: '-80px' }}
        variants={scrollSectionVariants}
        id="pricing"
        className="py-16 px-4 sm:px-6 max-w-5xl mx-auto space-y-12"
      >
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
                  className="w-full h-48 sm:h-64 object-cover group-hover:scale-106 transition-transform duration-500 ease-out"
                />
              </div>
              <div className="p-3.5 text-xs font-bold text-slate-900 flex justify-between items-center bg-white">
                <div>
                  <p>{theme.name}</p>
                  <span className="text-[10px] text-neutral-400 font-normal">{theme.tag}</span>
                </div>
                <ArrowUpRight className="w-4 h-4 text-neutral-400 group-hover:text-slate-950 group-hover:translate-x-0.5 group-hover:-translate-y-0.5 transition-all" />
              </div>
            </motion.div>
          ))}
        </div>
      </motion.section>

      {/* =========================================================================
          7. EVERYTHING IS PRE-BUILT (15 Modular Feature Grid)
      ========================================================================= */}
      <motion.section
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: '-80px' }}
        variants={scrollSectionVariants}
        className="py-16 px-4 sm:px-6 max-w-5xl mx-auto space-y-12"
      >
        <div className="text-center space-y-3 max-w-2xl mx-auto">
          <h2 className="text-3xl sm:text-5xl font-black text-slate-950 tracking-tight leading-tight">
            Everything is pre-built. <br />
            <span className="font-serif italic font-normal text-[#1d64ec]">Just customize and launch.</span>
          </h2>
          <p className="text-sm sm:text-base text-slate-600">
            Rich building blocks engineered to showcase, sell, and connect.
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-5">
          {prebuiltFeatures.map((feat, i) => {
            const Icon = feat.icon;
            return (
              <motion.div
                key={i}
                whileHover={{ y: -4, scale: 1.015 }}
                transition={{ duration: 0.3, ease: TRANSITION_EASE }}
                className="p-6 rounded-2xl bg-white border border-neutral-200/80 shadow-2xs space-y-3"
              >
                <div className="w-9 h-9 rounded-xl bg-neutral-100 text-slate-900 flex items-center justify-center">
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
          8. CREATOR TESTIMONIAL 2: OLIUR
      ========================================================================= */}
      <motion.section
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: '-80px' }}
        variants={scrollSectionVariants}
        className="py-12 px-4 sm:px-6 max-w-3xl mx-auto text-center"
      >
        <div className="p-8 sm:p-12 rounded-3xl bg-white border border-neutral-200/90 shadow-2xs space-y-5">
          <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 text-xs font-semibold text-[#1d64ec]">
            <Star className="w-3.5 h-3.5 fill-[#1d64ec]" />
            <span>Creator Review</span>
          </div>
          <blockquote className="text-xl sm:text-3xl font-serif italic text-slate-950 leading-snug">
            "A mini website builder more aimed for professionals. Love the aesthetic."
          </blockquote>
          <div className="pt-2 text-xs font-mono text-neutral-500">
            <span className="font-bold text-slate-900">Oliur</span> · oliur.pop.site · 462K Subscribers
          </div>
        </div>
      </motion.section>

      {/* =========================================================================
          9. FAQ ACCORDION WITH FLUID HEIGHT TRANSITION
      ========================================================================= */}
      <motion.section
        initial="hidden"
        whileInView="visible"
        viewport={{ once: true, margin: '-80px' }}
        variants={scrollSectionVariants}
        className="py-16 px-4 sm:px-6 max-w-3xl mx-auto space-y-8"
      >
        <div className="text-center space-y-2">
          <h2 className="text-3xl sm:text-4xl font-black text-slate-950 tracking-tight">
            Frequently Asked Questions
          </h2>
          <p className="text-sm text-slate-600">
            Everything you need to know about Pop Site.
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
          10. FINAL CALL TO ACTION BANNER
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
                  value={bottomClaimUsername}
                  onChange={(e) => setBottomClaimUsername(e.target.value)}
                  placeholder="yourname"
                  className="w-full bg-transparent px-1 py-2 text-sm font-semibold text-white placeholder:text-neutral-400 focus:outline-none"
                />
                <span className="text-xs font-mono text-neutral-300 font-medium">.pop.site</span>
              </div>

              <motion.button
                type="submit"
                whileHover={{ scale: 1.03 }}
                whileTap={{ scale: 0.96 }}
                className="h-10 sm:h-11 px-5 sm:px-6 rounded-xl sm:rounded-full bg-white hover:bg-neutral-100 text-slate-950 font-bold text-xs sm:text-sm shadow-xs flex items-center justify-center gap-1.5 transition-colors shrink-0 cursor-pointer"
              >
                <span>Claim</span>
                <ArrowRight className="w-3.5 h-3.5" />
              </motion.button>
            </form>
          </div>
        </div>
      </motion.section>

      {/* =========================================================================
          11. 4-COLUMN FOOTER
      ========================================================================= */}
      <footer className="border-t border-neutral-200/80 pt-12 pb-16 px-4 sm:px-6 max-w-5xl mx-auto text-xs text-neutral-500 space-y-8">
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-8 text-left">
          {/* Col 1 */}
          <div className="space-y-2 col-span-2 sm:col-span-1">
            <div className="flex items-center gap-2">
              <div className="h-6 w-6 rounded-md bg-black text-white flex items-center justify-center font-bold text-xs">
                P
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
              <li><a href="#pricing" className="hover:text-slate-950 transition-colors">Pricing</a></li>
              <li><a href="#sections" className="hover:text-slate-950 transition-colors">Sections</a></li>
              <li><a href="#featured" className="hover:text-slate-950 transition-colors">Featured</a></li>
              <li><a href="#memberships" className="hover:text-slate-950 transition-colors">Memberships</a></li>
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
            <h4 className="font-bold text-slate-900 text-xs">Status</h4>
            <ul className="space-y-1.5 text-[11.5px]">
              <li><span className="text-emerald-600 font-semibold">● All Systems Normal</span></li>
              <li><span>PWA Engine v2.4</span></li>
              <li><span>Zero Learning Curve</span></li>
            </ul>
          </div>
        </div>

        <div className="pt-6 border-t border-neutral-100 flex flex-col sm:flex-row items-center justify-between gap-3 text-[11px] text-neutral-400">
          <p>© 2026 Pop Site. All rights reserved.</p>
          <p>Built for creators, designers, and professionals.</p>
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
