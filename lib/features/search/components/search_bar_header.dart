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
        left: 12.0,
        right: 12.0,
        bottom: isSubmitted && hasQuery ? 0.0 : 8.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search Input Row
          Row(
            children: [
              // Back Button
              if (onBack != null)
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, size: 20.0, color: Color(0xFF0F172A)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
                  splashRadius: 20.0,
                )
              else
                const Padding(
                  padding: EdgeInsets.only(left: 4.0, right: 8.0),
                  child: Icon(Icons.search, size: 20.0, color: Color(0xFF94A3B8)),
                ),

              // Search Text Field Input
              Expanded(
                child: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 18.0, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 8.0),
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
                      if (hasQuery)
                        GestureDetector(
                          onTap: onClear,
                          child: Container(
                            width: 20.0,
                            height: 20.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFFCBD5E1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 13.0, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Filter Icon Button
              if (onFilterTap != null)
                IconButton(
                  onPressed: onFilterTap,
                  icon: const Icon(Icons.tune_rounded, size: 20.0, color: Color(0xFF64748B)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
                  splashRadius: 20.0,
                ),
            ],
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
