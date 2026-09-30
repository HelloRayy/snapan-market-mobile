import 'package:flutter/material.dart';

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
      backgroundColor: Colors.white,
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline_rounded, color: Color(0xFF0F172A)),
              title: const Text('Lihat Profil', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: onViewProfile,
            ),
            ListTile(
              leading: const Icon(Icons.shield_outlined, color: Color(0xFF0F172A)),
              title: const Text('Laporkan Pengguna', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: onReportUser,
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
              title: const Text('Bersihkan Obrolan', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
              onTap: onClearChat,
            ),
          ],
        ),
      ),
    );
  }
}
