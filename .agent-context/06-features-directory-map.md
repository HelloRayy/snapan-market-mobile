# 06 - Features Directory Map

Cheat-sheet mapping all features between Flutter (`lib/`) and React PWA (`src/`):

| Feature Area | Flutter Path (`lib/`) | React PWA Path (`src/`) |
| :--- | :--- | :--- |
| **Home Timeline / Feed** | `lib/features/feed/screens/home_feed_screen.dart`<br/>`lib/features/feed/components/market_post_card.dart`<br/>`lib/features/feed/components/post_card/` | `src/ui/pages/HomePage.tsx`<br/>`src/ui/components/marketplace/MarketPostCard.tsx` |
| **Search & Discovery** | `lib/features/search/screens/search_screen.dart`<br/>`lib/features/search/components/search_bar_header.dart` | `src/ui/pages/SearchPage.tsx` |
| **Post Detail Screen** | `lib/features/feed/screens/post_detail_screen.dart`<br/>`lib/features/feed/components/post_comment_item.dart` | `src/ui/pages/PostDetailPage.tsx` |
| **User Profile & Edit** | `lib/features/profile/screens/profile_screen.dart`<br/>`lib/features/profile/screens/edit_profile_screen.dart` | `src/ui/pages/ProfilePage.tsx` |
| **Campus Map 2D** | `lib/features/map/screens/campus_map_screen.dart`<br/>`lib/features/map/components/campus_2d_blueprint_painter.dart` | `src/ui/pages/CampusMapPage.tsx` |
| **COD Meeting Points** | `lib/features/locations/screens/campus_locations_picker_screen.dart`<br/>`lib/features/locations/components/` | `src/services/api/meetingPointsService.ts` |
| **Checkout & Orders** | `lib/features/checkout/screens/checkout_screen.dart` | `src/ui/pages/CheckoutPage.tsx`<br/>`src/ui/store/cartStore.ts` |
| **Direct Chat / Room** | `lib/features/messages/screens/chat_conversation_screen.dart`<br/>`lib/features/messages/screens/direct_messages_screen.dart` | `src/ui/pages/DirectMessagesPage.tsx`<br/>`src/ui/components/chat/` |
| **Create Post Modal** | `lib/features/create_post/screens/create_post_modal.dart` | `src/ui/components/marketplace/CreatePostModal.tsx` |
| **Popovers & Overlays** | `lib/features/feed/components/home_menu_popover.dart`<br/>`lib/features/feed/components/media_lightbox_dialog.dart` | `src/ui/components/marketplace/BuyBottomSheet.tsx` |
