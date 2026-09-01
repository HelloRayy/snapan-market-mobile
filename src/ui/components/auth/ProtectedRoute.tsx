import React from 'react';
import { useAuth } from '@/ui/hooks/useAuth';
import { Button } from '@/ui/components/ui/Button';

interface ProtectedRouteProps {
  children: React.ReactNode;
}

export const ProtectedRoute: React.FC<ProtectedRouteProps> = ({ children }) => {
  const { isAuthenticated, isLoading, signInWithGoogle } = useAuth();

  if (isLoading) {
    return (
      <div className="flex h-screen items-center justify-center bg-slate-900 text-slate-100">
        <div className="flex flex-col items-center gap-3">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-emerald-500 border-t-transparent"></div>
          <p className="text-sm font-medium text-slate-400">Memuat sesi...</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center p-6 bg-slate-900 text-slate-100 text-center">
        <div className="max-w-sm space-y-4">
          <h2 className="text-2xl font-bold text-slate-100">Akses Terbatas</h2>
          <p className="text-sm text-slate-400">
            Silakan login terlebih dahulu untuk mengakses halaman marketplace ini.
          </p>
          <Button variant="primary" size="lg" className="w-full" onClick={signInWithGoogle}>
            Login dengan Google
          </Button>
        </div>
      </div>
    );
  }

  return <>{children}</>;
};
