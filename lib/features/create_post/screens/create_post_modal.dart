import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/features/create_post/components/create_post_bottom_sheets.dart';
import 'package:snapan_market/features/create_post/components/create_post_footer_bar.dart';
import 'package:snapan_market/features/create_post/components/create_post_header_bar.dart';
import 'package:snapan_market/features/create_post/components/create_post_image_helper.dart';
import 'package:snapan_market/features/create_post/components/create_post_main_input_block.dart';
import 'package:snapan_market/features/create_post/components/create_post_media_preview.dart';
import 'package:snapan_market/features/create_post/components/create_post_product_fields.dart';
import 'package:snapan_market/features/create_post/components/create_post_sub_threads.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

/// Full-Page Screen for Creating Threads & Selling Products (<250 lines orchestrator).
class CreatePostModal extends StatefulWidget {
  final PostMode initialMode;
  final String currentUserName;
  final String currentUserAvatar;
  final ValueChanged<Map<String, dynamic>>? onSubmitPost;

  const CreatePostModal({
    super.key,
    this.initialMode = PostMode.thread,
    this.currentUserName = '',
    this.currentUserAvatar = '',
    this.onSubmitPost,
  });

  static Future<void> show(
    BuildContext context, {
    PostMode initialMode = PostMode.thread,
    String? currentUserName,
    String? currentUserAvatar,
    ValueChanged<Map<String, dynamic>>? onSubmitPost,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        fullscreenDialog: true,
        pageBuilder: (context, _, __) => CreatePostModal(
          initialMode: initialMode,
          currentUserName: currentUserName ?? '',
          currentUserAvatar: currentUserAvatar ?? '',
          onSubmitPost: onSubmitPost,
        ),
        transitionsBuilder: (context, animation, _, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0.0, 1.0), end: Offset.zero).animate(
            CurvedAnimation(parent: animation, curve: const Cubic(0.25, 1.0, 0.5, 1.0), reverseCurve: Curves.easeInCubic),
          ),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  late PostMode _postMode;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _productTitleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _descFocusNode = FocusNode();
  final GlobalKey _titleKey = GlobalKey();
  final GlobalKey _priceKey = GlobalKey();
  final GlobalKey _descKey = GlobalKey();
  final GlobalKey _topicTriggerKey = GlobalKey();

  final List<String> _images = [];
  final List<SubThreadItem> _subThreads = [];
  TopicOption? _selectedTopic;
  SchoolPlace? _selectedLocation;
  PresetGif? _selectedGif;
  bool _showPoll = false;
  bool _showEmojiBar = false;
  final List<TextEditingController> _pollOptionControllers = [TextEditingController(), TextEditingController(), TextEditingController()];
  Duration _pollDeadlineDuration = const Duration(hours: 24);
  bool _pollAllowChangeVote = true;
  bool _pollIsMultipleChoice = false;
  String _audiencePrivacy = 'Semua orang dapat membalas';
  bool _isSubmitting = false;
  bool _showSellingIntentBanner = false;

  @override
  void initState() {
    super.initState();
    _postMode = widget.initialMode;
    _captionController.addListener(_checkSellingIntent);
    _captionController.addListener(() => setState(() {}));

    for (final pair in [(_titleFocusNode, _titleKey), (_priceFocusNode, _priceKey), (_descFocusNode, _descKey)]) {
      pair.$1.addListener(() { if (pair.$1.hasFocus) _scrollToField(pair.$2); });
    }
  }

  void _scrollToField(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (key.currentContext != null && mounted) {
        Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic, alignment: 0.25);
      }
    });
  }

  @override
  void dispose() {
    for (final c in [_scrollController, _captionController, _productTitleController, _priceController, _stockController, _descController, _titleFocusNode, _priceFocusNode, _descFocusNode, ..._pollOptionControllers]) {
      c.dispose();
    }
    super.dispose();
  }

  void _checkSellingIntent() {
    if (_postMode == PostMode.product) {
      if (_showSellingIntentBanner) setState(() => _showSellingIntentBanner = false);
      return;
    }
    final text = _captionController.text.toLowerCase();
    const sellingKeywords = ['jual', 'dijual', 'wts', 'preloved', 'harga', 'rp', 'stok', 'ready', 'beli'];
    final hasKeyword = sellingKeywords.any((kw) => text.contains(kw));
    if (hasKeyword != _showSellingIntentBanner) {
      setState(() => _showSellingIntentBanner = hasKeyword);
    }
  }

  Future<void> _handlePickImage() async {
    HapticFeedback.selectionClick();
    if (_images.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Maksimal 5 foto per postingan'), behavior: SnackBarBehavior.floating));
      return;
    }
    final picked = await CreatePostImageHelper.pickImages(context, remaining: 5 - _images.length);
    if (picked != null && mounted) setState(() => _images.addAll(picked));
  }

  bool get _canSubmit {
    final hasPoll = _showPoll &&
        _postMode == PostMode.thread &&
        _pollOptionControllers.where((c) => c.text.trim().isNotEmpty).length >= 2;
    return _captionController.text.trim().isNotEmpty ||
        _images.isNotEmpty ||
        _productTitleController.text.trim().isNotEmpty ||
        hasPoll;
  }

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;
    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    final uploadedImages = await CreatePostImageHelper.uploadAllImages(_images);
    final isProduct = _postMode == PostMode.product;

    Map<String, dynamic>? pollData;
    if (_showPoll && !isProduct) {
      final validOptions = _pollOptionControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      if (validOptions.length >= 2) {
        pollData = {
          'id': 'poll-${DateTime.now().millisecondsSinceEpoch}',
          'options': validOptions.asMap().entries.map((e) => {
            'id': 'opt-${e.key + 1}',
            'text': e.value,
            'votes_count': 0,
          }).toList(),
          'total_votes': 0,
          'is_multiple_choice': _pollIsMultipleChoice,
          'allow_change_vote': _pollAllowChangeVote,
          'expires_at': DateTime.now().add(_pollDeadlineDuration).toUtc().toIso8601String(),
          'is_closed': false,
        };
      }
    }

    final payload = {
      'postType': isProduct ? 'product' : 'thread',
      'caption': _captionController.text.trim(),
      'title': isProduct ? _productTitleController.text.trim() : _captionController.text.trim(),
      'price': isProduct ? int.tryParse(_priceController.text.replaceAll(RegExp(r'\D'), '')) ?? 0 : null,
      'stock': isProduct ? int.tryParse(_stockController.text.trim()) ?? 1 : null,
      'description': isProduct ? _descController.text.trim() : null,
      'images': uploadedImages,
      'locationTag': _selectedLocation?.name ?? 'SMKN 8 Semarang',
      'topicTag': _selectedTopic?.name,
      'subThreads': _subThreads.map((s) => {'caption': s.caption, 'images': s.images}).toList(),
      'poll': pollData,
      'createdAt': DateTime.now().toIso8601String(),
    };

    widget.onSubmitPost?.call(payload);
    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isProduct ? 'Produk berhasil diposting!' : 'Utas berhasil diposting!'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CreatePostHeaderBar(
                postMode: _postMode,
                onCancel: () => Navigator.of(context).pop(),
                onDraftsTap: () {},
                onMoreOptionsTap: () {},
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
                    return SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(0.0, 12.0, 0.0, keyboardHeight > 0 ? keyboardHeight + 80.0 : 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_showSellingIntentBanner)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: CreatePostSellingIntentBanner(
                                onSwitchToProduct: () => setState(() {
                                  _postMode = PostMode.product;
                                  _showSellingIntentBanner = false;
                                }),
                              ),
                            ),
                          CreatePostMainInputBlock(
                            postMode: _postMode,
                            currentUserName: widget.currentUserName,
                            currentUserAvatar: widget.currentUserAvatar,
                            captionController: _captionController,
                            images: _images,
                            selectedGif: _selectedGif,
                            showPoll: _showPoll,
                            showEmojiBar: _showEmojiBar,
                            pollOptionControllers: _pollOptionControllers,
                            selectedTopic: _selectedTopic,
                            topicTriggerKey: _topicTriggerKey,
                            onPickImage: _handlePickImage,
                            onGifSelected: (g) => setState(() => _selectedGif = g),
                            onToggleEmoji: () => setState(() => _showEmojiBar = !_showEmojiBar),
                            onTogglePoll: () => setState(() => _showPoll = !_showPoll),
                            onTopicSelected: (t) => setState(() => _selectedTopic = t),
                            onLocationSelected: (l) => setState(() => _selectedLocation = l),
                            onToggleMode: (isProduct) => setState(() => _postMode = isProduct ? PostMode.product : PostMode.thread),
                            onRemoveImage: (idx) => setState(() => _images.removeAt(idx)),
                            onAddPollOption: () => setState(() => _pollOptionControllers.add(TextEditingController())),
                            onRemovePollOption: (idx) => setState(() {
                              if (_pollOptionControllers.length > 2) {
                                _pollOptionControllers.removeAt(idx).dispose();
                              } else {
                                _pollOptionControllers[idx].clear();
                              }
                            }),
                            onDismissPoll: () => setState(() {
                              _showPoll = false;
                              for (var c in _pollOptionControllers) { c.clear(); }
                            }),
                            pollDeadlineDuration: _pollDeadlineDuration,
                            onPollDurationChanged: (d) => setState(() => _pollDeadlineDuration = d),
                            pollAllowChangeVote: _pollAllowChangeVote,
                            onPollAllowChangeVoteChanged: (v) => setState(() => _pollAllowChangeVote = v),
                            pollIsMultipleChoice: _pollIsMultipleChoice,
                            onPollMultipleChoiceChanged: (v) => setState(() => _pollIsMultipleChoice = v),
                          ),
                          if (_postMode == PostMode.product) ...[
                            const SizedBox(height: 8.0),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: CreatePostProductFields(
                                productTitleController: _productTitleController,
                                priceController: _priceController,
                                descController: _descController,
                                titleKey: _titleKey,
                                priceKey: _priceKey,
                                descKey: _descKey,
                                titleFocusNode: _titleFocusNode,
                                priceFocusNode: _priceFocusNode,
                                descFocusNode: _descFocusNode,
                                selectedLocation: _selectedLocation,
                                onPickLocation: () => CreatePostBottomSheets.showLocationPickerBottomSheet(
                                  context: context,
                                  onLocationSelected: (loc) => setState(() => _selectedLocation = loc),
                                ),
                                onLocationSelected: (loc) => setState(() => _selectedLocation = loc),
                              ),
                            ),
                          ] else ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: CreatePostSubThreads(
                                subThreads: _subThreads,
                                currentUserAvatar: widget.currentUserAvatar,
                                onAddSubThread: () => setState(() => _subThreads.add(SubThreadItem(id: 'sub_${DateTime.now().millisecondsSinceEpoch}', caption: ''))),
                                onRemoveSubThread: (idx) => setState(() => _subThreads.removeAt(idx)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              CreatePostFooterBar(
                audiencePrivacy: _audiencePrivacy,
                canSubmit: _canSubmit,
                isSubmitting: _isSubmitting,
                onPrivacyTap: () => CreatePostBottomSheets.showPrivacyPickerBottomSheet(
                  context: context,
                  onPrivacySelected: (p) => setState(() => _audiencePrivacy = p),
                ),
                onSubmit: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
