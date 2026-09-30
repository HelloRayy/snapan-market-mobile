import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          onBookmarkToggle: (_) {},
          onRepostToggle: _controller.toggleRepost,
          onDeletePost: (deleted) => _controller.removePost(deleted.id),
        ),
      ),
    );
    if (result is Map && result['deleted'] == true) {
      final postId = result['postId'] as String?;
      if (postId != null) _controller.removePost(postId);
    }
  }

  void _handleEditProfile() async {
    if (!SupabaseService.instance.isAuthenticated) {
      _handleOpenAuth();
      return;
    }
    HapticFeedback.lightImpact();
    final updated = await Navigator.of(context).push<ProfileUserModel>(
      AppSlidePageRoute(
        builder: (_) => EditProfileScreen(
          initialUser: _controller.user,
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

  void _handleDirectMessage() {
    final user = _controller.user;
    final conv = ConversationModel(
      id: 'conv_${user.id.isNotEmpty ? user.id : user.username}',
      user: ConversationUser(
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
    Navigator.of(context).push(AppSlidePageRoute(builder: (_) => ChatConversationScreen(conversation: conv)));
  }

  @override
  Widget build(BuildContext context) {
    final user = _controller.user;
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

    final body = RefreshIndicator(
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
                            if (user.avatar.isNotEmpty) {
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
            onRepostToggle: _controller.toggleRepost,
            onImageClick: (item, idx) => MediaLightboxDialog.show(context: context, images: item.images, initialIndex: idx, post: item),
            onDeletePost: (post) => _controller.removePost(post.id),
            onReplyImageClick: (imgs, idx) => MediaLightboxDialog.show(context: context, images: imgs, initialIndex: idx),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120.0)),
        ],
      ),
    );

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
