import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Modal bottom sheet providing conversation actions (view profile, report, clear chat).
class ChatOptionsSheet extends StatelessWidget {
  final VoidCallback onViewProfile;
  final VoidCallback onReportUser;
  final VoidCallback onClearChat;

  const ChatOptionsSheet({
    super.key,
    required this.onViewProfile,
    required this.onReportUser,
    required this.onClearChat,
  });

  static Future<void> show({
    required BuildContext context,
    required VoidCallback onViewProfile,
    required VoidCallback onReportUser,
    required VoidCallback onClearChat,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.adaptiveSurface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => ChatOptionsSheet(
        onViewProfile: () {
          Navigator.pop(ctx);
          onViewProfile();
        },
        onReportUser: () {
          Navigator.pop(ctx);
          onReportUser();
        },
        onClearChat: () {
          Navigator.pop(ctx);
          onClearChat();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = AppColors.adaptiveText(context);
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.adaptiveText(context),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(CupertinoIcons.person, color: iconColor),
              title: Text('Lihat Profil', style: textStyle),
              onTap: onViewProfile,
            ),
            ListTile(
              leading: Icon(CupertinoIcons.shield, color: iconColor),
              title: Text('Laporkan Pengguna', style: textStyle),
              onTap: onReportUser,
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.trash, color: Colors.red),
              title: const Text('Bersihkan Obrolan', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              onTap: onClearChat,
            ),
          ],
        ),
      ),
    );
  }
}
