import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/create_post/components/create_post_author_line.dart';
import 'package:snapan_market/features/create_post/components/create_post_bottom_sheets.dart';
import 'package:snapan_market/features/create_post/components/create_post_footer_bar.dart';
import 'package:snapan_market/features/create_post/components/create_post_header_bar.dart';
import 'package:snapan_market/features/create_post/components/create_post_media_toolbar.dart';
import 'package:snapan_market/features/create_post/components/create_post_poll_builder.dart';
import 'package:snapan_market/features/create_post/components/create_post_product_fields.dart';
import 'package:snapan_market/features/create_post/components/create_post_selling_toggle.dart';
import 'package:snapan_market/features/create_post/components/create_post_sub_threads.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

/// Full-Page Screen for Creating Threads & Selling Products
///
/// Refactored to clean modular architecture:
/// - Screen orchestrator connecting isolated subcomponents
/// - Auto-scroll on field focus with zero keyboard overlap
/// - 100% borderless top caption textarea
/// - Unified Kumo UI "Posting" button across all modes
class CreatePostModal extends StatefulWidget {
  final PostMode initialMode;
  final String currentUserName;
  final String currentUserAvatar;
  final ValueChanged<Map<String, dynamic>>? onSubmitPost;

  const CreatePostModal({
    super.key,
    this.initialMode = PostMode.thread,
    this.currentUserName = 'radityarayhannnn',
    this.currentUserAvatar =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
    this.onSubmitPost,
  });

  static Future<void> show(
    BuildContext context, {
    PostMode initialMode = PostMode.thread,
    ValueChanged<Map<String, dynamic>>? onSubmitPost,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierDismissible: false,
        fullscreenDialog: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            CreatePostModal(
          initialMode: initialMode,
          onSubmitPost: onSubmitPost,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 260),
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
  final TextEditingController _productTitleController =
      TextEditingController();
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
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  String _audiencePrivacy = 'Semua orang dapat membalas';
  bool _isSubmitting = false;
  bool _showSellingIntentBanner = false;

  final List<String> _dummyImagesPool = [
    'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=800&q=80',
    'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=800&q=80',
    'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80',
    'https://images.unsplash.com/photo-1556742049-0a67e55722c6?w=800&q=80',
  ];

  @override
  void initState() {
    super.initState();
    _postMode = widget.initialMode;
    _captionController.addListener(_checkSellingIntent);
    _captionController.addListener(() => setState(() {}));

    _titleFocusNode.addListener(() {
      if (_titleFocusNode.hasFocus) _scrollToField(_titleKey);
    });
    _priceFocusNode.addListener(() {
      if (_priceFocusNode.hasFocus) _scrollToField(_priceKey);
    });
    _descFocusNode.addListener(() {
      if (_descFocusNode.hasFocus) _scrollToField(_descKey);
    });
  }

  void _scrollToField(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (key.currentContext != null && mounted) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          alignment: 0.25,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _captionController.dispose();
    _productTitleController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
    _titleFocusNode.dispose();
    _priceFocusNode.dispose();
    _descFocusNode.dispose();
    for (var c in _pollOptionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _checkSellingIntent() {
    if (_postMode == PostMode.product) {
      if (_showSellingIntentBanner) {
        setState(() => _showSellingIntentBanner = false);
      }
      return;
    }

    final text = _captionController.text.toLowerCase();
    const sellingKeywords = [
      'jual',
      'dijual',
      'wts',
      'preloved',
      'harga',
      'rp',
      'stok',
      'ongkir',
      'ready',
      'beli'
    ];

    final hasKeyword = sellingKeywords.any((kw) => text.contains(kw));
    if (hasKeyword && !_showSellingIntentBanner) {
      setState(() => _showSellingIntentBanner = true);
    } else if (!hasKeyword && _showSellingIntentBanner) {
      setState(() => _showSellingIntentBanner = false);
    }
  }

  void _handlePickImage() {
    HapticFeedback.selectionClick();
    if (_dummyImagesPool.isNotEmpty) {
      final nextImg = _dummyImagesPool[_images.length % _dummyImagesPool.length];
      setState(() {
        _images.add(nextImg);
      });
    }
  }

  void _handleAddSubThread() {
    HapticFeedback.selectionClick();
    setState(() {
      _subThreads.add(
        SubThreadItem(
          id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
          caption: '',
        ),
      );
    });
  }

  bool get _canSubmit {
    return _captionController.text.trim().isNotEmpty ||
        _images.isNotEmpty ||
        _productTitleController.text.trim().isNotEmpty;
  }

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 300));

    final isProduct = _postMode == PostMode.product;
    final payload = {
      'postType': isProduct ? 'product' : 'thread',
      'caption': _captionController.text.trim(),
      'title': isProduct
          ? _productTitleController.text.trim()
          : _captionController.text.trim(),
      'price': isProduct
          ? int.tryParse(_priceController.text.replaceAll(RegExp(r'\D'), '')) ?? 0
          : null,
      'stock': isProduct
          ? int.tryParse(_stockController.text.trim()) ?? 1
          : null,
      'description': isProduct ? _descController.text.trim() : null,
      'images': List<String>.from(_images),
      'locationTag': _selectedLocation?.name,
      'topicTag': _selectedTopic?.name,
      'subThreads': _subThreads
          .map((s) => {'caption': s.caption, 'images': s.images})
          .toList(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    if (widget.onSubmitPost != null) {
      widget.onSubmitPost!(payload);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isProduct
                ? 'Produk berhasil diposting ke Pasar!'
                : 'Utas berhasil diposting ke Feed!',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
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
          top: true,
          bottom: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Header Bar (Zero-rebuild static bar)
              CreatePostHeaderBar(
                postMode: _postMode,
                onCancel: () => Navigator.of(context).pop(),
                onDraftsTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Draft postingan tersimpan otomatis'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onMoreOptionsTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opsi lanjutan akan segera hadir'),
                      duration: Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              // 2. Scrollable Body Area with Isolated Keyboard Inset Padding
              Expanded(
                child: Builder(
                  builder: (context) {
                    final keyboardHeight =
                        MediaQuery.viewInsetsOf(context).bottom;
                    return SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      padding: EdgeInsets.fromLTRB(
                        0.0,
                        12.0,
                        0.0,
                        keyboardHeight > 0 ? keyboardHeight + 80.0 : 20.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Selling Intent Suggestion Banner
                          if (_showSellingIntentBanner)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: _buildSellingIntentBanner(),
                            ),
                          // Main Thread Block (Left Avatar + Line | Right Form)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Column: Avatar & Vertical Thread Connector Line
                                  SizedBox(
                                    width: 36.0,
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          child: Image.network(
                                            widget.currentUserAvatar,
                                            width: 36.0,
                                            height: 36.0,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Container(
                                              width: 36.0,
                                              height: 36.0,
                                              color: const Color(0xFFF1F5F9),
                                              child: const Icon(
                                                Icons.person_rounded,
                                                size: 20.0,
                                                color: AppColors.muted,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6.0),
                                        if (_postMode == PostMode.thread)
                                          Expanded(
                                            child: Container(
                                              width: 2.0,
                                              color: const Color(0xFFE2E8F0),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(width: 12.0),

                                // Right Column: Author Header, Textarea, Toolbar, Toggle, Forms
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Author Name + Topic Picker
                                      CreatePostAuthorLine(
                                        authorName: widget.currentUserName,
                                        selectedTopic: _selectedTopic,
                                        topicTriggerKey: _topicTriggerKey,
                                        onTopicTriggerTap: () =>
                                            CreatePostBottomSheets
                                                .showTopicPickerPopup(
                                          context: context,
                                          triggerKey: _topicTriggerKey,
                                          onTopicSelected: (t) => setState(
                                              () => _selectedTopic = t),
                                        ),
                                        onTopicClear: () => setState(
                                            () => _selectedTopic = null),
                                      ),
                                      const SizedBox(height: 2.0),

                                      // 100% Borderless Main Caption Input
                                      TextField(
                                        controller: _captionController,
                                        minLines: 1,
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                        style: const TextStyle(
                                          fontSize: 15.0,
                                          color: AppColors.ink,
                                          height: 1.35,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: _postMode == PostMode.thread
                                              ? 'Apa yang baru?'
                                              : 'Ceritakan tentang produk jualanmu...',
                                          hintStyle: const TextStyle(
                                            fontSize: 15.0,
                                            color: Color(0xFF94A3B8),
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                          filled: false,
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),

                                      // Attached Images Preview
                                      if (_images.isNotEmpty) ...[
                                        const SizedBox(height: 12.0),
                                        _buildImagesPreview(),
                                      ],

                                      // Selected GIF Preview
                                      if (_selectedGif != null) ...[
                                        const SizedBox(height: 10.0),
                                        _buildGifPreview(),
                                      ],

                                      // Polling Options Block (Matching Image #1)
                                      if (_showPoll) ...[
                                        CreatePostPollBuilder(
                                          controllers: _pollOptionControllers,
                                          onAddOption: () {
                                            setState(() {
                                              _pollOptionControllers
                                                  .add(TextEditingController());
                                            });
                                          },
                                          onRemoveOption: (idx) {
                                            setState(() {
                                              if (_pollOptionControllers
                                                      .length >
                                                  2) {
                                                final removed =
                                                    _pollOptionControllers
                                                        .removeAt(idx);
                                                removed.dispose();
                                              } else {
                                                _pollOptionControllers[idx]
                                                    .clear();
                                              }
                                            });
                                          },
                                          onDismissPoll: () {
                                            setState(() {
                                              _showPoll = false;
                                              for (var c
                                                  in _pollOptionControllers) {
                                                c.clear();
                                              }
                                            });
                                          },
                                        ),
                                      ],

                                      const SizedBox(height: 10.0),

                                      // 7-Icon Media Toolbar
                                      CreatePostMediaToolbar(
                                        showEmojiBar: _showEmojiBar,
                                        showPollBuilder: _showPoll,
                                        onPickImage: _handlePickImage,
                                        onPickGif: () => CreatePostBottomSheets
                                            .showGifPickerBottomSheet(
                                          context: context,
                                          onGifSelected: (gif) => setState(
                                              () => _selectedGif = gif),
                                        ),
                                        onToggleEmoji: () => setState(
                                            () => _showEmojiBar =
                                                !_showEmojiBar),
                                        onInsertEmoji: (emoji) =>
                                            _captionController.text += emoji,
                                        onTogglePoll: () => setState(
                                            () => _showPoll = !_showPoll),
                                        onPickTopic: () =>
                                            CreatePostBottomSheets
                                                .showTopicPickerPopup(
                                          context: context,
                                          triggerKey: _topicTriggerKey,
                                          onTopicSelected: (t) => setState(
                                              () => _selectedTopic = t),
                                        ),
                                        onPickLocation: () =>
                                            CreatePostBottomSheets
                                                .showLocationPickerBottomSheet(
                                          context: context,
                                          onLocationSelected: (loc) => setState(
                                              () => _selectedLocation = loc),
                                        ),
                                        onAudioTap: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Audio clip segera hadir'),
                                              duration: Duration(seconds: 1),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 8.0),

                                      // "Saya ingin Berjualan" Clean Bare Switch Toggle
                                      CreatePostSellingToggle(
                                        isProductMode:
                                            _postMode == PostMode.product,
                                        onToggle: (isProduct) => setState(() {
                                          _postMode = isProduct
                                              ? PostMode.product
                                              : PostMode.thread;
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_postMode == PostMode.product)
                          const SizedBox(height: 8.0),
                          // Thread Continuation Chain vs Product Rich Fields
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: _postMode == PostMode.thread
                                ? CreatePostSubThreads(
                                    subThreads: _subThreads,
                                    currentUserAvatar: widget.currentUserAvatar,
                                    onAddSubThread: _handleAddSubThread,
                                    onRemoveSubThread: (idx) => setState(
                                        () => _subThreads.removeAt(idx)),
                                  )
                                : CreatePostProductFields(
                                    productTitleController:
                                        _productTitleController,
                                    priceController: _priceController,
                                    descController: _descController,
                                    titleKey: _titleKey,
                                    priceKey: _priceKey,
                                    descKey: _descKey,
                                    titleFocusNode: _titleFocusNode,
                                    priceFocusNode: _priceFocusNode,
                                    descFocusNode: _descFocusNode,
                                    selectedLocation: _selectedLocation,
                                    onPickLocation: () =>
                                        CreatePostBottomSheets
                                            .showLocationPickerBottomSheet(
                                      context: context,
                                      onLocationSelected: (loc) => setState(
                                          () => _selectedLocation = loc),
                                    ),
                                    onLocationSelected: (loc) => setState(
                                        () => _selectedLocation = loc),
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // 3. Pinned Bottom Footer Bar
              CreatePostFooterBar(
                audiencePrivacy: _audiencePrivacy,
                canSubmit: _canSubmit,
                isSubmitting: _isSubmitting,
                onPrivacyTap: () =>
                    CreatePostBottomSheets.showPrivacyPickerBottomSheet(
                  context: context,
                  onPrivacySelected: (p) =>
                      setState(() => _audiencePrivacy = p),
                ),
                onSubmit: _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSellingIntentBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: AppColors.primaryPastel,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome_rounded,
            size: 15.0,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6.0),
          const Expanded(
            child: Text(
              'Ingin menjual barang?',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              _postMode = PostMode.product;
              _showSellingIntentBanner = false;
            }),
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
            ),
            child: const Text(
              'Beralih ke Jual',
              style: TextStyle(fontSize: 11.0, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesPreview() {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return SizedBox(
      height: 185.0,
      child: Transform.translate(
        offset: const Offset(-64.0, 0),
        child: OverflowBox(
          minWidth: screenWidth,
          maxWidth: screenWidth,
          minHeight: 185.0,
          maxHeight: 185.0,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: screenWidth,
            height: 185.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              padding: const EdgeInsets.only(left: 64.0, right: 16.0),
              itemCount: _images.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 10.0),
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return GestureDetector(
                    onTap: _handlePickImage,
                    child: Container(
                      width: 115.0,
                      height: 185.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.plus,
                            size: 26.0,
                            color: Color(0xFF64748B),
                          ),
                          SizedBox(height: 6.0),
                          Text(
                            'Tambah Foto',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Stack(
                  children: [
                    Container(
                      width: 155.0,
                      height: 185.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.network(
                          _images[index],
                          width: 155.0,
                          height: 185.0,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 155.0,
                            height: 185.0,
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(
                              Icons.image_outlined,
                              size: 32.0,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6.0,
                      right: 6.0,
                      child: GestureDetector(
                        onTap: () => setState(() => _images.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          decoration: const BoxDecoration(
                            color: Color(0xB3000000),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGifPreview() {
    final screenWidth = MediaQuery.sizeOf(context).width;

    return SizedBox(
      height: 150.0,
      child: Transform.translate(
        offset: const Offset(-64.0, 0),
        child: OverflowBox(
          minWidth: screenWidth,
          maxWidth: screenWidth,
          minHeight: 150.0,
          maxHeight: 150.0,
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: screenWidth,
            child: Padding(
              padding: const EdgeInsets.only(left: 64.0, right: 16.0),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Image.network(
                      _selectedGif!.url,
                      height: 150.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        height: 150.0,
                        width: double.infinity,
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(
                          Icons.gif_box_outlined,
                          size: 32.0,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6.0,
                    right: 6.0,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedGif = null),
                      child: Container(
                        padding: const EdgeInsets.all(5.0),
                        decoration: const BoxDecoration(
                          color: Color(0xB3000000),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
