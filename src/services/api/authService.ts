
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
