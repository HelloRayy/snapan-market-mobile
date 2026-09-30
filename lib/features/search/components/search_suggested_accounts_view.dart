import 'package:flutter/material.dart';
import 'package:snapan-market/core/components/snaps_skeleton.dart';
import 'package:snapan-market/features/search/components/suggested_account_tile.dart';
import 'package:snapan-market/features/search/models/search_models.dart';

/// Renders the idle state with suggested student accounts to follow.
class SearchSuggestedAccountsView extends StatefulWidget {
  final List<SuggestedAccount> accounts;
  final bool isLoadingInitial;
  final void Function(String username, SuggestedAccount account) onNavigateToProfile;
  final ValueChanged<String> onToggleFollow;

  const SearchSuggestedAccountsView({
    super.key,
    required this.accounts,
    required this.isLoadingInitial,
    required this.onNavigateToProfile,
    required this.onToggleFollow,
  });

  @override
  State<SearchSuggestedAccountsView> createState() => _SearchSuggestedAccountsViewState();
}

class _SearchSuggestedAccountsViewState extends State<SearchSuggestedAccountsView> {
  int _visibleSuggestedCount = 5;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoadingInitial && widget.accounts.isEmpty) {
      return const SingleChildScrollView(
        child: SearchResultSkeleton(),
      );
    }

    if (widget.accounts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'Belum ada akun siswa lain terdaftar',
            style: TextStyle(
              fontSize: 14.0,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                "Saran ikuti",
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                "Rekomendasi",
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _visibleSuggestedCount.clamp(0, widget.accounts.length),
          separatorBuilder: (_, __) => const Divider(
            color: Color(0xFFF1F5F9),
            height: 1.0,
            thickness: 1.0,
          ),
          itemBuilder: (_, idx) {
            final acc = widget.accounts[idx];
            return SuggestedAccountTile(
              account: acc,
              onTap: () => widget.onNavigateToProfile(acc.username, acc),
              onFollowTap: () => widget.onToggleFollow(acc.id),
            );
          },
        ),
        if (_visibleSuggestedCount < widget.accounts.length)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _visibleSuggestedCount = (_visibleSuggestedCount + 5).clamp(0, widget.accounts.length);
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Text(
                    "Lihat saran lainnya (${widget.accounts.length - _visibleSuggestedCount})",
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1D64EC),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
