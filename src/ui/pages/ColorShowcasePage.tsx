import React, { useState } from 'react';
import { ArrowLeft, Check, Copy, Handshake, MapPin, Sparkles, Star, MessageCircle, Phone } from 'lucide-react';
import { triggerHaptic } from '@/utils/haptics';

interface ColorOption {
  id: string;
  name: string;
  subtitle: string;
  vibe: string;
  primaryHex: string;
  primaryHoverHex: string;
  pastelBgHex: string;
  pastelTextHex: string;
  borderHex: string;
  shadowClass: string;
}

const COLOR_OPTIONS: ColorOption[] = [
  {
    id: 'indigo',
    name: 'Option A: Electric Indigo',
    subtitle: 'Vibe: Linear, Raycast, Stripe',
    vibe: 'Modern, Cutting-Edge, Anti-AI Slop, Deep Violet-Blue Hue Shift',
    primaryHex: '#3d38f5',
    primaryHoverHex: '#312bd9',
    pastelBgHex: '#eef0ff',
    pastelTextHex: '#3d38f5',
    borderHex: '#d8dbfe',
    shadowClass: 'shadow-indigo-500/20',
  },
  {
    id: 'ultramarine',
    name: 'Option B: Deep Ultramarine',
    subtitle: 'Vibe: Arc Browser, Monzo, Coinbase',
    vibe: 'High Pigment Cobalt, Confident, Ultra Crisp on OLED',
    primaryHex: '#0950ec',
    primaryHoverHex: '#0742c4',
    pastelBgHex: '#eaf2ff',
    pastelTextHex: '#0950ec',
    borderHex: '#cbe0ff',
    shadowClass: 'shadow-blue-600/20',
  },
  {
    id: 'cerulean',
    name: 'Option C: Cerulean Ink (Almamater)',
    subtitle: 'Vibe: Identitas Vokasi SMKN 8',
    vibe: 'Solid School Ink Blue, Formal-Casual Balance, Trustworthy',
    primaryHex: '#134cd8',
    primaryHoverHex: '#0e3eb8',
    pastelBgHex: '#ebf2ff',
    pastelTextHex: '#134cd8',
    borderHex: '#cddffe',
    shadowClass: 'shadow-blue-700/20',
  },
  {
    id: 'obsidian',
    name: 'Option D: Obsidian Ink & Ice Blue',
    subtitle: 'Vibe: Meta Threads, Apple Minimalism',
    vibe: 'Pure Monochrome Solid Black with Crisp Slate Ice Pill',
    primaryHex: '#0f172a',
    primaryHoverHex: '#000000',
    pastelBgHex: '#f1f5f9',
    pastelTextHex: '#0f172a',
    borderHex: '#e2e8f0',
    shadowClass: 'shadow-slate-900/20',
  },
  {
    id: 'current',
    name: 'Option E: General Blue (Current)',
    subtitle: 'Vibe: Generic Bootstrap / AI Template',
    vibe: 'Standard saturated electric blue without hue drift',
    primaryHex: '#1d64ec',
    primaryHoverHex: '#1551c6',
    pastelBgHex: '#eff6ff',
    pastelTextHex: '#1d64ec',
    borderHex: '#dbeafe',
    shadowClass: 'shadow-blue-500/20',
  },
];

export const ColorShowcasePage: React.FC<{ onBack: () => void }> = ({ onBack }) => {
  const [selectedId, setSelectedId] = useState<string>('indigo');
  const [copiedHex, setCopiedHex] = useState<string | null>(null);

  const currentOption = COLOR_OPTIONS.find((c) => c.id === selectedId) || COLOR_OPTIONS[0];

  const handleCopy = (hex: string) => {
    triggerHaptic('selection');
    navigator.clipboard.writeText(hex);
    setCopiedHex(hex);
    setTimeout(() => setCopiedHex(null), 1800);
  };

  return (
    <div className="min-h-screen bg-[#f8f9fa] text-slate-900 font-gt-standard pb-24 max-w-[620px] mx-auto select-none animate-in fade-in duration-200">
      {/* Top Sticky Header */}
      <header className="sticky top-0 z-40 bg-white/95 backdrop-blur-md border-b border-neutral-200/80 px-4 h-14 flex items-center justify-between">
        <button
          type="button"
          onClick={onBack}
          className="w-9 h-9 rounded-full hover:bg-neutral-100 flex items-center justify-center text-slate-800 active:scale-90 transition-all cursor-pointer"
        >
          <ArrowLeft className="w-5 h-5" />
        </button>
        <h1 className="font-bold text-[16px] text-slate-900">Brand Color Laboratory</h1>
        <div className="w-9" />
      </header>

      <main className="p-4 space-y-6">
        {/* Intro Card */}
        <div className="bg-white rounded-2xl p-4 border border-neutral-200/80 shadow-2xs space-y-2">
          <div className="flex items-center gap-2">
            <Sparkles className="w-4 h-4 text-amber-500" />
            <h2 className="font-bold text-[15px] text-slate-900">Pilih & Bandingkan Warna Signature</h2>
          </div>
          <p className="text-[13px] text-slate-600 leading-relaxed">
            Pilih salah satu palet di bawah ini untuk melihat pratinjau langsung pada komponen <strong>Checkout UI</strong> secara <i>real-time</i>.
          </p>
        </div>

        {/* 1. PALETTE SELECTION CARDS */}
        <div className="space-y-3">
          <h3 className="font-bold text-[13px] text-slate-500 uppercase tracking-wider px-1">
            Daftar Palet Warna
          </h3>

          <div className="space-y-2.5">
            {COLOR_OPTIONS.map((opt) => {
              const isSelected = opt.id === selectedId;
              return (
                <div
                  key={opt.id}
                  onClick={() => {
                    triggerHaptic('light');
                    setSelectedId(opt.id);
                  }}
                  className={`p-3.5 rounded-2xl border transition-all cursor-pointer bg-white ${
                    isSelected
                      ? 'border-slate-900 ring-2 ring-slate-900/10 shadow-sm'
                      : 'border-neutral-200/80 hover:border-neutral-300'
                  }`}
                >
                  <div className="flex items-center justify-between gap-3">
                    <div className="flex items-center gap-3">
                      {/* Swatch Circle */}
                      <div
                        className="w-10 h-10 rounded-full shadow-xs flex items-center justify-center text-white shrink-0"
                        style={{ backgroundColor: opt.primaryHex }}
                      >
                        {isSelected && <Check className="w-5 h-5 stroke-[2.5]" />}
                      </div>

                      <div>
                        <h4 className="font-bold text-[14.5px] text-slate-900">{opt.name}</h4>
                        <p className="text-[12px] text-slate-500 font-normal">{opt.subtitle}</p>
                      </div>
                    </div>

                    {/* Copy Button */}
                    <button
                      type="button"
                      onClick={(e) => {
                        e.stopPropagation();
                        handleCopy(opt.primaryHex);
                      }}
                      className="px-2.5 py-1 rounded-lg bg-neutral-100 hover:bg-neutral-200 text-slate-700 text-[11.5px] font-mono flex items-center gap-1.5 transition-all"
                    >
                      <Copy className="w-3 h-3" />
                      <span>{copiedHex === opt.primaryHex ? 'Copied!' : opt.primaryHex}</span>
                    </button>
                  </div>

                  <p className="mt-2 text-[12px] text-slate-500 pl-13 italic">
                    "{opt.vibe}"
                  </p>
                </div>
              );
            })}
          </div>
        </div>

        {/* 2. LIVE INTERACTIVE CHECKOUT PREVIEW */}
        <div className="space-y-3 pt-2">
          <div className="flex items-center justify-between px-1">
            <h3 className="font-bold text-[13px] text-slate-500 uppercase tracking-wider">
              Live Mockup Checkout Page
            </h3>
            <span className="text-[11px] font-mono px-2 py-0.5 rounded-md bg-neutral-200/80 text-slate-700">
              {currentOption.primaryHex}
            </span>
          </div>

          {/* Rendered Mockup Card */}
          <div className="bg-white rounded-3xl border border-neutral-200/80 p-5 shadow-sm space-y-4">
            {/* Header with Badges */}
            <div className="flex items-center justify-between gap-2">
              {/* Ready for COD Badge */}
              <div
                className="inline-flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-[12.5px] font-bold tracking-tight transition-colors duration-200"
                style={{
                  backgroundColor: currentOption.pastelBgHex,
                  color: currentOption.pastelTextHex,
                }}
              >
                <Handshake className="w-3.5 h-3.5 stroke-[2.2]" style={{ color: currentOption.primaryHex }} />
                <span>Ready for COD</span>
              </div>

              {/* Rating Badge */}
              <div className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-amber-50 text-amber-900 text-[12.5px] font-bold">
                <Star className="w-3.5 h-3.5 fill-amber-400 text-amber-400 stroke-none" />
                <span>4.5</span>
              </div>
            </div>

            {/* Product Title */}
            <div>
              <h2 className="font-bold text-[20px] text-slate-900 leading-snug">
                Buku Pemrograman Web & Bergerak XII RPL
              </h2>
              <div className="flex items-center gap-1.5 text-[13px] text-neutral-500 font-normal mt-1">
                <MapPin className="w-3.5 h-3.5 shrink-0 stroke-[2.2]" style={{ color: currentOption.primaryHex }} />
                <span>SMKN 8 Jakarta · <strong className="text-slate-800">XII PPLG 1</strong></span>
              </div>
            </div>

            {/* Description Sample */}
            <p className="text-[13px] text-slate-600 leading-relaxed">
              Buku pegangan siswa original kurikulum merdeka, materi lengkap HTML, CSS, JS, dan React Native. Siap COD di Lab PPLG 1.
            </p>

            {/* Seller Card */}
            <div className="bg-neutral-50/90 rounded-2xl p-3.5 border border-neutral-200/80 flex items-center justify-between gap-3 shadow-2xs">
              <div className="flex items-center gap-3">
                <img
                  src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80"
                  alt="Seller"
                  className="w-10 h-10 rounded-full object-cover border border-white"
                />
                <div>
                  <h4 className="font-bold text-[14px] text-slate-900">Raditya Rayhan</h4>
                  <p className="text-[12px] text-slate-500">@radityarayhannnn</p>
                </div>
              </div>

              <div className="flex items-center gap-2">
                <button
                  type="button"
                  className="w-9 h-9 rounded-full bg-slate-900 text-white flex items-center justify-center"
                >
                  <MessageCircle className="w-4 h-4 fill-white text-slate-900" />
                </button>
                <button
                  type="button"
                  className="w-9 h-9 rounded-full bg-slate-900 text-white flex items-center justify-center"
                >
                  <Phone className="w-4 h-4 fill-white" />
                </button>
              </div>
            </div>

            {/* Live Bottom Bar Button Mockup */}
            <div className="pt-2 border-t border-neutral-100 flex items-center justify-between gap-4">
              <div>
                <span className="text-[11px] text-slate-400 block">Total Pembayaran</span>
                <span className="font-extrabold text-[20px] text-slate-900">Rp 35.000</span>
              </div>

              <button
                type="button"
                className="flex-1 py-3.5 px-5 rounded-2xl text-white font-bold text-[14.5px] flex items-center justify-center gap-2 shadow-md transition-all active:scale-95"
                style={{
                  backgroundColor: currentOption.primaryHex,
                }}
              >
                <span>Buat Pesanan COD</span>
              </button>
            </div>
          </div>
        </div>
      </main>
    </div>
  );
};
