import { useEffect, useRef } from 'react';
import { adminSecurityService } from '../services/adminSecurityService';

interface UseAdminSecurityProps {
  userId?: string | null;
  onLogout: () => void;
  idleTimeoutMinutes?: number;
}

export function useAdminSecurity({
  userId,
  onLogout,
  idleTimeoutMinutes = 20,
}: UseAdminSecurityProps) {
  const idleTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // 1. Inactivity Auto-Lock Timer
  useEffect(() => {
    if (!userId) return;

    const timeoutMs = idleTimeoutMinutes * 60 * 1000;

    const resetTimer = () => {
      if (idleTimerRef.current) clearTimeout(idleTimerRef.current);
      idleTimerRef.current = setTimeout(() => {
        alert('Sesi admin kedaluwarsa: Tidak ada aktivitas selama 20 menit.');
        adminSecurityService.clearLocalSessionToken();
        onLogout();
      }, timeoutMs);
    };

    resetTimer();

    const activityEvents = ['mousemove', 'keydown', 'click', 'scroll', 'touchstart'];
    activityEvents.forEach((evt) => window.addEventListener(evt, resetTimer, { passive: true }));

    return () => {
      if (idleTimerRef.current) clearTimeout(idleTimerRef.current);
      activityEvents.forEach((evt) => window.removeEventListener(evt, resetTimer));
    };
  }, [userId, onLogout, idleTimeoutMinutes]);

  // 2. Single Device Session Verification
  useEffect(() => {
    if (!userId) return;

    let isMounted = true;

    async function checkConcurrentSession() {
      if (!userId || !isMounted) return;
      const isSessionValid = await adminSecurityService.validateActiveSession(userId);
      if (!isSessionValid && isMounted) {
        alert('Akses Dibatasi: Akun admin Anda telah aktif di perangkat lain. Sesi ini ditutup otomatis.');
        adminSecurityService.clearLocalSessionToken();
        onLogout();
      }
    }

    // Check on tab focus
    const handleFocus = () => {
      checkConcurrentSession();
    };
    window.addEventListener('focus', handleFocus);

    // Periodic check every 45 seconds
    const interval = setInterval(checkConcurrentSession, 45000);

    return () => {
      isMounted = false;
      window.removeEventListener('focus', handleFocus);
      clearInterval(interval);
    };
  }, [userId, onLogout]);
}
