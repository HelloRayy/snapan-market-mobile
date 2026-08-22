import { supabase } from './supabase';
import type { MarketPostWithSeller } from '@/types/supabase';

/**
 * Fetch semua postingan yang disimpan/dibookmark oleh user
 */
export async function getUserBookmarks(userId: string): Promise<MarketPostWithSeller[]> {
  const { data: bookmarkRecords, error: bookmarkError } = await supabase
    .from('post_bookmarks')
    .select(`
      post_id,
      post:market_posts!post_bookmarks_post_id_fkey(
        *,
        seller:profiles!market_posts_seller_id_fkey(*)
      )
    `)
    .eq('user_id', userId)
    .order('created_at', { ascending: false });

  if (bookmarkError) {
    console.error(`Error fetching bookmarks for user ${userId}:`, bookmarkError.message);
    throw bookmarkError;
  }

  if (!bookmarkRecords || bookmarkRecords.length === 0) return [];

  const posts = bookmarkRecords
    .map((record) => record.post)
    .filter(Boolean) as unknown as MarketPostWithSeller[];

  const postIds = posts.map((p) => p.id);

  // Fetch count of likes & comments for bookmarked posts
  const { data: likesData } = await supabase
    .from('post_likes')
    .select('post_id, user_id')
    .in('post_id', postIds);

  const { data: commentsData } = await supabase
    .from('post_comments')
    .select('post_id')
    .in('post_id', postIds);

  const likesMap: Record<string, number> = {};
  const userLikesMap: Record<string, boolean> = {};
  (likesData || []).forEach((like) => {
    likesMap[like.post_id] = (likesMap[like.post_id] || 0) + 1;
    if (like.user_id === userId) {
      userLikesMap[like.post_id] = true;
    }
  });

  const commentsMap: Record<string, number> = {};
  (commentsData || []).forEach((comment) => {
    commentsMap[comment.post_id] = (commentsMap[comment.post_id] || 0) + 1;
  });

  return posts.map((post) => ({
    ...post,
    likes_count: likesMap[post.id] || post.likes_count || 0,
    comments_count: commentsMap[post.id] || post.comments_count || 0,
    is_liked_by_user: !!userLikesMap[post.id],
    is_bookmarked_by_user: true
  }));
}

/**
 * Toggle bookmark / simpan postingan
 */
export async function togglePostBookmark(postId: string, userId: string, isBookmarked: boolean): Promise<void> {
  if (isBookmarked) {
    const { error } = await supabase
      .from('post_bookmarks')
      .delete()
      .eq('post_id', postId)
      .eq('user_id', userId);

    if (error) {
      console.error(`Error removing bookmark for post ${postId}:`, error.message);
      throw error;
    }
  } else {
    const { error } = await supabase
      .from('post_bookmarks')
      .insert({
        post_id: postId,
        user_id: userId
      });

    if (error) {
      console.error(`Error bookmarking post ${postId}:`, error.message);
      throw error;
    }
  }
}
