import React from 'react';
import market3Img from '../../../assets/new-market-asset/market-3 1.webp';

export const Slide3Visual: React.FC = () => {
  return (
    <div className="relative w-full aspect-[4/5] flex items-center justify-center overflow-hidden select-none">
      <img
        src={market3Img}
        alt="Transaksi & COD Praktis di Sekolah"
        className="max-w-full max-h-full mx-auto my-auto object-contain drop-shadow-md transition-transform duration-300 hover:scale-[1.02]"
      />
    </div>
  );
};
