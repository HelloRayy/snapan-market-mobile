import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/create_post/models/create_post_types.dart';

class CreatePostSellingIntentBanner extends StatelessWidget {
  final VoidCallback onSwitchToProduct;

  const CreatePostSellingIntentBanner({
    super.key,
    required this.onSwitchToProduct,
  });

  @override
  Widget build(BuildContext context) {
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
            onPressed: onSwitchToProduct,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
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
}

class CreatePostImagesPreview extends StatelessWidget {
  final List<String> images;
  final VoidCallback onAddImage;
  final ValueChanged<int> onRemoveImage;

  const CreatePostImagesPreview({
    super.key,
    required this.images,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
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
              itemCount: images.length + 1,
              separatorBuilder: (context, index) => const SizedBox(width: 10.0),
              itemBuilder: (context, index) {
                if (index == images.length) {
                  return GestureDetector(
                    onTap: onAddImage,
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

                final img = images[index];
                final isNetwork = img.startsWith('http://') || img.startsWith('https://');

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
                        child: isNetwork
                            ? Image.network(
                                img,
                                width: 155.0,
                                height: 185.0,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _errorPlaceholder(),
                              )
                            : Image.file(
                                File(img),
                                width: 155.0,
                                height: 185.0,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _errorPlaceholder(),
                              ),
                      ),
                    ),
                    Positioned(
                      top: 6.0,
                      right: 6.0,
                      child: GestureDetector(
                        onTap: () => onRemoveImage(index),
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

  Widget _errorPlaceholder() {
    return Container(
      width: 155.0,
      height: 185.0,
      color: const Color(0xFFF1F5F9),
      child: const Icon(
        Icons.broken_image_outlined,
        size: 32.0,
        color: AppColors.muted,
      ),
    );
  }
}

class CreatePostGifPreview extends StatelessWidget {
  final PresetGif gif;
  final VoidCallback onRemove;

  const CreatePostGifPreview({
    super.key,
    required this.gif,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
                      gif.url,
                      height: 150.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
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
                      onTap: onRemove,
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
