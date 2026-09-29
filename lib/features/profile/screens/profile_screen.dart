import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/components/snaps_skeleton.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/auth/screens/auth_screen.dart';

import 'package:snapan_market/features/feed/components/market_post_card.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/feed/screens/post_detail_screen.dart';
import 'package:snapan_market/features/feed/components/home_feed_header.dart';
import 'package:snapan_market/features/feed/components/media_lightbox_dialog.dart';

import 'package:snapan_market/features/profile/components/profile_info_header.dart';

import 'package:snapan_market/features/profile/components/profile_action_buttons.dart';
import 'package:snapan_market/features/profile/components/profile_tab_bar.dart';
import 'package:snapan_market/features/profile/components/profile_reply_thread_card.dart';
import 'package:snapan_market/features/profile/components/profile_media_grid.dart';
import 'package:snapan_market/features/profile/models/profile_user_model.dart';
import 'package:snapan_market/features/profile/screens/edit_profile_screen.dart';
import 'package:snapan_market/features/messages/models/conversation_model.dart';
import 'package:snapan_market/features/messages/screens/chat_conversation_screen.dart';
import 'package:snapan_market/features/messages/services/direct_messages_service.dart';
import 'package:snapan_market/core/services/follow_service.dart';


/// Full Profile Screen matching ProfilePage.tsx 1:1
///
/// Features:
/// - Sticky Top Bar with Search toggle & filter
/// - Name, Handle, 60x60 Avatar, Class, Verified Badge
/// - Bio & Left-Aligned 3-Avatar Stacked Follower + Seller stats
/// - Bakat & Minat Badges (Chips)
/// - Edit Profile / Follow Action CTA
/// - 3-Tab Sticky Switcher: [Utas] | [Balasan] | [Media]
/// - Live search query filtering across posts, replies, and media
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
  ProfileTab _activeTab = ProfileTab.threads;
  RealtimeChannel? _profileSubscription;
  RealtimeChannel? _followRealtimeSubscription;

  // Search in Profile state
  bool _showSearch = false;
  String _searchQuery = '';

  static List<MarketPostModel>? _cachedOwnPosts;
  static ProfileUserModel? _cachedOwnUser;
  bool _isLoading = true;

  late ProfileUserModel _user;
  late List<MarketPostModel> _allUserPosts;
  late List<ProfileReplyThreadModel> _allUserReplies;

  bool get _isOwnProfile {
    final target = widget.username?.toLowerCase().replaceAll('@', '').trim();
    if (target == null || target.isEmpty || target == 'me') {
      return true;
    }
    final currentUser = SupabaseService.instance.currentUser;
    if (currentUser != null) {
      final currentUsername = currentUser.userMetadata?['username']?.toString().toLowerCase().trim();
      if (currentUsername != null && currentUsername == target) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _initProfileData();
    _loadLiveProfile();
    _setupRealtimeSubscription();
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initProfileData();
    _loadLiveProfile();
    _setupRealtimeSubscription();
  }

  void reloadProfile() {
    _initProfileData();
    _loadLiveProfile();
    _setupRealtimeSubscription();
  }

  void _setupRealtimeSubscription() {
    _profileSubscription?.unsubscribe();
    _followRealtimeSubscription?.unsubscribe();

    final currentUser = SupabaseService.instance.currentUser;
    if (_isOwnProfile && currentUser != null) {
      _profileSubscription = SupabaseService.instance.subscribeToProfile(
        currentUser.id,
        (newRecord) {
          if (!mounted) return;
          debugPrint('ProfileScreen Realtime update received: $newRecord');
          setState(() {
            _user = _user.copyWith(
              name: newRecord['full_name'] as String? ?? _user.name,
              username: newRecord['username'] as String? ?? _user.username,
              classGroup: newRecord['class_group'] as String? ?? _user.classGroup,
              avatar: (newRecord['avatar_url'] as String?)?.isNotEmpty == true
                  ? newRecord['avatar_url'] as String
                  : _user.avatar,
              bio: newRecord['bio'] as String? ?? _user.bio,
              isVerified: newRecord['is_verified'] as bool? ?? false,
            );
          });
        },
      );

      _followRealtimeSubscription = SupabaseService.instance.subscribeToFollowers(
        currentUser.id,
        () {
          if (!mounted) return;
          FollowService.instance.loadFollowerCount(currentUser.id);
        },
      );
    } else if (!_isOwnProfile && _user.id.isNotEmpty) {
      _followRealtimeSubscription = SupabaseService.instance.subscribeToFollowers(
        _user.id,
        () {
          if (!mounted) return;
          FollowService.instance.loadFollowerCount(_user.id);
        },
      );
    }
  }

  Future<void> _loadLiveProfile() async {
    if (_isOwnProfile) {
      final currentUser = SupabaseService.instance.currentUser;
      if (currentUser == null) return;

      try {
        final profile = await SupabaseService.instance.getProfile(currentUser.id);
        final livePosts = await SupabaseService.instance.fetchUserPosts(currentUser.id);
        final ownFollowersCount = await FollowService.instance.loadFollowerCount(currentUser.id);
        final meta = currentUser.userMetadata ?? {};
        final metaTags = meta['tags'];
        List<String> userTags = _user.tags;
        if (profile?['interests'] is String && (profile!['interests'] as String).isNotEmpty) {
          userTags = (profile['interests'] as String).split(',');
        } else if (metaTags is List) {
          userTags = metaTags.map((e) => e.toString()).toList();
        }

        if (!mounted) return;
        setState(() {
          if (profile != null) {
            _user = _user.copyWith(
              id: profile['id'] as String? ?? currentUser.id,
              name: profile['full_name'] as String? ?? _user.name,
              username: profile['username'] as String? ?? _user.username,
              classGroup: profile['class_group'] as String? ?? _user.classGroup,
              avatar: (profile['avatar_url'] as String?)?.isNotEmpty == true
                  ? profile['avatar_url'] as String
                  : _user.avatar,
              bio: profile['bio'] as String? ?? (meta['bio'] as String?) ?? _user.bio,
              link: profile['link'] as String? ?? (meta['link'] as String?) ?? _user.link,
              tags: userTags,
              followersCount: ownFollowersCount,
              isVerified: profile['is_verified'] as bool? ?? false,
            );
          } else {
            final fullName = (meta['full_name'] as String?)?.trim();
            final username = (meta['username'] as String?)?.trim();
            final classGroup = (meta['class_group'] as String?)?.trim();
            final avatar = (meta['avatar_url'] as String?)?.trim() ?? '';
            final bio = (meta['bio'] as String?)?.trim();
            final link = (meta['link'] as String?)?.trim();

            _user = _user.copyWith(
              name: (fullName != null && fullName.isNotEmpty) ? fullName : _user.name,
              username: (username != null && username.isNotEmpty) ? username : _user.username,
              classGroup: (classGroup != null && classGroup.isNotEmpty) ? classGroup : _user.classGroup,
              avatar: avatar.isNotEmpty ? avatar : _user.avatar,
              bio: (bio != null && bio.isNotEmpty) ? bio : _user.bio,
              link: link ?? _user.link,
              tags: userTags,
              followersCount: ownFollowersCount,
            );
          }
          _allUserPosts = livePosts;
          _isLoading = false;
          _cachedOwnPosts = livePosts;
          _cachedOwnUser = _user;
        });
      } catch (e) {
        debugPrint('Error _loadLiveProfile: $e');
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      final cleanUsername = widget.username?.replaceAll('@', '').toLowerCase().trim();
      if (cleanUsername == null || cleanUsername.isEmpty) return;

      try {
        final matchedProfiles = await SupabaseService.instance.searchProfiles(cleanUsername);
        if (matchedProfiles.isNotEmpty && mounted) {
          final p = matchedProfiles.first;
          final targetId = p['id'] as String? ?? '';
          final targetPosts = await SupabaseService.instance.fetchUserPosts(targetId);
          final otherFollowersCount = await FollowService.instance.loadFollowerCount(targetId);

          if (!mounted) return;
          setState(() {
            _user = _user.copyWith(
              id: targetId,
              name: p['full_name'] as String? ?? _user.name,
              username: p['username'] as String? ?? cleanUsername,
              classGroup: p['class_group'] as String? ?? _user.classGroup,
              avatar: (p['avatar_url'] as String?)?.isNotEmpty == true
                  ? p['avatar_url'] as String
                  : _user.avatar,
              bio: p['bio'] as String? ?? _user.bio,
              link: p['link'] as String? ?? _user.link,
              followersCount: otherFollowersCount,
              isVerified: p['is_verified'] as bool? ?? false,
            );
            _allUserPosts = targetPosts;
            _isLoading = false;
          });
          _setupRealtimeSubscription();
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } catch (e) {
        debugPrint('Error fetching other user profile from Supabase: $e');
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _initProfileData() {
    if (_isOwnProfile) {
      if (_cachedOwnPosts != null) {
        _allUserPosts = List.from(_cachedOwnPosts!);
        _isLoading = false;
      } else {
        _allUserPosts = [];
        _isLoading = true;
      }

      if (_cachedOwnUser != null) {
        _user = _cachedOwnUser!;
      } else {
        final currentUser = SupabaseService.instance.currentUser;
        if (currentUser != null) {
          final meta = currentUser.userMetadata ?? {};
          final fullName = (meta['full_name'] as String?)?.trim();
          final username = (meta['username'] as String?)?.trim();
          final classGroup = (meta['class_group'] as String?)?.trim();
          final avatar = (meta['avatar_url'] as String?)?.trim() ?? '';
          final bio = (meta['bio'] as String?)?.trim();
          final link = (meta['link'] as String?)?.trim();
          final tagsRaw = meta['tags'];
          List<String> tags = [];
          if (tagsRaw is List) {
            tags = tagsRaw.map((e) => e.toString()).toList();
          } else if (tagsRaw is String && tagsRaw.isNotEmpty) {
            tags = tagsRaw.split(',');
          }

          _user = ProfileUserModel(
            id: currentUser.id,
            name: (fullName != null && fullName.isNotEmpty) ? fullName : 'Siswa Snapan',
            username: (username != null && username.isNotEmpty) ? username : 'siswa',
            classGroup: (classGroup != null && classGroup.isNotEmpty) ? classGroup : 'SMKN 8 Jakarta',
            avatar: avatar,
            bio: (bio != null && bio.isNotEmpty) ? bio : 'Siswa ${classGroup ?? 'SMKN 8 Jakarta'}',
            tags: tags,
            link: link ?? '',
            followersCount: 0,
            soldCount: 0,
            rating: 5.0,
            isVerified: false,
          );
        } else {
          _user = const ProfileUserModel(
            id: 'guest',
            name: 'Tamu Snapan',
            username: 'tamu',
            classGroup: 'Belum Masuk',
            avatar: '',
            bio: 'Masuk atau daftar akun untuk melihat profil, mengunggah utas dan produk.',
            link: '',
            followersCount: 0,
            soldCount: 0,
            rating: 5.0,
            isVerified: false,
          );
        }
      }
      _allUserReplies = [];
    } else {
      if (widget.initialUser != null) {
        _user = widget.initialUser!;
        _isLoading = false;
      } else {
        final cleanUsername = (widget.username ?? 'siswa').replaceAll('@', '').trim();
        _user = ProfileUserModel(
          id: '',
          name: cleanUsername,
          username: cleanUsername,
          avatar: '',
          bio: '',
          classGroup: '',
          tags: const [],
          followersCount: 0,
          soldCount: 0,
          rating: 5.0,
          isVerified: false,
        );
      }

      _allUserPosts = [];
      _allUserReplies = [];
    }
  }

  Future<void> _handleDeletePost(MarketPostModel post) async {
    final int existingIndex = _allUserPosts.indexWhere((p) => p.id == post.id);
    if (existingIndex == -1) return;

    // 1. Optimistic removal from profile posts list
    setState(() {
      _allUserPosts.removeAt(existingIndex);
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Postingan berhasil dihapus'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    // 2. Perform backend deletion
    try {
      final isAdmin = await SupabaseService.instance.isCurrentUserAdmin();
      final isOwner = SupabaseService.instance.currentUser?.id == post.seller.id;
      await SupabaseService.instance.deletePost(post.id, asAdmin: isAdmin && !isOwner);
    } catch (e) {
      debugPrint('Error deleting post in profile: $e');
      if (mounted) {
        setState(() {
          _allUserPosts.insert(existingIndex.clamp(0, _allUserPosts.length), post);
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus postingan. Silakan coba lagi.'),
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handlePostClick(MarketPostModel post) async {
    HapticFeedback.lightImpact();
    final result = await Navigator.of(context).push(
      AppSlidePageRoute(
        builder: (_) => PostDetailScreen(
          post: post,
          onDeletePost: _handleDeletePost,
        ),
      ),
    );

    if (result is Map && result['deleted'] == true) {
      final postId = result['postId'] as String?;
      if (postId != null) {
        setState(() {
          _allUserPosts.removeWhere((p) => p.id == postId);
        });
      }
    }
  }

  void _handleLikeToggle(MarketPostModel item) {
    HapticFeedback.lightImpact();
    setState(() {
      final isLiked = item.isLiked;
      final updated = item.copyWith(
        isLiked: !isLiked,
        likesCount: isLiked ? (item.likesCount - 1) : (item.likesCount + 1),
      );
      _allUserPosts = _allUserPosts.map((p) => p.id == item.id ? updated : p).toList();
    });
  }

  void _handleRepostToggle(MarketPostModel item) {
    HapticFeedback.lightImpact();
    setState(() {
      final isReposted = item.isReposted;
      final updated = item.copyWith(
        isReposted: !isReposted,
        repostsCount: isReposted ? (item.repostsCount - 1) : (item.repostsCount + 1),
      );
      _allUserPosts = _allUserPosts.map((p) => p.id == item.id ? updated : p).toList();
    });
  }

  void _handleImageClick(MarketPostModel item, int index) {
    if (item.images.isEmpty || index >= item.images.length) return;
    MediaLightboxDialog.show(
      context: context,
      images: item.images,
      initialIndex: index,
      post: item,
      onLikeToggle: _handleLikeToggle,
      onRepostToggle: _handleRepostToggle,
    );
  }

  void _openImageViewer(List<String> images, [int index = 0]) {
    MediaLightboxDialog.show(
      context: context,
      images: images,
      initialIndex: index,
    );
  }

  void _handleOpenAuth() {
    Navigator.push(
      context,
      AppSlidePageRoute(
        builder: (context) => AuthScreen(
          onBack: () => Navigator.pop(context),
          onSuccess: () {
            Navigator.pop(context);
            _initProfileData();
            _loadLiveProfile();
          },
        ),
      ),
    );
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
          initialUser: _user,
          onSave: (savedUser) {
            setState(() {
              _user = savedUser;
              _allUserPosts = _allUserPosts.map((p) {
                return p.copyWith(

                  seller: p.seller.copyWith(
                    name: savedUser.name,
                    username: savedUser.username,
                    avatar: savedUser.avatar,
                    classGroup: savedUser.classGroup,
                  ),
                );
              }).toList();
            });
          },
        ),
      ),
    );

    if (updated != null && mounted) {
      final currentUser = SupabaseService.instance.currentUser;
      if (currentUser != null) {
        SupabaseService.instance.updateProfile(
          userId: currentUser.id,
          fullName: updated.name,
          username: updated.username,
          classGroup: updated.classGroup,
          avatarUrl: updated.avatar,
        );
      }
      setState(() {
        _user = updated;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


  void _handleAvatarTap() {
    if (_user.avatar.trim().isEmpty) return;
    MediaLightboxDialog.show(
      context: context,
      images: [_user.avatar],
      initialIndex: 0,
    );
  }

  void _handleDirectMessage() {
    final conv = ConversationModel(
      id: 'conv_${_user.id.isNotEmpty ? _user.id : _user.username}',
      user: ConversationUser(
        name: _user.name,
        username: _user.username,
        avatar: _user.avatar,
        classGroup: _user.classGroup,
        isVerified: _user.isVerified,
      ),
      lastMessage: '',
      timestamp: 'Baru saja',
      unreadCount: 0,
      isSender: true,
    );
    DirectMessagesService.instance.addOrUpdateConversation(conv);
    Navigator.of(context).push(
      AppSlidePageRoute(
        builder: (_) => ChatConversationScreen(conversation: conv),
      ),
    );
  }

  @override
  void dispose() {
    _profileSubscription?.unsubscribe();
    _followRealtimeSubscription?.unsubscribe();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter posts according to search query
    final displayPosts = _allUserPosts.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.caption.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Filter replies
    final displayReplies = _allUserReplies.where((t) {
      if (_searchQuery.isEmpty) return true;
      return t.reply.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.parentPost.caption.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Extract media items for Media tab
    final mediaItems = _allUserPosts
        .expand((p) => p.images.map((img) => ProfileMediaItem(imageUrl: img, post: p)))
        .where((m) {
          if (_searchQuery.isEmpty) return true;
          return m.post.caption.toLowerCase().contains(_searchQuery.toLowerCase());
        })
        .toList();

    final Widget bodyScrollView = CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [

          // Collapsible Search Bar when active
          if (_showSearch)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 4.0),
                child: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Icon(
                          Icons.search_rounded,
                          size: 18.0,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          controller: TextEditingController(text: _searchQuery)
                            ..selection = TextSelection.fromPosition(
                              TextPosition(offset: _searchQuery.length),
                            ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.normal,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Cari utas atau media di profil...',
                            hintStyle: TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => _searchQuery = ''),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Icon(
                              Icons.cancel_rounded,
                              size: 16.0,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // 1. Profile Bio & Information Header
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListenableBuilder(
                  listenable: FollowService.instance,
                  builder: (context, _) {
                    final isFollowing = FollowService.instance.isFollowing(_user.id, _user.username);
                    final reactiveFollowersCount = FollowService.instance.getFollowerCount(
                      _user.id,
                      _user.followersCount,
                    );
                    final displayUser = _user.copyWith(followersCount: reactiveFollowersCount);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileInfoHeader(
                          user: displayUser,
                          isOwnProfile: _isOwnProfile,
                          onEditInterests: _handleEditProfile,
                          onAvatarTap: _handleAvatarTap,
                        ),
                        ProfileActionButtons(
                          isOwnProfile: _isOwnProfile,
                          isFollowing: isFollowing,
                          isLoggedIn: SupabaseService.instance.isAuthenticated,
                          onEditProfile: _handleEditProfile,
                          onAuthTap: _handleOpenAuth,
                          onToggleFollow: () async {
                            await FollowService.instance.toggleFollow(
                              targetUserId: _user.id,
                              targetUsername: _user.username,
                            );
                          },
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

          // 2. Tab Bar Switcher (Utas, Balasan, Media) - scrolls away naturally with the profile content
          SliverToBoxAdapter(
            child: RepaintBoundary(
              child: ProfileTabBar(
                activeTab: _activeTab,
                onTabChanged: (tab) => setState(() => _activeTab = tab),
              ),
            ),
          ),

          // 3. Tab Content Area
          if (_activeTab == ProfileTab.threads) ...[
            if (_isLoading && displayPosts.isEmpty)
              const SliverToBoxAdapter(
                child: FeedTimelineSkeleton(itemCount: 3),
              )
            else if (displayPosts.isNotEmpty)
              SliverList.builder(
                itemCount: displayPosts.length,
                itemBuilder: (context, index) {
                  final post = displayPosts[index];
                  return MarketPostCard(
                    key: ValueKey(post.id),
                    item: post,
                    onPostClick: _handlePostClick,
                    onLikeToggle: _handleLikeToggle,
                    onRepostToggle: _handleRepostToggle,
                    onImageClick: _handleImageClick,
                    onDeletePost: _handleDeletePost,
                  );
                },
              )
            else
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 24.0),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 36.0,
                        color: Color(0xFFCBD5E1),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Belum ada postingan',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Postingan dan produk jualan akan muncul di sini.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF94A3B8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ] else if (_activeTab == ProfileTab.replies) ...[
            if (_isLoading && displayReplies.isEmpty)
              const SliverToBoxAdapter(
                child: FeedTimelineSkeleton(itemCount: 2),
              )
            else if (displayReplies.isNotEmpty)
              SliverList.builder(
                itemCount: displayReplies.length,
                itemBuilder: (context, index) {
                  final replyThread = displayReplies[index];
                  return ProfileReplyThreadCard(
                    key: ValueKey(replyThread.id),
                    thread: replyThread,
                    onPostClick: _handlePostClick,
                    onImageClick: (imgs, idx) => _openImageViewer(imgs, idx),
                  );

                },
              )
            else
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 24.0),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 36.0,
                        color: Color(0xFFCBD5E1),
                      ),
                      const SizedBox(height: 10.0),
                      const Text(
                        'Belum ada balasan',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        '@${_user.username} belum membalas utas apa pun.',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF94A3B8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ] else if (_activeTab == ProfileTab.media) ...[
            SliverToBoxAdapter(
              child: ProfileMediaGrid(
                mediaItems: mediaItems,
                onMediaTap: _handlePostClick,
              ),
            ),
          ],

          // Bottom clearance for floating nav bar
          const SliverToBoxAdapter(
            child: SizedBox(height: 120.0),
          ),
        ],
      );

    final Widget refreshableBody = RefreshIndicator(
      onRefresh: _loadLiveProfile,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: bodyScrollView,
    );

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: HomeFeedHeader(
          onBackTap: widget.onBack,
          onMenuTap: widget.onOpenMenu,
          onTitleTap: () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              );
            }
          },
          onSearchTap: () {
            setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) _searchQuery = '';
            });
          },
        ),
        body: refreshableBody,
      );
    }

    return refreshableBody;
  }

}
