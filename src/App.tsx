import { useState, useEffect, useRef } from 'react';
import { CheckCheck } from 'lucide-react';
import { OnboardingScreen } from '@/ui/components/onboarding/OnboardingScreen';
import { PwaLandingPage } from '@/ui/components/pwa/PwaLandingPage';
import { HomePage } from '@/ui/pages/HomePage';
import { PostDetailPage } from '@/ui/pages/PostDetailPage';
import { ProfilePage } from '@/ui/pages/ProfilePage';
import { SearchPage } from '@/ui/pages/SearchPage';
import { DirectMessagesPage, MOCK_CONVERSATIONS } from '@/ui/pages/DirectMessagesPage';
import { ChatTopBar } from '@/ui/components/chat/ChatTopBar';
import {
  ChatBubble,
  ChatBubbleMessage,
  ChatBubbleTimestamp,
} from '@/ui/components/ui/chat-bubble';
import { NavigationDrawer } from '@/ui/components/navigation/NavigationDrawer';
import { CreatePostModal } from '@/ui/components/marketplace/CreatePostModal';
import { MarketBottomNav } from '@/ui/components/marketplace/MarketBottomNav';
import { MarketPostItem } from '@/types/marketFeed';
import { MOCK_MARKET_POSTS } from '@/data/mockMarketData';
import { useAuth } from '@/ui/hooks/useAuth';
import { useSmoothScroll } from '@/ui/hooks/useSmoothScroll';
import { triggerHaptic } from '@/utils/haptics';
import { ColorShowcasePage } from '@/ui/pages/ColorShowcasePage';
import { CampusMapPage } from '@/ui/pages/CampusMapPage';
import { ToastNotification } from '@/ui/components/ui/ToastNotification';

// Dynamic URL Helper: Extracts matching post from /@username/post/:postId or #post-:postId
function getPostFromLocation(): MarketPostItem | null {
  if (typeof window === 'undefined') return null;

  const path = window.location.pathname;
  const hash = window.location.hash;

  // 1. Check pathname: /@username/post/:postId or /post/:postId
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

  // 2. Check hash fallback: #post-post-thread-1
  if (hash.startsWith('#post-')) {
    const rawId = hash.replace(/^#post-/, '');
    const found = MOCK_MARKET_POSTS.find((p) => p.id === rawId || `post-${p.id}` === rawId);
    if (found) return found;
  }

  return null;
}

// Dynamic URL Helper: Extracts chat threadId from /direct/t/:threadId or /messages/t/:threadId
function getChatThreadFromLocation(): string | null {
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

export function App() {
  // Initialize Lenis Kinetic Smooth Scroll Engine (120fps physics)
  useSmoothScroll();

  const { user, profile } = useAuth();
  const [isCreateModalOpen, setIsCreateModalOpen] = useState<boolean>(false);

  // Synchronously compute onboarding completion from localStorage / Supabase session to prevent 1-frame splash flash
  const [hasCompletedOnboarding, setHasCompletedOnboarding] = useState<boolean>(() => {
    if (typeof window === 'undefined') return false;
    const isExplicitOnboardingRoute =
      window.location.pathname === '/onboarding' || window.location.hash === '#onboarding';
    if (isExplicitOnboardingRoute) return false;

    // 1. Check explicit onboarding completion flag
    const savedOnboarded = localStorage.getItem('snapan_has_onboarded');
    if (savedOnboarded === 'true') return true;

    // 2. Check if user already has an active Supabase auth session saved in localStorage
    try {
      const hasSupabaseAuth = Object.keys(localStorage).some(
        (key) => key.startsWith('sb-') && key.endsWith('-auth-token')
      );
      if (hasSupabaseAuth) return true;
    } catch {
      // Safe fallback
    }

    return false;
  });

  const [currentRoute, setCurrentRoute] = useState<string>(window.location.pathname);
  const [selectedPost, setSelectedPost] = useState<MarketPostItem | null>(null);
  const [activeChatThreadId, setActiveChatThreadId] = useState<string | null>(() => getChatThreadFromLocation());
  const [isDrawerOpen, setIsDrawerOpen] = useState<boolean>(false);
  // Double-Back to Exit Toast State
  const [showExitToast, setShowExitToast] = useState(false);
  const lastBackPressTimeRef = useRef<number>(0);

  // Scroll Restoration: Preserve home feed scroll, reset non-home routes to top
  const homeScrollYRef = useRef<number>(0);
  const prevRouteRef = useRef<string>(window.location.pathname);
  const postDetailOriginRouteRef = useRef<string>('/');

  // Dynamic Route Checks
  const isMapRoute = currentRoute === '/map' || window.location.hash === '#map';
  const isColorsRoute = currentRoute === '/colors' || window.location.hash === '#colors';
  const isDownloadRoute = currentRoute === '/download' || window.location.hash === '#download';
  const isOnboardingRoute = currentRoute === '/onboarding' || window.location.hash === '#onboarding';
  const isSearchRoute = currentRoute === '/search' || window.location.hash === '#search';
  const isMessagesRoute = currentRoute === '/messages' || currentRoute === '/direct' || window.location.hash === '#messages' || window.location.hash === '#direct';
  const isPostDetailRoute = currentRoute.includes('/post/') || currentRoute.includes('/postingan/') || window.location.hash.startsWith('#post-');
  
  // Dynamic Route Check: /@username or #@username or /profile (excluding /@username/post/...)
  const isProfileRoute = !isPostDetailRoute && !isMessagesRoute && !activeChatThreadId && (currentRoute.startsWith('/@') || currentRoute === '/profile' || (window.location.hash.startsWith('#@') && !isPostDetailRoute));
  
  let targetProfileUsername = 'radityarayhannnn';
  if (currentRoute.startsWith('/@')) {
    targetProfileUsername = decodeURIComponent(currentRoute.slice(2).split('/')[0]);
  } else if (window.location.hash.startsWith('#@')) {
    targetProfileUsername = decodeURIComponent(window.location.hash.slice(2).split('/')[0]);
  } else if (currentRoute === '/profile') {
    targetProfileUsername = profile?.full_name?.toLowerCase().replace(/\s+/g, '') || 'radityarayhannnn';
  }

  const myUsername = profile?.full_name?.toLowerCase().replace(/\s+/g, '') || user?.user_metadata?.full_name?.toLowerCase().replace(/\s+/g, '') || 'radityarayhannnn';
  const isViewingOtherUserProfile = isProfileRoute && targetProfileUsername !== myUsername && targetProfileUsername !== 'me';

  // Initialize Root History Guard & Deep Link Post Resolver
  useEffect(() => {
    if (typeof window === 'undefined') return;

    // Resolve post from initial URL if navigated directly or reloaded
    const initialPost = getPostFromLocation();
    if (initialPost) {
      setSelectedPost(initialPost);
      const authorHandle = initialPost.seller.username || initialPost.seller.name.toLowerCase().replace(/\s+/g, '') || 'author';
      const cleanHandle = authorHandle.replace(/^@/, '');
      const canonicalUrl = `/@${cleanHandle}/post/${initialPost.id}`;
      window.history.replaceState({ isSnapanRoot: false, layer: 'post-detail', postId: initialPost.id, username: cleanHandle }, '', canonicalUrl);
      setCurrentRoute(canonicalUrl);
    } else if (!window.history.state || !window.history.state.isSnapanRoot) {
      window.history.replaceState({ isSnapanRoot: true, route: window.location.pathname }, '', window.location.pathname);
    }
  }, []);

  // PopState & PWA System Back Button Listener
  useEffect(() => {
    const handlePopState = () => {
      const hash = window.location.hash;
      const nextRoute = window.location.pathname;

      // 1. If currently Drawer is open, close it cleanly
      if (isDrawerOpen) {
        setIsDrawerOpen(false);
        return;
      }

      // 2. Resolve chat room state from popstate URL
      const threadMatch = getChatThreadFromLocation();
      setActiveChatThreadId(threadMatch);

      // 3. Resolve post detail state from popstate URL
      const postMatch = getPostFromLocation();
      if (postMatch) {
        setSelectedPost(postMatch);
      } else {
        setSelectedPost(null);
      }

      // 4. Update route state
      setCurrentRoute(nextRoute);
      if (nextRoute === '/') {
        window.dispatchEvent(new CustomEvent('snapan:show-nav'));
      }

      // 4. Double-Back to Exit Protection when at Root Home
      const nextIsRoot = nextRoute === '/' && !hash.startsWith('#@') && !postMatch;
      if (nextIsRoot && !postMatch && !isDrawerOpen) {
        const now = Date.now();
        if (now - lastBackPressTimeRef.current < 2000) {
          // Double back within 2s -> Allow OS to exit PWA
          window.history.back();
        } else {
          // First back press -> Push root guard state back and show confirmation toast
          lastBackPressTimeRef.current = now;
          window.history.pushState({ isSnapanRoot: true, route: '/' }, '', '/');
          setShowExitToast(true);
          setTimeout(() => setShowExitToast(false), 2000);
        }
      }
    };

    const isExplicitOnboardingRoute =
      window.location.pathname === '/onboarding' || window.location.hash === '#onboarding';

    if (isExplicitOnboardingRoute) {
      setHasCompletedOnboarding(false);
    } else if (user) {
      localStorage.setItem('snapan_has_onboarded', 'true');
      setHasCompletedOnboarding(true);
    }

    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, [user, isDrawerOpen]);

  // Route-based Scroll Management: Reset on new non-home routes, restore when returning to Home
  useEffect(() => {
    const prevRoute = prevRouteRef.current;
    const isCurrentHome = !isProfileRoute && !isDownloadRoute && !isOnboardingRoute && !isPostDetailRoute && !isMessagesRoute;
    const wasPrevHome = prevRoute === '/' || (!prevRoute.startsWith('/@') && prevRoute !== '/profile' && !prevRoute.startsWith('#@') && prevRoute !== '/download' && prevRoute !== '/onboarding' && prevRoute !== '/messages');

    if (wasPrevHome && !isCurrentHome) {
      // Leaving Home -> Reset scroll to top (0, 0) for new route
      window.scrollTo({ top: 0, left: 0, behavior: 'instant' });
    } else if (!wasPrevHome && isCurrentHome) {
      // Returning to Home -> Restore previously saved home scroll position
      requestAnimationFrame(() => {
        window.scrollTo({ top: homeScrollYRef.current, left: 0, behavior: 'instant' });
      });
    } else if (!isCurrentHome) {
      // Switching between non-home routes -> Reset scroll to top
      window.scrollTo({ top: 0, left: 0, behavior: 'instant' });
    }

    prevRouteRef.current = currentRoute;
  }, [currentRoute, isProfileRoute, isDownloadRoute, isOnboardingRoute, isPostDetailRoute, isMessagesRoute]);

  const navigateToWeb = () => {
    window.history.pushState({ route: '/' }, '', '/');
    setCurrentRoute('/');
  };

  const navigateToHome = () => {
    window.dispatchEvent(new CustomEvent('snapan:show-nav'));
    window.history.pushState({ route: '/' }, '', '/');
    setCurrentRoute('/');
  };

  const navigateToSearch = () => {
    // Record current home scroll position before navigating away
    if (!isProfileRoute && !isSearchRoute && !isPostDetailRoute) {
      homeScrollYRef.current = window.scrollY;
    }
    window.history.pushState({ route: '/search' }, '', '/search');
    setCurrentRoute('/search');
  };

  const navigateToChatThread = (threadId: string) => {
    const url = `/direct/t/${threadId}`;
    window.history.pushState({ isSnapanRoot: false, layer: 'chat-room', threadId }, '', url);
    setCurrentRoute(url);
    setActiveChatThreadId(threadId);
  };

  const handleCloseChatThread = () => {
    setActiveChatThreadId(null);
    if (window.history.length > 1) {
      window.history.back();
    } else {
      navigateToMessages();
    }
  };

  const navigateToMessages = () => {
    // Record current home scroll position before navigating away
    if (!isProfileRoute && !isSearchRoute && !isPostDetailRoute && !isMessagesRoute) {
      homeScrollYRef.current = window.scrollY;
    }
    window.history.pushState({ route: '/messages' }, '', '/messages');
    setCurrentRoute('/messages');
  };

  const navigateToProfile = (username: string) => {
    // Record current home scroll position before navigating away
    if (!isProfileRoute && !isSearchRoute && !isPostDetailRoute) {
      homeScrollYRef.current = window.scrollY;
    }
    const clean = username.replace(/^@/, '');
    window.history.pushState({ type: 'profile', username: clean }, '', `/@${clean}`);
    setCurrentRoute(`/@${clean}`);
  };

  const handleOpenDrawer = () => {
    window.history.pushState({ layer: 'drawer' }, '', window.location.pathname + window.location.hash);
    setIsDrawerOpen(true);
  };

  const handleCloseDrawer = () => {
    if (window.history.state?.layer === 'drawer') {
      window.history.back();
    } else {
      setIsDrawerOpen(false);
    }
  };

  const handleOpenPostDetail = (post: MarketPostItem) => {
    // Record origin route and home scroll before opening detail
    postDetailOriginRouteRef.current = currentRoute;
    if (!isProfileRoute && !isSearchRoute && !isPostDetailRoute) {
      homeScrollYRef.current = window.scrollY;
    }
    const authorHandle = post.seller.username || post.seller.name.toLowerCase().replace(/\s+/g, '') || 'author';
    const cleanHandle = authorHandle.replace(/^@/, '');
    const canonicalUrl = `/@${cleanHandle}/post/${post.id}`;
    window.history.pushState(
      { layer: 'post-detail', postId: post.id, username: cleanHandle },
      '',
      canonicalUrl
    );
    setCurrentRoute(canonicalUrl);
    setSelectedPost(post);
  };

  const handleClosePostDetail = () => {
    window.dispatchEvent(new CustomEvent('snapan:show-nav'));
    setSelectedPost(null);
    if (window.history.state?.layer === 'post-detail') {
      window.history.back();
    } else {
      const returnRoute = postDetailOriginRouteRef.current || (currentRoute.startsWith('/@') && !currentRoute.includes('/post/')
        ? `/@${targetProfileUsername}`
        : '/');
      window.history.pushState({ isSnapanRoot: true, route: returnRoute }, '', returnRoute);
      setCurrentRoute(returnRoute);
    }
  };

  const handleOnboardingComplete = () => {
    localStorage.setItem('snapan_has_onboarded', 'true');
    setHasCompletedOnboarding(true);
  };

  return (
    <div className="relative min-h-screen max-w-full w-full bg-pure-white text-slate-ink overflow-x-hidden font-gt-standard">
      {/* Render Dedicated PWA Download Landing Page if route is /download */}
      {isDownloadRoute ? (
        <PwaLandingPage onProceedToWeb={navigateToWeb} />
      ) : hasCompletedOnboarding && !isOnboardingRoute ? (
        <div className="relative min-h-screen">
          {/* Main Feed HomePage (Always preserved in DOM so scroll position is never lost) */}
          <div className={isProfileRoute || isSearchRoute || isMessagesRoute || (selectedPost && postDetailOriginRouteRef.current === '/search') ? 'hidden' : 'block'}>
            <HomePage
              onSelectPost={handleOpenPostDetail}
              onNavigateToProfile={navigateToProfile}
              onNavigateSearch={navigateToSearch}
              onNavigateMessages={navigateToMessages}
              onOpenMenu={handleOpenDrawer}
            />
          </div>

          {/* Dedicated Search / Explore Single Page (Preserved in DOM so query, tabs & scroll are never lost) */}
          <div className={isSearchRoute || (selectedPost && postDetailOriginRouteRef.current === '/search') ? 'block' : 'hidden'}>
            <SearchPage
              onBack={() => {
                navigateToHome();
              }}
              onNavigateToProfile={navigateToProfile}
              onNavigateHome={navigateToHome}
              onNavigateMessages={navigateToMessages}
              onSelectPost={handleOpenPostDetail}
              onOpenMenu={handleOpenDrawer}
            />
          </div>

          {/* Profile Page (Dynamic Route /@username) */}
          {isProfileRoute && (
            <ProfilePage
              username={targetProfileUsername}
              onBack={isViewingOtherUserProfile ? () => window.history.back() : undefined}
              onSelectPost={handleOpenPostDetail}
              onOpenMenu={handleOpenDrawer}
              onNavigateTab={(tab) => {
                if (tab === 'home') {
                  navigateToHome();
                } else if (tab === 'messages') {
                  navigateToMessages();
                }
              }}
            />
          )}

          {/* Direct Messages Page (Route /messages or #messages) */}
          {isMessagesRoute && !activeChatThreadId && (
            <DirectMessagesPage
              onBack={navigateToHome}
              onNavigateHome={navigateToHome}
              onNavigateSearch={navigateToSearch}
              onNavigateProfile={navigateToProfile}
              onSelectConversation={(threadId) => navigateToChatThread(threadId)}
            />
          )}

          {/* Color Laboratory Showcase Page (Route /colors or #colors) */}
          {isColorsRoute && (
            <div className="fixed inset-0 z-50 bg-[#f8f9fa] overflow-y-auto">
              <ColorShowcasePage onBack={navigateToHome} />
            </div>
          )}

          {/* Interactive 2D Campus Map Page (Route /map or #map) */}
          {isMapRoute && (
            <div className="fixed inset-0 z-50 bg-[#f8fafc] overflow-y-auto">
              <CampusMapPage onBack={navigateToHome} />
            </div>
          )}

          {/* Side Navigation Drawer (Sliding from Left with Backdrop Blur) */}
          <NavigationDrawer
            isOpen={isDrawerOpen}
            onClose={handleCloseDrawer}
            onNavigateHome={navigateToHome}
            onNavigateSearch={navigateToSearch}
            onNavigateProfile={navigateToProfile}
            onNavigateMessages={navigateToMessages}
            onOpenCreateModal={() => setIsCreateModalOpen(true)}
            onNavigateDownload={() => {
              setCurrentRoute('/download');
              window.history.pushState({}, '', '/download');
            }}
            onNavigateColors={() => {
              setCurrentRoute('/colors');
              window.history.pushState({}, '', '/colors');
            }}
            onNavigateMap={() => {
              setCurrentRoute('/map');
              window.history.pushState({}, '', '/map');
            }}
          />

          {/* Create Post / New Thread Modal Triggered Globally from Sidebar */}
          <CreatePostModal
            isOpen={isCreateModalOpen}
            onClose={() => setIsCreateModalOpen(false)}
            onSubmitPost={async () => {
              setIsCreateModalOpen(false);
            }}
          />

          {/* Canonical 5-Icon Market Bottom Navigation */}
          {!selectedPost && !activeChatThreadId && !isColorsRoute && !isMapRoute && (
            <MarketBottomNav
              activeTab={
                isMessagesRoute
                  ? 'messages'
                  : isSearchRoute
                  ? 'search'
                  : isProfileRoute && !isViewingOtherUserProfile
                  ? 'profile'
                  : 'home'
              }
              userAvatar={profile?.avatar_url || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80'}
              onTabChange={(tab) => {
                triggerHaptic('selection');
                if (tab === 'home') {
                  navigateToHome();
                } else if (tab === 'search') {
                  navigateToSearch();
                } else if (tab === 'messages') {
                  navigateToMessages();
                } else if (tab === 'profile') {
                  navigateToProfile(profile?.full_name?.toLowerCase().replace(/\s+/g, '') || 'radityarayhannnn');
                }
              }}
              onPostClick={() => {
                triggerHaptic('medium');
                setIsCreateModalOpen(true);
              }}
            />
          )}
          {/* Detail Page Layer (Threads/Instagram Subtle Scale Zoom & Fade In) */}
          {selectedPost && (
            <div
              key={selectedPost.id}
              data-lenis-prevent
              className="fixed inset-0 z-50 bg-white overflow-hidden transform-gpu animate-page-zoom touch-pan-y"
              style={{
                willChange: 'transform, opacity',
                backfaceVisibility: 'hidden',
                WebkitBackfaceVisibility: 'hidden',
              }}
            >
              <PostDetailPage
                post={selectedPost}
                onBack={handleClosePostDetail}
                onUserClick={(uname) => {
                  handleClosePostDetail();
                  navigateToProfile(uname);
                }}
              />
            </div>
          )}
          {/* Fullscreen Chat Room Layer with ChatTopBar Slicing */}
          {activeChatThreadId && (
            <div
              key={activeChatThreadId}
              data-lenis-prevent
              className="fixed inset-0 z-50 bg-white overflow-hidden transform-gpu animate-page-zoom touch-pan-y flex flex-col"
              style={{
                willChange: 'transform, opacity',
                backfaceVisibility: 'hidden',
                WebkitBackfaceVisibility: 'hidden',
              }}
            >
              {/* Chat TopBar: ArrowLeft - PFP Profile + Name - Option Icon */}
              <ChatTopBar
                participant={
                  (() => {
                    const conv = MOCK_CONVERSATIONS.find((c) => c.id === activeChatThreadId);
                    if (conv) {
                      return {
                        name: conv.user.name,
                        username: conv.user.username,
                        avatar: conv.user.avatar,
                        isVerified: conv.user.isVerified,
                        isOnline: conv.user.isOnline,
                      };
                    }
                    return {
                      name: 'Sarah Anastasya',
                      username: 'sarahanas',
                      avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80',
                      isVerified: true,
                      isOnline: true,
                    };
                  })()
                }
                onBack={handleCloseChatThread}
                onViewProfile={(uname) => {
                  handleCloseChatThread();
                  navigateToProfile(uname);
                }}
              />

              {/* Chat Messages Stream (2 Bubble Bertumpuk Kiri, 2 Bubble Bertumpuk Kanan) */}
              <main
                data-lenis-prevent
                className="flex-1 overflow-y-auto px-3.5 py-4 space-y-4 bg-[#fbfbfb] touch-pan-y"
              >
                {/* GRUP 1: 2 Bubble Bertumpuk Penerima (Kiri / Left) - Jam 08:15 */}
                <div className="flex flex-col items-start gap-y-1 max-w-[85%] sm:max-w-[75%] mr-auto">
                  {/* Bubble 1 (Atas) */}
                  <ChatBubble variant="received" shape="firstReceived" className="w-full">
                    <ChatBubbleMessage>
                      Halo kak! Mau tanya soal kalkulator Casio FX-991EX nya
                    </ChatBubbleMessage>
                  </ChatBubble>

                  {/* Bubble 2 (Bawah - Menyatu) */}
                  <ChatBubble variant="received" shape="lastReceived" className="w-full">
                    <ChatBubbleMessage>
                      Kira-kira masih lengkap sama dus dan buku panduannya gak ya?
                    </ChatBubbleMessage>
                    <ChatBubbleTimestamp className="text-neutral-600 font-medium">
                      08:15
                    </ChatBubbleTimestamp>
                  </ChatBubble>
                </div>

                {/* GRUP 2: 2 Bubble Bertumpuk Pengirim (Kanan / Right) - Jam 08:18 */}
                <div className="flex flex-col items-end gap-y-1 max-w-[85%] sm:max-w-[75%] ml-auto">
                  {/* Bubble 1 (Atas) */}
                  <ChatBubble variant="sent" shape="firstSent" className="w-full">
                    <ChatBubbleMessage>
                      Halo Sarah! Masih lengkap semua kok, dus buku sama cover pelindungnya masih ada 👍
                    </ChatBubbleMessage>
                  </ChatBubble>

                  {/* Bubble 2 (Bawah - Menyatu) */}
                  <ChatBubble variant="sent" shape="lastSent" className="w-full">
                    <ChatBubbleMessage>
                      Baterainya juga baru aja diganti minggu kemarin, jadi siap pakai banget.
                    </ChatBubbleMessage>
                    <ChatBubbleTimestamp
                      className="text-white/80"
                      statusIcon={<CheckCheck className="w-3.5 h-3.5 text-white/95 stroke-[2.2]" />}
                    >
                      08:18
                    </ChatBubbleTimestamp>
                  </ChatBubble>
                </div>
              </main>
            </div>
          )}

          {/* Native Double-Back to Exit Confirmation Toast */}
          <ToastNotification
            message={showExitToast ? 'Tekan sekali lagi untuk keluar' : null}
            onClose={() => setShowExitToast(false)}
            duration={2000}
          />
        </div>
      ) : (
        <OnboardingScreen onComplete={handleOnboardingComplete} />
      )}
    </div>
  );
}

export default App;
