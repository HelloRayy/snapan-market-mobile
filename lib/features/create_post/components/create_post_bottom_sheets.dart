import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

/// Centralized bottom sheets and popups for CreatePostModal
class CreatePostBottomSheets {
  const CreatePostBottomSheets._();

  /// Topic Picker Anchored Popover Modal
  static void showTopicPickerPopup({
    required BuildContext context,
    required GlobalKey triggerKey,
    required ValueChanged<TopicOption> onTopicSelected,
  }) {
    HapticFeedback.selectionClick();
    final customTopicController = TextEditingController();

    final renderBox = triggerKey.currentContext?.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? const Offset(60, 110);
    final size = renderBox?.size ?? Size.zero;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Topic Popover',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (dialogContext, anim1, anim2) {
        final screenWidth = MediaQuery.sizeOf(dialogContext).width;
        final popoverLeft = (offset.dx - 12.0).clamp(16.0, screenWidth - 266.0);
        final popoverTop = offset.dy + size.height + 4.0;

        return Stack(
          children: [
            Positioned(
              top: popoverTop,
              left: popoverLeft,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 250.0,
                  padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000),
                        blurRadius: 24.0,
                        offset: Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 6.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        child: Text(
                          'TOPIK POPULER SMKN 8',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      for (var t in kPresetTopics.take(3)) ...[
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onTopicSelected(t);
                            Navigator.of(dialogContext).pop();
                          },
                          borderRadius: BorderRadius.circular(10.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                            child: Row(
                              children: [
                                Icon(
                                  t.isOfficial ? Icons.stars_rounded : Icons.tag_rounded,
                                  size: 16.0,
                                  color: t.isOfficial ? AppColors.primary : AppColors.muted,
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '#${t.name}',
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w600,
                                          color: t.isOfficial ? AppColors.primary : AppColors.ink,
                                        ),
                                      ),
                                      if (t.subtitle != null) ...[
                                        Text(
                                          t.subtitle!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 4.0),
                      const Divider(color: Color(0xFFF1F5F9), height: 1.0),
                      const SizedBox(height: 4.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                        child: Container(
                          height: 34.0,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                '#',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.muted,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Expanded(
                                child: TextField(
                                  controller: customTopicController,
                                  maxLength: 20,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Ketik topik baru...',
                                    hintStyle: TextStyle(fontSize: 12.0, color: Color(0xFF94A3B8)),
                                    counterText: '',
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onSubmitted: (val) {
                                    if (val.trim().isNotEmpty) {
                                      HapticFeedback.selectionClick();
                                      onTopicSelected(
                                        TopicOption(
                                          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                                          name: val.trim().replaceAll('#', ''),
                                        ),
                                      );
                                      Navigator.of(dialogContext).pop();
                                    }
                                  },
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  final val = customTopicController.text.trim();
                                  if (val.isNotEmpty) {
                                    HapticFeedback.selectionClick();
                                    onTopicSelected(
                                      TopicOption(
                                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                                        name: val.replaceAll('#', ''),
                                      ),
                                    );
                                    Navigator.of(dialogContext).pop();
                                  }
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 22.0,
                                  height: 22.0,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_upward_rounded,
                                    size: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
          child: ScaleTransition(
            alignment: Alignment.topLeft,
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// COD Location Picker Bottom Sheet
  static void showLocationPickerBottomSheet({
    required BuildContext context,
    required ValueChanged<SchoolPlace> onLocationSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih Titik Temu COD SMKN 8',
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10.0),
            for (var p in kRichSchoolPlaces) ...[
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(CupertinoIcons.location, color: AppColors.primary),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${p.subtitle} · ${p.distance}'),
                onTap: () {
                  onLocationSelected(p);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// GIF Picker Bottom Sheet
  static void showGifPickerBottomSheet({
    required BuildContext context,
    required ValueChanged<PresetGif> onGifSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih GIF Populer',
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10.0),
            GridView.builder(
              shrinkWrap: true,
              itemCount: kPresetGifs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, idx) => GestureDetector(
                onTap: () {
                  onGifSelected(kPresetGifs[idx]);
                  Navigator.of(context).pop();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(kPresetGifs[idx].url, fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Emoji Picker Bottom Sheet
  static void showEmojiPickerBottomSheet({
    required BuildContext context,
    required ValueChanged<String> onEmojiSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            for (var emoji in kPresetEmojis) ...[
              GestureDetector(
                onTap: () {
                  onEmojiSelected(emoji);
                  Navigator.of(context).pop();
                },
                child: Text(emoji, style: const TextStyle(fontSize: 26.0)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Privacy Picker Bottom Sheet
  static void showPrivacyPickerBottomSheet({
    required BuildContext context,
    required ValueChanged<String> onPrivacySelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Siapa pun dapat membalas & mengutip'),
            onTap: () {
              onPrivacySelected('Siapa pun dapat membalas & mengutip');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('Pengikut Anda'),
            onTap: () {
              onPrivacySelected('Pengikut Anda');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('Hanya yang disebut'),
            onTap: () {
              onPrivacySelected('Hanya yang disebut');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
