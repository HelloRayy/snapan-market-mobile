import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/create_post/components/create_post_author_line.dart';
import 'package:snapan_market/features/create_post/components/create_post_bottom_sheets.dart';
import 'package:snapan_market/features/create_post/components/create_post_media_preview.dart';
import 'package:snapan_market/features/create_post/components/create_post_media_toolbar.dart';
import 'package:snapan_market/features/create_post/components/create_post_poll_builder.dart';
import 'package:snapan_market/features/create_post/components/create_post_selling_toggle.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

class CreatePostMainInputBlock extends StatelessWidget {
  final PostMode postMode;
  final String currentUserName;
  final String currentUserAvatar;
  final TextEditingController captionController;
  final List<String> images;
  final PresetGif? selectedGif;
  final bool showPoll;
  final bool showEmojiBar;
  final List<TextEditingController> pollOptionControllers;
  final TopicOption? selectedTopic;
  final GlobalKey topicTriggerKey;
  final VoidCallback onPickImage;
  final ValueChanged<PresetGif?> onGifSelected;
  final VoidCallback onToggleEmoji;
  final VoidCallback onTogglePoll;
  final ValueChanged<TopicOption?> onTopicSelected;
  final ValueChanged<SchoolPlace?> onLocationSelected;
  final ValueChanged<bool> onToggleMode;
  final ValueChanged<int> onRemoveImage;
  final VoidCallback onAddPollOption;
  final ValueChanged<int> onRemovePollOption;
  final VoidCallback onDismissPoll;
  final Duration pollDeadlineDuration;
  final ValueChanged<Duration> onPollDurationChanged;
  final bool pollAllowChangeVote;
  final ValueChanged<bool> onPollAllowChangeVoteChanged;

  const CreatePostMainInputBlock({
    super.key,
    required this.postMode,
    required this.currentUserName,
    required this.currentUserAvatar,
    required this.captionController,
    required this.images,
    required this.selectedGif,
    required this.showPoll,
    required this.showEmojiBar,
    required this.pollOptionControllers,
    required this.selectedTopic,
    required this.topicTriggerKey,
    required this.onPickImage,
    required this.onGifSelected,
    required this.onToggleEmoji,
    required this.onTogglePoll,
    required this.onTopicSelected,
    required this.onLocationSelected,
    required this.onToggleMode,
    required this.onRemoveImage,
    required this.onAddPollOption,
    required this.onRemovePollOption,
    required this.onDismissPoll,
    required this.pollDeadlineDuration,
    required this.onPollDurationChanged,
    required this.pollAllowChangeVote,
    required this.onPollAllowChangeVoteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Dynamic Thread Line (Behind Avatar, centered: 36/2 - 2/2 = 17.0)
          if (postMode == PostMode.thread)
            Positioned(
              left: 17.0,
              top: 42.0,
              bottom: 0.0,
              child: Container(
                width: 2.0,
                color: const Color(0xFFE2E8F0),
              ),
            ),

          // 2. Content Row: Avatar (top-aligned) + Main Input Column
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 36.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.0),
                  child: currentUserAvatar.isNotEmpty
                      ? Image.network(
                          currentUserAvatar,
                          width: 36.0,
                          height: 36.0,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 36,
                            height: 36,
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.person_rounded, size: 20, color: AppColors.muted),
                          ),
                        )
                      : Container(
                          width: 36,
                          height: 36,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.person_rounded, size: 20, color: AppColors.muted),
                        ),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  CreatePostAuthorLine(
                    authorName: currentUserName,
                    selectedTopic: selectedTopic,
                    topicTriggerKey: topicTriggerKey,
                    onTopicTriggerTap: () => CreatePostBottomSheets.showTopicPickerPopup(
                      context: context,
                      triggerKey: topicTriggerKey,
                      onTopicSelected: onTopicSelected,
                    ),
                    onTopicClear: () => onTopicSelected(null),
                  ),
                  const SizedBox(height: 2.0),
                  TextField(
                    controller: captionController,
                    minLines: 1,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    style: const TextStyle(fontSize: 15.0, color: AppColors.ink, height: 1.35),
                    decoration: InputDecoration(
                      hintText: postMode == PostMode.thread ? 'Apa yang baru?' : 'Ceritakan tentang produk jualanmu...',
                      hintStyle: const TextStyle(fontSize: 15.0, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  if (images.isNotEmpty) ...[
                    const SizedBox(height: 12.0),
                    CreatePostImagesPreview(
                      images: images,
                      onAddImage: onPickImage,
                      onRemoveImage: onRemoveImage,
                    ),
                  ],
                  if (selectedGif != null) ...[
                    const SizedBox(height: 10.0),
                    CreatePostGifPreview(gif: selectedGif!, onRemove: () => onGifSelected(null)),
                  ],
                  if (showPoll) ...[
                    CreatePostPollBuilder(
                      controllers: pollOptionControllers,
                      onAddOption: onAddPollOption,
                      onRemoveOption: onRemovePollOption,
                      onDismissPoll: onDismissPoll,
                      deadlineDuration: pollDeadlineDuration,
                      onDurationChanged: onPollDurationChanged,
                      allowChangeVote: pollAllowChangeVote,
                      onAllowChangeVoteChanged: onPollAllowChangeVoteChanged,
                    ),
                  ],
                  const SizedBox(height: 10.0),
                  CreatePostMediaToolbar(
                    showEmojiBar: showEmojiBar,
                    showPollBuilder: showPoll,
                    onPickImage: onPickImage,
                    onPickGif: () => CreatePostBottomSheets.showGifPickerBottomSheet(
                      context: context,
                      onGifSelected: onGifSelected,
                    ),
                    onToggleEmoji: onToggleEmoji,
                    onInsertEmoji: (e) => captionController.text += e,
                    onTogglePoll: onTogglePoll,
                    onPickTopic: () => CreatePostBottomSheets.showTopicPickerPopup(
                      context: context,
                      triggerKey: topicTriggerKey,
                      onTopicSelected: onTopicSelected,
                    ),
                    onPickLocation: () => CreatePostBottomSheets.showLocationPickerBottomSheet(
                      context: context,
                      onLocationSelected: onLocationSelected,
                    ),
                    onAudioTap: () {},
                  ),
                  const SizedBox(height: 8.0),
                    CreatePostSellingToggle(
                      isProductMode: postMode == PostMode.product,
                      onToggle: onToggleMode,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
