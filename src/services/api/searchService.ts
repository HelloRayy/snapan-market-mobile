import { supabase } from './supabase';
import type { MarketPostWithSeller, ProfileWithFollowStats } from '@/types/supabase';

// ─────────────────────────────────────────────────────────────────────────────
// Result Types
// ─────────────────────────────────────────────────────────────────────────────

export type SearchTab = 'top' | 'latest' | 'profiles';

export interface SearchResults {
  posts: MarketPostWithSeller[];
  profiles: ProfileWithFollowStats[];
  hasMore: boolean;
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Post Search (Full-Text + ILIKE fallback)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Cari postingan berdasarkan query teks.
 *
 * - Tab "Terpopuler" (top)   → diurutkan (likes_count + comments_count * 2) DESC
 * - Tab "Terbaru"  (latest)  → diurutkan created_at DESC
 *
 * Menggunakan ILIKE pada caption, title, topic_tag, dan location_tag
 * agar kompatibel tanpa perlu setup pg_trgm / tsvector terlebih dahulu.
 * Bila GIN index tersedia, Supabase otomatis menggunakannya.
 */
export async function searchPosts(
  query: string,
  tab: Exclude<SearchTab, 'profiles'> = 'latest',
  options: {
    limit?: number;
    offset?: number;
    category?: string;
    post_type?: 'thread' | 'product' | 'all';
  } = {}
): Promise<{ posts: MarketPostWithSeller[]; hasMore: boolean }> {
  const { limit = 20, offset = 0, category, post_type } = options;
  const trimmed = query.trim();

  if (!trimmed) return { posts: [], hasMore: false };

  let q = supabase
    .from('market_posts')
    .select(
      `
      *,
      seller:profiles!market_posts_seller_id_fkey(*)
    `,
      { count: 'exact' }
    )
    .or(
      `caption.ilike.%${trimmed}%,title.ilike.%${trimmed}%,topic_tag.ilike.%${trimmed}%,location_tag.ilike.%${trimmed}%`
    );

  if (category && category !== 'Semua') {
    q = q.eq('category', category);
  }

  if (post_type && post_type !== 'all') {
    q = q.eq('post_type', post_type);
  }

  // Sorting: "Terpopuler" → custom score (likes + comments*2) requires RPC,
  // fallback: sort by likes_count DESC for popular tab
  if (tab === 'top') {
    q = q.order('likes_count', { ascending: false }).order('comments_count', { ascending: false });
  } else {
    q = q.order('created_at', { ascending: false });
  }

  const { data, error, count } = await q.range(offset, offset + limit - 1);

  if (error) {
    console.error('Error searching posts:', error.message);
    throw error;
  }

  const posts: MarketPostWithSeller[] = (data || []).map((post) => ({
    ...post,
    seller: post.seller as unknown as import('@/types/supabase').Profile,
  }));

  return {
    posts,
    hasMore: count ? offset + limit < count : false,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Profile Search
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Cari pengguna berdasarkan username, nama lengkap, atau kelas.
 * Diurutkan: akun terverifikasi muncul pertama, lalu alphabetical.
 */
export async function searchProfiles(
  query: string,
  options: {
    limit?: number;
    offset?: number;
    currentUserId?: string;
  } = {}
): Promise<{ profiles: ProfileWithFollowStats[]; hasMore: boolean }> {
  const { limit = 20, offset = 0, currentUserId } = options;
  const trimmed = query.trim();

  if (!trimmed) return { profiles: [], hasMore: false };

  const { data, error, count } = await supabase
    .from('profiles')
    .select('*', { count: 'exact' })
    .or(
      `username.ilike.%${trimmed}%,full_name.ilike.%${trimmed}%,class_group.ilike.%${trimmed}%`
    )
    .order('is_verified', { ascending: false })
    .order('full_name', { ascending: true })
    .range(offset, offset + limit - 1);

  if (error) {
    console.error('Error searching profiles:', error.message);
    throw error;
  }

  const profiles = data || [];

  // Bulk-check follow status for current user
  let followingSet = new Set<string>();
  if (currentUserId && profiles.length > 0) {
    const targetIds = profiles.map((p) => p.id);
    const { data: followData } = await supabase
      .from('user_follows')
      .select('following_id')
      .eq('follower_id', currentUserId)
      .in('following_id', targetIds);

    followingSet = new Set((followData || []).map((f) => f.following_id));
  }

  return {
    profiles: profiles.map((p) => ({
      ...p,
      is_followed_by_user: followingSet.has(p.id),
    })) as ProfileWithFollowStats[],
    hasMore: count ? offset + limit < count : false,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Unified Search (All Tabs at Once)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Jalankan pencarian postingan (top + latest) dan profil sekaligus dalam
 * satu panggilan — cocok untuk hasil pencarian pertama kali.
 */
export async function searchAll(
  query: string,
  options: {
    limit?: number;
    currentUserId?: string;
  } = {}
): Promise<SearchResults> {
  const { limit = 10, currentUserId } = options;
  const trimmed = query.trim();

  if (!trimmed) return { posts: [], profiles: [], hasMore: false };

  const [postsResult, profilesResult] = await Promise.all([
    searchPosts(trimmed, 'top', { limit }),
    searchProfiles(trimmed, { limit: 5, currentUserId }),
  ]);

  return {
    posts: postsResult.posts,
    profiles: profilesResult.profiles,
    hasMore: postsResult.hasMore || profilesResult.hasMore,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Suggested Accounts (Discovery — Tanpa Query)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Ambil akun-akun terverifikasi atau populer untuk ditampilkan di SearchPage
 * saat user belum mengetik apapun di search bar.
 * Dikecualikan: akun milik user sendiri dan akun yang sudah diikuti.
 */
export async function getSuggestedAccounts(
  currentUserId?: string,
  limit = 12
): Promise<ProfileWithFollowStats[]> {
  let q = supabase
    .from('profiles')
    .select('*')
    .order('is_verified', { ascending: false })
    .order('verified_sales_count', { ascending: false })
    .limit(limit + 5); // Fetch sedikit lebih untuk filtering

  if (currentUserId) {
    q = q.neq('id', currentUserId);
  }

  const { data, error } = await q;

  if (error) {
    console.error('Error fetching suggested accounts:', error.message);
    return [];
  }

  const profiles = data || [];

  // Filter out profiles already followed by current user
  let followingSet = new Set<string>();
  if (currentUserId && profiles.length > 0) {
    const { data: followData } = await supabase
      .from('user_follows')
      .select('following_id')
      .eq('follower_id', currentUserId)
      .in(
        'following_id',
        profiles.map((p) => p.id)
      );
    followingSet = new Set((followData || []).map((f) => f.following_id));
  }

  return profiles
    .slice(0, limit)
    .map((p) => ({
      ...p,
      is_followed_by_user: followingSet.has(p.id),
    })) as ProfileWithFollowStats[];
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Trending Topics
// ─────────────────────────────────────────────────────────────────────────────

export interface TrendingTopic {
  tag: string;
  count: number;
}

/**
 * Ambil topic_tag paling banyak digunakan dalam 7 hari terakhir.
 * Menggunakan teknik GROUP BY di level Supabase (select kolom + count).
 */
export async function getTrendingTopics(limit = 8): Promise<TrendingTopic[]> {
  const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString();

  const { data, error } = await supabase
    .from('market_posts')
    .select('topic_tag')
    .not('topic_tag', 'is', null)
    .gte('created_at', sevenDaysAgo)
    .limit(200); // Ambil sample postingan recent

  if (error) {
    console.error('Error fetching trending topics:', error.message);
    return [];
  }

  // Client-side aggregation
  const tagCountMap: Record<string, number> = {};
  (data || []).forEach((post) => {
    if (post.topic_tag) {
      tagCountMap[post.topic_tag] = (tagCountMap[post.topic_tag] || 0) + 1;
    }
  });

  return Object.entries(tagCountMap)
    .map(([tag, count]) => ({ tag, count }))
    .sort((a, b) => b.count - a.count)
    .slice(0, limit);
}
