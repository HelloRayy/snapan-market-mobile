import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:snapan_market/core/navigation/app_slide_page_route.dart';
import 'package:snapan_market/core/services/poll_sync_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/features/auth/screens/auth_screen.dart';
import 'package:snapan_market/features/feed/components/post_card/post_poll_option_tile.dart';
import 'package:snapan_market/features/feed/models/market_post_model.dart';

/// Minimalist Threads-Style Poll Section (<120 lines)
class PostPollSection extends StatelessWidget {
  final MarketPostModel post;
  final void Function(MarketPostModel post, List<String> optionIds)? onVote;

  const PostPollSection({
    super.key,
    required this.post,
    this.onVote,
  });

  PostPollModel? get _poll => post.poll;

  void _handleOptionTap(BuildContext context, PostPollOptionModel option) {
    if (!SupabaseService.instance.isAuthenticated) {
      HapticFeedback.lightImpact();
      _promptLogin(context);
      return;
    }

    final poll = _poll;
    if (poll == null || poll.isExpired) return;
    if (poll.hasVoted && !poll.allowChangeVote) return;

    if (!poll.userVotedOptionIds.contains(option.id)) {
      if (poll.hasVoted) {
        HapticFeedback.selectionClick();
      } else {
        HapticFeedback.mediumImpact();
      }
      _submitVote([option.id]);
    }
  }

  void _submitVote(List<String> optionIds) {
    if (optionIds.isEmpty) return;
    if (onVote != null) {
      onVote!(post, optionIds);
    } else if (post.poll != null) {
      PollSyncService.instance.castVote(
        postId: post.id,
        optionIds: optionIds,
        currentPoll: post.poll!,
        remoteCaller: (pId, oIds) => SupabaseService.instance.votePoll(
          postId: pId,
          optionIds: oIds,
        ),
      );
    }
  }

  void _promptLogin(BuildContext context) {
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

    final showResults = poll.hasVoted || poll.isExpired;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...poll.options.map((opt) {
            return PostPollOptionTile(
              poll: poll,
              option: opt,
              showResults: showResults,
              isSelected: poll.userVotedOptionIds.contains(opt.id),
              onTap: () => _handleOptionTap(context, opt),
            );
          }),
          const SizedBox(height: 4.0),
          _buildFooter(poll),
        ],
      ),
    );
  }

  Widget _buildFooter(PostPollModel poll) {
    final hasLocation = post.locationTag != null && post.locationTag!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasLocation) ...[
            Flexible(
              child: Text(
                post.locationTag!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                  letterSpacing: -0.1,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
          ] else
            const SizedBox.shrink(),
          Flexible(
            child: Text(
              '${poll.totalVotes} suara • ${poll.remainingTimeLabel}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: hasLocation ? TextAlign.end : TextAlign.start,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
