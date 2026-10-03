
import { supabase } from './supabase';
import type { Profile } from '@/types/supabase';

/**
 * Sign In dengan Google OAuth Provider
 */
export async function signInWithGoogle() {
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: {
      redirectTo: window.location.origin
    }
  });

  if (error) {
    console.error('Error signing in with Google:', error.message);
    throw error;
  }

  return data;
}

export interface AccountSuspensionNotice {
  reason: string;
  suspendedUntil: string | null;
  fullName?: string;
  username?: string;
}

export class AccountSuspendedError extends Error {
  code = 'ACCOUNT_SUSPENDED' as const;
  suspension: AccountSuspensionNotice;

  constructor(suspension: AccountSuspensionNotice) {
    super(`Akun ini sedang ditangguhkan: ${suspension.reason}`);
    this.name = 'AccountSuspendedError';
    this.suspension = suspension;
  }
}

export function getStoredSuspensionNotice(): AccountSuspensionNotice | null {
  try {
    const raw = sessionStorage.getItem('snapan_suspended_notice');
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

export function clearStoredSuspensionNotice() {
  try {
    sessionStorage.removeItem('snapan_suspended_notice');
  } catch {}
}

/**
 * Sign In dengan Email & Password (mendukung identifier email atau username)
 */
export async function signInWithEmail(emailOrIdentifier: string, password: string) {
  let email = emailOrIdentifier.trim();
  if (!email.includes('@')) {
    const cleanUsername = email.toLowerCase().replace(/^@/, '');
    email = `${cleanUsername}@snapan.id`;
  }

  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password
  });

  if (error) {
    console.error('Error signing in with email:', error.message);
    throw error;
  }

  // Check if profile is suspended
  if (data?.user) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('id, full_name, username, is_suspended, suspended_until, suspend_reason, role')
      .eq('id', data.user.id)
      .maybeSingle();

    if (profile?.is_suspended && profile.role !== 'admin') {
      const until = profile.suspended_until ? new Date(profile.suspended_until) : null;
      const isStillSuspended = !until || until.getTime() > Date.now();
      if (isStillSuspended) {
        // Sign out immediately to purge session
        await supabase.auth.signOut();
        const notice: AccountSuspensionNotice = {
          reason: profile.suspend_reason || 'Pelanggaran terhadap tata tertib komunitas SMKN 8 Semarang.',
          suspendedUntil: profile.suspended_until ?? null,
          fullName: profile.full_name || undefined,
          username: profile.username || undefined,
        };
        sessionStorage.setItem('snapan_suspended_notice', JSON.stringify(notice));
        throw new AccountSuspendedError(notice);
      }
    }
  }

  // Sesi valid dan normal: bersihkan notice tersimpan jika ada
  sessionStorage.removeItem('snapan_suspended_notice');

  return data;
}

/**
 * Sign Up dengan Email & Password
 */
export async function signUpWithEmail(email: string, password: string, fullName?: string, classGroup?: string) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: {
        full_name: fullName || 'Siswa Snapan',
        name: fullName || 'Siswa Snapan',
        class_group: classGroup || 'Siswa Snapan'
      }
    }
  });

  if (error) {
    console.error('Error signing up with email:', error.message);
    throw error;
  }

  // Backup Manual Upsert ke public.profiles jika trigger belum terpasang
  if (data?.user) {
    try {
      await supabase.from('profiles').upsert({
        id: data.user.id,
        full_name: fullName || 'Siswa Snapan',
        class_group: classGroup || 'Siswa Snapan',
        role: 'user'
      });
    } catch (profileErr) {
      console.warn('Manual profile upsert skipped:', profileErr);
    }
  }

  return data;
}

/**
 * Keluar dari sesi (Sign Out)
 */
export async function signOut() {
  const { error } = await supabase.auth.signOut();
  if (error) {
    console.error('Error signing out:', error.message);
    throw error;
  }
}

/**
 * Mendapatkan user aktif dari Supabase Auth Session
 */
export async function getCurrentUser() {
  const { data: { user }, error } = await supabase.auth.getUser();
  if (error) {
    console.error('Error getting current user:', error.message);
    return null;
  }
  return user;
}

/**
 * Mendapatkan profil lengkap dari tabel `public.profiles` berdasarkan Auth User
 */
export async function getCurrentProfile(): Promise<Profile | null> {
  const user = await getCurrentUser();
  if (!user) return null;

  const { data: profile, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .maybeSingle();

  if (error) {
    console.error('Error fetching current user profile:', error.message);
    throw error;
  }

  return profile;
}

/**
 * Update data profil pengguna
 */
export async function updateProfile(userId: string, updates: Partial<Omit<Profile, 'id' | 'created_at'>>) {
  const { data, error } = await supabase
    .from('profiles')
    .update(updates)
    .eq('id', userId)
    .select()
    .single();

  if (error) {
    console.error(`Error updating profile for user ${userId}:`, error.message);
    throw error;
  }

  return data;
}

/**
 * Listener perubahan status otentikasi (login / logout)
 */
export async function onAuthStateChange(callback: (event: string, session: unknown) => void) {
  return supabase.auth.onAuthStateChange(callback);
}
