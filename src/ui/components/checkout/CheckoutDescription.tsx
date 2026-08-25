import React, { useState } from 'react';
import { triggerHaptic } from '@/utils/haptics';

interface CheckoutDescriptionProps {
  description?: string;
}

export const CheckoutDescription: React.FC<CheckoutDescriptionProps> = ({ description }) => {
  const [isExpanded, setIsExpanded] = useState(false);

  const rawText =
    description && description.trim().length > 0
      ? description
      : 'Barang berkualitas siap serah terima fisik (COD) di lingkungan sekolah SMKN 8 Jakarta. Silakan hubungi penjual untuk informasi lebih lanjut.';

  const isLong = rawText.length > 150;
  const displayText = !isLong || isExpanded ? rawText : `${rawText.slice(0, 140)}...`;

  const handleToggle = () => {
    triggerHaptic('selection');
    setIsExpanded((prev) => !prev);
  };

  return (
    <section className="space-y-2 select-none font-gt-standard pt-1">
      <h3 className="font-bold text-[16px] text-slate-900 tracking-tight">
        Deskripsi Produk
      </h3>

      <p className="text-[13.5px] text-slate-600 leading-relaxed font-normal break-words whitespace-pre-line">
        {displayText}
        {isLong && (
          <button
            type="button"
            onClick={handleToggle}
            className="text-slate-900 font-bold text-[13px] ml-1.5 hover:underline cursor-pointer inline-block"
          >
            {isExpanded ? 'Sembunyikan' : 'Baca Selengkapnya'}
          </button>
        )}
      </p>
    </section>
  );
};
