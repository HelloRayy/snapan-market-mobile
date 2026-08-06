import React, { useState, useRef } from 'react';
import { ChevronRight, LogIn } from 'lucide-react';
import { Slide1Visual } from './Slide1Visual';
import { Slide2Visual } from './Slide2Visual';
import { Slide3Visual } from './Slide3Visual';
import { Slide4Visual } from './Slide4Visual';
import { AuthSlideVisual } from './AuthSlideVisual';
import { ButtonPrimary } from '../ui/ButtonPrimary';
import { ButtonSecondary } from '../ui/ButtonSecondary';

interface OnboardingScreenProps {
  onComplete: () => void;
}

export const OnboardingScreen: React.FC<OnboardingScreenProps> = ({ onComplete }) => {
  const [currentSlide, setCurrentSlide] = useState(0);

  // Touch Swipe Gesture State
  const touchStartX = useRef<number | null>(null);
  const touchEndX = useRef<number | null>(null);

  const slides = [
    {
      id: 0,
      title: 'Pusat Jual Beli Warga SMKN 8 Semarang',
      description: 'Mulai dari barang preloved, jajanan lezat kantin, hingga karya buatanmu — tawarkan semua produkmu langsung ke teman & guru di SMKN 8 Semarang.',
      type: 'content' as const,
      visual: <Slide1Visual />
    },
    {
      id: 1,
      title: 'Jual & Kelola Produkmu dengan Mudah',
      description: 'Unggah foto produk, atur harga, dan terima pesanan langsung dari teman & guru di SMKN 8 Semarang hanya dalam beberapa langkah.',
      type: 'content' as const,
      visual: <Slide2Visual />
    },
    {
      id: 2,
      title: 'Transaksi & COD Praktis di Sekolah',
      description: 'Ketemuan langsung di sekolah, bayar saat terima barang (COD), atau pesan kantin untuk diambil tanpa perlu antre.',
      type: 'content' as const,
      visual: <Slide3Visual />
    },
    {
      id: 3,
      title: 'Siap Menjelajahi Snapan Market!',
      description: 'Mulai jelajahi dan nikmati pengalaman jual beli online antar warga SMKN 8 yang aman dan praktis.',
      type: 'content' as const,
      visual: <Slide4Visual />
    },
    {
      id: 4,
      title: 'Ayo Buat dan Atur Akun Kamu',
      description: 'Masuk atau daftar untuk menikmati pengalaman belanja dan berjualan terbaik.',
      type: 'auth' as const,
      visual: null
    }
  ];

  const handleNext = () => {
    if (currentSlide < slides.length - 1) {
      setCurrentSlide((prev) => prev + 1);
    } else {
      onComplete();
    }
  };

  const handleSkip = () => {
    setCurrentSlide(slides.length - 1);
  };

  // Touch Swipe Gesture Handlers
  const handleTouchStart = (e: React.TouchEvent) => {
    touchStartX.current = e.targetTouches[0].clientX;
    touchEndX.current = null;
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    touchEndX.current = e.targetTouches[0].clientX;
  };

  const handleTouchEnd = () => {
    if (!touchStartX.current || !touchEndX.current) return;
    const distance = touchStartX.current - touchEndX.current;
    const isSwipeLeft = distance > 40;
    const isSwipeRight = distance < -40;

    if (isSwipeLeft && currentSlide < slides.length - 1) {
      setCurrentSlide((prev) => prev + 1);
    } else if (isSwipeRight && currentSlide > 0) {
      setCurrentSlide((prev) => prev - 1);
    }
  };

  const current = slides[currentSlide];

  return (
    <div
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
      className="fixed inset-0 z-50 flex flex-col justify-between bg-pure-white p-5 text-slate-ink select-none overflow-y-auto no-scrollbar font-gt-standard"
    >
      {current.type === 'auth' ? (
        /* Slide Terakhir: Halaman Masuk / Daftar */
        <div className="w-full h-full animate-in fade-in slide-in-from-right-6 duration-300 ease-out">
          <AuthSlideVisual
            onBack={() => setCurrentSlide((prev) => prev - 1)}
            onSuccess={onComplete}
          />
        </div>
      ) : (
        /* Slide Standard Onboarding (Slide 1 - 4) */
        <>
          {/* Top Visual Carousel Viewport (Native Horizontal Slide Motion) */}
          <div className="w-full max-w-sm mx-auto pt-2 overflow-hidden">
            <div
              className="flex w-full transition-transform duration-350 cubic-bezier(0.16,1,0.3,1)"
              style={{ transform: `translateX(-${currentSlide * 100}%)` }}
            >
              {slides.slice(0, 4).map((slide) => (
                <div key={slide.id} className="w-full shrink-0">
                  {slide.visual}
                </div>
              ))}
            </div>
          </div>

          {/* Middle Text & Pagination Dots */}
          <div className="w-full max-w-sm mx-auto my-auto py-4 space-y-4">
            {/* Pagination Dots with Fluid Pill Animation (4 Dots for Content Slides) */}
            <div className="flex items-center gap-1.5" role="tablist" aria-label="Indikator Slide">
              {slides.slice(0, 4).map((slide, index) => (
                <button
                  key={slide.id}
                  onClick={() => setCurrentSlide(index)}
                  className={`h-1.5 rounded-full transition-all duration-300 cubic-bezier(0.16,1,0.3,1) active:scale-90 cursor-pointer ${
                    currentSlide === index ? 'w-8 bg-[#1d64ec] shadow-sm' : 'w-2 bg-cool-stone hover:bg-warm-fog'
                  }`}
                  aria-label={`Buka slide ${index + 1}`}
                  aria-selected={currentSlide === index}
                />
              ))}
            </div>

            {/* Dynamic Staggered Text Transition */}
            <div
              key={`text-${currentSlide}`}
              className="space-y-2 animate-in fade-in slide-in-from-right-4 duration-300 ease-out"
            >
              <h2 className="text-2xl font-bold tracking-tight text-slate-ink leading-snug font-shopify-sans">
                {current.title}
              </h2>
              <p className="text-sm text-ash-veil leading-relaxed font-normal font-gt-standard">
                {current.description}
              </p>
            </div>
          </div>

          {/* Bottom Action Bar */}
          <div className="w-full max-w-sm mx-auto flex items-center justify-between gap-3 pb-6">
            {currentSlide < 3 && (
              <ButtonSecondary
                size="lg"
                onClick={handleSkip}
                className="shrink-0 font-bold"
              >
                Lewati
              </ButtonSecondary>
            )}

            <ButtonPrimary
              size="lg"
              onClick={handleNext}
              className="flex-1 justify-center font-bold"
              iconRight={
                currentSlide === 3 ? (
                  <LogIn className="w-4 h-4 text-white" />
                ) : (
                  <div className="flex items-center text-white">
                    <ChevronRight className="w-4 h-4 -mr-2.5 opacity-30 group-hover:opacity-60 transition-opacity duration-150" />
                    <ChevronRight className="w-4 h-4 -mr-2.5 opacity-60 group-hover:opacity-80 transition-opacity duration-150" />
                    <ChevronRight className="w-4 h-4 text-white" />
                  </div>
                )
              }
            >
              {currentSlide === 3 ? 'Mulai Sekarang' : 'Lanjut'}
            </ButtonPrimary>
          </div>
        </>
      )}
    </div>
  );
};
