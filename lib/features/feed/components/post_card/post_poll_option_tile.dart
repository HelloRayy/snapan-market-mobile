import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:snapan_market/core/theme/app_colors.dart';
import 'package:snapan_market/features/feed/models/post_poll_model.dart';

/// Single Option Tile for Poll (Vote Button or Animated Result Bar) (<150 lines)
class PostPollOptionTile extends StatelessWidget {
  final PostPollModel poll;
  final PostPollOptionModel option;
  final bool showResults;
  final bool isSelected;
  final VoidCallback onTap;

  const PostPollOptionTile({
    super.key,
    required this.poll,
    required this.option,
    required this.showResults,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7.0),
      child: showResults ? _buildResultBar(context) : _buildVoteButton(context),
    );
  }

  Widget _buildVoteButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkSurface : Colors.white;
    final defaultBorder = isDark ? const Color(0x1AFFFFFF) : const Color(0xFFCBD5E1);
    final textColor = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        height: 44.0,
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : defaultBg,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? AppColors.primary : defaultBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                option.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: textColor,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = poll.getPercentage(option);
    final percentageInt = poll.getPercentageInt(option);
    final isWinning = poll.isWinning(option);
    final isUserPick = poll.userVotedOptionIds.contains(option.id);
    final canVote = !poll.isExpired && poll.allowChangeVote;

    final barBg = isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC);
    final barBorder = isUserPick
        ? AppColors.primary.withValues(alpha: 0.4)
        : (isDark ? const Color(0x1AFFFFFF) : const Color(0xFFE2E8F0));
    final barFillColor = isWinning
        ? AppColors.primary.withValues(alpha: isDark ? 0.28 : 0.18)
        : (isUserPick
            ? AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.10)
            : (isDark ? const Color(0x26FFFFFF) : const Color(0xFFE2E8F0).withValues(alpha: 0.7)));

    final textColor = isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A);
    final percentageColor = isWinning
        ? AppColors.primary
        : (isDark ? AppColors.darkTextSecondary : const Color(0xFF475569));

    return InkWell(
      onTap: canVote ? onTap : null,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        height: 44.0,
        decoration: BoxDecoration(
          color: barBg,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: barBorder,
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: percentage),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, _) {
                      return Container(
                        width: constraints.maxWidth * val,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: barFillColor,
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (isUserPick) ...[
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 16.0,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8.0),
                              ],
                              Flexible(
                                child: Text(
                                  option.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'SFPro',
                                    fontSize: 13.5,
                                    fontWeight: isWinning ? FontWeight.w700 : FontWeight.w500,
                                    color: textColor,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          '$percentageInt%',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: isWinning ? FontWeight.w700 : FontWeight.w600,
                            color: percentageColor,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
