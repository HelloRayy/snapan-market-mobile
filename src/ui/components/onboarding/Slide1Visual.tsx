import React from 'react';
import market1Svg from '../../../assets/new-market-asset/market-1 1.svg';

export const Slide1Visual: React.FC = () => {
  return (
    <div className="relative w-full aspect-[4/5] flex items-center justify-center overflow-hidden select-none">
      <img
        src={market1Svg}
        alt="Pusat Jual Beli Warga SMKN 8 Semarang"
        className="w-[85%] h-[85%] mx-auto my-auto object-contain drop-shadow-md transition-transform duration-300 hover:scale-[1.02]"
      />
    </div>
  );
};
