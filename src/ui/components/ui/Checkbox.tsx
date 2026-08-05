import React from 'react';
import { Check } from 'lucide-react';

export interface CheckboxProps {
  id?: string;
  checked?: boolean;
  onCheckedChange?: (checked: boolean) => void;
  disabled?: boolean;
  label?: React.ReactNode;
  className?: string;
}

export const Checkbox: React.FC<CheckboxProps> = ({
  id,
  checked = false,
  onCheckedChange,
  disabled = false,
  label,
  className = '',
}) => {
  return (
    <label
      htmlFor={id}
      className={`inline-flex items-start gap-2.5 cursor-pointer select-none group ${
        disabled ? 'cursor-not-allowed opacity-50' : ''
      } ${className}`}
    >
      <div className="relative flex items-center justify-center mt-0.5 shrink-0">
        <input
          id={id}
          type="checkbox"
          checked={checked}
          disabled={disabled}
          onChange={(e) => onCheckedChange?.(e.target.checked)}
          className="peer sr-only"
        />
        <div
          className={`w-5 h-5 rounded-lg border transition-all duration-200 flex items-center justify-center shadow-2xs ${
            checked
              ? 'bg-[#1d64ec] border-[#1d64ec] text-white shadow-xs'
              : 'border-neutral-300 bg-pure-white group-hover:border-neutral-400 peer-focus-visible:ring-2 peer-focus-visible:ring-blue-500'
          }`}
        >
          {checked && <Check className="w-3.5 h-3.5 stroke-[3] text-white animate-in zoom-in-50 duration-150" aria-hidden="true" />}
        </div>
      </div>
      {label && <span className="text-xs text-slate-700 font-medium leading-relaxed">{label}</span>}
    </label>
  );
};
