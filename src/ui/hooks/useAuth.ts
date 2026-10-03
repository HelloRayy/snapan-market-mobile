import { useEffect, useState } from 'react';
import { User, Session } from '@supabase/supabase-js';
import { supabase } from '@/services/api/supabase';
import { 
  signInWithGoogle, 
  signInWithEmail, 
  signUpWithEmail, 
  signOut, 
  getCurrentProfile 
} from '@/services/api/authService';
import type { Profile } from '@/types/supabase';

export function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [session, setSession] = useState<Session | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    let profileChannel: any = null;

    const checkAndHandleSuspension = (prof: Profile | null): boolean => {
      if (prof?.is_suspended && prof.role !== 'admin') {
        const until = prof.suspended_until ? new Date(prof.suspended_until) : null;
        const isStillSuspended = !until || until.getTime() > Date.now();
        if (isStillSuspended) {
          const notice = {
            reason: prof.suspend_reason || 'Pelanggaran terhadap tata tertib komunitas SMKN 8 Semarang.',
            suspendedUntil: prof.suspended_until,
            fullName: prof.full_name,
            username: prof.username,
          };
          try {
            sessionStorage.setItem('snapan_suspended_notice', JSON.stringify(notice));
          } catch {}
          window.dispatchEvent(new CustomEvent('snapan_account_suspended', { detail: notice }));
          supabase.auth.signOut().catch(() => {});
          return true;
        }
      }
      return false;
    };

    const setupRealtimeSubscription = (userId: string) => {
      if (profileChannel) {
        supabase.removeChannel(profileChannel);
      }
      profileChannel = supabase
        .channel(`public:profiles:${userId}`)
        .on(
          'postgres_changes',
          {
            event: 'UPDATE',
            schema: 'public',
            table: 'profiles',
            filter: `id=eq.${userId}`,
          },
          async (payload: any) => {
            const updated = payload.new as Profile;
            if (checkAndHandleSuspension(updated)) {
              setSession(null);
              setUser(null);
              setProfile(null);
            } else {
              setProfile(updated);
            }
          }
        )
        .subscribe();
    };

    // 1. Ambil session awal
    supabase.auth.getSession().then(async ({ data: { session } }) => {
      if (session?.user) {
        try {
          const prof = await getCurrentProfile();
          if (checkAndHandleSuspension(prof)) {
            setSession(null);
            setUser(null);
            setProfile(null);
            setIsLoading(false);
            return;
          }
          setSession(session);
          setUser(session.user);
          setProfile(prof);
          setupRealtimeSubscription(session.user.id);
        } catch (err) {
          console.warn('Gagal memuat profile awal:', err);
          setSession(session);
          setUser(session?.user ?? null);
        }
      } else {
        setSession(null);
        setUser(null);
        setProfile(null);
      }
      setIsLoading(false);
    });

    // 2. Listener perubahan sesi (login, logout, token refresh)
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (_event, session) => {
        if (session?.user) {
          try {
            const prof = await getCurrentProfile();
            if (checkAndHandleSuspension(prof)) {
              setSession(null);
              setUser(null);
              setProfile(null);
              setIsLoading(false);
              return;
            }
            setSession(session);
            setUser(session.user);
            setProfile(prof);
            setupRealtimeSubscription(session.user.id);
          } catch (err) {
            console.warn('Gagal update profile listener:', err);
            setSession(session);
            setUser(session?.user ?? null);
          }
        } else {
          setSession(null);
          setUser(null);
          setProfile(null);
          if (profileChannel) {
            supabase.removeChannel(profileChannel);
            profileChannel = null;
          }
        }
        setIsLoading(false);
      }
    );

    return () => {
      subscription.unsubscribe();
      if (profileChannel) {
        supabase.removeChannel(profileChannel);
      }
    };
  }, []);

  return {
    user,
    profile,
    session,
    isLoading,
    isAuthenticated: !!user,
    signInWithGoogle,
    signInWithEmail,
    signUpWithEmail,
    signOut
  };
}
