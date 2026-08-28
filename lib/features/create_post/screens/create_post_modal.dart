import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/core/utils/rupiah_input_formatter.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

/// Full-Page Screen for Creating Threads & Selling Products
///
/// 100% exact match to web single-page layout (Image #2):
/// - Full-page Scaffold with pure white canvas (no bottom-sheet peek)
/// - Header: "Batal" | "Utas Baru" | Drafts & More options ("...")
/// - Vertical Thread Connector Line from author avatar to sub-thread
/// - 7-Icon Media Toolbar on Row 1 + Dedicated "Jual Barang" switch pill on Row 2 (anti-overflow)
/// - Sub-thread chained continuation ("Tambahkan ke utas")
/// - Product e-commerce fields (Price with Rp prefix, Stock, School COD Place picker)
/// - Pinned Bottom Footer: Audience selector + "Posting" pill button
class CreatePostModal extends StatefulWidget {
  final PostMode initialMode;
  final VoidCallback? onClose;
  final ValueChanged<Map<String, dynamic>>? onSubmitPost;
  final String currentUsername;
  final String currentUserAvatar;

  const CreatePostModal({
    super.key,
    this.initialMode = PostMode.thread,
    this.onClose,
    this.onSubmitPost,
    this.currentUsername = 'radityarayhannnn',
    this.currentUserAvatar =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
  });

  /// Static helper to open as a full-page modal route
  static Future<void> show(
    BuildContext context, {
    PostMode initialMode = PostMode.thread,
    ValueChanged<Map<String, dynamic>>? onSubmitPost,
  }) {
    return Navigator.of(context).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) => CreatePostModal(
          initialMode: initialMode,
          onSubmitPost: onSubmitPost,
        ),
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

  final List<String> _images = [];
  TopicOption? _selectedTopic;
  SchoolPlace? _selectedLocation;
  PresetGif? _selectedGif;
  bool _showPoll = false;
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  String _audiencePrivacy = 'Siapa pun dapat membalas & mengutip';
  bool _isSubmitting = false;
  bool _showSellingIntentBanner = false;
  final GlobalKey _topicTriggerKey = GlobalKey();
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
          alignment: 0.25, // Placed comfortably in upper half above keyboard
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
    final sellingKeywords = [
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
    if (hasKeyword != _showSellingIntentBanner) {
      setState(() => _showSellingIntentBanner = hasKeyword);
    }
  }

  void _handlePickImage() {
    HapticFeedback.selectionClick();
    final nextImage = _dummyImagesPool[_images.length % _dummyImagesPool.length];
    setState(() {
      _images.add(nextImage);
    });
  }

  void _handleRemoveImage(int index) {
    HapticFeedback.selectionClick();
    setState(() {
      _images.removeAt(index);
    });
  }

  void _handleAddSubThread() {
    HapticFeedback.selectionClick();
    setState(() {
      _subThreads.add(SubThreadItem(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      ));
    });
  }

  void _handleSubmit() {
    if (_isSubmitting) return;

    final caption = _captionController.text.trim();
    if (caption.isEmpty && _images.isEmpty && _productTitleController.text.trim().isEmpty) {
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    final postData = <String, dynamic>{
      'mode': _postMode == PostMode.thread ? 'thread' : 'product',
      'caption': caption,
      'images': List<String>.from(_images),
      'topic': _selectedTopic?.name,
      'location': _selectedLocation?.name,
      'gif': _selectedGif?.url,
      'productTitle': _productTitleController.text.trim(),
      'price': int.tryParse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      'stock': int.tryParse(_stockController.text.trim()) ?? 1,
      'description': _descController.text.trim(),
      'privacy': _audiencePrivacy,
      'subThreads': _subThreads.map((s) => {'caption': s.caption, 'images': s.images}).toList(),
    };

    widget.onSubmitPost?.call(postData);
    Navigator.of(context).pop();
  }

  void _handleCancel() {
    final hasContent = _captionController.text.isNotEmpty ||
        _productTitleController.text.isNotEmpty ||
        _images.isNotEmpty;

    if (!hasContent) {
      if (widget.onClose != null) {
        widget.onClose!();
      } else {
        Navigator.of(context).pop();
      }
      return;
    }

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Buang postingan ini?'),
        message: const Text('Perubahan yang belum diposting akan hilang.'),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              if (widget.onClose != null) {
                widget.onClose!();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Buang'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Lanjutkan Mengedit'),
        ),
      ),
    );
  }

  bool get _canSubmit {
    return _captionController.text.trim().isNotEmpty ||
        _images.isNotEmpty ||
        _productTitleController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

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
              // 1. Top Header Bar (Matching Image #2)
              _buildHeaderBar(context),

              // 2. Scrollable Body Area with Vertical Thread Connector Line
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    16.0,
                    12.0,
                    16.0,
                    keyboardHeight > 0 ? keyboardHeight + 80.0 : 20.0,
                  ),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Smart Intent Detection Banner
                    if (_showSellingIntentBanner) _buildSellingIntentBanner(),

                    // Main Thread Block (Left Avatar + Connector Line | Right Editor)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Avatar & Vertical Thread Connector Line
                        Column(
                          children: [
                            // Author Avatar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18.0),
                              child: Image.network(
                                widget.currentUserAvatar,
                                width: 36.0,
                                height: 36.0,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
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
                            // Vertical Thread Connector Line (Runs down to switch row matching Image #1)
                            Container(
                              width: 2.0,
                              height: _postMode == PostMode.thread ? 75.0 : 90.0,
                              color: const Color(0xFFE2E8F0),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12.0),

                        // Right Column: Author Header, Textarea, Attached Content, Toolbar
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Author Name + Topic Picker
                              _buildAuthorAndTopicLine(),
                              const SizedBox(height: 2.0),
                              _buildMainTextInput(),


                              // Attached Images Horizontal Carousel
                              if (_images.isNotEmpty) ...[
                                const SizedBox(height: 12.0),
                                _buildImagesPreview(),
                              ],

                              // Selected GIF Preview
                              if (_selectedGif != null) ...[
                                const SizedBox(height: 10.0),
                                _buildGifPreview(),
                              ],

                              // Selected Location Chip
                              if (_selectedLocation != null) ...[
                                const SizedBox(height: 8.0),
                                _buildLocationChip(),
                              ],

                              // Poll Builder Card
                              if (_showPoll) ...[
                                const SizedBox(height: 12.0),
                                _buildPollBuilder(),
                              ],

                              const SizedBox(height: 8.0),

                              // 7-Icon Media Toolbar (Row 1)
                              _buildMediaIconsRow(),

                              const SizedBox(height: 6.0),

                              // "Jual Barang" Switch Pill (Row 2 - Anti-Overflow)
                              _buildSellingSwitchPill(),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Full-Width Product Fields (Positioned below the top author/toolbar block matching Image #1)
                    if (_postMode == PostMode.product) ...[
                      const SizedBox(height: 18.0),
                      _buildProductFields(),
                    ],
                    // Sub-Threads Chain (Only in Thread Mode - matching Image #1)
                    if (_postMode == PostMode.thread) ...[
                      if (_subThreads.isNotEmpty) ...[
                        const SizedBox(height: 12.0),
                        _buildSubThreadsChain(),
                      ],

                      const SizedBox(height: 8.0),

                      // Sub-Thread Continuation Trigger ("Tambahkan ke utas")
                      _buildSubThreadTrigger(),
                    ],
                    const SizedBox(height: 40.0),
                  ],
                ),
              ),
            ),

            // 3. Pinned Bottom Footer Bar (Privacy Selector + Posting Pill Button)
            _buildFooterBar(),
          ],
        ),
      ),
    ),
  );
  }

  // 1. Top Header Bar (Absolute Centered Title matching Image #1)
  Widget _buildHeaderBar(BuildContext context) {
    return Container(
      height: 52.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left: Batal
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: _handleCancel,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Color(0xFF1E293B), // Slate 800
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ),

          // Center: Absolute Centered Title ("Utas Baru")
          Text(
            _postMode == PostMode.thread ? 'Utas Baru' : 'Jual Produk',
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A), // Slate 900
              letterSpacing: -0.3,
            ),
          ),

          // Right: Drafts Document Icon + More Options ("...")
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Draft postingan tersimpan otomatis'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(
                      CupertinoIcons.doc_text,
                      size: 20.0,
                      color: Color(0xFF334155), // Slate 700
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(
                      CupertinoIcons.ellipsis,
                      size: 20.0,
                      color: Color(0xFF334155), // Slate 700
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Author Name + Topic Tag Line
  Widget _buildAuthorAndTopicLine() {
    return Row(
      children: [
        Text(
          widget.currentUsername,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 6.0),
        const Icon(Icons.chevron_right_rounded, size: 14.0, color: AppColors.muted),
        const SizedBox(width: 2.0),
        GestureDetector(
          key: _topicTriggerKey,
          onTap: _showTopicPickerPopup,
          behavior: HitTestBehavior.opaque,
          child: Text(
            _selectedTopic != null ? '#${_selectedTopic!.name}' : 'Komunitas atau topik',
            style: TextStyle(
              fontSize: 13.0,
              color: _selectedTopic != null ? AppColors.primary : const Color(0xFF64748B),
              fontWeight: _selectedTopic != null ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  // Main Textarea ("Apa yang baru?" - Compact & Auto-Expanding)
  Widget _buildMainTextInput() {
    return TextField(
      controller: _captionController,
      minLines: 1, // Compact starting height
      maxLines: null, // Expands dynamically as user types
      keyboardType: TextInputType.multiline,
      style: const TextStyle(
        fontSize: 15.0,
        color: AppColors.ink,
        height: 1.35,
      ),
      decoration: InputDecoration(
        hintText: _postMode == PostMode.thread
            ? 'Apa yang baru?'
            : 'Tulis deskripsi atau rincian jualan...',
        hintStyle: const TextStyle(
          fontSize: 15.0,
          color: Color(0xFF94A3B8),
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
  // 7-Icon Media Toolbar (Row 1 - Thumb Friendly)
  Widget _buildMediaIconsRow() {
    return Row(
      children: [
        // 1. Galeri Foto
        _MediaIconButton(
          icon: CupertinoIcons.photo,
          tooltip: 'Foto',
          onTap: _handlePickImage,
        ),
        const SizedBox(width: 2.0),
        // 2. GIF
        _MediaIconButton(
          icon: Icons.gif_box_outlined,
          tooltip: 'GIF',
          onTap: _showGifPickerBottomSheet,
        ),
        const SizedBox(width: 2.0),
        // 3. Emoji
        _MediaIconButton(
          icon: CupertinoIcons.smiley,
          tooltip: 'Emoji',
          onTap: _showEmojiPickerBottomSheet,
        ),
        const SizedBox(width: 2.0),
        // 4. Polling
        _MediaIconButton(
          icon: CupertinoIcons.chart_bar_square,
          tooltip: 'Polling',
          onTap: () => setState(() => _showPoll = !_showPoll),
        ),
        const SizedBox(width: 2.0),
        // 5. Topik / Tags
        _MediaIconButton(
          icon: Icons.scatter_plot_rounded,
          tooltip: 'Topik',
          onTap: _showTopicPickerPopup,
        ),
        const SizedBox(width: 2.0),
        // 6. Lokasi COD
        _MediaIconButton(
          icon: CupertinoIcons.location,
          tooltip: 'Lokasi COD',
          onTap: _showLocationPickerBottomSheet,
        ),
        const SizedBox(width: 2.0),
        // 7. Audio / Music Note
        _MediaIconButton(
          icon: CupertinoIcons.music_note_2,
          tooltip: 'Audio',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Audio clip segera hadir'),
                duration: Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );
  }

  // "Jual Barang" Clean Switch Toggle (Flush Left)
  Widget _buildSellingSwitchPill() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _postMode = _postMode == PostMode.product
              ? PostMode.thread
              : PostMode.product;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 38.0,
            height: 22.0,
            child: FittedBox(
              fit: BoxFit.fill,
              child: CupertinoSwitch(
                value: _postMode == PostMode.product,
                activeTrackColor: AppColors.primary,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _postMode = val ? PostMode.product : PostMode.thread;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 6.0), // Tight clean gap
          Text(
            'Jual Barang',
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w600,
              color: _postMode == PostMode.product
                  ? AppColors.primary
                  : const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  // Sub-Thread Continuation Trigger ("Tambahkan ke utas")
  Widget _buildSubThreadTrigger() {
    return GestureDetector(
      onTap: _handleAddSubThread,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              widget.currentUserAvatar,
              width: 24.0,
              height: 24.0,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 14.0),
          const Text(
            'Tambahkan ke utas',
            style: TextStyle(
              fontSize: 14.0,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // Pinned Bottom Footer Bar (Matching Image #2)
  Widget _buildFooterBar() {
    final canSubmit = _canSubmit;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Left: "Siapa pun dapat membalas & mengutip" (Flexible with ellipsis to prevent overflow)
          Expanded(
            child: GestureDetector(
              onTap: _showPrivacyPickerBottomSheet,
              behavior: HitTestBehavior.opaque,
              child: Text(
                _audiencePrivacy,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12.0),

          // Right: "Posting" / "Jual" Pill Button
          GestureDetector(
            onTap: canSubmit ? _handleSubmit : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 9.0),
              decoration: BoxDecoration(
                color: canSubmit ? AppColors.primary : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: canSubmit ? AppColors.primaryDark : const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 14.0,
                      height: 14.0,
                      child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                    )
                  : Text(
                      _postMode == PostMode.thread ? 'Posting' : 'Jual',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: canSubmit ? Colors.white : const Color(0xFF94A3B8),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Product Fields Layout (Matching Image #2 1:1)
  Widget _buildProductFields() {
    const codPresets = [
      {'name': 'Kantin', 'emoji': '🍜'},
      {'name': 'Lab PPLG', 'emoji': '💻'},
      {'name': 'Perpustakaan', 'emoji': '📚'},
      {'name': 'Depan Gerbang', 'emoji': '🏫'},
      {'name': 'Lapangan', 'emoji': '⚽'},
      {'name': 'Gazebo DKV', 'emoji': '☕'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Nama Barang / Jasa *
        _buildFieldLabel('Nama Barang / Jasa', isRequired: true),
        const SizedBox(height: 6.0),
        TextField(
          key: _titleKey,
          focusNode: _titleFocusNode,
          controller: _productTitleController,
          cursorColor: AppColors.primary,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
          decoration: _buildCleanInputDecoration(
            hint: 'Tulis nama barang atau jasa...',
          ),
        ),
        const SizedBox(height: 14.0),

        // 2. Harga (Rp) *
        _buildFieldLabel('Harga (Rp)', isRequired: true),
        const SizedBox(height: 6.0),
        TextField(
          key: _priceKey,
          focusNode: _priceFocusNode,
          controller: _priceController,
          keyboardType: TextInputType.number,
          cursorColor: AppColors.primary,
          inputFormatters: [
            const RupiahInputFormatter(),
          ],
          style: const TextStyle(
            fontSize: 15.0,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
          decoration: _buildCleanInputDecoration(
            hint: '0',
            prefixWidget: Padding(
              padding: const EdgeInsets.only(left: 14.0, right: 4.0),
              child: Text(
                'Rp ',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: _priceController.text.isNotEmpty
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: _priceController.text.isNotEmpty
                      ? const Color(0xFF0F172A)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14.0),

        // 3. Deskripsi Singkat
        _buildFieldLabel('Deskripsi Singkat'),
        const SizedBox(height: 6.0),
        TextField(
          key: _descKey,
          focusNode: _descFocusNode,
          controller: _descController,
          minLines: 3,
          maxLines: 4,
          cursorColor: AppColors.primary,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0F172A),
          ),
          decoration: _buildCleanInputDecoration(
            hint: 'Tulis kondisi barang, kelengkapan, atau alasan jual...',
          ),
        ),
        const SizedBox(height: 14.0),

        // 4. Titik COD di Sekolah
        _buildFieldLabel('Titik COD di Sekolah'),
        const SizedBox(height: 6.0),
        TextField(
          readOnly: true,
          onTap: _showLocationPickerBottomSheet,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: _selectedLocation != null
                ? _selectedLocation!.name
                : 'Ketik titik temu COD (Kantin, Lab, dll)...',
            hintStyle: TextStyle(
              fontSize: 13.5,
              color: _selectedLocation != null ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
              fontWeight: _selectedLocation != null ? FontWeight.w600 : FontWeight.w400,
            ),
            prefixIcon: const Icon(CupertinoIcons.location, size: 16.0, color: Color(0xFF64748B)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 6.0,
          runSpacing: 6.0,
          children: [
            for (var preset in codPresets) ...[
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedLocation = SchoolPlace(
                      id: 'preset_${preset['name']}',
                      name: preset['name']!,
                      subtitle: 'Titik Temu COD Sekolah',
                      distance: 'Kampus SMKN 8',
                    );
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _selectedLocation?.name == preset['name']
                        ? const Color(0xFFEFF6FF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: _selectedLocation?.name == preset['name']
                          ? AppColors.primary
                          : const Color(0xFFE2E8F0),
                      width: _selectedLocation?.name == preset['name'] ? 1.4 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(preset['emoji']!, style: const TextStyle(fontSize: 12.0)),
                      const SizedBox(width: 4.0),
                      Text(
                        preset['name']!,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: _selectedLocation?.name == preset['name']
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: _selectedLocation?.name == preset['name']
                              ? AppColors.primary
                              : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1E293B), // Slate 800
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Color(0xFFEF4444), // Red *
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
  InputDecoration _buildCleanInputDecoration({
    required String hint,
    Widget? prefixWidget,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: Color(0xFF94A3B8),
      ),
      prefixIcon: prefixWidget,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: Colors.white,
      focusColor: Colors.white,
      hoverColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  // Attached Images Preview
  Widget _buildImagesPreview() {
    return SizedBox(
      height: 90.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _images.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          if (index == _images.length) {
            return GestureDetector(
              onTap: _handlePickImage,
              child: Container(
                width: 80.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.camera, size: 20.0, color: AppColors.muted),
                    SizedBox(height: 2.0),
                    Text('Tambah', style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
                  ],
                ),
              ),
            );
          }

          final imgUrl = _images[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(imgUrl, width: 90.0, height: 90.0, fit: BoxFit.cover),
              ),
              Positioned(
                top: 3.0,
                right: 3.0,
                child: GestureDetector(
                  onTap: () => _handleRemoveImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 12.0, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Selected GIF Preview
  Widget _buildGifPreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.network(_selectedGif!.url, height: 120.0, width: double.infinity, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4.0,
          right: 4.0,
          child: GestureDetector(
            onTap: () => setState(() => _selectedGif = null),
            child: Container(
              padding: const EdgeInsets.all(3.0),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14.0, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Location Chip
  Widget _buildLocationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.primaryPastel,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.location_solid, size: 12.0, color: AppColors.primary),
          const SizedBox(width: 4.0),
          Text(
            _selectedLocation!.name,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 4.0),
          GestureDetector(
            onTap: () => setState(() => _selectedLocation = null),
            child: const Icon(Icons.close, size: 12.0, color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }

  // Poll Builder
  Widget _buildPollBuilder() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Polling Komunitas', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: () => setState(() => _showPoll = false),
                child: const Icon(Icons.close, size: 14.0, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          for (int i = 0; i < _pollOptionControllers.length; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: TextField(
                controller: _pollOptionControllers[i],
                style: const TextStyle(fontSize: 13.0),
                decoration: InputDecoration(
                  hintText: 'Pilihan ${i + 1}...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Sub-Thread Chain
  Widget _buildSubThreadsChain() {
    return Column(
      children: [
        for (int i = 0; i < _subThreads.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(width: 2.0, height: 36.0, color: const Color(0xFFE2E8F0)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(widget.currentUserAvatar, width: 24.0, height: 24.0, fit: BoxFit.cover),
                  ),
                ],
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: TextField(
                  onChanged: (val) => _subThreads[i].caption = val,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Lanjutkan utas (${i + 2})...',
                    hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 14.0, color: AppColors.muted),
                onPressed: () => setState(() => _subThreads.removeAt(i)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // Selling Intent Banner
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
          const Icon(Icons.auto_awesome_rounded, size: 15.0, color: AppColors.primary),
          const SizedBox(width: 6.0),
          const Expanded(
            child: Text(
              'Ingin menjual barang?',
              style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w600, color: AppColors.primaryDark),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              _postMode = PostMode.product;
              _showSellingIntentBanner = false;
            }),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
            ),
            child: const Text('Beralih ke Jual', style: TextStyle(fontSize: 11.0, color: Colors.white)),
          ),
        ],
      ),
    );
  }
  // Topic Picker Anchored Popover Modal (Positioned directly under "Komunitas atau topik")
  void _showTopicPickerPopup() {
    HapticFeedback.selectionClick();
    final customTopicController = TextEditingController();

    final renderBox = _topicTriggerKey.currentContext?.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? const Offset(60, 110);
    final size = renderBox?.size ?? Size.zero;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Topic Popover',
      barrierColor: Colors.transparent, // No background darkening
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
                    borderRadius: BorderRadius.circular(16.0), // rounded-2xl
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F000000), // shadow-xl
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
                      // Header: Topik Populer
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

                      // Top 3 Topics Only
                      for (var t in kPresetTopics.take(3)) ...[
                        InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedTopic = t);
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

                      // Refined Custom Topic Input Pill
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                        child: Container(
                          height: 34.0,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9), // Soft neutral pill
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
                                      setState(() {
                                        _selectedTopic = TopicOption(
                                          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                                          name: val.trim().replaceAll('#', ''),
                                        );
                                      });
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
                                    setState(() {
                                      _selectedTopic = TopicOption(
                                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                                        name: val.replaceAll('#', ''),
                                      );
                                    });
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

  void _showLocationPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Titik Temu COD SMKN 8', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10.0),
            for (var p in kRichSchoolPlaces) ...[
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(CupertinoIcons.location, color: AppColors.primary),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${p.subtitle} · ${p.distance}'),
                onTap: () {
                  setState(() => _selectedLocation = p);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showGifPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pilih GIF Populer', style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10.0),
            GridView.builder(
              shrinkWrap: true,
              itemCount: kPresetGifs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.5),
              itemBuilder: (context, idx) => GestureDetector(
                onTap: () {
                  setState(() => _selectedGif = kPresetGifs[idx]);
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

  void _showEmojiPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            for (var emoji in kPresetEmojis) ...[
              GestureDetector(
                onTap: () {
                  _captionController.text += emoji;
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

  void _showPrivacyPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.0))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Siapa pun dapat membalas & mengutip'),
            onTap: () {
              setState(() => _audiencePrivacy = 'Siapa pun dapat membalas & mengutip');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('Pengikut Anda'),
            onTap: () {
              setState(() => _audiencePrivacy = 'Pengikut Anda');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('Hanya yang disebut'),
            onTap: () {
              setState(() => _audiencePrivacy = 'Hanya yang disebut');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

/// Thumb-Friendly 38x38px Action Icon Button for Media Toolbar
class _MediaIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MediaIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_MediaIconButton> createState() => _MediaIconButtonState();
}

class _MediaIconButtonState extends State<_MediaIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 36.0,
          height: 36.0,
          decoration: BoxDecoration(
            color: _isPressed ? const Color(0x0F000000) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: 21.5, // Crisp, easily visible icon size
              color: _isPressed ? AppColors.ink : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
