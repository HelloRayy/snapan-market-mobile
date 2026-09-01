import { useState, useEffect, useRef, useCallback } from 'react';
import { MarketPostItem } from '@/types/marketFeed';
import { MOCK_MARKET_POSTS } from '@/data/mockMarketData';
import { triggerHaptic } from '@/utils/haptics';

export function getPostFromLocation(): MarketPostItem | null {
  if (typeof window === 'undefined') return null;
  const path = window.location.pathname;
  const hash = window.location.hash;

  if (path.startsWith('/@') || path.startsWith('/post/')) {
    const parts = path.split('/').filter(Boolean);
    const potentialPostId = parts[parts.length - 1];
    if (potentialPostId && potentialPostId !== parts[0]) {
      const found = MOCK_MARKET_POSTS.find(
        (p) => p.id === potentialPostId || p.id === decodeURIComponent(potentialPostId)
      );
      if (found) return found;
    }
  }

  if (hash.startsWith('#post-')) {
    const rawId = hash.replace(/^#post-/, '');
    const found = MOCK_MARKET_POSTS.find((p) => p.id === rawId || `post-${p.id}` === rawId);
    if (found) return found;
  }

  return null;
}

export function getChatThreadFromLocation(): string | null {
  if (typeof window === 'undefined') return null;
  const path = window.location.pathname;
  const hash = window.location.hash;

  if (path.startsWith('/direct/t/') || path.startsWith('/messages/t/')) {
    const parts = path.split('/t/').filter(Boolean);
    const rawThreadId = parts[1]?.split('/')[0];
    if (rawThreadId) {
      return decodeURIComponent(rawThreadId);
    }
  }

  if (hash.startsWith('#chat-')) {
    return decodeURIComponent(hash.replace(/^#chat-/, ''));
  }

  return null;
}

export function useAppNavigation() {
  const [hasCompletedOnboarding, setHasCompletedOnboarding] = useState<boolean>(() => {
    if (typeof window === 'undefined') return false;
    const isExplicitOnboardingRoute =
      window.location.pathname === '/onboarding' || window.location.hash === '#onboarding';
    if (isExplicitOnboardingRoute) return false;

    const savedOnboarded = localStorage.getItem('snapan_has_onboarded');
    if (savedOnboarded === 'true') return true;

    try {
      const hasSupabaseAuth = Object.keys(localStorage).some(
        (key) => key.startsWith('sb-') && key.endsWith('-auth-token')
      );
      if (hasSupabaseAuth) return true;
    } catch {}

    return false;
  });

  const [currentRoute, setCurrentRoute] = useState<string>(() => {
    if (typeof window === 'undefined') return '/download';
    const path = window.location.pathname;
    if (path === '/' || path === '') return '/download';
    return path;
  });
  const [selectedPost, setSelectedPost] = useState<MarketPostItem | null>(null);
  const [activeChatThreadId, setActiveChatThreadId] = useState<string | null>(() => getChatThreadFromLocation());
  const [isDrawerOpen, setIsDrawerOpen] = useState<boolean>(false);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState<boolean>(false);

  const isPostDetailActiveRef = useRef<boolean>(false);
  const postDetailOriginRouteRef = useRef<string>('/home');
  const postDetailOriginScrollYRef = useRef<number>(0);
  const lastBackPressTimeRef = useRef<number>(0);

  // Auto-redirect base / to /download
  useEffect(() => {
    if (typeof window !== 'undefined' && (window.location.pathname === '/' || window.location.pathname === '')) {
      window.history.replaceState({}, '', '/download');
      setCurrentRoute('/download');
    }
  }, []);

  const navigateToHome = useCallback(() => {
    triggerHaptic('light');
    setSelectedPost(null);
    setActiveChatThreadId(null);
    setCurrentRoute('/home');
    window.history.pushState({}, '', '/home');
  }, []);

  const navigateToSearch = useCallback(() => {
    triggerHaptic('light');
    setSelectedPost(null);
    setActiveChatThreadId(null);
    setCurrentRoute('/search');
    window.history.pushState({}, '', '/search');
  }, []);

  const navigateToMessages = useCallback(() => {
    triggerHaptic('light');
    setSelectedPost(null);
    setActiveChatThreadId(null);
    setCurrentRoute('/messages');
    window.history.pushState({}, '', '/messages');
  }, []);

  const navigateToProfile = useCallback((username: string) => {
    triggerHaptic('light');
    setSelectedPost(null);
    setActiveChatThreadId(null);
    const targetRoute = `/@${username}`;
    setCurrentRoute(targetRoute);
    window.history.pushState({}, '', targetRoute);
  }, []);

  const navigateToChatThread = useCallback((threadId: string) => {
    triggerHaptic('medium');
    setActiveChatThreadId(threadId);
    window.history.pushState({}, '', `/direct/t/${encodeURIComponent(threadId)}`);
  }, []);

  const handleOpenPostDetail = useCallback((post: MarketPostItem) => {
    triggerHaptic('medium');
    postDetailOriginRouteRef.current = currentRoute;
    postDetailOriginScrollYRef.current = window.scrollY || document.documentElement.scrollTop || 0;
    setSelectedPost(post);
    isPostDetailActiveRef.current = true;

    const username = post.seller.username || 'user';
    window.history.pushState({ postId: post.id }, '', `/@${username}/post/${post.id}`);
  }, [currentRoute]);

  const handleClosePostDetail = useCallback(() => {
    triggerHaptic('light');
    setSelectedPost(null);
    isPostDetailActiveRef.current = false;
    window.history.pushState({}, '', postDetailOriginRouteRef.current);
    setTimeout(() => {
      window.scrollTo({ top: postDetailOriginScrollYRef.current, behavior: 'instant' as ScrollBehavior });
    }, 10);
  }, []);

  const handleCloseChatThread = useCallback(() => {
    triggerHaptic('light');
    setActiveChatThreadId(null);
    window.history.pushState({}, '', '/messages');
  }, []);

  // Listen for browser Back/Forward (popstate)
  useEffect(() => {
    const handlePopState = () => {
      const chatThread = getChatThreadFromLocation();
      setActiveChatThreadId(chatThread);

      const matchedPost = getPostFromLocation();
      if (matchedPost) {
        setSelectedPost(matchedPost);
        isPostDetailActiveRef.current = true;
      } else {
        setSelectedPost(null);
        isPostDetailActiveRef.current = false;
      }
      setCurrentRoute(window.location.pathname);
    };

    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  // PWA Double-Back Exit Guard
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape' || e.key === 'Backspace') {
        if (selectedPost) {
          handleClosePostDetail();
          return;
        }
        if (activeChatThreadId) {
          handleCloseChatThread();
          return;
        }
        if (isDrawerOpen) {
          setIsDrawerOpen(false);
          return;
        }
        if (currentRoute !== '/home' && currentRoute !== '/download') {
          navigateToHome();
          return;
        }
        const now = Date.now();
        if (now - lastBackPressTimeRef.current > 2000) {
          lastBackPressTimeRef.current = now;
          triggerHaptic('medium');
        }
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [selectedPost, activeChatThreadId, isDrawerOpen, currentRoute, handleClosePostDetail, handleCloseChatThread, navigateToHome]);

  return {
    hasCompletedOnboarding,
    setHasCompletedOnboarding,
    currentRoute,
    setCurrentRoute,
    selectedPost,
    activeChatThreadId,
    isDrawerOpen,
    setIsDrawerOpen,
    isCreateModalOpen,
    setIsCreateModalOpen,
    postDetailOriginRouteRef,
    navigateToHome,
    navigateToSearch,
    navigateToMessages,
    navigateToProfile,
    navigateToChatThread,
    handleOpenPostDetail,
    handleClosePostDetail,
    handleCloseChatThread,
  };
}
