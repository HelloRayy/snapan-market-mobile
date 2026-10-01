import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Primary grouped card for feed modes and vocational community channels (<140 lines).
class HomeNavChannelsCard extends StatelessWidget {
  final VoidCallback? onForYouTap;
  final VoidCallback? onMarketTap;
  final ValueChanged<String>? onChannelTap;

  const HomeNavChannelsCard({
    super.key,
    this.onForYouTap,
    this.onMarketTap,
    this.onChannelTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161618),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF27272A), width: 1.0),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NAVIGASI UTAMA',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF71717A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8.0),

          // 1. Untuk Anda (For you)
          _buildItem(
            dotColor: const Color(0xFF3B82F6),
            title: 'Untuk Anda (For You)',
            badgeText: 'Utama',
            badgeBg: Colors.transparent,
            badgeTextColor: const Color(0xFF71717A),
            onTap: onForYouTap,
          ),
          const SizedBox(height: 6.0),

          // 2. Jualan & Pasar
          _buildItem(
            dotColor: const Color(0xFF10B981),
            title: 'Jualan & Pasar Siswa',
            badgeText: 'COD',
            badgeBg: const Color(0xFF064E3B),
            badgeTextColor: const Color(0xFF34D399),
            onTap: onMarketTap,
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Divider(color: const Color(0xFF27272A), height: 1.0),
          ),

          const Text(
            'SALURAN KEJURUAN',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF71717A),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8.0),

          // 3. PPLG Channel
          _buildChannelItem(
            title: 'PPLG & Software',
            subtitle: '1,2M siswa • Aktif',
            color1: const Color(0xFF2563EB),
            color2: const Color(0xFF4F46E5),
            char1: 'P',
            char2: 'S',
            onTap: () => onChannelTap?.call('pplg'),
          ),
          const SizedBox(height: 8.0),

          // 4. DKV Channel
          _buildChannelItem(
            title: 'DKV & Desain Kreatif',
            subtitle: '149K siswa • Aktif',
            color1: const Color(0xFFD97706),
            color2: const Color(0xFFE11D48),
            char1: 'D',
            char2: 'K',
            onTap: () => onChannelTap?.call('dkv'),
          ),
          const SizedBox(height: 8.0),

          // 5. Kuliner Channel
          _buildChannelItem(
            title: 'Kuliner & Kantin 8',
            subtitle: '21,2K siswa • Aktif',
            color1: const Color(0xFF059669),
            color2: const Color(0xFF10B981),
            char1: 'K',
            char2: 'B',
            onTap: () => onChannelTap?.call('kuliner'),
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required Color dotColor,
    required String title,
    required String badgeText,
    required Color badgeBg,
    required Color badgeTextColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            Row(
              children: [
                Container(width: 7.0, height: 7.0, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                const SizedBox(width: 9.0),
                Text(
                  title,
                  style: const TextStyle(fontFamily: 'SFPro', fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
              decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(4.0)),
              child: Text(badgeText, style: TextStyle(fontFamily: 'SFPro', fontSize: 9.5, fontWeight: FontWeight.w600, color: badgeTextColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelItem({
    required String title,
    required String subtitle,
    required Color color1,
    required Color color2,
    required String char1,
    required String char2,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.between,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontFamily: 'SFPro', fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 1.0),
                Text(subtitle, style: const TextStyle(fontFamily: 'SFPro', fontSize: 10.5, color: Color(0xFFA1A1AA))),
              ],
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: [
                    _buildAvatarBubble(char1, color1),
                    Transform.translate(offset: const Offset(-6.0, 0.0), child: _buildAvatarBubble(char2, color2)),
                  ],
                ),
                Positioned(
                  right: -2.0,
                  top: -2.0,
                  child: Container(
                    width: 7.0,
                    height: 7.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF161618), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarBubble(String char, Color bg) {
    return Container(
      width: 19.0,
      height: 19.0,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF161618), width: 1.2),
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: const TextStyle(fontFamily: 'SFPro', fontSize: 9.0, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}
