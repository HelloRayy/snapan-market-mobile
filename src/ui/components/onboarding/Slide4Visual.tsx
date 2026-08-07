import React from 'react';
import personLoginBgSvg from '../../../assets/new-market-asset/person-login-bg.svg';

export const Slide4Visual: React.FC = () => {
  return (
    <div className="relative w-full aspect-[4/5] flex items-center justify-center overflow-hidden select-none">
      <img
        src={personLoginBgSvg}
        alt="Siap Menjelajahi Snapan Market!"
        className="w-[85%] h-[85%] mx-auto my-auto object-contain drop-shadow-md transition-transform duration-300 hover:scale-[1.02]"
      />
    </div>
  );
};
