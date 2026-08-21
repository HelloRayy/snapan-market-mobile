import { supabase } from './supabase';
import type { PostCommentWithUser } from '@/types/supabase';

/**
 * Fetch semua komentar postingan beserta profil user dan struktur balasan bersarang (threaded tree)
 */
export async function getPostComments(
  postId: string,
  currentUserId?: string
): Promise<PostCommentWithUser[]> {
  const { data: rawComments, error } = await supabase
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

  if (!rawComments || rawComments.length === 0) return [];

  const commentIds = rawComments.map((c) => c.id);

  // Fetch likes per comment
  const { data: likesData } = await supabase
    .from('comment_likes')
    .select('comment_id, user_id')
    .in('comment_id', commentIds);

  const likesMap: Record<string, number> = {};
  const userLikesMap: Record<string, boolean> = {};

  (likesData || []).forEach((like) => {
    likesMap[like.comment_id] = (likesMap[like.comment_id] || 0) + 1;
    if (currentUserId && like.user_id === currentUserId) {
      userLikesMap[like.comment_id] = true;
    }
  });

  // Map all comments with user profiles & like counts
  const allComments: PostCommentWithUser[] = rawComments.map((c) => ({
    ...c,
    user: c.user as unknown as PostCommentWithUser['user'],
    likes_count: likesMap[c.id] || c.likes_count || 0,
    is_liked_by_user: !!userLikesMap[c.id],
    replies: []
  }));

  // Build threaded tree (Root comments + nested replies)
  const commentMap = new Map<string, PostCommentWithUser>();
  const rootComments: PostCommentWithUser[] = [];

  allComments.forEach((comment) => {
    commentMap.set(comment.id, comment);
  });

  allComments.forEach((comment) => {
    if (comment.parent_comment_id && commentMap.has(comment.parent_comment_id)) {
      const parent = commentMap.get(comment.parent_comment_id)!;
      if (!parent.replies) parent.replies = [];
      parent.replies.push(comment);
    } else {
      rootComments.push(comment);
    }
  });

  return rootComments;
}

/**
 * Tambah komentar utama atau balasan bersarang (sub-thread) pada postingan
 */
export async function createPostComment(payload: {
  post_id: string;
  user_id: string;
  content: string;
  parent_comment_id?: string | null;
  images?: string[];
}) {
  const { data, error } = await supabase
    .from('post_comments')
    .insert({
      post_id: payload.post_id,
      user_id: payload.user_id,
      content: payload.content,
      parent_comment_id: payload.parent_comment_id || null,
      images: payload.images || []
    })
    .select(`
      *,
      user:profiles!post_comments_user_id_fkey(*)
    `)
    .single();

  if (error) {
    console.error('Error creating comment:', error.message);
    throw error;
  }

  return {
    ...data,
    user: data.user as unknown as PostCommentWithUser['user'],
    likes_count: 0,
    is_liked_by_user: false,
    replies: []
  } as PostCommentWithUser;
}

/**
 * Toggle Suka / Batal Suka pada komentar
 */
export async function toggleCommentLike(commentId: string, userId: string, isLiked: boolean) {
  if (isLiked) {
    const { error } = await supabase
      .from('comment_likes')
      .delete()
      .eq('comment_id', commentId)
      .eq('user_id', userId);

    if (error) {
      console.error(`Error unliking comment ${commentId}:`, error.message);
      throw error;
    }
  } else {
    const { error } = await supabase
      .from('comment_likes')
      .insert({
        comment_id: commentId,
        user_id: userId
      });

    if (error) {
      console.error(`Error liking comment ${commentId}:`, error.message);
      throw error;
    }
  }
}

/**
 * Hapus komentar milik pengguna sendiri
 */
export async function deletePostComment(commentId: string, userId: string) {
  const { error } = await supabase
    .from('post_comments')
    .delete()
    .eq('id', commentId)
    .eq('user_id', userId);

  if (error) {
    console.error(`Error deleting comment ${commentId}:`, error.message);
    throw error;
  }
}
