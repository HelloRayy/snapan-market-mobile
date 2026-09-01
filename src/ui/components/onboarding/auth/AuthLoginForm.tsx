import React from 'react';
import { Mail, Lock, Eye, EyeOff, AlertCircle, Loader2 } from 'lucide-react';
import { ButtonPrimary } from '../../ui/ButtonPrimary';
import { ButtonSecondary } from '../../ui/ButtonSecondary';
import { Checkbox } from '../../ui/Checkbox';

interface AuthLoginFormProps {
  loginIdentifier: string;
  setLoginIdentifier: (val: string) => void;
  password: string;
  setPassword: (val: string) => void;
  rememberMe: boolean;
  setRememberMe: (val: boolean) => void;
  showPassword: boolean;
  setShowPassword: (val: boolean) => void;
  focusedField: string | null;
  setFocusedField: (val: string | null) => void;
  errors: { loginIdentifier?: string; password?: string };
  setErrors: React.Dispatch<React.SetStateAction<any>>;
  shakeKey: number;
  isSubmitting: boolean;
  onGoogleSignIn: () => void;
}

export const AuthLoginForm: React.FC<AuthLoginFormProps> = ({
  loginIdentifier,
  setLoginIdentifier,
  password,
  setPassword,
  rememberMe,
  setRememberMe,
  showPassword,
  setShowPassword,
  focusedField,
  setFocusedField,
  errors,
  setErrors,
  shakeKey,
  isSubmitting,
  onGoogleSignIn,
}) => {
  return (
    <div className="space-y-4 animate-in fade-in duration-200">
      {/* 1. Identifier Floating Label Input (Email / WhatsApp / Username) */}
      <div>
        <div
          key={`identifier-box-${shakeKey}`}
          className={`relative flex items-center h-14 rounded-[22px] border bg-pure-white px-4 transition-all shadow-2xs ${
            errors.loginIdentifier
              ? 'border-rose-400 bg-rose-50/20 focus-within:border-rose-500 focus-within:ring-2 focus-within:ring-rose-500/20 do-shake'
              : focusedField === 'loginIdentifier'
              ? 'border-[#1d64ec] ring-2 ring-blue-500/20'
              : 'border-neutral-200 hover:border-neutral-300'
          }`}
        >
          <Mail
            className={`h-5 w-5 shrink-0 mr-3 ${
              errors.loginIdentifier
                ? 'text-rose-500'
                : focusedField === 'loginIdentifier'
                ? 'text-[#1d64ec]'
                : 'text-neutral-400'
            }`}
            aria-hidden="true"
          />

          <label
            htmlFor="auth-login-identifier-input"
            className={`absolute pointer-events-none transition-all duration-200 ease-out select-none ${
              focusedField === 'loginIdentifier' || loginIdentifier
                ? 'left-8 top-0 -translate-y-1/2 text-xs bg-pure-white px-1.5 rounded-md'
                : 'left-11 top-1/2 -translate-y-1/2 text-sm font-normal text-neutral-400'
            } ${
              errors.loginIdentifier
                ? 'text-rose-500 font-semibold'
                : focusedField === 'loginIdentifier'
                ? 'text-[#1d64ec]'
                : loginIdentifier
                ? 'text-slate-900 font-semibold'
                : 'text-neutral-400 font-normal'
            }`}
          >
            Email, No. WA, atau Username
          </label>

          <input
            id="auth-login-identifier-input"
            name="identifier"
            type="text"
            autoComplete="username"
            value={loginIdentifier}
            onFocus={() => setFocusedField('loginIdentifier')}
            onBlur={() => setFocusedField(null)}
            onChange={(e) => {
              setLoginIdentifier(e.target.value);
              setErrors((prev: any) => ({ ...prev, loginIdentifier: undefined }));
            }}
            className="w-full bg-transparent text-base font-bold text-slate-900 focus:outline-none pt-1 truncate"
          />
        </div>
        {errors.loginIdentifier && (
          <p className="text-[11px] text-rose-500 font-semibold flex items-center gap-1.5 mt-1.5 ml-1 leading-none animate-in fade-in duration-200">
            <AlertCircle className="h-3.5 w-3.5 shrink-0" />
            <span>{errors.loginIdentifier}</span>
          </p>
        )}
      </div>

      {/* 2. Password Floating Label Input */}
      <div>
        <div
          key={`password-box-${shakeKey}`}
          className={`relative flex items-center h-14 rounded-[22px] border bg-pure-white px-4 transition-all shadow-2xs ${
            errors.password
              ? 'border-rose-400 bg-rose-50/20 focus-within:border-rose-500 focus-within:ring-2 focus-within:ring-rose-500/20 do-shake'
              : focusedField === 'password'
              ? 'border-[#1d64ec] ring-2 ring-blue-500/20'
              : 'border-neutral-200 hover:border-neutral-300'
          }`}
        >
          <Lock
            className={`h-5 w-5 shrink-0 mr-3 ${
              errors.password
                ? 'text-rose-500'
                : focusedField === 'password'
                ? 'text-[#1d64ec]'
                : 'text-neutral-400'
            }`}
            aria-hidden="true"
          />

          <label
            htmlFor="auth-password-input"
            className={`absolute pointer-events-none transition-all duration-200 ease-out select-none ${
              focusedField === 'password' || password
                ? 'left-8 top-0 -translate-y-1/2 text-xs bg-pure-white px-1.5 rounded-md'
                : 'left-11 top-1/2 -translate-y-1/2 text-sm font-normal text-neutral-400'
            } ${
              errors.password
                ? 'text-rose-500 font-semibold'
                : focusedField === 'password'
                ? 'text-[#1d64ec]'
                : password
                ? 'text-slate-900 font-semibold'
                : 'text-neutral-400 font-normal'
            }`}
          >
            Kata Sandi
          </label>

          <input
            id="auth-password-input"
            name="password"
            type={showPassword ? 'text' : 'password'}
            autoComplete="current-password"
            value={password}
            onFocus={() => setFocusedField('password')}
            onBlur={() => setFocusedField(null)}
            onChange={(e) => {
              setPassword(e.target.value);
              setErrors((prev: any) => ({ ...prev, password: undefined }));
            }}
            className="w-full bg-transparent text-base font-bold text-slate-900 focus:outline-none pt-1 truncate"
          />

          <button
            type="button"
            onClick={() => setShowPassword(!showPassword)}
            className="text-neutral-400 hover:text-slate-700 transition-colors p-1.5 cursor-pointer ml-1"
            aria-label={showPassword ? 'Sembunyikan kata sandi' : 'Tampilkan kata sandi'}
          >
            {showPassword ? (
              <EyeOff className="h-4.5 w-4.5" />
            ) : (
              <Eye className="h-4.5 w-4.5" />
            )}
          </button>
        </div>
        {errors.password && (
          <p className="text-[11px] text-rose-500 font-semibold flex items-center gap-1.5 mt-1.5 ml-1 leading-none animate-in fade-in duration-200">
            <AlertCircle className="h-3.5 w-3.5 shrink-0" />
            <span>{errors.password}</span>
          </p>
        )}
      </div>

      {/* Remember Me & Forgot Password */}
      <div className="flex items-center justify-between text-xs py-1">
        <label className="flex items-center gap-2 cursor-pointer select-none">
          <Checkbox checked={rememberMe} onCheckedChange={setRememberMe} />
          <span className="text-slate-700 font-semibold">Ingat Saya</span>
        </label>
        <button
          type="button"
          className="text-neutral-500 font-medium hover:text-[#1d64ec] hover:underline cursor-pointer focus:outline-none"
        >
          Lupa Kata Sandi?
        </button>
      </div>

      {/* Primary Submit Button */}
      <ButtonPrimary
        type="submit"
        size="lg"
        disabled={isSubmitting}
        className="w-full justify-center font-bold h-13 text-sm rounded-full bg-[#1d64ec] hover:bg-blue-600 shadow-md shadow-blue-500/25 text-white cursor-pointer active:scale-[0.98]"
      >
        {isSubmitting ? (
          <Loader2 className="h-5 w-5 animate-spin text-white" />
        ) : (
          'Masuk ke Akun'
        )}
      </ButtonPrimary>

      {/* Divider */}
      <div className="relative flex items-center justify-center py-2">
        <div className="absolute inset-0 flex items-center">
          <div className="w-full border-t border-neutral-200/80" />
        </div>
        <span className="relative bg-pure-white px-3 text-[11px] font-bold text-neutral-400 uppercase tracking-wider">
          atau
        </span>
      </div>

      {/* Google OAuth Button */}
      <ButtonSecondary
        type="button"
        size="lg"
        onClick={onGoogleSignIn}
        className="w-full justify-center font-bold h-13 text-sm rounded-full border-neutral-200/90 hover:bg-neutral-50 active:scale-[0.98] cursor-pointer flex items-center gap-2.5 text-slate-800"
      >
        <svg className="h-4.5 w-4.5 shrink-0" viewBox="0 0 24 24">
          <path
            fill="#4285F4"
            d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"
          />
          <path
            fill="#34A853"
            d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"
          />
          <path
            fill="#FBBC05"
            d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"
          />
          <path
            fill="#EA4335"
            d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"
          />
        </svg>
        <span>Lanjutkan dengan Google</span>
      </ButtonSecondary>
    </div>
  );
};
