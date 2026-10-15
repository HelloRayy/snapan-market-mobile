import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapan_market/core/utils/snaps_toast.dart';
import 'package:snapan_market/core/services/feedback_service.dart';
import 'package:snapan_market/core/services/media_upload_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Bug and Feedback Reporter Bottom Sheet
/// Sliced from pen.dev Node `cEmG6` (Source of truth for Layout & Placement)
/// with full adaptive Dark/Light Mode using AppColors design tokens.
class BugReportBottomSheet extends StatefulWidget {
  const BugReportBottomSheet({super.key});

  /// Static helper to display the sheet
  static Future<void> show(BuildContext context) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => const BugReportBottomSheet(),
    );
  }

  @override
  State<BugReportBottomSheet> createState() => _BugReportBottomSheetState();
}

class _BugReportBottomSheetState extends State<BugReportBottomSheet> {
  static const List<String> _kCategories = [
    'Bug Tampilan / UI',
    'Error Fitur / Tombol Macet',
    'Gagal Unggah Foto / Media',
    'Aplikasi Lambat / Lag',
    'Lainnya / Masukan Khusus',
  ];

  String _selectedCategory = _kCategories[0];
  final TextEditingController _customTopicController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  XFile? _screenshotFile;
  bool _isSubmitting = false;
  Map<String, dynamic>? _diagnostics;

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  @override
  void dispose() {
    _customTopicController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadDiagnostics() async {
    final diag = await FeedbackService.instance.getAppDiagnostics();
    if (mounted) {
      setState(() => _diagnostics = diag);
    }
  }

  Future<void> _handlePickScreenshot() async {
    HapticFeedback.selectionClick();
    final file = await MediaUploadService.instance.pickSingleImage(
      maxWidth: 1080,
      maxHeight: 1920,
      imageQuality: 75,
    );
    if (file != null && mounted) {
      setState(() => _screenshotFile = file);
    }
  }

  void _handleRemoveScreenshot() {
    HapticFeedback.selectionClick();
    setState(() => _screenshotFile = null);
  }

  void _showCategoryPicker(BuildContext context, bool isDark) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (pickerCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF383A3A) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Pilih Kategori Kendala',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.adaptiveText(pickerCtx),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _kCategories.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppColors.adaptiveDivider(pickerCtx),
                  ),
                  itemBuilder: (_, index) {
                    final item = _kCategories[index];
                    final isSelected = item == _selectedCategory;
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                      title: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                              : AppColors.adaptiveText(pickerCtx),
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              CupertinoIcons.checkmark_alt,
                              size: 18,
                              color: isDark ? AppColors.darkPrimary : AppColors.primary,
                            )
                          : null,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedCategory = item);
                        Navigator.of(pickerCtx).pop();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    final desc = _descriptionController.text.trim();
    if (desc.isEmpty) {
      SnapsToast.show(
        context,
        'Mohon jelaskan kendala atau rincian masalah Anda',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    if (desc.length < 5) {
      SnapsToast.show(
        context,
        'Deskripsi masalah terlalu singkat (minimal 5 karakter)',
        backgroundColor: AppColors.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.lightImpact();

    final isCustom = _selectedCategory == 'Lainnya / Masukan Khusus';
    final customTopic = isCustom ? _customTopicController.text.trim() : null;

    final success = await FeedbackService.instance.submitFeedback(
      category: _selectedCategory,
      description: desc,
      customTopic: customTopic,
      screenshotFile: _screenshotFile,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
      SnapsToast.show(
        context,
        'Laporan Anda berhasil dikirim. Terima kasih!',
        backgroundColor: AppColors.success,
      );
    } else {
      SnapsToast.show(
        context,
        'Gagal mengirim laporan. Periksa koneksi internet atau coba via WhatsApp.',
        backgroundColor: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isCustomCategory = _selectedCategory == 'Lainnya / Masukan Khusus';

    final surfaceColor = AppColors.adaptiveSurface(context);
    final elevatedColor = isDark ? AppColors.darkSurfaceElevated : AppColors.inputBg;
    final borderColor = AppColors.adaptiveBorder(context);
    final textColor = AppColors.adaptiveText(context);
    final mutedColor = AppColors.adaptiveMuted(context);
    final primaryAccent = isDark ? AppColors.darkPrimary : AppColors.primary;
    final primaryPastelBg = isDark ? AppColors.darkPrimaryPastel : AppColors.primaryPastel;

    final appVer = _diagnostics?['app_version'] ?? 'v1.0.30';
    final platform = _diagnostics?['platform'] ?? 'Android';

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: borderColor, width: 0.8),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF383A3A) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Header Row: Squircle Icon Box + Title & Subtitle
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: primaryPastelBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      CupertinoIcons.ant,
                      size: 22,
                      color: primaryAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laporkan masalah',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Bantu kami menyempurnakan Snaps Mobile',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 3. Dropdown Kategori Kendala
              Text(
                'Kategori kendala',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _showCategoryPicker(context, isDark),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: elevatedColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_down,
                        size: 16,
                        color: mutedColor,
                      ),
                    ],
                  ),
                ),
              ),

              // 4. Custom Topic Input (Animated when "Lainnya" chosen)
              AnimatedCrossFade(
                crossFadeState: isCustomCategory
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Topik kendala',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: primaryAccent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: elevatedColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: primaryAccent, width: 1.0),
                        ),
                        child: TextField(
                          controller: _customTopicController,
                          style: TextStyle(fontSize: 13.5, color: textColor),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Tuliskan topik kendala Anda...',
                            hintStyle: TextStyle(fontSize: 13, color: mutedColor),
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Rincian Masalah (Text Area)
              Text(
                'Rincian masalah',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: elevatedColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  minLines: 3,
                  style: TextStyle(fontSize: 13, height: 1.45, color: textColor),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText:
                        'Ceritakan apa yang terjadi, tombol mana yang ditekan, atau pesan error yang muncul...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: mutedColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 6. Screenshot Attachment Card
              GestureDetector(
                onTap: _screenshotFile == null ? _handlePickScreenshot : null,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: elevatedColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor, width: 0.8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _screenshotFile != null
                            ? CupertinoIcons.check_mark_circled_solid
                            : CupertinoIcons.photo_on_rectangle,
                        size: 18,
                        color: _screenshotFile != null ? AppColors.success : primaryAccent,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _screenshotFile != null
                              ? 'Tangkapan layar terlampir (${File(_screenshotFile!.path).uri.pathSegments.last})'
                              : 'Lampirkan tangkapan layar (opsional)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: _screenshotFile != null ? textColor : mutedColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_screenshotFile != null)
                        GestureDetector(
                          onTap: _handleRemoveScreenshot,
                          child: Icon(
                            CupertinoIcons.xmark_circle_fill,
                            size: 18,
                            color: mutedColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 7. Auto Device Info Text (Minimalist)
              Center(
                child: Text(
                  'Snaps $appVer • $platform',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w400,
                    color: mutedColor,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 8. Submit Button (KumoButton Style Capsule)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryAccent,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: primaryAccent.withValues(alpha: 0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Kirim laporan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // 9. Secondary WhatsApp Fallback Link
              Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    FeedbackService.instance.launchWhatsAppAdmin(
                      category: _selectedCategory,
                      customTopic: isCustomCategory ? _customTopicController.text.trim() : null,
                      description: _descriptionController.text.trim(),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Text(
                      'Butuh bantuan langsung? Hubungi Tim Admin di WhatsApp',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: primaryAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
