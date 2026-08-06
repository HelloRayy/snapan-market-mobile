import React from 'react';
import { Download, X } from 'lucide-react';
import { usePWA } from '@/ui/hooks/usePWA';
import { ButtonPrimary } from '../ui/ButtonPrimary';

export const InstallBanner: React.FC = () => {
  const { isInstallable, promptInstall } = usePWA();
  const [dismissed, setDismissed] = React.useState(false);

  if (!isInstallable || dismissed) return null;

  return (
    <div className="fixed top-3 left-3 right-3 z-50 rounded-2xl border border-emerald-500/30 bg-slate-900/95 p-3.5 shadow-2xl backdrop-blur-xl animate-in slide-in-from-top-4 duration-300">
      <div className="flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
            <Download className="h-5 w-5" />
          </div>
          <div>
            <h4 className="text-sm font-semibold text-slate-100">Install Snapan Market</h4>
            <p className="text-xs text-slate-400">Akses cepat & bekerja offline di HP kamu</p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <ButtonPrimary size="sm" onClick={promptInstall}>
            Install
          </ButtonPrimary>
          <button
            onClick={() => setDismissed(true)}
            className="rounded-lg p-1 text-slate-400 hover:bg-slate-800 hover:text-white"
            aria-label="Tutup banner"
          >
            <X className="h-4 w-4" />
          </button>
        </div>
      </div>
    </div>
  );
};
