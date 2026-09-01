import "package:flutter/material.dart";

class CheckoutHeroImage extends StatefulWidget {
  final List<String> images;
  final String title;

  const CheckoutHeroImage({
    super.key,
    required this.images,
    required this.title,
  });

  @override
  State<CheckoutHeroImage> createState() => _CheckoutHeroImageState();
}

class _CheckoutHeroImageState extends State<CheckoutHeroImage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imgs = widget.images.isNotEmpty
        ? widget.images
        : ["https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=800&q=80"];

    return Column(
      children: [
        SizedBox(
          height: 260.0,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: imgs.length,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemBuilder: (_, idx) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Image.network(
                    imgs[idx],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Center(
                        child: Icon(Icons.image_outlined, size: 40.0, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        if (imgs.length > 1) ...[
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(imgs.length, (idx) {
              final isActive = idx == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                width: isActive ? 18.0 : 6.0,
                height: 6.0,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF3D38F5) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3.0),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
