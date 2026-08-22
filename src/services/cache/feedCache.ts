import { MarketPostItem } from '@/types/marketFeed';

const FEED_CACHE_KEY = 'snapan_feed_cache_v1';
const FEED_CACHE_TIMESTAMP_KEY = 'snapan_feed_cache_ts';

export function saveFeedCache(posts: MarketPostItem[]): void {
  if (typeof window === 'undefined') return;
  try {
    // Cache up to 30 latest posts
    const sliceToCache = posts.slice(0, 30);
    localStorage.setItem(FEED_CACHE_KEY, JSON.stringify(sliceToCache));
    localStorage.setItem(FEED_CACHE_TIMESTAMP_KEY, Date.now().toString());
  } catch (err) {
    console.warn('Failed to save feed cache:', err);
  }
}

export function loadFeedCache(): MarketPostItem[] | null {
  if (typeof window === 'undefined') return null;
  try {
    const raw = localStorage.getItem(FEED_CACHE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    if (Array.isArray(parsed) && parsed.length > 0) {
      return parsed;
    }
  } catch (err) {
    console.warn('Failed to load feed cache:', err);
  }
  return null;
}
