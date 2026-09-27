# Graph Report - snapan-market-mobile  (2026-09-27)

## Corpus Check
- Large corpus: 495 files · ~628,595 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 2588 nodes · 4220 edges · 147 communities (121 shown, 26 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS · INFERRED: 7 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Flutter Core & Utilities
- Marketplace Feed & Interactions
- Module: Features Feed Models Mar
- Post & Product Creation
- Formatting & Helpers
- Post & Product Creation
- Post & Product Creation
- Marketplace Feed & Interactions
- Authentication & Session
- Student Profile & Showcase
- Notifications & Activity
- Campus Blueprint & Map
- Marketplace Feed & Interactions
- Flutter Core & Utilities
- Post & Product Creation
- Direct Messaging & Chat
- Flutter Core & Utilities
- Home Feed Timeline
- Notifications & Activity
- Direct Messaging & Chat
- Module: Boxfit
- Module: Features Feed Components
- COD Checkout & Orders
- Direct Messaging & Chat
- Direct Messaging & Chat
- Design Tokens & Theme
- COD Checkout & Orders
- Module: Features Search Screens 
- Post & Product Creation
- Campus Blueprint & Map
- Student Profile & Showcase
- Flutter Core & Utilities
- Post & Product Creation
- Module: Features Feed Components
- Module: Features Feed Components
- Module: Playwright Config
- Post & Product Creation
- Module: Features Feed Components
- Design Tokens & Theme
- Direct Messaging & Chat
- Design Tokens & Theme
- Post & Product Creation
- Module: Features Feed Components
- Direct Messaging & Chat
- Module: Tsconfig
- Student Profile & Showcase
- Module: Features Feed Components
- Module: Features Search Componen
- PWA Landing Showcase
- Authentication & Session
- Module: Core Components App Entr
- Post & Product Creation
- Home Feed Timeline
- Module: Features Locations Scree
- Direct Messaging & Chat
- Design Tokens & Theme
- Home Feed Timeline
- Design Tokens & Theme
- Supabase Schema & Client
- Module: Features Feed Components
- Module: Features Profile Models 
- Direct Messaging & Chat
- PWA Landing Showcase
- Post & Product Creation
- Authentication & Session
- Home Feed Timeline
- Module: Features Feed Components
- Module: Features Search Models S
- Home Feed Timeline
- App Routing & Shell
- PWA Landing Showcase
- Module: Animation
- Module: Animationcontroller
- Formatting & Helpers
- Module: Features Feed Components
- Direct Messaging & Chat
- Flutter Core & Utilities
- Module: Features Feed Components
- Module: Features Feed Components
- Module: Features Feed Components
- Module: Features Map Models Camp
- Module: Features Profile Compone
- Supabase Schema & Client
- COD Checkout & Orders
- Direct Messaging & Chat
- Design Tokens & Theme
- PWA Landing Showcase
- Supabase Schema & Client
- Formatting & Helpers
- Module: Features Auth Models Aut
- Direct Messaging & Chat
- Direct Messaging & Chat
- Module: Ui Components Auth Prote
- Module: Ui Components Ui Mobiles
- Module: Focusnode
- Module: Features Auth Components
- COD Checkout & Orders
- Module: Package Scripts
- Supabase Schema & Client
- Post & Product Creation
- Module: Features Feed Components
- Direct Messaging & Chat
- Module: Comment Action Bar Dart
- Flutter Core & Utilities
- Direct Messaging & Chat
- COD Checkout & Orders
- Module: Features Profile Compone
- Module: Class
- Module: Features Search Componen
- Module: Annotation Immutable
- Supabase Schema & Client
- Module: Features Auth Components
- Module: Features Feed Components
- Module: Features Feed Components
- Supabase Schema & Client
- Module: Core Utils String Utils
- Module: Features Feed Components
- Module: Os
- Module: Ref Https
- Marketplace Feed & Interactions
- Supabase Schema & Client
- Module: Android Gradlew
- Design Tokens & Theme
- Notifications & Activity
- Module: Cursor Mcp
- Module: Kiro Settings Mcp
- Module: Mcp
- Module: Ref Pngjs
- Module: Types Agentation D
- Module: Types Kumo D
- Module: Httpclient
- Module: Httpclientrequest
- Module: Httpheaders
- Module: Httpoverrides
- Module: Core Components Glass To
- Module: Core Components Glass To
- Authentication & Session
- Module: Vercel
- Module: Types Kumo D Button
- Module: Types Kumo D Kumoprovide

## God Nodes (most connected - your core abstractions)
1. `react` - 108 edges
2. `triggerHaptic()` - 78 edges
3. `lucide-react` - 67 edges
4. `MarketPostItem` - 33 edges
5. `useAuth()` - 22 edges
6. `supabase` - 20 edges
7. `AppSlidePageRoute` - 19 edges
8. `compilerOptions` - 19 edges
9. `cn()` - 18 edges
10. `framer-motion` - 16 edges

## Surprising Connections (you probably didn't know these)
- `_open2DMap` --navigates--> `AppSlidePageRoute`  [EXTRACTED]
  lib/features/locations/screens/campus_locations_picker_screen.dart → lib/core/navigation/app_slide_page_route.dart
- `build` --navigates--> `AppSlidePageRoute`  [EXTRACTED]
  lib/features/messages/screens/chat_conversation_screen.dart → lib/core/navigation/app_slide_page_route.dart
- `_handleViewProfile` --navigates--> `AppSlidePageRoute`  [EXTRACTED]
  lib/features/messages/screens/chat_conversation_screen.dart → lib/core/navigation/app_slide_page_route.dart
- `useAuth()` --indirect_call--> `signInWithGoogle()`  [INFERRED]
  src/ui/hooks/useAuth.ts → src/services/api/authService.ts
- `useAuth()` --indirect_call--> `signInWithEmail()`  [INFERRED]
  src/ui/hooks/useAuth.ts → src/services/api/authService.ts

## Import Cycles
- None detected.

## Communities (147 total, 26 thin omitted)

### Community 0 - "Flutter Core & Utilities"
Cohesion: 0.02
Nodes (88): Container, ContentType?, dart:async, dart:convert, dart:io, dart:typed_data, DateTime?, Encoding (+80 more)

### Community 1 - "Marketplace Feed & Interactions"
Cohesion: 0.07
Nodes (46): togglePostBookmark(), MarketPostItem, PostComment, SellerProfile, ThreadChainItem, CheckoutProductHeader(), CheckoutProductHeaderProps, CheckoutSellerCardProps (+38 more)

### Community 2 - "Module: Features Feed Models Mar"
Cohesion: 0.04
Nodes (54): avatar, caption, category, classGroup, comments, commentsCount, content, copyWith (+46 more)

### Community 3 - "Post & Product Creation"
Cohesion: 0.04
Nodes (52): _audiencePrivacy, build, _buildGifPreview, _buildImagesPreview, _buildSellingIntentBanner, _captionController, _checkSellingIntent, createState (+44 more)

### Community 4 - "Formatting & Helpers"
Cohesion: 0.04
Nodes (47): AppFormatters, buffer, clean, currentYear, day, diff, diffDays, diffHours (+39 more)

### Community 5 - "Post & Product Creation"
Cohesion: 0.07
Nodes (34): CreatePostModal, ThreadsTopicIcon(), CreatePostDraftsSheet(), CreatePostDraftsSheetProps, SavedDraftData, CreatePostFooter(), CreatePostFooterProps, CreatePostHeader() (+26 more)

### Community 6 - "Post & Product Creation"
Cohesion: 0.04
Nodes (44): _activeTab, build, _buildHomeFeedTab, _buildNavTabScreen, createState, _currentNavTab, dispose, _errorMessage (+36 more)

### Community 7 - "Marketplace Feed & Interactions"
Cohesion: 0.08
Nodes (31): framer-motion, react, UserReplyThread, AuthPromptPopoverProps, containerVariants, letterVariants, SnapsLogoSvg(), SnapsLogoSvgProps (+23 more)

### Community 8 - "Authentication & Session"
Cohesion: 0.05
Nodes (41): AuthMode, build, _buildLoginForm, _buildRegisterForm, _clearAllErrors, _clearError, createState, dispose (+33 more)

### Community 9 - "Student Profile & Showcase"
Cohesion: 0.09
Nodes (25): MOCK_MARKET_POSTS, MOCK_USER_REPLIES, createMarketPost(), getMarketPosts(), mapSupabasePostToFeedItem(), loadFeedCache(), saveFeedCache(), NavigationDrawer() (+17 more)

### Community 10 - "Notifications & Activity"
Cohesion: 0.05
Nodes (35): ActivityItemTile, build, _getBadgeColor, _getBadgeIcon, notification, onTap, ActivityNotification, ActivityType (+27 more)

### Community 11 - "Campus Blueprint & Map"
Cohesion: 0.10
Nodes (27): BuildingOutline, FloorData, RoomZone, SCHOOL_BUILDING_OUTLINES, SCHOOL_FLOORS, CheckoutDescription(), CheckoutDescriptionProps, CheckoutHeroImage() (+19 more)

### Community 12 - "Marketplace Feed & Interactions"
Cohesion: 0.08
Nodes (4): uploadMarketMedia(), uploadMultipleMarketMedia(), supabase, Category

### Community 13 - "Flutter Core & Utilities"
Cohesion: 0.05
Nodes (36): action, actions, backgroundColor, badgeCount, build, _buildCenterTitle, _buildDefaultLeading, _buildDefaultTrailing (+28 more)

### Community 14 - "Post & Product Creation"
Cohesion: 0.06
Nodes (34): caption, distance, iconType, id, images, isOfficial, kPresetEmojis, kPresetGifs (+26 more)

### Community 15 - "Direct Messaging & Chat"
Cohesion: 0.07
Nodes (22): lucide-react, ActiveChatOverlay, ActiveChatOverlayProps, ChatComposerBar(), ChatComposerBarProps, ChatProductCard(), ChatProductCardProps, ChatProductContext (+14 more)

### Community 16 - "Flutter Core & Utilities"
Cohesion: 0.09
Nodes (33): CustomPainter, GlassToolbarTop, ReplyLBranchPainter, ThreadBranchPainter, HomeFeedHeader, HomeFeedTabSwitch, activeColor, build (+25 more)

### Community 17 - "Home Feed Timeline"
Cohesion: 0.06
Nodes (33): _activeTab, _allUserPosts, _allUserReplies, build, createState, didUpdateWidget, dispose, _handleDirectMessage (+25 more)

### Community 18 - "Notifications & Activity"
Cohesion: 0.10
Nodes (30): Seller, CartItem, CartItemWithPost, CommentLike, CreateInAppOrderResult, Database, InAppOrder, InAppOrderWithDetails (+22 more)

### Community 19 - "Direct Messaging & Chat"
Cohesion: 0.09
Nodes (20): react-dom, App(), CampusMapPage, ColorShowcasePage, PostDetailPage, src_index, MarketBottomNav(), MarketBottomNavProps (+12 more)

### Community 20 - "Module: Boxfit"
Cohesion: 0.07
Nodes (29): BoxFit, double?, EdgeInsetsGeometry?, black, borderRadius, build, createState, height (+21 more)

### Community 21 - "Module: Features Feed Components"
Cohesion: 0.06
Nodes (30): build, _buildDetailCard, _buildFeedCard, createState, didUpdateWidget, dispose, _handleFollowToggle, _handleLikeToggle (+22 more)

### Community 22 - "COD Checkout & Orders"
Cohesion: 0.07
Nodes (30): build, _buildSortMenuItem, _comments, CommentSortOrder, createState, dispose, _handleAddComment, _handleBuySheet (+22 more)

### Community 23 - "Direct Messaging & Chat"
Cohesion: 0.06
Nodes (29): build, ChatProductCard, ChatProductCardShape, _getBorderRadius, location, onCheckLocation, onViewProduct, product (+21 more)

### Community 24 - "Direct Messaging & Chat"
Cohesion: 0.07
Nodes (29): home,
  messages,
  activity,, build, create, createState, currentTab, _DockTabItem, _DockTabItemState, glyph (+21 more)

### Community 25 - "Design Tokens & Theme"
Cohesion: 0.07
Nodes (29): AppColors, authGradient, border, canvas, error, gradientBottom, gradientIndigo, gradientLavender (+21 more)

### Community 26 - "COD Checkout & Orders"
Cohesion: 0.09
Nodes (23): AuthHeader, build, onBack, title, build, CheckoutLocationCard, onSelectMapTap, onSelectSpotTap (+15 more)

### Community 27 - "Module: Features Search Screens "
Cohesion: 0.08
Nodes (26): _accounts, _activeTab, build, _buildBody, _buildEmptyState, createState, dispose, _getMatchingAccounts (+18 more)

### Community 28 - "Post & Product Creation"
Cohesion: 0.08
Nodes (23): HttpClientResponse, build, DropdownColumnBox, label, onSelected, options, selectedValue, build (+15 more)

### Community 29 - "Campus Blueprint & Map"
Cohesion: 0.08
Nodes (24): Campus2DBlueprintPainter, floor, paint, rooms, selectedRoom, shouldRepaint, CampusRoom, build (+16 more)

### Community 30 - "Student Profile & Showcase"
Cohesion: 0.08
Nodes (25): _avatar, _bioController, build, child, _classController, createState, dispose, EditProfileScreen (+17 more)

### Community 31 - "Flutter Core & Utilities"
Cohesion: 0.11
Nodes (25): CreatePostModal, AppEntranceSplash, _AppEntranceSplashState, CreatePostModal, _CreatePostModalState, BuyBottomSheet, _BuyBottomSheetState, CommentActionBar (+17 more)

### Community 32 - "Post & Product Creation"
Cohesion: 0.09
Nodes (23): build, CreatePostMediaToolbar, createState, emoji, icon, isActive, _isPressed, _MediaIconButton (+15 more)

### Community 33 - "Module: Features Feed Components"
Cohesion: 0.09
Nodes (22): build, createState, _currentIndex, dispose, _handleLikeToggle, _handleRepostToggle, _handleShare, images (+14 more)

### Community 34 - "Module: Features Feed Components"
Cohesion: 0.09
Nodes (22): build, _buildContentText, _buildHeaderRow, comment, _copyToClipboard, createState, didUpdateWidget, _handleLikeToggle (+14 more)

### Community 35 - "Module: Playwright Config"
Cohesion: 0.14
Nodes (14): ref_fs, ref_http, ref_path, @playwright/test, capture(), createStaticServer(), captureViewport(), run() (+6 more)

### Community 36 - "Post & Product Creation"
Cohesion: 0.10
Nodes (20): _, CreatePostBottomSheets, showEmojiPickerBottomSheet, showGifPickerBottomSheet, showLocationPickerBottomSheet, showPrivacyPickerBottomSheet, showTopicPickerPopup, build (+12 more)

### Community 37 - "Module: Features Feed Components"
Cohesion: 0.10
Nodes (21): build, CommentInputBar, _CommentInputBarState, createState, didUpdateWidget, dispose, _focusNode, _handleSubmit (+13 more)

### Community 38 - "Design Tokens & Theme"
Cohesion: 0.10
Nodes (21): build, createState, icon, iconColor, initState, _isPressed, isSaved, label (+13 more)

### Community 39 - "Direct Messaging & Chat"
Cohesion: 0.14
Nodes (17): class-variance-authority, clsx, tailwind-merge, Badge(), BadgeProps, Card, CardProps, ChatBubble (+9 more)

### Community 40 - "Design Tokens & Theme"
Cohesion: 0.10
Nodes (19): Color, avatarCenterX, color, curveRadius, paint, radius, shouldRepaint, startX (+11 more)

### Community 41 - "Post & Product Creation"
Cohesion: 0.10
Nodes (20): build, _buildCleanInputDecoration, _buildFieldLabel, _codPresets, CreatePostProductFields, descController, descFocusNode, descKey (+12 more)

### Community 42 - "Module: Features Feed Components"
Cohesion: 0.10
Nodes (16): build, CommentAuthorBadge, build, CommentImagesSection, images, build, item, PostCaptionText (+8 more)

### Community 43 - "Direct Messaging & Chat"
Cohesion: 0.10
Nodes (20): _activeFilter, build, _buildCarouselChip, _buildEmptyState, _buildFoldersTabCarousel, createState, DirectMessagesScreen, _DirectMessagesScreenState (+12 more)

### Community 44 - "Module: Tsconfig"
Cohesion: 0.10
Nodes (20): compilerOptions, allowImportingTsExtensions, baseUrl, isolatedModules, jsx, lib, module, moduleResolution (+12 more)

### Community 45 - "Student Profile & Showcase"
Cohesion: 0.11
Nodes (19): CheckoutScreen, _CheckoutScreenState, createState, dispose, _handleOrderSubmit, initState, _isLiked, _isOrdering (+11 more)

### Community 46 - "Module: Features Feed Components"
Cohesion: 0.10
Nodes (19): build, _buildMenuItem, _confirmLogout, _currentOverlay, dismiss, HomeMenuPopover, isShowing, _menuKey (+11 more)

### Community 47 - "Module: Features Search Componen"
Cohesion: 0.10
Nodes (19): activeTab, build, controller, hasQuery, isActive, isSubmitted, label, onBack (+11 more)

### Community 48 - "PWA Landing Showcase"
Cohesion: 0.12
Nodes (18): name, private, type, version, @cloudflare/kumo, esbuild, @mappedin/mappedin-js, tailwindcss (+10 more)

### Community 49 - "Authentication & Session"
Cohesion: 0.18
Nodes (15): src_assets_new_market_asset_otp_hero, getCurrentProfile(), getCurrentUser(), onAuthStateChange(), signInWithEmail(), signInWithGoogle(), signOut(), signUpWithEmail() (+7 more)

### Community 50 - "Module: Core Components App Entr"
Cohesion: 0.11
Nodes (18): _aOpacity, _aScale, _bgOpacity, build, _controller, createState, dispose, _glideOffset (+10 more)

### Community 51 - "Post & Product Creation"
Cohesion: 0.11
Nodes (17): audiencePrivacy, build, canSubmit, CreatePostFooterBar, isSubmitting, onPrivacyTap, onSubmit, build (+9 more)

### Community 52 - "Home Feed Timeline"
Cohesion: 0.11
Nodes (17): build, onBackTap, onMenuTap, onSearchTap, onTitleTap, preferredSize, title, activeTab (+9 more)

### Community 53 - "Module: Features Locations Scree"
Cohesion: 0.11
Nodes (18): _activeFilter, build, CampusLocationsPickerScreen, _CampusLocationsPickerScreenState, createState, dispose, _handleSelectSpot, initState (+10 more)

### Community 54 - "Direct Messaging & Chat"
Cohesion: 0.11
Nodes (18): build, _buildChatBubble, ChatConversationScreen, _ChatConversationScreenState, conversation, createState, dispose, _handleClearChat (+10 more)

### Community 55 - "Design Tokens & Theme"
Cohesion: 0.11
Nodes (17): aliases, components, hooks, lib, ui, utils, iconLibrary, rsc (+9 more)

### Community 56 - "Home Feed Timeline"
Cohesion: 0.12
Nodes (17): forYou,, activeTab, build, createState, FeedTab, _handleTapCancel, _handleTapDown, _handleTapUp (+9 more)

### Community 57 - "Design Tokens & Theme"
Cohesion: 0.11
Nodes (17): IconData, bestTime, buildingName, category, categoryLabel, code, codSafetyHint, description (+9 more)

### Community 58 - "Supabase Schema & Client"
Cohesion: 0.11
Nodes (17): client, currentUser, fetchFeedPosts, getProfile, instance, isAuthenticated, onAuthStateChange, signInWithGoogle (+9 more)

### Community 59 - "Module: Features Feed Components"
Cohesion: 0.11
Nodes (17): build, _buildContentText, _buildHeaderRow, CommentReplyTile, isFirst, isLast, onLikeToggle, onReplyClick (+9 more)

### Community 60 - "Module: Features Profile Models "
Cohesion: 0.11
Nodes (17): avatar, bio, classGroup, copyWith, followersCount, id, isVerified, link (+9 more)

### Community 61 - "Direct Messaging & Chat"
Cohesion: 0.15
Nodes (13): ChatTopBarParticipant, ChatTopBarProps, PostSubmenuDropdown, PostSubmenuDropdownProps, MenuLevel, SubmenuDropdown, SubmenuDropdownComponent(), SubmenuDropdownItem (+5 more)

### Community 62 - "PWA Landing Showcase"
Cohesion: 0.16
Nodes (12): AuthLoginForm(), AuthLoginFormProps, AuthOtpVerificationSheet(), AuthOtpVerificationSheetProps, AuthRegisterForm(), AuthRegisterFormProps, CustomPwaInstallModalProps, ButtonPrimary (+4 more)

### Community 63 - "Post & Product Creation"
Cohesion: 0.12
Nodes (14): formatEditUpdate, PhoneNumberFormatter, formatEditUpdate, includePrefix, parsePrice, RupiahInputFormatter, build, controllers (+6 more)

### Community 64 - "Authentication & Session"
Cohesion: 0.12
Nodes (16): build, createState, _currentPage, didChangeDependencies, dispose, _goToPage, _nextPage, _OnboardingScreenState (+8 more)

### Community 65 - "Home Feed Timeline"
Cohesion: 0.12
Nodes (16): CupertinoRouteTransitionMixin, AppSlidePageRoute, build, _openLocationPicker, _openMapPicker, _showOrderSuccessModal, _handleMapTap, _handlePostClick (+8 more)

### Community 66 - "Module: Features Feed Components"
Cohesion: 0.12
Nodes (13): build, hasBadge, HeartNavGlyph, isActive, build, HomeNavGlyph, isActive, badgeCount (+5 more)

### Community 67 - "Module: Features Search Models S"
Cohesion: 0.12
Nodes (15): avatar, bio, copyWith, followersCount, fullName, id, isFollowing, isVerified (+7 more)

### Community 68 - "Home Feed Timeline"
Cohesion: 0.13
Nodes (15): AppRoot, _AppRootState, build, createState, initialize, _isOnboarded, main, _showSplash (+7 more)

### Community 69 - "App Routing & Shell"
Cohesion: 0.16
Nodes (10): OnboardingScreen, src_assets_new_market_asset_market_1_1, src_assets_new_market_asset_market_2_1, src_assets_new_market_asset_market_3_1, src_assets_new_market_asset_person_login_bg, OnboardingScreenProps, Slide1Visual(), Slide2Visual() (+2 more)

### Community 70 - "PWA Landing Showcase"
Cohesion: 0.18
Nodes (11): PwaLandingPage, CustomPwaInstallModal(), InstallBanner(), popSiteHtml, popSiteMobileHtml, src_ui_components_pwa_pwalanding, PwaLandingPage(), PwaLandingPageProps (+3 more)

### Community 71 - "Module: Animation"
Cohesion: 0.13
Nodes (14): Animation, build, isLiked, isReposted, item, likeScaleAnim, likesCount, onLikeToggle (+6 more)

### Community 72 - "Module: Animationcontroller"
Cohesion: 0.13
Nodes (14): AnimationController?, build, createState, didUpdateWidget, dispose, initState, isLiked, _likeAnimController (+6 more)

### Community 73 - "Formatting & Helpers"
Cohesion: 0.13
Nodes (14): build, controller, errorText, inputFormatters, keyboardType, KumoFloatingField, label, obscureText (+6 more)

### Community 74 - "Module: Features Feed Components"
Cohesion: 0.13
Nodes (13): avatarUrl, build, CommentAvatar, name, onUserClick, size, username, build (+5 more)

### Community 75 - "Direct Messaging & Chat"
Cohesion: 0.14
Nodes (14): build, _canSend, ChatComposerBar, _ChatComposerBarState, _controller, createState, dispose, _handleSend (+6 more)

### Community 76 - "Flutter Core & Utilities"
Cohesion: 0.14
Nodes (13): bool get, Duration?, Duration get, buildContent, builder, buildTransitions, fullscreenDialog, maintainState (+5 more)

### Community 77 - "Module: Features Feed Components"
Cohesion: 0.14
Nodes (11): CommentOptionsSheet, show, build, CommentRepliesExpandRow, isExpanded, onToggle, replies, kMockMarketPosts (+3 more)

### Community 78 - "Module: Features Feed Components"
Cohesion: 0.13
Nodes (12): build, isFollowed, onFollowToggle, onUserClick, PostAuthorAvatar, seller, build, onTap (+4 more)

### Community 79 - "Module: Features Feed Components"
Cohesion: 0.14
Nodes (13): build, isDetail, isFollowed, item, onFollowToggle, onMoreOptionsClick, onPostClick, onTopicClick (+5 more)

### Community 80 - "Module: Features Map Models Camp"
Cohesion: 0.14
Nodes (13): buildingName, category, categoryLabel, code, description, floor, hint, id (+5 more)

### Community 81 - "Module: Features Profile Compone"
Cohesion: 0.15
Nodes (12): build, _buildMiniAvatar, isOwnProfile, onEditInterests, ProfileInfoHeader, user, kDefaultProfileUser, kMockUserReplies (+4 more)

### Community 82 - "Supabase Schema & Client"
Cohesion: 0.14
Nodes (14): dependencies, class-variance-authority, @cloudflare/kumo, clsx, framer-motion, lucide-react, @mappedin/mappedin-js, react (+6 more)

### Community 83 - "COD Checkout & Orders"
Cohesion: 0.24
Nodes (11): zustand, CartItem, Order, OrderItem, Product, ProductFilter, ProductCardProps, CartState (+3 more)

### Community 84 - "Direct Messaging & Chat"
Cohesion: 0.15
Nodes (12): int get, build, createState, _maxStock, onChatSeller, onConfirmOrder, post, _quantity (+4 more)

### Community 85 - "Design Tokens & Theme"
Cohesion: 0.15
Nodes (11): build, OnboardingSlideView, slide, assetPath, description, id, isSvg, OnboardingSlide (+3 more)

### Community 86 - "PWA Landing Showcase"
Cohesion: 0.15
Nodes (13): devDependencies, esbuild, @playwright/test, pngjs, tailwindcss, @tailwindcss/vite, @types/node, @types/react (+5 more)

### Community 88 - "Formatting & Helpers"
Cohesion: 0.17
Nodes (10): int?, build, CheckoutPriceBreakdown, originalPrice, price, build, CheckoutProductHeader, post (+2 more)

### Community 89 - "Module: Features Auth Models Aut"
Cohesion: 0.17
Nodes (10): AuthConstants, classNumOptions, gradeOptions, majorOptions, activeFilter, build, _filters, LocationSpotFilterChips (+2 more)

### Community 90 - "Direct Messaging & Chat"
Cohesion: 0.17
Nodes (10): build, conversation, ConversationListItem, onTap, ConversationModel, kInitialDimasMessages, kInitialSarahMessages, kMockConversations (+2 more)

### Community 91 - "Direct Messaging & Chat"
Cohesion: 0.20
Nodes (4): ConversationWithParticipant, DirectMessageWithSender, Conversation, DirectMessage

### Community 92 - "Module: Ui Components Auth Prote"
Cohesion: 0.21
Nodes (9): ProtectedRoute(), ProtectedRouteProps, Button, ButtonPrimary, ButtonPrimaryProps, ButtonProps, ButtonSecondary, ButtonSecondaryProps (+1 more)

### Community 93 - "Module: Ui Components Ui Mobiles"
Cohesion: 0.23
Nodes (10): MobileSearchBar, MobileSearchBarProps, MobileSearchBarRef, calculateTokenScore(), extractTokens(), INITIAL_SUGGESTED_ACCOUNTS, SearchPage(), SearchPageProps (+2 more)

### Community 94 - "Module: Focusnode"
Cohesion: 0.18
Nodes (10): FocusNode, build, createState, dispose, _focusNode, _handleAddTag, _handleRemoveTag, _inputController (+2 more)

### Community 95 - "Module: Features Auth Components"
Cohesion: 0.18
Nodes (10): build, icon, label, onAppleTap, onGoogleTap, onTap, SocialAuthRow, _SocialButton (+2 more)

### Community 96 - "COD Checkout & Orders"
Cohesion: 0.20
Nodes (10): build, CheckoutHeroImage, _CheckoutHeroImageState, createState, _currentPage, dispose, images, _pageController (+2 more)

### Community 97 - "Module: Package Scripts"
Cohesion: 0.18
Nodes (11): scripts, analyze:diff, build, capture:target, dev, dev:host, extract:computed, lint (+3 more)

### Community 98 - "Supabase Schema & Client"
Cohesion: 0.25
Nodes (8): searchAll(), searchPosts(), searchProfiles(), SearchResults, SearchTab, TrendingTopic, MarketPostWithSeller, ProfileWithFollowStats

### Community 99 - "Post & Product Creation"
Cohesion: 0.20
Nodes (9): GlobalKey, authorName, build, CreatePostAuthorLine, onTopicClear, onTopicTriggerTap, selectedTopic, topicTriggerKey (+1 more)

### Community 100 - "Module: Features Feed Components"
Cohesion: 0.22
Nodes (9): build, child, createState, CustomNavTabItem, _CustomNavTabItemState, isActive, _isPressed, onTap (+1 more)

### Community 101 - "Direct Messaging & Chat"
Cohesion: 0.20
Nodes (9): ChatMessageModel, copyWith, id, isMe, MessageStatus, senderId, status, text (+1 more)

### Community 102 - "Module: Comment Action Bar Dart"
Cohesion: 0.22
Nodes (8): comment_action_bar.dart, comment_author_badge.dart, comment_avatar.dart, comment_images_section.dart, comment_options_sheet.dart, comment_replies_expand_row.dart, comment_reply_tile.dart, thread_branch_painter.dart

### Community 103 - "Flutter Core & Utilities"
Cohesion: 0.22
Nodes (8): dart:ui, build, onBuyClick, onChatClick, originalPrice, price, StickyBuyBar, stockCount

### Community 104 - "Direct Messaging & Chat"
Cohesion: 0.22
Nodes (8): build, CheckoutSellerCard, department, onChatTap, onProfileTap, sellerAvatar, sellerName, sellerUsername

### Community 105 - "COD Checkout & Orders"
Cohesion: 0.22
Nodes (8): building, categoryLabel, CheckoutSpot, floor, hint, id, kDefaultCampusSpots, name

### Community 106 - "Module: Features Profile Compone"
Cohesion: 0.22
Nodes (8): build, createState, currentAvatar, nameController, onAvatarChanged, _showAvatarPicker, package:snapan_market/features/profile/models/mock_profile_data.dart, TextEditingController

### Community 107 - "Module: Class"
Cohesion: 0.29
Nodes (7): class, build, createState, FloatingMarketplaceSquircleButton, _FloatingMarketplaceSquircleButtonState, _isPressed, onTap

### Community 108 - "Module: Features Search Componen"
Cohesion: 0.25
Nodes (7): account, build, onFollowTap, onTap, SuggestedAccountTile, package:snapan_market/features/search/models/search_models.dart, SuggestedAccount

### Community 109 - "Module: Annotation Immutable"
Cohesion: 0.29
Nodes (7): @immutable, CommentUserModel, MarketPost, MarketPostModel, PostCommentModel, SellerModel, ThreadChainItemModel

### Community 110 - "Supabase Schema & Client"
Cohesion: 0.29
Nodes (6): authCallbackUrlScheme, storageBucketMedia, supabaseAnonKey, SupabaseConstants, supabaseUrl, static const String

### Community 111 - "Module: Features Auth Components"
Cohesion: 0.29
Nodes (6): build, GoogleLogo, _GoogleLogoPainter, paint, shouldRepaint, size

### Community 112 - "Module: Features Feed Components"
Cohesion: 0.33
Nodes (6): build, createState, FloatingPlusSquircleButton, _FloatingPlusSquircleButtonState, _isPressed, onTap

### Community 113 - "Module: Features Feed Components"
Cohesion: 0.33
Nodes (6): build, createState, FloatingKumoFabButton, _FloatingKumoFabButtonState, _isPressed, onTap

### Community 114 - "Supabase Schema & Client"
Cohesion: 0.29
Nodes (5): env, envContent, envPath, runTests(), supabase

### Community 115 - "Module: Core Utils String Utils"
Cohesion: 0.33
Nodes (5): cleanTag, _emojiRegex, StringUtils, stripEmojis, static final RegExp

### Community 116 - "Module: Features Feed Components"
Cohesion: 0.33
Nodes (5): post_action_bar.dart, post_author_avatar.dart, post_caption_text.dart, post_card_header.dart, post_media_section.dart

### Community 117 - "Module: Os"
Cohesion: 0.33
Nodes (4): os, pil, generate_icons(), Generate Snaps PWA and Android Launcher Icons from official logo typography.

### Community 118 - "Module: Ref Https"
Cohesion: 0.40
Nodes (5): ref_https, downloadFile(), FONTS, IMAGES, run()

### Community 122 - "Supabase Schema & Client"
Cohesion: 0.33
Nodes (4): env, envContent, envPath, supabase

### Community 123 - "Module: Android Gradlew"
Cohesion: 0.60
Nodes (3): gradlew script, die(), warn()

### Community 125 - "Design Tokens & Theme"
Cohesion: 0.50
Nodes (3): package:flutter_test/flutter_test.dart, package:snapan_market/main.dart, main

## Knowledge Gaps
- **1496 isolated node(s):** `codegraph`, `codegraph`, `codegraph`, `$schema`, `style` (+1491 more)
  These have ≤1 connection - possible missing edges. (Counts symbols only; 1737 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **26 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `react` connect `Marketplace Feed & Interactions` to `Marketplace Feed & Interactions`, `Module: Types Agentation D`, `Module: Types Kumo D`, `Post & Product Creation`, `App Routing & Shell`, `PWA Landing Showcase`, `Direct Messaging & Chat`, `Student Profile & Showcase`, `Campus Blueprint & Map`, `Direct Messaging & Chat`, `PWA Landing Showcase`, `Authentication & Session`, `Direct Messaging & Chat`, `Module: Ui Components Ui Mobiles`, `Module: Ui Components Auth Prote`, `Direct Messaging & Chat`, `PWA Landing Showcase`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **Why does `MarketPostModel` connect `Module: Annotation Immutable` to `Module: Features Feed Components`, `Module: Features Feed Models Mar`, `Design Tokens & Theme`, `Module: Animation`, `Module: Features Feed Components`, `Module: Features Profile Models `, `Module: Features Feed Components`, `Direct Messaging & Chat`, `Module: Features Feed Components`, `COD Checkout & Orders`, `Post & Product Creation`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Why does `_MockHttpClientResponse` connect `Post & Product Creation` to `Flutter Core & Utilities`, `Supabase Schema & Client`?**
  _High betweenness centrality (0.006) - this node is a cross-community bridge._
- **What connects `codegraph`, `codegraph`, `codegraph` to the rest of the system?**
  _1496 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Flutter Core & Utilities` be split into smaller, more focused modules?**
  _Cohesion score 0.02247191011235955 - nodes in this community are weakly interconnected._
- **Should `Marketplace Feed & Interactions` be split into smaller, more focused modules?**
  _Cohesion score 0.0741745816372682 - nodes in this community are weakly interconnected._
- **Should `Module: Features Feed Models Mar` be split into smaller, more focused modules?**
  _Cohesion score 0.03636363636363636 - nodes in this community are weakly interconnected._