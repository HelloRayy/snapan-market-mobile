import React, { useState } from 'react';
import { Shield, Lock, Mail, Eye, EyeOff, AlertCircle, ArrowLeft } from 'lucide-react';
import { Button, Input, LayerCard, Badge } from '@cloudflare/kumo';
import { supabase } from '@/services/api/supabase';
import { adminService } from '../services/adminService';

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
          'Akses ditolak: Akun Anda tidak memiliki hak otorisasi Admin SMKN 8 Jakarta.'
        );
        setIsLoading(false);
        return;
      }

      onSuccess();
    } catch (err: any) {
      setErrorMessage(err.message || 'Terjadi kesalahan saat otentikasi admin.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-kumo-canvas flex flex-col justify-center items-center px-4 py-12 selection:bg-indigo-600 selection:text-white">
      {/* Top Navigation Back link */}
      {onBackToApp && (
        <div className="absolute top-6 left-6">
          <Button
            variant="ghost"
            size="sm"
            onClick={onBackToApp}
            className="flex items-center gap-1.5 text-xs text-kumo-subtle hover:text-kumo-default"
          >
            <ArrowLeft className="h-3.5 w-3.5" />
            Kembali ke Aplikasi Siswa
          </Button>
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
              <h1 className="text-xl font-bold tracking-tight text-kumo-default">
                sNaps Admin Portal
              </h1>
              <Badge variant="outline" className="border-indigo-200 text-indigo-600 bg-indigo-50 text-[10px]">
                Internal
              </Badge>
            </div>
            <p className="text-xs text-kumo-subtle">
              Sistem Manajemen Terpadu Marketplace & Feed SMKN 8 Jakarta
            </p>
          </div>
        </div>

        {/* Login Card */}
        <LayerCard className="p-6 md:p-8 border border-kumo-hairline bg-kumo-canvas rounded-2xl shadow-sm">
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="flex items-center gap-2 pb-2 border-b border-kumo-hairline">
              <Shield className="h-4 w-4 text-indigo-600" />
              <span className="text-xs font-semibold uppercase tracking-wider text-kumo-subtle">
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
              <label className="text-xs font-medium text-kumo-default flex items-center gap-1.5">
                <Mail className="h-3.5 w-3.5 text-kumo-subtle" />
                Email Administrator
              </label>
              <Input
                type="email"
                required
                placeholder="admin@snapan.id"
                value={email}
                onChange={(e: React.ChangeEvent<HTMLInputElement>) => setEmail(e.target.value)}
                disabled={isLoading}
                className="w-full text-sm"
              />
            </div>

            {/* Password Field */}
            <div className="space-y-1.5">
              <label className="text-xs font-medium text-kumo-default flex items-center gap-1.5">
                <Lock className="h-3.5 w-3.5 text-kumo-subtle" />
                Kata Sandi
              </label>
              <div className="relative">
                <Input
                  type={showPassword ? 'text' : 'password'}
                  required
                  placeholder="••••••••••••"
                  value={password}
                  onChange={(e: React.ChangeEvent<HTMLInputElement>) => setPassword(e.target.value)}
                  disabled={isLoading}
                  className="w-full pr-10 text-sm"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-3 top-1/2 -translate-y-1/2 text-kumo-subtle hover:text-kumo-default transition-colors"
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
              <Button
                type="submit"
                variant="primary"
                disabled={isLoading}
                className="w-full py-2.5 text-sm font-medium bg-indigo-600 hover:bg-indigo-700 text-white shadow-xs justify-center"
              >
                {isLoading ? 'Memverifikasi Hak Akses...' : 'Masuk ke Portal Admin'}
              </Button>
            </div>
          </form>
        </LayerCard>

        {/* Footer info */}
        <div className="text-center">
          <p className="text-[11px] text-kumo-subtle">
            Hanya dapat diakses oleh akun terverifikasi dengan role <span className="font-mono text-indigo-600">admin</span> pada basis data SMKN 8 Jakarta.
          </p>
        </div>
      </div>
    </div>
  );
}
