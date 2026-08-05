import React, { useEffect } from 'react';
import { Store } from 'lucide-react';

interface SplashScreenProps {
  onFinish: () => void;
}

export const SplashScreen: React.FC<SplashScreenProps> = ({ onFinish }) => {
  useEffect(() => {
    const timer = setTimeout(() => {
      onFinish();
    }, 2500);

    return () => clearTimeout(timer);
  }, [onFinish]);

  return (
    <div
      onClick={onFinish}
      className="fixed inset-0 z-50 flex cursor-pointer flex-col items-center justify-between bg-pure-white p-8 text-slate-ink select-none transition-opacity duration-500 font-gt-standard"
    >
      <div className="flex-1 flex flex-col items-center justify-center gap-4 text-center">
        <div className="relative flex h-20 w-20 items-center justify-center rounded-3xl bg-shop-violet text-pure-white shadow-xl shadow-shop-violet/30 animate-pulse">
          <Store className="h-10 w-10 text-pure-white" />
        </div>

        <div className="space-y-1">
          <h1 className="text-3xl font-black tracking-tight text-slate-ink font-shopify-sans">
            SNAPAN<span className="text-shop-violet">MARKET</span>
          </h1>
          <p className="text-xs text-ash-veil font-medium tracking-widest uppercase font-gt-standard">
            E-Commerce Mobile PWA
          </p>
        </div>
      </div>

      <div className="flex flex-col items-center gap-2 pb-6">
        <div className="h-1.5 w-1.5 rounded-full bg-shop-violet animate-ping"></div>
        <p className="text-[11px] text-ash-veil font-medium">Ketuk untuk melanjutkan</p>
      </div>
    </div>
  );
};
