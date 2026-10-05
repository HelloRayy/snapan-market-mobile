import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/services/global_notification_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Bottom Sheet Panduan Pengaturan Notifikasi HP (Agar notifikasi di luar app tembus)
class NotificationGuideBottomSheet extends StatefulWidget {
  const NotificationGuideBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationGuideBottomSheet(),
    );
  }

  @override
  State<NotificationGuideBottomSheet> createState() => _NotificationGuideBottomSheetState();
}

class _NotificationGuideBottomSheetState extends State<NotificationGuideBottomSheet> {
  bool _isSyncing = false;
  String? _syncStatus;

  static const MethodChannel _settingsChannel = MethodChannel('com.snapan.market/settings');

  Future<void> _openNotificationSettings() async {
    HapticFeedback.lightImpact();
    try {
      await _settingsChannel.invokeMethod('openNotificationSettings');
    } catch (e) {
      debugPrint('Error opening notification settings: $e');
    }
  }

  Future<void> _handleSyncToken() async {
    HapticFeedback.mediumImpact();

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      HapticFeedback.heavyImpact();
      setState(() {
        _isSyncing = false;
        _syncStatus = 'Perhatian: Anda belum login. Silakan masuk ke akun Snaps Anda terlebih dahulu agar token tersambung ke profil.';
      });
      return;
    }

    setState(() {
      _isSyncing = true;
      _syncStatus = null;
    });

    try {
      await GlobalNotificationService.instance.syncFcmTokenNow();
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _syncStatus = 'Token perangkat berhasil disinkronkan ke server untuk akun Anda!';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _syncStatus = 'Gagal sinkronisasi: ${e.toString().replaceAll('StateError: ', '').replaceAll('Exception: ', '')}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 32.0),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40.0,
                height: 4.5,
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(3.0),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Icon(
                    CupertinoIcons.bell_fill,
                    color: AppColors.primary,
                    size: 22.0,
                  ),
                ),
                const SizedBox(width: 14.0),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panduan Notifikasi HP',
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          fontSize: 17.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        'Pastikan notifikasi tetap masuk saat aplikasi ditutup',
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Color(0xFFCBD5E1), size: 24.0),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 18.0),
            const Divider(color: Color(0xFFF1F5F9), height: 1.0),
            const SizedBox(height: 16.0),

            // Account connection status indicator
            Builder(
              builder: (context) {
                final user = Supabase.instance.client.auth.currentUser;
                final isLoggedIn = user != null;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    color: isLoggedIn ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: isLoggedIn ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isLoggedIn ? CupertinoIcons.checkmark_shield_fill : CupertinoIcons.exclamationmark_triangle_fill,
                        size: 16.0,
                        color: isLoggedIn ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          isLoggedIn
                              ? 'Akun Terhubung: ${user.email?.split('@').first ?? 'Aktif'}'
                              : 'Belum Login: Masuk akun dahulu agar notifikasi terhubung',
                          style: TextStyle(
                            fontFamily: 'SFPro',
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: isLoggedIn ? const Color(0xFF15803D) : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Step 1
            _buildStepTile(
              stepNumber: '1',
              title: 'Izinkan Notifikasi & Kategori',
              description: 'Buka Info Aplikasi Snaps > Notifikasi > Nyalakan "Izinkan Notifikasi" dan pastikan kategori "Pengumuman & Notifikasi Snaps" aktif (Suara & Pop-up).',
              icon: CupertinoIcons.app_badge,
            ),
            const SizedBox(height: 14.0),

            // Step 2
            _buildStepTile(
              stepNumber: '2',
              title: 'Penghemat Baterai (Tanpa Batasan)',
              description: 'Di Info Aplikasi Snaps > Penghemat Baterai > Pilih "Tidak ada batasan" (No restrictions) agar OS tidak mematikan koneksi FCM saat app ditutup.',
              icon: CupertinoIcons.battery_charging,
            ),
            const SizedBox(height: 14.0),

            // Step 3 (Khusus Xiaomi / Oppo / Vivo)
            _buildStepTile(
              stepNumber: '3',
              title: 'Mulai Otomatis (Autostart)',
              description: 'Khusus pengguna Xiaomi, Oppo, Vivo, & Realme: Aktifkan izin "Mulai Otomatis / Autostart" agar pengumuman darurat tetap berdering.',
              icon: CupertinoIcons.bolt_fill,
            ),

            const SizedBox(height: 20.0),

            // Feedback / Status message
            if (_syncStatus != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(bottom: 12.0),
                decoration: BoxDecoration(
                  color: _syncStatus!.contains('berhasil') ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: _syncStatus!.contains('berhasil') ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _syncStatus!.contains('berhasil') ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.exclamationmark_circle,
                      color: _syncStatus!.contains('berhasil') ? const Color(0xFF059669) : const Color(0xFFDC2626),
                      size: 18.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        _syncStatus!,
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: _syncStatus!.contains('berhasil') ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action 1: Buka Pengaturan Notifikasi HP Langsung (1-Tap Shortcut)
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: OutlinedButton.icon(
                onPressed: _openNotificationSettings,
                icon: const Icon(CupertinoIcons.gear_alt_fill, size: 18.0, color: AppColors.primary),
                label: const Text(
                  'Buka Pengaturan Notifikasi HP',
                  style: TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10.0),

            // Action 2: Sinkronisasi Token Sekarang
            SizedBox(
              width: double.infinity,
              height: 48.0,
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _handleSyncToken,
                icon: _isSyncing
                    ? const CupertinoActivityIndicator(color: Colors.white, radius: 9.0)
                    : const Icon(CupertinoIcons.arrow_2_circlepath, size: 18.0, color: Colors.white),
                label: Text(
                  _isSyncing ? 'Menghubungkan ke Google FCM...' : 'Hubungkan / Daftarkan Token HP Sekarang',
                  style: const TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTile({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26.0,
          height: 26.0,
          margin: const EdgeInsets.only(top: 2.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8.0),
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber,
            style: const TextStyle(
              fontFamily: 'SFPro',
              fontSize: 12.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 3.0),
              Text(
                description,
                style: const TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 12.5,
                  height: 1.35,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
