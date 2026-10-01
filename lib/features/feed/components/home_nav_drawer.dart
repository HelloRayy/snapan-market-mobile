import 'package:flutter/material.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/feed/components/drawer/home_nav_channels_card.dart';
import 'package:snapan_market/features/feed/components/drawer/home_nav_footer.dart';
import 'package:snapan_market/features/feed/components/drawer/home_nav_header.dart';
import 'package:snapan_market/features/feed/components/drawer/home_nav_preferences_card.dart';
import 'package:snapan_market/features/feed/components/drawer/home_nav_quick_pills.dart';

/// Clean Orchestrator for Left-to-Right Navigation Drawer (<130 lines).
///
/// Implements 1:1 parity with the Source of Truth HTML design:
/// 1. HomeNavHeader (User profile & create post button)
/// 2. HomeNavQuickPills (Disukai & Arsip buttons)
/// 3. HomeNavChannelsCard (Feeds & Vocational Channels SMKN 8)
/// 4. HomeNavPreferencesCard (Theme, settings, reporting)
/// 5. HomeNavFooter (Logout & Version Branding)
class HomeNavDrawer extends StatelessWidget {
  final Map<String, dynamic>? userProfile;
  final VoidCallback? onForYouTap;
  final VoidCallback? onMarketTap;
  final VoidCallback? onCreatePost;
  final VoidCallback? onLikedTap;
  final VoidCallback? onArchiveTap;
  final VoidCallback? onAppearanceTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onReportTap;
  final VoidCallback? onCheckUpdateTap;
  final ValueChanged<String>? onChannelTap;
  final VoidCallback? onLogout;
  final VoidCallback? onAuthTap;
  final VoidCallback? onClose;

  const HomeNavDrawer({
    super.key,
    this.userProfile,
    this.onForYouTap,
    this.onMarketTap,
    this.onCreatePost,
    this.onLikedTap,
    this.onArchiveTap,
    this.onAppearanceTap,
    this.onSettingsTap,
    this.onReportTap,
    this.onCheckUpdateTap,
    this.onChannelTap,
    this.onLogout,
    this.onAuthTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAuthenticated = SupabaseService.instance.isAuthenticated;

    return Drawer(
      width: 285.0,
      elevation: 0.0,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: const Color(0xFF000000),
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          child: Column(
            children: [
              // Scrollable Main Section
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // 1. Profile & Quick Action Header
                      HomeNavHeader(
                        userProfile: userProfile,
                        onCreatePost: () {
                          onClose?.call();
                          onCreatePost?.call();
                        },
                      ),
                      const SizedBox(height: 14.0),

                      // 2. Quick Action Pills (Disukai & Arsip)
                      HomeNavQuickPills(
                        onLikedTap: () {
                          onClose?.call();
                          onLikedTap?.call();
                        },
                        onArchiveTap: () {
                          onClose?.call();
                          onArchiveTap?.call();
                        },
                      ),
                      const SizedBox(height: 14.0),

                      // 3. Main Feeds & Vocational Channels Card
                      HomeNavChannelsCard(
                        onForYouTap: () {
                          onClose?.call();
                          onForYouTap?.call();
                        },
                        onMarketTap: () {
                          onClose?.call();
                          onMarketTap?.call();
                        },
                        onChannelTap: (channelId) {
                          onClose?.call();
                          onChannelTap?.call(channelId);
                        },
                      ),
                      const SizedBox(height: 12.0),

                      // 4. Secondary Preferences Card
                      HomeNavPreferencesCard(
                        onAppearanceTap: () {
                          onClose?.call();
                          onAppearanceTap?.call();
                        },
                        onSettingsTap: () {
                          onClose?.call();
                          onSettingsTap?.call();
                        },
                        onReportTap: () {
                          onClose?.call();
                          onReportTap?.call();
                        },
                      ),
                      const SizedBox(height: 14.0),
                    ],
                  ),
                ),
              ),

              // 5. Pinned Bottom Footer & Logout Action
              HomeNavFooter(
                isAuthenticated: isAuthenticated,
                onLogout: () {
                  onClose?.call();
                  onLogout?.call();
                },
                onAuthTap: () {
                  onClose?.call();
                  onAuthTap?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
