import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Empty state widget for Direct Messages inbox when no conversations match.
class DirectMessagesEmptyState extends StatelessWidget {
  final String activeFilter;
  final String searchQuery;

  const DirectMessagesEmptyState({
    super.key,
    required this.activeFilter,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54.0,
              height: 54.0,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(18.0),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 28.0,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14.0),
            Text(
              activeFilter == 'requests'
                  ? 'Tidak ada pesan dari pembeli'
                  : 'Tidak ada obrolan',
              style: const TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6.0),
            Text(
              searchQuery.isNotEmpty
                  ? 'Tidak ditemukan pesan dengan kata kunci "$searchQuery"'
                  : activeFilter == 'requests'
                      ? 'Pesan dari calon pembeli produk jualan Anda akan muncul di sini.'
                      : 'Mulai kirim pesan ke teman atau penjual barang di Snapan Market.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF94A3B8),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
