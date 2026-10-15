import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:snapan_market/core/theme/app_colors.dart";
import "package:snapan_market/features/search/models/search_models.dart";
export "package:snapan_market/features/search/models/search_models.dart" show SearchResultsTab;

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.adaptiveCanvas(context),
        border: Border(
          bottom: BorderSide(color: AppColors.adaptiveBorder(context), width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. TOP HEADER ROW: Identical layout to HomeFeedHeader (52px, back arrow, centered 'Cari' title)
            Container(
              height: 52.0,
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Leading Back Arrow (matching Chat, Aktivitas, Profil)
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: Icon(
                        CupertinoIcons.chevron_back,
                        size: 22.0,
                        color: AppColors.adaptiveText(context),
                      ),
                      onPressed: onBack,
                      tooltip: 'Kembali',
                      splashRadius: 20.0,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                    ),
                  ),

                  // Center Title: 'Cari' (matching standard 17.5px SF Pro bold)
                  Center(
                    child: Text(
                      'Cari',
                      style: TextStyle(
                        fontFamily: 'SF Pro',
                        fontSize: 17.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.adaptiveText(context),
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. SEARCHBAR INPUT ROW (Height: 42px)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
              child: Container(
                height: 42.0,
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: AppColors.adaptiveBorder(context), width: 0.8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Search Icon
                    Icon(
                      CupertinoIcons.search,
                      size: 18.0,
                      color: AppColors.adaptiveMuted(context),
                    ),

                    const SizedBox(width: 10.0),

                    // Search Text Field Input
                    Expanded(
                      child: TextField(
                        controller: controller,
                        onChanged: onChanged,
                        onSubmitted: (_) => onSubmitted(),
                        textInputAction: TextInputAction.search,
                        style: TextStyle(
                          fontFamily: 'SFPro',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.adaptiveText(context),
                          letterSpacing: -0.2,
                        ),
                        decoration: InputDecoration(
                          hintText: "Cari",
                          hintStyle: TextStyle(
                            fontFamily: 'SFPro',
                            fontSize: 14.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.adaptiveMuted(context),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),

                    // Clear Query Button (x) when query is present
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
                              CupertinoIcons.xmark,
                              size: 11.0,
                              color: Colors.white,
                            ),
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
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.adaptiveBorder(context), width: 0.8),
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
                color: isActive ? AppColors.adaptiveText(context) : Colors.transparent,
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
              color: isActive ? AppColors.adaptiveText(context) : AppColors.adaptiveMuted(context),
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }
}
