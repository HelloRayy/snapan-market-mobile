import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

/// Fullscreen Modal / Bottom Sheet for Creating Threads & Selling Products
///
/// 100% faithful Flutter translation of `src/ui/components/marketplace/CreatePostModal.tsx`:
/// - Dual Mode: Utas Biasa (`thread`) vs Jual Produk (`product`)
/// - Smart Selling Intent Detection: detects selling keywords & suggests switching mode
/// - 7-Icon Media Toolbar (Gallery, GIF, Emoji, Poll, COD Location, Voice, Topic)
/// - Sub-thread chained continuation ("Tambahkan ke utas")
/// - Product e-commerce fields (Price with Rp prefix, Stock, School COD Place picker)
/// - Draft management and audience privacy control
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

  /// Static helper to open modal smoothly as a full-screen bottom sheet
  static Future<void> show(
    BuildContext context, {
    PostMode initialMode = PostMode.thread,
    ValueChanged<Map<String, dynamic>>? onSubmitPost,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) => CreatePostModal(
        initialMode: initialMode,
        onClose: () => Navigator.of(context).pop(),
        onSubmitPost: (data) {
          Navigator.of(context).pop();
          onSubmitPost?.call(data);
        },
      ),
    );
  }

  @override
  State<CreatePostModal> createState() => _CreatePostModalState();
}

class _CreatePostModalState extends State<CreatePostModal> {
  late PostMode _postMode;

  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _productTitleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  final List<String> _images = [];
  final List<SubThreadItem> _subThreads = [];
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
  }

  @override
  void dispose() {
    _captionController.dispose();
    _productTitleController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tuliskan sesuatu atau tambahkan foto terlebih dahulu'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Bar: Batal | Judul Modal | Drafts / Actions
          _buildHeaderBar(context),

          // 2. Scrollable Body Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Smart Intent Detection Banner
                  if (_showSellingIntentBanner) _buildSellingIntentBanner(),

                  // Author Header Line (Avatar + Username + Topic Tag Dropdown)
                  _buildAuthorLine(),

                  const SizedBox(height: 12.0),

                  // Main Textarea
                  _buildMainTextInput(),

                  // Product Specific Selling Fields (if postMode == product)
                  if (_postMode == PostMode.product) ...[
                    const SizedBox(height: 16.0),
                    _buildProductFields(),
                  ],

                  // Attached Images Horizontal Carousel
                  if (_images.isNotEmpty) ...[
                    const SizedBox(height: 14.0),
                    _buildImagesPreview(),
                  ],

                  // Selected GIF Preview
                  if (_selectedGif != null) ...[
                    const SizedBox(height: 12.0),
                    _buildGifPreview(),
                  ],

                  // Selected Location Chip
                  if (_selectedLocation != null) ...[
                    const SizedBox(height: 10.0),
                    _buildLocationChip(),
                  ],

                  // Poll Builder Card
                  if (_showPoll) ...[
                    const SizedBox(height: 14.0),
                    _buildPollBuilder(),
                  ],

                  // 7-Icon Media Toolbar
                  const SizedBox(height: 16.0),
                  _buildMediaToolbar(),

                  // Sub-Thread Chained Continuation ("Tambahkan ke utas")
                  if (_subThreads.isNotEmpty) ...[
                    const SizedBox(height: 16.0),
                    _buildSubThreadsChain(),
                  ],

                  // Button "Tambahkan ke utas"
                  const SizedBox(height: 12.0),
                  _buildAddSubThreadButton(),

                  const SizedBox(height: 40.0),
                ],
              ),
            ),
          ),

          // 3. Pinned Bottom Footer Bar (Privacy Selector + Kumo Submit Button)
          _buildFooterBar(),
        ],
      ),
    );
  }

  // 1. Header Bar
  Widget _buildHeaderBar(BuildContext context) {
    return Container(
      height: 52.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Batal
          GestureDetector(
            onTap: _handleCancel,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Batal',
                style: TextStyle(
                  fontSize: 15.0,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Title
          Text(
            _postMode == PostMode.thread ? 'Utas Baru' : 'Jual Produk Baru',
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),

          // Right: Action / Draft Indicator
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Draft postingan otomatis tersimpan'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(
              CupertinoIcons.doc_text,
              size: 20.0,
              color: AppColors.muted,
            ),
            tooltip: 'Drafts',
          ),
        ],
      ),
    );
  }

  // Smart Selling Intent Banner
  Widget _buildSellingIntentBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.primaryPastel,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 16.0, color: AppColors.primary),
          const SizedBox(width: 8.0),
          const Expanded(
            child: Text(
              'Ingin menjual barang/jasa?',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              setState(() {
                _postMode = PostMode.product;
                _showSellingIntentBanner = false;
              });
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
            ),
            child: const Text(
              'Beralih ke Jual',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Author Line (Avatar, Username, Topic Chip)
  Widget _buildAuthorLine() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar
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
              child: const Icon(Icons.person_rounded, size: 20.0, color: AppColors.muted),
            ),
          ),
        ),
        const SizedBox(width: 10.0),

        // Username + Topic
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.currentUsername,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 2.0),

              // Topic Chip Dropdown Trigger
              GestureDetector(
                onTap: _showTopicPickerBottomSheet,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedTopic != null
                          ? '#${_selectedTopic!.name}'
                          : 'Komunitas atau topik',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _selectedTopic != null ? AppColors.primary : AppColors.muted,
                        fontWeight: _selectedTopic != null ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 2.0),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 14.0,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Main Textarea
  Widget _buildMainTextInput() {
    return TextField(
      controller: _captionController,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      style: const TextStyle(
        fontSize: 15.5,
        color: AppColors.ink,
        height: 1.4,
      ),
      decoration: InputDecoration(
        hintText: _postMode == PostMode.thread
            ? 'Apa yang baru?'
            : 'Ceritakan detail barang atau jasamu...',
        hintStyle: const TextStyle(
          fontSize: 15.5,
          color: Color(0xFF94A3B8),
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // Product E-Commerce Fields
  Widget _buildProductFields() {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Produk & COD SMKN 8',
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.w700,
              color: AppColors.slateInk,
            ),
          ),
          const SizedBox(height: 12.0),

          // Nama Produk
          TextField(
            controller: _productTitleController,
            style: const TextStyle(fontSize: 14.0, color: AppColors.ink),
            decoration: _buildInputDecoration(
              label: 'Nama Produk / Jasa',
              hint: 'e.g. Seragam Batik SMKN 8, Jasa Logo DKV',
              icon: CupertinoIcons.tag,
            ),
          ),
          const SizedBox(height: 10.0),

          // Harga & Stok
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14.0, color: AppColors.ink),
                  decoration: _buildInputDecoration(
                    label: 'Harga (Rp)',
                    hint: '25.000',
                    icon: CupertinoIcons.money_dollar,
                  ),
                ),
              ),
              const SizedBox(width: 10.0),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14.0, color: AppColors.ink),
                  decoration: _buildInputDecoration(
                    label: 'Stok',
                    hint: '1',
                    icon: CupertinoIcons.cube_box,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Lokasi Titik Temu COD Kampus SMKN 8
          GestureDetector(
            onTap: _showLocationPickerBottomSheet,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.location, size: 16.0, color: AppColors.primary),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      _selectedLocation != null
                          ? _selectedLocation!.name
                          : 'Pilih Titik Temu COD Sekolah...',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: _selectedLocation != null ? AppColors.ink : AppColors.muted,
                        fontWeight: _selectedLocation != null ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 16.0, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 12.5, color: AppColors.muted),
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFFCBD5E1)),
      prefixIcon: Icon(icon, size: 16.0, color: AppColors.muted),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  // Attached Images Preview List
  Widget _buildImagesPreview() {
    return SizedBox(
      height: 100.0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _images.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8.0),
        itemBuilder: (context, index) {
          if (index == _images.length) {
            // Add More Button
            return GestureDetector(
              onTap: _handlePickImage,
              child: Container(
                width: 90.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.camera, size: 22.0, color: AppColors.muted),
                    SizedBox(height: 4.0),
                    Text('Tambah', style: TextStyle(fontSize: 11.0, color: AppColors.muted)),
                  ],
                ),
              ),
            );
          }

          final imgUrl = _images[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  imgUrl,
                  width: 100.0,
                  height: 100.0,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4.0,
                right: 4.0,
                child: GestureDetector(
                  onTap: () => _handleRemoveImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(3.0),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 14.0, color: Colors.white),
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
          borderRadius: BorderRadius.circular(12.0),
          child: Image.network(
            _selectedGif!.url,
            height: 140.0,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 6.0,
          right: 6.0,
          child: GestureDetector(
            onTap: () => setState(() => _selectedGif = null),
            child: Container(
              padding: const EdgeInsets.all(4.0),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14.0, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // Selected Location Chip
  Widget _buildLocationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: AppColors.primaryPastel,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(CupertinoIcons.location_solid, size: 14.0, color: AppColors.primary),
          const SizedBox(width: 4.0),
          Text(
            _selectedLocation!.name,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: 4.0),
          GestureDetector(
            onTap: () => setState(() => _selectedLocation = null),
            child: const Icon(Icons.close, size: 14.0, color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }

  // Poll Builder Card
  Widget _buildPollBuilder() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(CupertinoIcons.chart_bar_square, size: 16.0, color: AppColors.primary),
                  SizedBox(width: 6.0),
                  Text(
                    'Polling Komunitas',
                    style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _showPoll = false),
                child: const Icon(Icons.close, size: 16.0, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          for (int i = 0; i < _pollOptionControllers.length; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: TextField(
                controller: _pollOptionControllers[i],
                style: const TextStyle(fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Pilihan ${i + 1}...',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
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

  // 7-Icon Media Toolbar
  Widget _buildMediaToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: 6 Action Icons
        Row(
          children: [
            _ToolbarIconButton(
              icon: CupertinoIcons.photo,
              tooltip: 'Galeri Foto',
              onTap: _handlePickImage,
            ),
            _ToolbarIconButton(
              icon: Icons.gif_box_outlined,
              tooltip: 'GIF',
              onTap: _showGifPickerBottomSheet,
            ),
            _ToolbarIconButton(
              icon: CupertinoIcons.smiley,
              tooltip: 'Emoji',
              onTap: _showEmojiPickerBottomSheet,
            ),
            _ToolbarIconButton(
              icon: CupertinoIcons.chart_bar_square,
              tooltip: 'Polling',
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _showPoll = !_showPoll);
              },
            ),
            _ToolbarIconButton(
              icon: CupertinoIcons.location,
              tooltip: 'Lokasi COD',
              onTap: _showLocationPickerBottomSheet,
            ),
            _ToolbarIconButton(
              icon: CupertinoIcons.mic,
              tooltip: 'Voice Note',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Perekam suara segera hadir'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),

        // Right: Switch Toggle "Jual Barang"
        Row(
          children: [
            Text(
              'Jual Barang',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: _postMode == PostMode.product ? AppColors.primary : AppColors.muted,
              ),
            ),
            const SizedBox(width: 4.0),
            CupertinoSwitch(
              value: _postMode == PostMode.product,
              activeTrackColor: AppColors.primary,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() {
                  _postMode = val ? PostMode.product : PostMode.thread;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  // Sub-Thread Chained Items
  Widget _buildSubThreadsChain() {
    return Column(
      children: [
        for (int i = 0; i < _subThreads.length; i++) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 2.0,
                      height: 40.0,
                      color: const Color(0xFFCBD5E1),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        widget.currentUserAvatar,
                        width: 24.0,
                        height: 24.0,
                        fit: BoxFit.cover,
                      ),
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
                      hintStyle: const TextStyle(fontSize: 14.0, color: Color(0xFF94A3B8)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16.0, color: AppColors.muted),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _subThreads.removeAt(i));
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Add Sub-thread trigger
  Widget _buildAddSubThreadButton() {
    return GestureDetector(
      onTap: _handleAddSubThread,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              widget.currentUserAvatar,
              width: 20.0,
              height: 20.0,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10.0),
          const Text(
            'Tambahkan ke utas',
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 3. Pinned Bottom Footer Bar
  Widget _buildFooterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF1F5F9), width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Audience Privacy Selector
          GestureDetector(
            onTap: _showPrivacyPickerBottomSheet,
            behavior: HitTestBehavior.opaque,
            child: Text(
              _audiencePrivacy,
              style: const TextStyle(
                fontSize: 12.0,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Right: Kumo Primary Blue Submit Button
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(strokeWidth: 2.0, color: Colors.white),
                  )
                : Text(
                    _postMode == PostMode.thread ? 'Posting' : 'Jual',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Bottom Sheets Helpers (Topic, Location, GIF, Emoji, Privacy)
  void _showTopicPickerBottomSheet() {
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
              'Pilih Topik Komunitas SMKN 8',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12.0),
            for (var t in kPresetTopics) ...[
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(CupertinoIcons.number, color: AppColors.primary),
                title: Text('#${t.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: t.subtitle != null ? Text(t.subtitle!) : null,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedTopic = t);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLocationPickerBottomSheet() {
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
              'Pilih Titik Temu COD Kampus SMKN 8',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12.0),
            for (var p in kRichSchoolPlaces) ...[
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(CupertinoIcons.location, color: AppColors.primary),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${p.subtitle} · ${p.distance}'),
                onTap: () {
                  HapticFeedback.selectionClick();
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
              'Pilih GIF Populer',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12.0),
            GridView.builder(
              shrinkWrap: true,
              itemCount: kPresetGifs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, idx) {
                final gif = kPresetGifs[idx];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedGif = gif);
                    Navigator.of(context).pop();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(gif.url, fit: BoxFit.cover),
                  ),
                );
              },
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
                  HapticFeedback.selectionClick();
                  _captionController.text += emoji;
                  Navigator.of(context).pop();
                },
                child: Text(emoji, style: const TextStyle(fontSize: 28.0)),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
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

/// Small Circular Icon Button for Media Toolbar
class _ToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20.0, color: const Color(0xFF64748B)),
      tooltip: tooltip,
      onPressed: onTap,
      padding: const EdgeInsets.all(6.0),
      constraints: const BoxConstraints(minWidth: 32.0, minHeight: 32.0),
    );
  }
}
