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
