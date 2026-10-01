import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ota_update/ota_update.dart';
import 'package:snapan_market/core/models/app_version_model.dart';
import 'package:snapan_market/core/services/app_update_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Interactive In-App Update Modal Bottom Sheet
/// Shows new release notes, download progress, and triggers native Android installer
class UpdateInfoBottomSheet extends StatefulWidget {
  final AppVersionModel update;
  final String currentVersionName;

  const UpdateInfoBottomSheet({
    super.key,
    required this.update,
    required this.currentVersionName,
  });

  /// Displays the modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required AppVersionModel update,
    required String currentVersionName,
  }) {
    HapticFeedback.mediumImpact();
    AppUpdateService.instance.markPrompted();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: !update.isMandatory,
      enableDrag: !update.isMandatory,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PopScope(
        canPop: !update.isMandatory,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            AppUpdateService.instance.dismissUpdate(update.versionCode);
          }
        },
        child: UpdateInfoBottomSheet(
          update: update,
          currentVersionName: currentVersionName,
        ),
      ),
    );
  }

  @override
  State<UpdateInfoBottomSheet> createState() => _UpdateInfoBottomSheetState();
}

class _UpdateInfoBottomSheetState extends State<UpdateInfoBottomSheet> {
  bool _isDownloading = false;
  int _downloadProgress = 0;
  String? _errorMessage;
  bool _isInstalling = false;
  Future<void> _openDownloadInBrowser() async {
    HapticFeedback.lightImpact();
    try {
      const platform = MethodChannel('com.snapan.market/browser');
      await platform.invokeMethod('openUrl', {'url': widget.update.downloadUrl});
    } catch (_) {
      Clipboard.setData(ClipboardData(text: widget.update.downloadUrl));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link download APK disalin ke clipboard! Buka browser untuk mengunduh.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _startOtaUpdate() {
    if (_isDownloading) return;
    HapticFeedback.lightImpact();

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _errorMessage = null;
      _isInstalling = false;
    });

    try {
      final filename = 'Snaps-v${widget.update.versionName}.apk';

      OtaUpdate().execute(
        widget.update.downloadUrl,
        destinationFilename: filename,
        androidProviderAuthority: 'com.snapan.market.snapan_market.ota_update_provider',
        usePackageInstaller: true,
      ).listen(
        (OtaEvent event) {
          if (!mounted) return;

          switch (event.status) {
            case OtaStatus.DOWNLOADING:
              final int progress = int.tryParse(event.value ?? '') ?? _downloadProgress;
              setState(() {
                _downloadProgress = progress;
              });
              break;

            case OtaStatus.INSTALLING:
              setState(() {
                _isDownloading = false;
                _isInstalling = true;
                _downloadProgress = 100;
              });
              // Automatically dismiss the bottom sheet after installer is handed off to Android
              Future.delayed(const Duration(milliseconds: 1000), () {
                if (mounted) {
                  Navigator.of(context, rootNavigator: true).maybePop();
                }
              });
              break;

            case OtaStatus.ALREADY_RUNNING_ERROR:
              setState(() {
                _isDownloading = false;
                _errorMessage = 'Proses unduhan sudah berjalan di latar belakang.';
              });
              break;

            case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
              setState(() {
                _isDownloading = false;
                _errorMessage = 'Izin pemasangan aplikasi belum diaktifkan. Buka Pengaturan HP > Aplikasi > Snaps > Aktifkan "Instal aplikasi tidak dikenal", lalu coba lagi.';
              });
              break;

            case OtaStatus.INTERNAL_ERROR:
            case OtaStatus.DOWNLOAD_ERROR:
            case OtaStatus.CHECKSUM_ERROR:
              setState(() {
                _isDownloading = false;
                _errorMessage = 'Gagal mengunduh file pembaruan. Periksa koneksi internet Anda.';
              });
              break;

            case OtaStatus.INSTALLATION_ERROR:
              setState(() {
                _isDownloading = false;
                _isInstalling = false;
                _errorMessage = 'Pemasangan paket gagal atau dibatalkan. Anda dapat mengunduh manual melalui tombol di bawah.';
              });
              break;

            case OtaStatus.INSTALLATION_DONE:
              setState(() {
                _isDownloading = false;
                _isInstalling = false;
              });
              Navigator.of(context, rootNavigator: true).maybePop();
              break;

            default:
              break;
          }
        },
        onError: (err) {
          if (!mounted) return;
          setState(() {
            _isDownloading = false;
            _errorMessage = 'Terjadi kesalahan sistem: $err';
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _errorMessage = 'Gagal memulai unduhan: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 24.0,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20.0,
            12.0,
            20.0,
            bottomPadding > 0 ? bottomPadding + 8.0 : 20.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Drag Handle
              if (!widget.update.isMandatory)
                Center(
                  child: Container(
                    width: 36.0,
                    height: 4.0,
                    margin: const EdgeInsets.only(bottom: 16.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),

              // 2. Header Icon & Version Chip Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPastel,
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.system_update_rounded,
                        size: 24.0,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.update.title,
                          style: const TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Row(
                          children: [
                            Text(
                              'v${widget.currentVersionName}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.0),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: 12.0,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                'v${widget.update.versionName}',
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16.0),

              // 3. Changelog Card
              Container(
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catatan Pembaruan:',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Text(
                      widget.update.changelog,
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF475569),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: const Color(0xFFFCA5A5), width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFB91C1C),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _openDownloadInBrowser,
                              icon: const Icon(Icons.open_in_browser_rounded, size: 16.0),
                              label: const Text('Buka di Browser (Download Manual)'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB91C1C),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                visualDensity: VisualDensity.compact,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          IconButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              Clipboard.setData(ClipboardData(text: widget.update.downloadUrl));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Link download APK disalin ke clipboard!'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 16.0, color: Color(0xFFB91C1C)),
                            tooltip: 'Salin Link',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: const BorderSide(color: Color(0xFFFCA5A5)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20.0),

              // 4. Download Progress Bar (When active)
              if (_isDownloading || _isInstalling) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isInstalling ? 'Mempersiapkan pemasangan...' : 'Mengunduh pembaruan...',
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '$_downloadProgress%',
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6.0),
                      child: LinearProgressIndicator(
                        value: _downloadProgress / 100.0,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        minHeight: 8.0,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ],

              // 5. Action Buttons
              SizedBox(
                height: 48.0,
                child: ElevatedButton(
                  onPressed: _isDownloading || _isInstalling ? null : _startOtaUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                  child: Text(
                    _isDownloading
                        ? 'Sedang Mengunduh... ($_downloadProgress%)'
                        : _isInstalling
                            ? 'Membuka Pemasang Paket...'
                            : 'Update Sekarang',
                  ),
                ),
              ),

              if (!widget.update.isMandatory && !_isDownloading && !_isInstalling) ...[
                const SizedBox(height: 8.0),
                SizedBox(
                  height: 44.0,
                  child: TextButton(
                    onPressed: () {
                      AppUpdateService.instance.dismissUpdate(widget.update.versionCode);
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    child: const Text('Nanti Saja'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
