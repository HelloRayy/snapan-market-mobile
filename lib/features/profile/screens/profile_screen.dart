import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/snaps_skeleton.dart';
import 'package:snapan_market/core/ui/default_profile_avatar.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/services/follow_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/auth/screens/auth_screen.dart';
import 'package:snapan_market/features/feed/components/home_feed_header.dart';
import 'package:snapan_market/features/feed/components/media_lightbox_dialog.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/feed/screens/post_detail_screen.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';
import 'package:snapan_market/features/messages/screens/chat_conversation_screen.dart';
import 'package:snapan_market/features/messages/services/direct_messages_service.dart';
import 'package:snapan_market/features/profile/components/profile_action_buttons.dart';
import 'package:snapan_market/features/profile/components/profile_content_tabs.dart';
import 'package:snapan_market/features/profile/components/profile_header_skeleton.dart';
import 'package:snapan_market/features/profile/components/profile_info_header.dart';
import 'package:snapan_market/features/profile/components/profile_media_grid.dart';
import 'package:snapan_market/features/profile/components/profile_search_bar.dart';
import 'package:snapan_market/features/profile/components/profile_tab_bar.dart';
import 'package:snapan_market/features/profile/controllers/profile_controller.dart';
import 'package:snapan_market/features/profile/models/profile_user_model.dart';
import 'package:snapan_market/features/profile/screens/edit_profile_screen.dart';

/// Full Profile Screen (<300 lines orchestrator).
class ProfileScreen extends StatefulWidget {
  final String? username;
  final ProfileUserModel? initialUser;
  final VoidCallback? onBack;
  final VoidCallback? onOpenMenu;
  final bool showAppBar;

  const ProfileScreen({
    super.key,
    this.username,
    this.initialUser,
    this.onBack,
    this.onOpenMenu,
    this.showAppBar = true,
  });

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  final ProfileController _controller = ProfileController();
  ProfileTab _activeTab = ProfileTab.threads;
  bool _showSearch = false;
  String _searchQuery = '';

  bool get _isOwnProfile {
    final target = widget.username?.toLowerCase().replaceAll('@', '').trim();
    if (target == null || target.isEmpty || target == 'me') return true;
    final currentUser = SupabaseService.instance.currentUser;
    if (currentUser != null) {
      final currentUsername = currentUser.userMetadata?['username']?.toString().toLowerCase().trim();
      if (currentUsername != null && currentUsername == target) return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() { if (mounted) setState(() {}); });
    reloadProfile();
  }

  void reloadProfile() {
    _controller.loadProfile(isOwnProfile: _isOwnProfile, username: widget.username);
  }

  @override
  void dispose() {
    _controller.disposeSubscriptions();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handlePostClick(MarketPostModel item) async {
    final result = await Navigator.push(
      context,
      AppSlidePageRoute(
        builder: (_) => PostDetailScreen(
          post: item,
          onLikeToggle: _controller.toggleLike,
          onBookmarkToggle: _controller.toggleBookmark,
          onRepostToggle: _controller.toggleRepost,
          onDeletePost: (deleted) => _controller.removePost(deleted.id),
        ),
      ),
    );
    if (result is Map) {
      if (result['deleted'] == true) {
        final postId = result['postId'] as String?;
        if (postId != null) _controller.removePost(postId);
      } else if (result['updatedPost'] is MarketPostModel) {
        _controller.updatePost(result['updatedPost'] as MarketPostModel);
      }
    }
  }

  void _handleEditProfile() async {
    if (!SupabaseService.instance.isAuthenticated) {
      _handleOpenAuth();
      return;
    }
    final user = _controller.user;
    if (user == null) return;
    HapticFeedback.lightImpact();
    final updated = await Navigator.of(context).push<ProfileUserModel>(
      AppSlidePageRoute(
        builder: (_) => EditProfileScreen(
          initialUser: user,
          onSave: (saved) => _controller.updateUser(saved),
        ),
      ),
    );
    if (updated != null && mounted) {
      _controller.updateUser(updated);
    }
  }

  void _handleOpenAuth() {
    Navigator.push(
      context,
      AppSlidePageRoute(
        builder: (_) => AuthScreen(
          onBack: () => Navigator.pop(context),
          onSuccess: () {
            Navigator.pop(context);
            reloadProfile();
          },
        ),
      ),
    );
  }

  void _handleDirectMessage() async {
    final user = _controller.user;
    if (user == null) return;
    String convId = 'conv_${user.id.isNotEmpty ? user.id : user.username}';
    if (user.id.isNotEmpty) {
      final realConvId = await SupabaseService.instance.getOrCreateConversation(
        otherUserId: user.id,
      );
      if (realConvId != null) {
        convId = realConvId;
      }
    }
    final conv = ConversationModel(
      id: convId,
      user: ConversationUser(
        id: user.id.isNotEmpty ? user.id : null,
        name: user.name,
        username: user.username,
        avatar: user.avatar,
        classGroup: user.classGroup,
        isVerified: user.isVerified,
      ),
      lastMessage: '',
      timestamp: 'Baru saja',
      unreadCount: 0,
      isSender: true,
    );
    DirectMessagesService.instance.addOrUpdateConversation(conv);
    if (mounted) {
      Navigator.of(context).push(AppSlidePageRoute(builder: (_) => ChatConversationScreen(conversation: conv)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body;

    if (_controller.isLoading && _controller.user == null) {
      // 1. Shimmer Skeleton state while fetching live profile
      body = CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          const SliverToBoxAdapter(child: ProfileHeaderSkeleton()),
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: ProfileTabBar(
                activeTab: ProfileTab.threads,
                onTabChanged: (_) {},
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: FeedTimelineSkeleton(itemCount: 4),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120.0)),
        ],
      );
    } else if (_controller.isNotFound) {
      // 2. User Not Found state
      body = Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.person_crop_circle_badge_exclam, size: 32, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pengguna Tidak Ditemukan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Profil yang Anda cari tidak terdaftar atau telah dihapus.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (widget.onBack != null) {
                    widget.onBack!();
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 0,
                ),
                child: const Text('Kembali', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    } else if (_controller.user != null) {
      // 3. Fully loaded live profile data
      final user = _controller.user!;
      final displayPosts = _controller.allUserPosts.where((p) {
        if (_searchQuery.isEmpty) return true;
        return p.caption.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      final displayReplies = _controller.allUserReplies.where((t) {
        if (_searchQuery.isEmpty) return true;
        return t.reply.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.parentPost.caption.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      final mediaItems = _controller.allUserPosts
          .expand((p) => p.images.map((img) => ProfileMediaItem(imageUrl: img, post: p)))
          .where((m) => _searchQuery.isEmpty || m.post.caption.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();

      body = RefreshIndicator(
        onRefresh: () => _controller.loadProfile(isOwnProfile: _isOwnProfile, username: widget.username),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            if (_showSearch)
              SliverToBoxAdapter(
                child: ProfileSearchBar(
                  searchQuery: _searchQuery,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  onClear: () => setState(() => _searchQuery = ''),
                ),
              ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListenableBuilder(
                    listenable: FollowService.instance,
                    builder: (context, _) {
                      final isFollowing = FollowService.instance.isFollowing(user.id, user.username);
                      final reactiveFollowers = FollowService.instance.getFollowerCount(user.id, user.followersCount);
                      final displayUser = user.copyWith(followersCount: reactiveFollowers);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileInfoHeader(
                            user: displayUser,
                            isOwnProfile: _isOwnProfile,
                            onEditInterests: _handleEditProfile,
                            onAvatarTap: () {
                              if (!kForceDefaultProfileAvatar && user.avatar.isNotEmpty) {
                                MediaLightboxDialog.show(context: context, images: [user.avatar], initialIndex: 0);
                              }
                            },
                          ),
                          ProfileActionButtons(
                            isOwnProfile: _isOwnProfile,
                            isFollowing: isFollowing,
                            isLoggedIn: SupabaseService.instance.isAuthenticated,
                            onEditProfile: _handleEditProfile,
                            onAuthTap: _handleOpenAuth,
                            onToggleFollow: () => FollowService.instance.toggleFollow(targetUserId: user.id, targetUsername: user.username),
                            onDirectMessage: _handleDirectMessage,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 10.0),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: RepaintBoundary(
                child: ProfileTabBar(
                  activeTab: _activeTab,
                  onTabChanged: (tab) => setState(() => _activeTab = tab),
                ),
              ),
            ),
            ProfileContentTabs(
              activeTab: _activeTab,
              isLoading: _controller.isLoading,
              displayPosts: displayPosts,
              displayReplies: displayReplies,
              mediaItems: mediaItems,
              username: user.username,
              onPostClick: _handlePostClick,
              onLikeToggle: _controller.toggleLike,
              onBookmarkToggle: _controller.toggleBookmark,
              onRepostToggle: _controller.toggleRepost,
              onVotePoll: (post, optionIds) => _controller.votePoll(post.id, optionIds),
              onImageClick: (item, idx) => MediaLightboxDialog.show(context: context, images: item.images, initialIndex: idx, post: item),
              onDeletePost: (post) => _controller.removePost(post.id),
              onReplyImageClick: (imgs, idx) => MediaLightboxDialog.show(context: context, images: imgs, initialIndex: idx),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120.0)),
          ],
        ),
      );
    } else {
      body = const Center(
        child: Text(
          'Silakan masuk untuk melihat profil.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
        ),
      );
    }

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: HomeFeedHeader(
          onBackTap: widget.onBack,
          onMenuTap: widget.onOpenMenu,
          onTitleTap: () {
            if (_scrollController.hasClients) _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);
          },
          onSearchTap: () => setState(() {
            _showSearch = !_showSearch;
            if (!_showSearch) _searchQuery = '';
          }),
        ),
        body: body,
      );
    }
    return body;
  }
}
