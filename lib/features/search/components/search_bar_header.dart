import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

enum SearchResultsTab { top, latest, profiles }

/// Combined Top Bar Header & Search Bar for Search Screen
///
/// Matches the Threads-style header layout from the user reference:
/// - Row 1 (Top Bar): Menu icon (`=`), Threads logo (`@`), "Buka aplikasi" action button
/// - Row 2 (Search Bar): Search icon, clean "Cari" placeholder, and filter sliders icon
/// - Row 3 (Tabs): When search query is submitted, displays [Terpopuler | Terbaru | Profil]
class SearchBarHeader extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;
  final VoidCallback? onBack;
  final VoidCallback? onMenuTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onOpenAppTap;
  final bool hasQuery;
  final bool isSubmitted;
  final SearchResultsTab activeTab;
  final ValueChanged<SearchResultsTab> onTabChanged;

  const SearchBarHeader({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    this.onBack,
    this.onMenuTap,
    this.onFilterTap,
    this.onOpenAppTap,
    required this.hasQuery,
    required this.isSubmitted,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. TOP HEADER ROW (Height: 48px, Menu + Logo @ + "Buka aplikasi")
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: SizedBox(
                height: 48.0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Left: Menu Hamburger Button (or Back arrow if query active)
                    Positioned(
                      left: 0,
                      child: IconButton(
                        icon: Icon(
                          hasQuery && onBack != null
                              ? LucideIcons.arrowLeft
                              : LucideIcons.menu,
                          size: 22.0,
                          color: const Color(0xFF1A1A1A),
                        ),
                        onPressed: hasQuery && onBack != null
                            ? onBack
                            : (onMenuTap ?? onBack),
                        tooltip: 'Menu Navigasi',
                        splashRadius: 20.0,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                      ),
                    ),

                    // Center: Threads Logo Glyph '@'
                    Center(
                      child: GestureDetector(
                        onTap: onBack,
                        behavior: HitTestBehavior.opaque,
                        child: const Text(
                          '@',
                          style: TextStyle(
                            fontFamily: 'SF Pro',
                            fontSize: 27.0,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            height: 1.0,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                    ),

                    // Right: "Buka aplikasi" action pill button
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: onOpenAppTap ?? onBack,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          height: 34.0,
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A), // Pure Slate Ink pill
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x14000000),
                                blurRadius: 4.0,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Buka aplikasi',
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6.0),

            // 2. SEARCHBAR INPUT ROW (Height: 44px)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 44.0,
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), // Soft gray canvas matching reference
                  borderRadius: BorderRadius.circular(14.0),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Search Icon
                    const Icon(
                      LucideIcons.search,
                      size: 18.0,
                      color: Color(0xFF94A3B8),
                    ),

                    const SizedBox(width: 10.0),

                    // Search Text Field Input
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: onChanged,
                        onSubmitted: (_) => onSubmitted(),
                        textInputAction: TextInputAction.search,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Cari",
                          hintStyle: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF94A3B8),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),

                    // Clear Query Button (x) or Filter Icon (sliders)
                    if (hasQuery)
                      GestureDetector(
                        onTap: onClear,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 6.0),
                          child: Container(
                            width: 20.0,
                            height: 20.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 13.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: onFilterTap,
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6.0),
                          child: Icon(
                            LucideIcons.slidersHorizontal,
                            size: 17.0,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8.0),

            // 3. Search Results Tabs [Terpopuler | Terbaru | Profil] when query is submitted
            if (hasQuery && isSubmitted) ...[
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFF1F5F9), width: 0.8),
                  ),
                ),
                child: Row(
                  children: [
                    _TabItem(
                      label: "Terpopuler",
                      isActive: activeTab == SearchResultsTab.top,
                      onTap: () => onTabChanged(SearchResultsTab.top),
                    ),
                    _TabItem(
                      label: "Terbaru",
                      isActive: activeTab == SearchResultsTab.latest,
                      onTap: () => onTabChanged(SearchResultsTab.latest),
                    ),
                    _TabItem(
                      label: "Profil",
                      isActive: activeTab == SearchResultsTab.profiles,
                      onTap: () => onTabChanged(SearchResultsTab.profiles),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF0F172A) : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}
