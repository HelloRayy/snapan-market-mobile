import { supabase } from './supabase';
import type { MarketPostWithSeller, MarketPostFilterOptions } from '@/types/supabase';

/**
 * Fetch semua postingan feed jualan & sosial beserta detail seller, jumlah suka, dan jumlah komentar
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

  // Fetch bookmarks for current user
  const userBookmarksMap: Record<string, boolean> = {};
  if (currentUserId) {
    const { data: bookmarksData } = await supabase
      .from('post_bookmarks')
      .select('post_id')
      .eq('user_id', currentUserId)
      .in('post_id', postIds);

    (bookmarksData || []).forEach((bm) => {
      userBookmarksMap[bm.post_id] = true;
    });
  }

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
    likes_count: likesMap[post.id] || post.likes_count || 0,
    comments_count: commentsMap[post.id] || post.comments_count || 0,
    is_liked_by_user: !!userLikesMap[post.id],
    is_bookmarked_by_user: !!userBookmarksMap[post.id]
  }));
}

/**
 * Pencarian & Filtering Lanjutan Postingan Feed / Produk Jualan
 */
export async function searchMarketPosts(
  options: MarketPostFilterOptions = {},
  currentUserId?: string
): Promise<MarketPostWithSeller[]> {
  let queryBuilder = supabase
    .from('market_posts')
    .select(`
      *,
      seller:profiles!market_posts_seller_id_fkey(*)
    `);

  // 1. Text Search (Caption, Title, Description, atau Topic Tag)
  if (options.query && options.query.trim() !== '') {
    const q = `%${options.query.trim()}%`;
    queryBuilder = queryBuilder.or(`caption.ilike.${q},title.ilike.${q},description.ilike.${q},topic_tag.ilike.${q}`);
  }

  // 2. Filter Kategori
  if (options.category && options.category !== 'Semua') {
    queryBuilder = queryBuilder.eq('category', options.category);
  }

  // 3. Filter Jenis Postingan (thread / product / all)
  if (options.post_type && options.post_type !== 'all') {
    queryBuilder = queryBuilder.eq('post_type', options.post_type);
  }

  // 4. Filter Rentang Harga (Min & Max Price)
  if (options.min_price !== undefined && options.min_price >= 0) {
    queryBuilder = queryBuilder.gte('price', options.min_price);
  }
  if (options.max_price !== undefined && options.max_price > 0) {
    queryBuilder = queryBuilder.lte('price', options.max_price);
  }

  // 5. Filter Lokasi Tag
  if (options.location_tag) {
    queryBuilder = queryBuilder.eq('location_tag', options.location_tag);
  }

  // 6. Filter Topik Tag
  if (options.topic_tag) {
    queryBuilder = queryBuilder.eq('topic_tag', options.topic_tag);
  }

  // 7. Sorting Order
  switch (options.sort_by) {
    case 'cheapest':
      queryBuilder = queryBuilder.order('price', { ascending: true });
      break;
    case 'pricy':
      queryBuilder = queryBuilder.order('price', { ascending: false });
      break;
    case 'popular':
      queryBuilder = queryBuilder.order('likes_count', { ascending: false });
      break;
    case 'latest':
    default:
      queryBuilder = queryBuilder.order('created_at', { ascending: false });
      break;
  }

  // 8. Pagination Limit & Offset
  if (options.limit) {
    const from = options.offset || 0;
    const to = from + options.limit - 1;
    queryBuilder = queryBuilder.range(from, to);
  }

  const { data: posts, error: postsError } = await queryBuilder;

  if (postsError) {
    console.error('Error searching market posts:', postsError.message);
    throw postsError;
  }

  if (!posts || posts.length === 0) return [];

  const postIds = posts.map((p) => p.id);

  // Fetch likes, comments, and bookmarks counts
  const { data: likesData } = await supabase
    .from('post_likes')
    .select('post_id, user_id')
    .in('post_id', postIds);

  const { data: commentsData } = await supabase
    .from('post_comments')
    .select('post_id')
    .in('post_id', postIds);

  const userBookmarksMap: Record<string, boolean> = {};
  if (currentUserId) {
    const { data: bookmarksData } = await supabase
      .from('post_bookmarks')
      .select('post_id')
      .eq('user_id', currentUserId)
      .in('post_id', postIds);

    (bookmarksData || []).forEach((bm) => {
      userBookmarksMap[bm.post_id] = true;
    });
  }

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
    likes_count: likesMap[post.id] || post.likes_count || 0,
    comments_count: commentsMap[post.id] || post.comments_count || 0,
    is_liked_by_user: !!userLikesMap[post.id],
    is_bookmarked_by_user: !!userBookmarksMap[post.id]
  }));
}

/**
 * Buat postingan jualan/utas baru di feed
 */
export async function createMarketPost(payload: {
  seller_id: string;
  post_type?: 'thread' | 'product';
  caption: string;
  title?: string;
  description?: string;
  images?: string[];
  is_video?: boolean;
  stock?: number;
  price?: number;
  original_price?: number;
  category?: string;
  location_tag?: string;
  topic_tag?: string;
  is_official_topic?: boolean;
  topic_icon?: string;
}) {
  const { data, error } = await supabase
    .from('market_posts')
    .insert({
      seller_id: payload.seller_id,
      post_type: payload.post_type || 'thread',
      caption: payload.caption,
      title: payload.title,
      description: payload.description,
      images: payload.images || [],
      is_video: payload.is_video || false,
      stock: payload.stock ?? 1,
      price: payload.price ?? 0,
      original_price: payload.original_price,
      category: payload.category || 'Umum',
      location_tag: payload.location_tag || 'SMKN 8',
      topic_tag: payload.topic_tag,
      is_official_topic: payload.is_official_topic || false,
      topic_icon: payload.topic_icon || 'threads'
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

