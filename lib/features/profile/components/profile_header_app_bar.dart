import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Top App Bar Header for Profile Screen matching ProfilePage.tsx 1:1
/// Features: Left Menu/Back CTA, Centered Snapan Logotype, Right Search Toggle CTA, and Collapsible Search Field
class ProfileHeaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showSearch;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onToggleSearch;
  final VoidCallback? onMenuTap;
  final VoidCallback? onBackTap;
  final VoidCallback? onTitleTap;

  const ProfileHeaderAppBar({
    super.key,
    required this.showSearch,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onToggleSearch,
    this.onMenuTap,
    this.onBackTap,
    this.onTitleTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(showSearch ? 102.0 : 52.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9), width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Action Row (Height: 52px)
            SizedBox(
              height: 52.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: Back button or Hamburger Menu
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (onBackTap != null) {
                          onBackTap!();
                        } else {
                          onMenuTap?.call();
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 44.0,
                        height: 44.0,
                        alignment: Alignment.center,
                        child: Icon(
                          onBackTap != null
                              ? Icons.arrow_back_rounded
                              : Icons.menu_rounded,
                          size: 22.0,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),

                    // Center: Snapan Brand Logotype
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTitleTap?.call();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24.0,
                            height: 24.0,
                            margin: const EdgeInsets.only(right: 6.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF3B82F6), Color(0xFF1D64EC)],
                              ),
                              borderRadius: BorderRadius.circular(6.0),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1D64EC).withValues(alpha: 0.25),
                                  blurRadius: 6.0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                '8',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                          const Text(
                            'snapan',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right: Search Toggle Button
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onToggleSearch();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 44.0,
                        height: 44.0,
                        alignment: Alignment.center,
                        child: Icon(
                          showSearch ? Icons.close_rounded : Icons.search_rounded,
                          size: 22.0,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Collapsible Search Input Row (Height: 50px)
            if (showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 10.0),
                child: Container(
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Icon(
                          Icons.search_rounded,
                          size: 18.0,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          autofocus: true,
                          controller: TextEditingController(text: searchQuery)
                            ..selection = TextSelection.fromPosition(
                              TextPosition(offset: searchQuery.length),
                            ),
                          onChanged: onSearchChanged,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.normal,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Cari utas atau media di profil...',
                            hintStyle: TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFF94A3B8),
                              fontWeight: FontWeight.normal,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                          ),
                        ),
                      ),
                      if (searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () => onSearchChanged(''),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Icon(
                              Icons.cancel_rounded,
                              size: 16.0,
                              color: Color(0xFF94A3B8),
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
    );
  }
}
