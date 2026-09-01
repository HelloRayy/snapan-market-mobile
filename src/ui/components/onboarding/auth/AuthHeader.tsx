import React from 'react';
import { ArrowLeft } from 'lucide-react';
import personLoginBg from '@/assets/new-market-asset/person-login-bg.svg';
import otpHero from '@/assets/new-market-asset/otp-hero.svg';

interface AuthHeaderProps {
  authTab: 'login' | 'register';
  regStep: 'form' | 'otp';
  onBack?: () => void;
}

export const AuthHeader: React.FC<AuthHeaderProps> = ({ authTab, regStep, onBack }) => {
  return (
    <div className="relative flex flex-col items-center pt-1 sm:pt-2 pb-2 select-none">
      {/* Top Floating Left Back Button */}
      {onBack && (
        <button
          type="button"
          onClick={onBack}
          aria-label="Kembali ke slide sebelumnya"
          className="absolute left-0 top-0 z-30 flex h-10 w-10 items-center justify-center rounded-full bg-white/95 border border-slate-200/90 text-slate-700 shadow-md shadow-slate-900/5 transition-all hover:bg-white active:scale-90 cursor-pointer"
        >
          <ArrowLeft className="h-5 w-5 stroke-[2.5]" />
        </button>
      )}

      {/* Hero Illustration */}
      <div className="relative mb-2 h-28 w-28 sm:h-32 sm:w-32 flex items-center justify-center">
        <img
          src={regStep === 'otp' ? otpHero : personLoginBg}
          alt="Ilustrasi Akun Snapan Market"
          className="h-full w-full object-contain drop-shadow-sm transition-all duration-300 transform-gpu"
        />
      </div>

      {/* Dynamic Header Typography (Only shown in Step 1 Form) */}
      {regStep === 'form' && (
        <div className="space-y-1 text-center px-4">
          <h1 className="text-xl sm:text-2xl font-extrabold tracking-tight text-slate-900 font-shopify-sans">
            {authTab === 'login' ? 'Selamat Datang Kembali!' : 'Gabung ke Komunitas'}
          </h1>
          <p className="text-xs sm:text-sm text-slate-600 font-medium leading-relaxed max-w-xs mx-auto">
            {authTab === 'login'
              ? 'Masuk untuk mulai bertransaksi aman di lingkungan sekolah.'
              : 'Daftar sekarang untuk jual beli karya & supplies di SMKN 8.'}
          </p>
        </div>
      )}
    </div>
  );
};
