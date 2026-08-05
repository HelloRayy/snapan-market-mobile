import React from 'react';
import { cn } from '@/utils/cn';

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  iconRight?: React.ReactNode;
  iconLeft?: React.ReactNode;
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'primary', size = 'md', isLoading, iconLeft, iconRight, children, disabled, ...props }, ref) => {
    // Cloudflare Kumo UI Base Styles
    const baseStyles = 'group relative inline-flex items-center justify-center font-semibold select-none border-0 focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 cursor-pointer disabled:cursor-not-allowed disabled:opacity-50 tracking-tight font-shopify-sans overflow-hidden transition-all duration-150';

    // Pure Cloudflare Kumo UI Color Variants (Matching User Exact Kumo Secondary Snippet)
    const variants = {
      // Primary: Cloudflare Kumo Gradient Button with Inset Highlight Shadow & Outer Ring Border
      primary: 'bg-[#1d64ec] text-white border border-[#154ec1] shadow-md shadow-blue-500/20 active:scale-[0.98]',
      // Secondary: Exact Kumo Secondary Button (bg-white/bg-[#f9fafb], ring-kumo-line ring-1, hover:bg-[#f3f4f6], text-[#111827], shadow-xs)
      secondary: 'bg-white text-[#111827] ring-1 ring-inset ring-[#e5e7eb] shadow-2xs hover:bg-[#f3f4f6] active:scale-[0.98]',
      // Outline
      outline: 'border-2 border-[#1d64ec] bg-white text-[#1d64ec] hover:bg-blue-50 active:scale-[0.98]',
      // Ghost
      ghost: 'text-[#4b5563] hover:bg-[#f3f4f6] hover:text-[#111827] active:scale-[0.98]',
      // Danger
      danger: 'bg-[#dc2626] text-white border border-[#991b1b] shadow-sm active:scale-[0.98]'
    };

    // Kumo Sizes
    const sizes = {
      sm: 'h-9 px-3 text-xs rounded-lg gap-1.5',
      md: 'h-11 px-4.5 text-sm rounded-xl gap-2',
      lg: 'h-14 px-6 text-base rounded-2xl gap-2.5'
    };

    return (
      <button
        ref={ref}
        disabled={disabled || isLoading}
        className={cn(baseStyles, variants[variant], sizes[size], className)}
        {...props}
      >
        {/* Exact Cloudflare Kumo Primary Button Gradient Overlay & Inset Shadow Highlight */}
        {variant === 'primary' && (
          <span className="absolute inset-0 rounded-[inherit] bg-gradient-to-b from-[#3b82f6] to-[#1d64ec] shadow-[inset_0_1px_0_0_rgba(255,255,255,0.35)] group-hover:from-[#2563eb] transition-all duration-150 pointer-events-none" />
        )}

        {/* Content Layer (z-10 to stay above gradient overlay) */}
        <span className="relative z-10 inline-flex items-center justify-center gap-2 w-full">
          {iconLeft && <span className="flex items-center shrink-0">{iconLeft}</span>}
          {isLoading ? (
            <span className="flex items-center gap-2">
              <svg className="animate-spin h-4 w-4 text-current" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <span>Memproses...</span>
            </span>
          ) : (
            <span className="truncate">{children}</span>
          )}
          {iconRight && (
            <span className="flex items-center shrink-0 transition-transform duration-150 ease-out group-hover:translate-x-0.5">
              {iconRight}
            </span>
          )}
        </span>
      </button>
    );
  }
);

Button.displayName = 'Button';

export interface ButtonPrimaryProps extends Omit<ButtonProps, 'variant'> {}

export const ButtonPrimary = React.forwardRef<HTMLButtonElement, ButtonPrimaryProps>(
  (props, ref) => <Button ref={ref} variant="primary" {...props} />
);

ButtonPrimary.displayName = 'ButtonPrimary';

export interface ButtonSecondaryProps extends Omit<ButtonProps, 'variant'> {}

export const ButtonSecondary = React.forwardRef<HTMLButtonElement, ButtonSecondaryProps>(
  (props, ref) => <Button ref={ref} variant="secondary" {...props} />
);

ButtonSecondary.displayName = 'ButtonSecondary';
