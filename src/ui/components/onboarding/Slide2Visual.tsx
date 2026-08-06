import React from 'react';
import market2Img from '../../../assets/new-market-asset/market-2 1.webp';

export const Slide2Visual: React.FC = () => {
  return (
    <div className="relative w-full aspect-[4/5] rounded-[32px] bg-gradient-to-b from-blue-50/50 via-sky-50/20 to-slate-50 border border-neutral-200/80 p-3 flex flex-col items-center justify-center overflow-hidden shadow-lg select-none">
      {/* Background Decorative Subtle Radial Glow */}
      <div className="absolute -top-10 -left-10 w-40 h-40 bg-blue-500/10 rounded-full blur-2xl pointer-events-none" />
      <div className="absolute -bottom-10 -right-10 w-36 h-36 bg-[#1d64ec]/10 rounded-full blur-2xl pointer-events-none" />

      {/* Main Image Asset Container */}
      <div className="relative w-full h-full flex items-center justify-center z-10">
        <img
          src={market2Img}
          alt="Jual & Kelola Produkmu dengan Mudah"
          className="w-full h-full object-contain drop-shadow-md transition-transform duration-300 hover:scale-[1.02]"
        />
      </div>
    </div>
  );
};
