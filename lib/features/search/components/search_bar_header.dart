import "package:flutter/material.dart";
import "package:snapan_market/core/theme/app_colors.dart";

enum SearchResultsTab { top, latest, profiles }

class SearchBarHeader extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onClear;
  final VoidCallback? onBack;
  final VoidCallback? onFilterTap;
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
    this.onFilterTap,
    required this.hasQuery,
    required this.isSubmitted,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Container(
      color: Colors.white.withValues(alpha: 0.96),
      padding: EdgeInsets.only(
        top: topPadding > 0 ? topPadding + 6.0 : 12.0,
        left: 16.0,
        right: 16.0,
        bottom: isSubmitted && hasQuery ? 0.0 : 8.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Input Row (100% Full-Width Capsule with Integrated Left Arrow)
          Container(
            height: 44.0,
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.0),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 5.0,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Integrated Left Action: Back Arrow if onBack exists, else Search Icon
                if (onBack != null)
                  GestureDetector(
                    onTap: onBack,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 28.0,
                      height: 32.0,
                      alignment: Alignment.centerLeft,
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 20.0,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.search_rounded,
                      size: 20.0,
                      color: Color(0xFF94A3B8),
                    ),
                  ),

                const SizedBox(width: 4.0),

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
                      hintText: "Cari produk, kreator, atau jurusan...",
                      hintStyle: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),

                // Clear Query Button (x) or Filter Icon
                if (hasQuery)
                  GestureDetector(
                    onTap: onClear,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        width: 20.0,
                        height: 20.0,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F172A), // High Contrast Solid Slate Ink / Black
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 12.0, color: Colors.white),
                      ),
                    ),
                  )
                else if (onFilterTap != null)
                  GestureDetector(
                    onTap: onFilterTap,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.tune_rounded, size: 18.0, color: Color(0xFF64748B)),
                    ),
                  ),
              ],
            ),
          ),

          // 3 Tabs (Terpopuler | Terbaru | Profil) when search submitted
          if (hasQuery && isSubmitted) ...[
            const SizedBox(height: 6.0),
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
