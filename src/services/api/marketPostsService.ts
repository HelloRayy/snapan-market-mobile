import { supabase } from './supabase';
import type { MarketPostWithSeller, PostCommentWithUser } from '@/types/supabase';

/**
 * Fetch semua postingan feed jualan beserta detail seller
 */
export async function getMarketPosts(currentUserId?: string): Promise<MarketPostWithSeller[]> {
  const { data: posts, error: postsError } = await supabase
    .from('market_posts')
    .select(`
      *,
      seller:profiles!market_posts_seller_id_fkey(*)
    `)
    .order('created_at', { ascending: false });

  if (postsError) {
    console.error('Error fetching market posts:', postsError.message);
    throw postsError;
  }

  if (!posts || posts.length === 0) return [];

  const postIds = posts.map((p) => p.id);

  // Fetch count of likes per post
  const { data: likesData } = await supabase
    .from('post_likes')
    .select('post_id, user_id')
    .in('post_id', postIds);

  // Fetch count of comments per post
  const { data: commentsData } = await supabase
    .from('post_comments')
    .select('post_id')
    .in('post_id', postIds);

  const likesMap: Record<string, number> = {};
  const userLikesMap: Record<string, boolean> = {};
  (likesData || []).forEach((like) => {
    likesMap[like.post_id] = (likesMap[like.post_id] || 0) + 1;
    if (currentUserId && like.user_id === currentUserId) {
      userLikesMap[like.post_id] = true;
    }
  });

  const commentsMap: Record<string, number> = {};
  (commentsData || []).forEach((comment) => {
    commentsMap[comment.post_id] = (commentsMap[comment.post_id] || 0) + 1;
  });

  return posts.map((post) => ({
    ...post,
    seller: post.seller as unknown as MarketPostWithSeller['seller'],
    likes_count: likesMap[post.id] || 0,
    comments_count: commentsMap[post.id] || 0,
    is_liked_by_user: !!userLikesMap[post.id]
  }));
}

/**
 * Buat postingan jualan baru di feed
 */
export async function createMarketPost(payload: {
  seller_id: string;
  caption: string;
  images?: string[];
  is_video?: boolean;
  stock?: number;
  price?: number;
  original_price?: number;
  category?: string;
  location_tag?: string;
}) {
  const { data, error } = await supabase
    .from('market_posts')
    .insert({
      seller_id: payload.seller_id,
      caption: payload.caption,
      images: payload.images || [],
      is_video: payload.is_video || false,
      stock: payload.stock ?? 1,
      price: payload.price ?? 0,
      original_price: payload.original_price,
      category: payload.category || 'Umum',
      location_tag: payload.location_tag || 'SMKN 8'
    })
    .select()
    .single();

  if (error) {
    console.error('Error creating market post:', error.message);
    throw error;
  }

  return data;
}

/**
 * Toggle like / unlike pada postingan
 */
export async function togglePostLike(postId: string, userId: string, isLiked: boolean) {
  if (isLiked) {
    // Unlike
    const { error } = await supabase
      .from('post_likes')
      .delete()
      .eq('post_id', postId)
      .eq('user_id', userId);

    if (error) {
      console.error('Error unliking post:', error.message);
      throw error;
    }
  } else {
    // Like
    const { error } = await supabase
      .from('post_likes')
      .insert({
        post_id: postId,
        user_id: userId
      });

    if (error) {
      console.error('Error liking post:', error.message);
      throw error;
    }
  }
}

/**
 * Fetch komentar postingan beserta profil komentator
 */
export async function getPostComments(postId: string): Promise<PostCommentWithUser[]> {
  const { data, error } = await supabase
    .from('post_comments')
    .select(`
      *,
      user:profiles!post_comments_user_id_fkey(*)
    `)
    .eq('post_id', postId)
    .order('created_at', { ascending: true });

  if (error) {
    console.error(`Error fetching comments for post ${postId}:`, error.message);
    throw error;
  }

  return (data || []).map((c) => ({
    ...c,
    user: c.user as unknown as PostCommentWithUser['user']
  }));
}

/**
 * Tambah komentar pada postingan
 */
export async function addPostComment(postId: string, userId: string, content: string) {
  const { data, error } = await supabase
    .from('post_comments')
    .insert({
      post_id: postId,
      user_id: userId,
      content
    })
    .select()
    .single();

  if (error) {
    console.error('Error adding post comment:', error.message);
    throw error;
  }

  return data;
}
