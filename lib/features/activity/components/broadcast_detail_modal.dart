import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/update_info_bottom_sheet.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/services/app_update_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/activity/models/activity_notification_model.dart';
import 'package:snapan_market/features/feed/screens/post_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-Open Official Broadcast Announcement Modal Dialog / Bottom Sheet
/// Displays complete announcement text, official badges, school metadata,
/// and direct action triggers (e.g. In-App Update, Web Link, or Post Link).
class BroadcastDetailModal extends StatelessWidget {
  final ActivityNotification notification;

  const BroadcastDetailModal({super.key, required this.notification});

  static Future<void> show(BuildContext context, ActivityNotification notification) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.88,
        child: BroadcastDetailModal(notification: notification),
      ),
    );
  }

  Future<void> _handleAction(BuildContext context) async {
    final actionType = notification.actionType ?? 'none';
    final actionUrl = notification.actionUrl ?? '';

    if (actionType == 'update_app') {
      Navigator.pop(context);
      try {
        final update = await AppUpdateService.instance.checkForUpdate(isManual: true);
        if (update != null && context.mounted) {
          final info = await AppUpdateService.instance.getPackageInfo();
          if (context.mounted) {
            UpdateInfoBottomSheet.show(context, update: update, currentVersionName: info.version);
          }
        }
      } catch (e) {
        debugPrint('Error triggering update from broadcast: $e');
      }
    } else if (actionType == 'external_url' && actionUrl.isNotEmpty) {
      final uri = Uri.tryParse(actionUrl);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else if (actionType == 'post_link' && actionUrl.isNotEmpty) {
      Navigator.pop(context);
      try {
        final post = await SupabaseService.instance.fetchPostById(actionUrl);
        if (post != null && context.mounted) {
          Navigator.push(
            context,
            AppSlidePageRoute(
              builder: (_) => PostDetailScreen(post: post),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error navigating to post from broadcast: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionType = notification.actionType ?? 'none';
    final hasAction = actionType != 'none';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 12.0,
        bottom: MediaQuery.paddingOf(context).bottom + 20.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38.0,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3.0),
              ),
            ),
          ),
          const SizedBox(height: 18.0),

          // Header: Megaphone Gradient Icon + Official Source
          Row(
            children: [
              Container(
                width: 44.0,
                height: 44.0,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF3D38F5), Color(0xFF6366F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  CupertinoIcons.speaker_2_fill,
                  color: Colors.white,
                  size: 20.0,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            notification.actorName.isNotEmpty
                                ? notification.actorName
                                : 'Pengumuman Resmi',
                            style: const TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.5, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(color: const Color(0xFFC7D2FE), width: 0.8),
                          ),
                          child: const Text(
                            "ADMINISTRATOR",
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4338CA),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      "SMKN 8 Semarang • ${notification.timeAgo}",
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Color(0xFFCBD5E1), size: 24.0),
              ),
            ],
          ),

          const SizedBox(height: 16.0),
          const Divider(color: Color(0xFFF1F5F9), height: 1.0),
          const SizedBox(height: 16.0),

          // Judul Pengumuman Penuh
          Text(
            notification.title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12.0),

          // Pesan Lengkap (Full Text, No Truncation, Full Expanded Scrollable)
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SelectableText(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF334155),
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20.0),

          // Action Button if Available (Update / URL / Post)
          if (hasAction) ...[
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton(
                onPressed: () => _handleAction(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      actionType == 'update_app'
                          ? CupertinoIcons.arrow_down_circle_fill
                          : actionType == 'external_url'
                              ? CupertinoIcons.globe
                              : CupertinoIcons.arrow_right_circle_fill,
                      size: 18.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      actionType == 'update_app'
                          ? 'Perbarui Aplikasi Sekarang'
                          : actionType == 'external_url'
                              ? 'Kunjungi Tautan Terkait'
                              : 'Lihat Postingan Terkait',
                      style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10.0),
          ],

          // Dismiss Button
          SizedBox(
            width: double.infinity,
            height: 44.0,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64748B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
              ),
              child: const Text(
                'Tutup Pengumuman',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
