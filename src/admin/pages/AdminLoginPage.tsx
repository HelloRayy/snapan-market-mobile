import React, { useState } from 'react';
import { Shield, Lock, Mail, Eye, EyeOff, AlertCircle, ArrowLeft, Loader2 } from 'lucide-react';
import { supabase } from '@/services/api/supabase';
import { adminService } from '../services/adminService';
import { adminSecurityService } from '../services/adminSecurityService';

interface AdminLoginPageProps {
  onSuccess: () => void;
  onBackToApp?: () => void;
}

export function AdminLoginPage({ onSuccess, onBackToApp }: AdminLoginPageProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim() || !password.trim()) {
      setErrorMessage('Silakan isi email dan kata sandi Anda.');
      return;
    }

    setIsLoading(true);
    setErrorMessage(null);

    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email: email.trim(),
        password: password.trim(),
      });

      if (error) {
        throw new Error(error.message || 'Gagal masuk. Periksa kembali email dan kata sandi.');
      }

      if (!data.user) {
        throw new Error('Sesi pengguna tidak ditemukan.');
      }

      // Validasi role admin di tabel profiles
      const isAdmin = await adminService.checkIsAdmin(data.user.id);
      if (!isAdmin) {
        await supabase.auth.signOut();
        setErrorMessage(
          'Akses ditolak: Akun Anda tidak memiliki hak otorisasi Admin SMKN 8 Semarang.'
        );
        setIsLoading(false);
        return;
      }

      // Daftarkan token sesi aktif tunggal & catat log audit
      await adminSecurityService.registerNewSessionToken(data.user.id);
      await adminSecurityService.logActivity({
        adminEmail: data.user.email || email.trim(),
        action: 'LOGIN_PASSWORD',
        targetInfo: 'Otentikasi berhasil via email/kata sandi',
      });

      onSuccess();
    } catch (err: any) {
      setErrorMessage(err.message || 'Terjadi kesalahan saat otentikasi admin.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 flex flex-col justify-center items-center px-4 py-12 selection:bg-indigo-600 selection:text-white">
      {/* Top Navigation Back link */}
      {onBackToApp && (
        <div className="absolute top-6 left-6">
          <button
            type="button"
            onClick={onBackToApp}
            className="flex items-center gap-1.5 text-xs text-slate-500 hover:text-slate-800 transition-colors px-3 py-1.5 rounded-lg hover:bg-slate-200/50 cursor-pointer"
          >
            <ArrowLeft className="h-3.5 w-3.5" />
            Kembali ke Aplikasi Siswa
          </button>
        </div>
      )}

      <div className="w-full max-w-md space-y-6">
        {/* Header Branding */}
        <div className="text-center space-y-2">
          <div className="inline-flex h-12 w-12 items-center justify-center rounded-2xl bg-indigo-600 text-white font-bold text-lg shadow-sm">
            8
          </div>
          <div className="space-y-1">
            <div className="flex items-center justify-center gap-2">
              <h1 className="text-xl font-bold tracking-tight text-slate-900">
                sNaps Admin Portal
              </h1>
              <span className="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-semibold border border-indigo-200 text-indigo-600 bg-indigo-50">
                Internal
              </span>
            </div>
            <p className="text-xs text-slate-500">
              Sistem Manajemen Terpadu Marketplace & Feed SMKN 8 Semarang
            </p>
          </div>
        </div>

        {/* Login Card */}
        <div className="p-6 md:p-8 border border-slate-200 bg-white rounded-2xl shadow-sm">
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="flex items-center gap-2 pb-2 border-b border-slate-100">
              <Shield className="h-4 w-4 text-indigo-600" />
              <span className="text-xs font-semibold uppercase tracking-wider text-slate-500">
                Otentikasi Administrator
              </span>
            </div>

            {/* Error Message Banner */}
            {errorMessage && (
              <div className="flex items-start gap-2.5 p-3 rounded-lg border border-rose-200 bg-rose-50 text-rose-800 text-xs">
                <AlertCircle className="h-4 w-4 shrink-0 text-rose-600 mt-0.5" />
                <span className="leading-relaxed">{errorMessage}</span>
              </div>
            )}

            {/* Email Field */}
            <div className="space-y-1.5">
              <label className="text-xs font-medium text-slate-700 flex items-center gap-1.5">
                <Mail className="h-3.5 w-3.5 text-slate-400" />
                Email Administrator
              </label>
              <div className="relative">
                <input
                  type="email"
                  required
                  placeholder="admin@snapan.id"
                  value={email}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => setEmail(e.target.value)}
                  disabled={isLoading}
                  className="w-full h-10 px-3 py-2 text-sm bg-slate-50/50 border border-slate-200 rounded-lg text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 transition-all disabled:opacity-50 disabled:bg-slate-100"
                />
              </div>
            </div>

            {/* Password Field */}
            <div className="space-y-1.5">
              <label className="text-xs font-medium text-slate-700 flex items-center gap-1.5">
                <Lock className="h-3.5 w-3.5 text-slate-400" />
                Kata Sandi
              </label>
              <div className="relative">
                <input
                  type={showPassword ? 'text' : 'password'}
                  required
                  placeholder="••••••••••••"
                  value={password}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => setPassword(e.target.value)}
                  disabled={isLoading}
                  className="w-full h-10 pl-3 pr-10 py-2 text-sm bg-slate-50/50 border border-slate-200 rounded-lg text-slate-900 placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-600 transition-all disabled:opacity-50 disabled:bg-slate-100"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-700 transition-colors p-1 cursor-pointer"
                >
                  {showPassword ? (
                    <EyeOff className="h-4 w-4" />
                  ) : (
                    <Eye className="h-4 w-4" />
                  )}
                </button>
              </div>
            </div>

            {/* Submit Button */}
            <div className="pt-2">
              <button
                type="submit"
                disabled={isLoading}
                className="w-full h-10 px-4 py-2 text-sm font-medium bg-indigo-600 hover:bg-indigo-700 active:bg-indigo-800 text-white rounded-lg shadow-sm transition-all flex items-center justify-center gap-2 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isLoading ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin text-white" />
                    <span>Memverifikasi Hak Akses...</span>
                  </>
                ) : (
                  <span>Masuk ke Portal Admin</span>
                )}
              </button>
            </div>
          </form>
        </div>

        {/* Footer info */}
        <div className="text-center">
          <p className="text-[11px] text-slate-500">
            Hanya dapat diakses oleh akun terverifikasi dengan role <span className="font-mono text-indigo-600">admin</span> pada basis data SMKN 8 Semarang.
          </p>
        </div>
      </div>
    </div>
  );
}
