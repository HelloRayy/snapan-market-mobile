import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/auth/screens/auth_screen.dart';
import 'package:snapan_market/features/feed/components/post_card/post_poll_option_tile.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';
import 'package:snapan_market/features/feed/models/post_poll_model.dart';

/// Interactive Threads-Style Poll Section (<160 lines)
class PostPollSection extends StatefulWidget {
  final MarketPostModel post;
  final void Function(MarketPostModel post, List<String> optionIds)? onVote;

  const PostPollSection({
    super.key,
    required this.post,
    this.onVote,
  });

  @override
  State<PostPollSection> createState() => _PostPollSectionState();
}

class _PostPollSectionState extends State<PostPollSection> {
  final Set<String> _selectedOptionIds = {};
  bool _isChangingVote = false;

  PostPollModel? get _poll => widget.post.poll;

  void _handleOptionTap(PostPollOptionModel option) {
    HapticFeedback.lightImpact();
    if (!SupabaseService.instance.isAuthenticated) {
      _promptLogin();
      return;
    }

    final poll = _poll;
    if (poll == null || poll.isExpired) return;

    if (poll.isMultipleChoice) {
      setState(() {
        if (_selectedOptionIds.contains(option.id)) {
          _selectedOptionIds.remove(option.id);
        } else {
          _selectedOptionIds.add(option.id);
        }
      });
    } else {
      _submitVote([option.id]);
    }
  }

  void _submitVote(List<String> optionIds) {
    if (optionIds.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isChangingVote = false;
      _selectedOptionIds.clear();
    });
    if (widget.onVote != null) {
      widget.onVote!(widget.post, optionIds);
    } else {
      SupabaseService.instance.votePoll(postId: widget.post.id, optionIds: optionIds);
    }
  }

  void _promptLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Silakan masuk untuk mengikuti polling'),
        action: SnackBarAction(
          label: 'Masuk',
          textColor: Colors.amberAccent,
          onPressed: () {
            Navigator.push(
              context,
              AppSlidePageRoute(
                builder: (navCtx) => AuthScreen(
                  onBack: () => Navigator.pop(navCtx),
                  onSuccess: () => Navigator.pop(navCtx),
                ),
              ),
            );
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final poll = _poll;
    if (poll == null || poll.options.isEmpty) return const SizedBox.shrink();

    final showResults = (poll.hasVoted || poll.isExpired) && !_isChangingVote;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...poll.options.map((opt) {
            return PostPollOptionTile(
              poll: poll,
              option: opt,
              showResults: showResults,
              isSelected: _selectedOptionIds.contains(opt.id),
              onTap: () => _handleOptionTap(opt),
            );
          }),
          if (!showResults && poll.isMultipleChoice) ...[
            const SizedBox(height: 6.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _selectedOptionIds.isNotEmpty
                      ? () => _submitVote(_selectedOptionIds.toList())
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.cloudGray,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: Text(
                    'Kirim Suara (${_selectedOptionIds.length})',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
                if (_isChangingVote) ...[
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: () => setState(() => _isChangingVote = false),
                    child: const Text('Batal', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 6.0),
          _buildFooter(poll, showResults),
        ],
      ),
    );
  }

  Widget _buildFooter(PostPollModel poll, bool showResults) {
    final subInfo = '${poll.totalVotes} suara • ${poll.remainingTimeLabel}${poll.isMultipleChoice ? ' • Pilihan ganda' : ''}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            subInfo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), letterSpacing: -0.1),
          ),
        ),
        if (showResults && poll.allowChangeVote && !poll.isExpired && poll.hasVoted) ...[
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isChangingVote = true;
                _selectedOptionIds.clear();
                _selectedOptionIds.addAll(poll.userVotedOptionIds);
              });
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
              child: Text(
                'Ubah pilihan',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
