import React, { useRef, useEffect } from 'react';
import { AlertCircle, Loader2, Headphones } from 'lucide-react';
import { ButtonPrimary } from '../../ui/ButtonPrimary';

interface AuthOtpVerificationSheetProps {
  otpDigits: string[];
  errors: { otpCode?: string };
  shakeKey: number;
  isSubmitting: boolean;
  countdown: number;
  onOtpChange: (index: number, val: string) => void;
  onOtpKeyDown: (index: number, e: React.KeyboardEvent<HTMLInputElement>) => void;
  onOtpPaste: (e: React.ClipboardEvent<HTMLInputElement>) => void;
  onVerifyOtp: (e: React.FormEvent) => void;
  onResendOtp: () => void;
}

export const AuthOtpVerificationSheet: React.FC<AuthOtpVerificationSheetProps> = ({
  otpDigits,
  errors,
  shakeKey,
  isSubmitting,
  countdown,
  onOtpChange,
  onOtpKeyDown,
  onOtpPaste,
  onVerifyOtp,
  onResendOtp,
}) => {
  const otpInputsRef = useRef<(HTMLInputElement | null)[]>([]);

  useEffect(() => {
    const timer = setTimeout(() => {
      otpInputsRef.current[0]?.focus();
    }, 100);
    return () => clearTimeout(timer);
  }, []);

  return (
    <form onSubmit={onVerifyOtp} className="space-y-6 pt-4 text-center animate-in fade-in slide-in-from-right-4 duration-300 ease-out">
      {/* Centered Main Title & Subtitle */}
      <div className="space-y-2">
        <h2 className="text-2xl font-extrabold tracking-tight text-slate-900 font-shopify-sans">
          Masukkan Kode Verifikasi
        </h2>
        <p className="text-xs text-slate-600 font-medium leading-relaxed max-w-xs mx-auto">
          Silakan masukkan 6 angka kode OTP yang telah kami kirimkan.
        </p>
      </div>

      {/* 6-Digit PIN Boxes */}
      <div className="space-y-2">
        <div
          key={`otp-box-${shakeKey}`}
          className={`flex items-center justify-center gap-2 my-2 ${errors.otpCode ? 'do-shake' : ''}`}
          role="group"
          aria-label="Kotak Isian Kode Verifikasi OTP 6-Digit"
        >
          {otpDigits.map((digit, idx) => (
            <input
              key={idx}
              ref={(el) => (otpInputsRef.current[idx] = el)}
              type="tel"
              inputMode="numeric"
              pattern="[0-9]*"
              autoComplete="one-time-code"
              maxLength={1}
              value={digit}
              aria-label={`Digit ${idx + 1} dari 6 untuk kode verifikasi OTP`}
              aria-invalid={!!errors.otpCode}
              onChange={(e) => onOtpChange(idx, e.target.value)}
              onKeyDown={(e) => onOtpKeyDown(idx, e)}
              onPaste={onOtpPaste}
              className={`w-12 h-14 text-center text-xl font-extrabold rounded-2xl border transition-all duration-150 shadow-2xs focus:outline-none ${
                errors.otpCode
                  ? 'border-rose-400 bg-rose-50/30 text-rose-600 focus:border-rose-500 focus:ring-4 focus:ring-rose-500/20'
                  : digit
                  ? 'border-[#1d64ec] bg-blue-50/40 text-[#1d64ec] ring-2 ring-blue-500/20 focus:scale-[1.04] focus:ring-4 focus:ring-blue-500/25'
                  : 'border-neutral-200 bg-neutral-50/50 text-slate-900 focus:border-[#1d64ec] focus:bg-pure-white focus:scale-[1.04] focus:ring-4 focus:ring-blue-500/25'
              }`}
            />
          ))}
        </div>

        {errors.otpCode && (
          <p className="text-[11px] text-rose-500 font-semibold flex items-center justify-center gap-1.5 leading-none animate-in fade-in duration-200" role="alert">
            <AlertCircle className="h-3.5 w-3.5 shrink-0" />
            <span>{errors.otpCode}</span>
          </p>
        )}
      </div>

      {/* Verify Primary Button */}
      <ButtonPrimary
        type="submit"
        size="lg"
        disabled={isSubmitting}
        className="w-full justify-center font-bold h-14 text-base rounded-full bg-[#1d64ec] hover:bg-blue-600 shadow-md shadow-blue-500/25 text-white cursor-pointer active:scale-[0.98]"
      >
        {isSubmitting ? (
          <Loader2 className="h-5 w-5 animate-spin text-white" />
        ) : (
          'Verifikasi'
        )}
      </ButtonPrimary>

      {/* Resend & Timer Text */}
      <div className="space-y-3 text-center text-xs" role="status" aria-live="polite">
        {countdown > 0 ? (
          <p className="text-slate-600 font-medium">
            Kirim ulang kode dalam <span className="font-bold text-slate-900">{countdown} detik</span>
          </p>
        ) : (
          <button
            type="button"
            onClick={onResendOtp}
            className="font-bold text-[#1d64ec] hover:underline cursor-pointer focus-visible:ring-2 focus-visible:ring-blue-500 rounded-sm"
          >
            Kirim Ulang Kode
          </button>
        )}

        {/* Customer Service Link */}
        <div className="pt-2 flex items-center justify-center gap-1.5">
          <span className="text-neutral-500">Butuh bantuan?</span>
          <button
            type="button"
            className="inline-flex items-center gap-1 font-bold text-[#1d64ec] hover:underline cursor-pointer focus:outline-none focus-visible:ring-2 focus-visible:ring-blue-500 rounded-sm"
          >
            <Headphones className="h-3.5 w-3.5 text-[#1d64ec]" aria-hidden="true" />
            <span>Hubungi Bantuan</span>
          </button>
        </div>
      </div>
    </form>
  );
};
