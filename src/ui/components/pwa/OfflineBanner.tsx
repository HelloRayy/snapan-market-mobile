import React from 'react';
import { WifiOff } from 'lucide-react';
import { useOnlineStatus } from '@/ui/hooks/useOnlineStatus';

export const OfflineBanner: React.FC = () => {
  const isOnline = useOnlineStatus();

  if (isOnline) return null;

  return (
    <div className="fixed top-0 left-0 right-0 z-50 bg-rose-500 text-white text-xs font-semibold px-4 py-1.5 flex items-center justify-center gap-2 shadow-lg">
      <WifiOff className="w-3.5 h-3.5" />
      <span>Kamu sedang Offline. Menampilkan data tersimpan di perangkat.</span>
    </div>
  );
};
