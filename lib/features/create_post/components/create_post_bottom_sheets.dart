import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/components/mascot_flair_badge.dart';
import 'package:snapan_market/core/models/mascot_flair_model.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

/// Centralized bottom sheets and popups for CreatePostModal
class CreatePostBottomSheets {
  const CreatePostBottomSheets._();

  /// Topic Picker Anchored Popover Modal (SNAPS-76 UI Polish: "Topik untuk kamu", clean no-#, subtle elevation)
  static void showTopicPickerPopup({
    required BuildContext context,
    required GlobalKey triggerKey,
    required ValueChanged<TopicOption> onTopicSelected,
  }) {
    HapticFeedback.selectionClick();

    final renderBox = triggerKey.currentContext?.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? const Offset(60, 110);
    final size = renderBox?.size ?? Size.zero;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Topic Popover',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (dialogContext, anim1, anim2) {
        final screenWidth = MediaQuery.sizeOf(dialogContext).width;
        final popoverLeft = (offset.dx - 8.0).clamp(16.0, screenWidth - 280.0);
        final popoverTop = offset.dy + size.height + 4.0;
        final triggerCenterDx = offset.dx + (size.width / 2);
        // Relative X position of the arrow beak within the 260px wide popover
        final arrowBeakX = (triggerCenterDx - popoverLeft).clamp(20.0, 240.0);

        return Stack(
          children: [
            Positioned(
              top: popoverTop,
              left: popoverLeft,
              child: Material(
                color: Colors.transparent,
                child: _TopicPickerPopoverContent(
                  arrowBeakX: arrowBeakX,
                  onTopicSelected: (topic) {
                    onTopicSelected(topic);
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            alignment: Alignment.topLeft,
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
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
      backgroundColor: AppColors.adaptiveSurfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Titik Temu COD SMKN 8',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
                color: AppColors.adaptiveText(context),
              ),
            ),
            const SizedBox(height: 10.0),
            for (var p in kRichSchoolPlaces) ...[
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(CupertinoIcons.location, color: AppColors.primary),
                title: Text(
                  p.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.adaptiveText(context),
                  ),
                ),
                subtitle: Text(
                  '${p.subtitle} · ${p.distance}',
                  style: TextStyle(color: AppColors.adaptiveMuted(context)),
                ),
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
      backgroundColor: AppColors.adaptiveSurfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih GIF Populer',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
                color: AppColors.adaptiveText(context),
              ),
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
      backgroundColor: AppColors.adaptiveSurfaceElevated(context),
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
      backgroundColor: AppColors.adaptiveSurfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              'Semua orang dapat membalas',
              style: TextStyle(color: AppColors.adaptiveText(context)),
            ),
            onTap: () {
              onPrivacySelected('Semua orang dapat membalas');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text(
              'Pengikut Anda',
              style: TextStyle(color: AppColors.adaptiveText(context)),
            ),
            onTap: () {
              onPrivacySelected('Pengikut Anda');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: Text(
              'Hanya yang disebut',
              style: TextStyle(color: AppColors.adaptiveText(context)),
            ),
            onTap: () {
              onPrivacySelected('Hanya yang disebut');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  /// Post Mascot & Emotion Picker Popover Menu (SNAPS-13: Anchored Popover Bubble Menu)
  static Future<void> showMascotPickerPopup({
    required BuildContext context,
    required GlobalKey triggerKey,
    required MascotFlairModel? currentFlair,
    required ValueChanged<MascotFlairModel?> onFlairSelected,
  }) {
    HapticFeedback.selectionClick();

    final renderBox = triggerKey.currentContext?.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? const Offset(40, 110);
    final size = renderBox?.size ?? Size.zero;

    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Mascot Popover',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (dialogContext, anim1, anim2) {
        final screenWidth = MediaQuery.sizeOf(dialogContext).width;
        const double popoverWidth = 264.0;
        final popoverLeft = (offset.dx - 8.0).clamp(16.0, screenWidth - popoverWidth - 16.0);
        final popoverTop = offset.dy + size.height + 4.0;
        final triggerCenterDx = offset.dx + (size.width / 2);
        final arrowBeakX = (triggerCenterDx - popoverLeft).clamp(20.0, popoverWidth - 24.0);

        return Stack(
          children: [
            Positioned(
              top: popoverTop,
              left: popoverLeft,
              child: Material(
                color: Colors.transparent,
                child: _MascotPickerPopoverContent(
                  popoverWidth: popoverWidth,
                  arrowBeakX: arrowBeakX,
                  currentFlair: currentFlair,
                  onFlairSelected: (flair) {
                    onFlairSelected(flair);
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            alignment: Alignment.topLeft,
            scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// Backward-compatible alias for Mascot Picker
  static void showMascotPickerBottomSheet({
    required BuildContext context,
    required MascotFlairModel? currentFlair,
    required ValueChanged<MascotFlairModel?> onFlairSelected,
  }) {
    // If called without triggerKey, fallback to center dialog or first available key
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext sheetContext) => CupertinoActionSheet(
        title: const Text('Maskot Postingan (@snaps beta)'),
        actions: [
          for (final bundle in MascotBundle.values)
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                onFlairSelected(MascotFlairModel(bundle: bundle, emotion: MascotEmotion.delighted));
              },
              child: Text(bundle.label),
            ),
          if (currentFlair != null)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                onFlairSelected(null);
              },
              child: const Text('Hapus Maskot'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: const Text('Batal'),
        ),
      ),
    );
  }
}

/// Refined Popover Widget for Mascot Selection (SNAPS-13: Anchored Popover Bubble Menu)
class _MascotPickerPopoverContent extends StatefulWidget {
  final double popoverWidth;
  final double arrowBeakX;
  final MascotFlairModel? currentFlair;
  final ValueChanged<MascotFlairModel?> onFlairSelected;

  const _MascotPickerPopoverContent({
    required this.popoverWidth,
    required this.arrowBeakX,
    this.currentFlair,
    required this.onFlairSelected,
  });

  @override
  State<_MascotPickerPopoverContent> createState() => _MascotPickerPopoverContentState();
}

class _MascotPickerPopoverContentState extends State<_MascotPickerPopoverContent> {
  late MascotBundle _selectedBundle;

  @override
  void initState() {
    super.initState();
    _selectedBundle = widget.currentFlair?.bundle ?? MascotBundle.koala;
  }

  @override
  Widget build(BuildContext context) {
    final popoverWidth = widget.popoverWidth;
    final arrowBeakX = widget.arrowBeakX;

    // Curated 6 most distinctive emotions (SNAPS-13: 3x2 clean layout, eliminating visually indistinguishable variants)
    final curatedEmotions = [
      MascotEmotion.delighted, // Happy 😊
      MascotEmotion.heart,     // Love 😍
      MascotEmotion.sparkle,   // Sparkle ✨
      MascotEmotion.wink,      // Wink 😉
      MascotEmotion.surprised, // Surprised 😲
      MascotEmotion.sleepy,    // Sleepy 😴
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Arrow Beak Pointer aligned directly under trigger
        Padding(
          padding: EdgeInsets.only(left: (arrowBeakX - 7.0).clamp(10.0, popoverWidth - 20.0)),
          child: CustomPaint(
            size: const Size(14.0, 7.0),
            painter: _PopoverBeakPainter(
              color: Colors.white,
              borderColor: const Color(0xFFE2E8F0),
            ),
          ),
        ),

        // Popover Main Container Card - Compact Snug Fit
        Container(
          width: popoverWidth,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 0.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 20.0,
                offset: Offset(0, 6),
              ),
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 5.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Bundle Switcher (Koala / Fox) - Hugged centered icon-first pills
              Center(
                child: Container(
                  height: 32.0,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: MascotBundle.values.map((bundle) {
                      final isSelected = _selectedBundle == bundle;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedBundle = bundle;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(7.0),
                            boxShadow: isSelected
                                ? const [
                                    BoxShadow(
                                      color: Color(0x0E000000),
                                      blurRadius: 3.0,
                                      offset: Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: MascotFlairBadge(
                            flair: MascotFlairModel(bundle: bundle, emotion: MascotEmotion.delighted),
                            size: 20.0,
                            enableGradientFade: false,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 8.0),

              // Grid 3x2 Curated Emotions (Compact 3-column layout)
              Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: curatedEmotions.map((emotion) {
                  final isCurrentActive = widget.currentFlair?.bundle == _selectedBundle &&
                      widget.currentFlair?.emotion == emotion;
                  final itemFlair = MascotFlairModel(bundle: _selectedBundle, emotion: emotion);

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        widget.onFlairSelected(itemFlair);
                      },
                      borderRadius: BorderRadius.circular(10.0),
                      splashColor: AppColors.primary.withValues(alpha: 0.12),
                      highlightColor: AppColors.primary.withValues(alpha: 0.06),
                      child: Container(
                        width: 78.5,
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        decoration: BoxDecoration(
                          color: isCurrentActive ? const Color(0xFFEFF6FF) : Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: isCurrentActive ? AppColors.primary : const Color(0xFFE2E8F0),
                            width: isCurrentActive ? 1.5 : 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 3.0,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            MascotFlairBadge(
                              flair: itemFlair,
                              size: 32.0,
                              enableGradientFade: false,
                            ),
                            const SizedBox(height: 3.0),
                            Text(
                              emotion.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: isCurrentActive ? FontWeight.w700 : FontWeight.w500,
                                color: isCurrentActive ? AppColors.primary : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 6.0),
              const Divider(height: 1.0, thickness: 0.8, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 3.0),

              // Footer: Hapus Maskot Action
              if (widget.currentFlair != null)
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    widget.onFlairSelected(null);
                  },
                  borderRadius: BorderRadius.circular(8.0),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.xmark_circle,
                          size: 13.0,
                          color: Color(0xFFEF4444),
                        ),
                        SizedBox(width: 5.0),
                        Text(
                          'Hapus Maskot',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Refined Popover Widget for Topic Selection (SNAPS-76 UI Polish: Arrow Beak + Seamless Icon)
class _TopicPickerPopoverContent extends StatefulWidget {
  final double arrowBeakX;
  final ValueChanged<TopicOption> onTopicSelected;

  const _TopicPickerPopoverContent({
    required this.arrowBeakX,
    required this.onTopicSelected,
  });

  @override
  State<_TopicPickerPopoverContent> createState() => _TopicPickerPopoverContentState();
}

class _TopicPickerPopoverContentState extends State<_TopicPickerPopoverContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitCustomTopic(String raw) {
    final clean = raw.trim().replaceAll('#', '');
    if (clean.isEmpty) return;
    HapticFeedback.selectionClick();
    widget.onTopicSelected(
      TopicOption(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        name: clean,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTopics = _searchQuery.isEmpty
        ? kPresetTopics
        : kPresetTopics
            .where((t) => t.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    final hasExactMatch = kPresetTopics.any(
      (t) => t.name.toLowerCase() == _searchQuery.toLowerCase(),
    );

    const double popoverWidth = 260.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Arrow Pointer Beak (Kerucut atas)
        Padding(
          padding: EdgeInsets.only(left: (widget.arrowBeakX - 7.0).clamp(16.0, popoverWidth - 24.0)),
          child: CustomPaint(
            size: const Size(14.0, 7.0),
            painter: _PopoverBeakPainter(
              color: Colors.white,
              borderColor: const Color(0xFFE2E8F0),
            ),
          ),
        ),

        // Popover Main Container Card
        Container(
          width: popoverWidth,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 6.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 0.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x18000000),
                blurRadius: 24.0,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Title: "Topik untuk kamu" (Sentence Case, friendly, subtle)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.sparkles,
                      size: 13.0,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 5.0),
                    const Text(
                      'Topik untuk kamu',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4.0),

              // Topic List Items (Seamless: Icon-only without container bg)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 180.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final topic in filteredTopics) ...[
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            widget.onTopicSelected(topic);
                          },
                          borderRadius: BorderRadius.circular(10.0),
                          splashColor: AppColors.primary.withValues(alpha: 0.08),
                          highlightColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
                            child: Row(
                              children: [
                                // Pure icon without container background for clean & seamless feel
                                Icon(
                                  topic.isOfficial
                                      ? CupertinoIcons.star_fill
                                      : CupertinoIcons.tag_fill,
                                  size: 14.5,
                                  color: topic.isOfficial
                                      ? AppColors.primary
                                      : const Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        topic.name,
                                        style: TextStyle(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w600,
                                          color: topic.isOfficial
                                              ? AppColors.primary
                                              : const Color(0xFF0F172A),
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      if (topic.subtitle != null) ...[
                                        const SizedBox(height: 1.0),
                                        Text(
                                          topic.subtitle!,
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

                      // If user is searching something new that doesn't exactly match presets
                      if (_searchQuery.isNotEmpty && !hasExactMatch) ...[
                        InkWell(
                          onTap: () => _submitCustomTopic(_searchQuery),
                          borderRadius: BorderRadius.circular(10.0),
                          splashColor: AppColors.primary.withValues(alpha: 0.08),
                          highlightColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7.0),
                            child: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.plus,
                                  size: 15.0,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 10.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Gunakan "$_searchQuery"',
                                        style: const TextStyle(
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const Text(
                                        'Buat topik kustom baru',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 4.0),
              const Divider(height: 1.0, thickness: 0.8, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 6.0),

              // Search / Create Input Box (Clean, without awkward '#')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                child: Container(
                  height: 36.0,
                  padding: const EdgeInsets.symmetric(horizontal: 9.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.search,
                        size: 14.0,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          maxLength: 24,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Cari atau buat topik...',
                            hintStyle: TextStyle(
                              fontSize: 12.0,
                              color: Color(0xFF94A3B8),
                            ),
                            counterText: '',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: _submitCustomTopic,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty) ...[
                        GestureDetector(
                          onTap: () => _submitCustomTopic(_searchQuery),
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            width: 24.0,
                            height: 24.0,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                            child: const Icon(
                              CupertinoIcons.arrow_up,
                              size: 13.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Painter for the upward pointing popover beak/caret (kerucut)
class _PopoverBeakPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  const _PopoverBeakPainter({
    required this.color,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    // Triangle pointing upwards
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();

    // Fill white
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Border line on top two sides of the triangle
    final borderPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height);

    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _PopoverBeakPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.borderColor != borderColor;
  }
}
