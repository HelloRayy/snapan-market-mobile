import { supabase } from './supabase';
import type { ProfileWithFollowStats } from '@/types/supabase';

/**
 * Fetch profil pengguna berdasarkan username beserta jumlah follower/following & status follow
 */
export async function getProfileByUsername(
  username: string,
  currentUserId?: string
): Promise<ProfileWithFollowStats | null> {
  const { data: profile, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('username', username)
    .maybeSingle();

  if (error || !profile) {
    if (error) console.error(`Error fetching profile for username ${username}:`, error.message);
    return null;
  }

  // Fetch count of followers & following
  const { count: followersCount } = await supabase
    .from('user_follows')
    .select('*', { count: 'exact', head: true })
    .eq('following_id', profile.id);

  const { count: followingCount } = await supabase
    .from('user_follows')
    .select('*', { count: 'exact', head: true })
    .eq('follower_id', profile.id);

  // Check if current logged-in user is following this profile
  let isFollowedByUser = false;
  if (currentUserId && currentUserId !== profile.id) {
    const { data: followRecord } = await supabase
      .from('user_follows')
      .select('follower_id')
      .eq('follower_id', currentUserId)
      .eq('following_id', profile.id)
      .maybeSingle();

    isFollowedByUser = !!followRecord;
  }

  return {
    ...profile,
    followers_count: followersCount || 0,
    following_count: followingCount || 0,
    is_followed_by_user: isFollowedByUser
  };
}

/**
 * Toggle Follow / Unfollow user lain
 */
export async function toggleFollowUser(
  followerId: string,
  followingId: string,
  isFollowing: boolean
): Promise<void> {
  if (followerId === followingId) {
    throw new Error('Anda tidak dapat mengikuti akun sendiri');
  }

  if (isFollowing) {
    const { error } = await supabase
      .from('user_follows')
      .delete()
      .eq('follower_id', followerId)
      .eq('following_id', followingId);

    if (error) {
      console.error(`Error unfollowing user ${followingId}:`, error.message);
      throw error;
    }
  } else {
    const { error } = await supabase
      .from('user_follows')
      .insert({
        follower_id: followerId,
        following_id: followingId
      });

    if (error) {
      console.error(`Error following user ${followingId}:`, error.message);
      throw error;
    }
  }
}

/**
 * Fetch profil pengguna berdasarkan User ID (UUID)
 */
export async function getProfileById(userId: string): Promise<ProfileWithFollowStats | null> {
  const { data: profile, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', userId)
    .maybeSingle();

  if (error || !profile) {
    if (error) console.error(`Error fetching profile for id ${userId}:`, error.message);
    return null;
  }

  const { count: followersCount } = await supabase
    .from('user_follows')
    .select('*', { count: 'exact', head: true })
    .eq('following_id', profile.id);

  const { count: followingCount } = await supabase
    .from('user_follows')
    .select('*', { count: 'exact', head: true })
    .eq('follower_id', profile.id);

  return {
    ...profile,
    followers_count: followersCount || 0,
    following_count: followingCount || 0,
    is_followed_by_user: false
  };
}

export interface UsernameCheckResult {
  available: boolean;
  cleanUsername: string;
  reason?: 'too_short' | 'invalid_chars' | 'reserved' | 'taken' | 'error';
  message?: string;
}

const RESERVED_USERNAMES = new Set([
  'admin',
  'administrator',
  'root',
  'snapan',
  'official',
  'support',
  'help',
  'system',
  'moderator',
  'smkn8',
  'smkn8semarang',
  'bot',
  'user',
  'guest',
  'public',
  'dashboard',
  'auth',
  'profile',
  'search',
  'direct',
  'messages',
  'market',
  'store'
]);

/**
 * Cek ketersediaan username di Supabase (public.profiles)
 * Digunakan untuk live check di Landing Page & flow registrasi/onboarding
 */
export async function checkUsernameAvailability(rawUsername: string): Promise<UsernameCheckResult> {
  const cleanUsername = rawUsername.replace(/^@+/, '').trim().toLowerCase();

  if (cleanUsername.length < 3) {
    return {
      available: false,
      cleanUsername,
      reason: 'too_short',
      message: 'Minimal 3 karakter'
    };
  }

  if (cleanUsername.length > 20 || !/^[a-z0-9_.]+$/.test(cleanUsername)) {
    return {
      available: false,
      cleanUsername,
      reason: 'invalid_chars',
      message: 'Hanya huruf kecil, angka, garis bawah (_), dan titik (.)'
    };
  }

  if (RESERVED_USERNAMES.has(cleanUsername)) {
    return {
      available: false,
      cleanUsername,
      reason: 'reserved',
      message: 'Username ini dilindungi oleh sistem'
    };
  }

  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('id, username')
      .ilike('username', cleanUsername)
      .maybeSingle();

    if (error) {
      console.warn('Error checking username availability from Supabase:', error.message);
      return {
        available: false,
        cleanUsername,
        reason: 'error',
        message: 'Gagal mengecek ke server'
      };
    }

    if (data) {
      return {
        available: false,
        cleanUsername,
        reason: 'taken',
        message: 'Username sudah digunakan oleh akun lain'
      };
    }

    return {
      available: true,
      cleanUsername,
      message: 'Username tersedia!'
    };
  } catch (err: any) {
    console.warn('Exception during username availability check:', err);
    return {
      available: false,
      cleanUsername,
      reason: 'error',
      message: 'Gagal memeriksa ketersediaan'
    };
  }
}

