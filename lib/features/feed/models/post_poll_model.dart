import 'package:flutter/foundation.dart';

/// Single option within a community thread poll
@immutable
class PostPollOptionModel {
  final String id;
  final String text;
  final int votesCount;

  const PostPollOptionModel({
    required this.id,
    required this.text,
    this.votesCount = 0,
  });

  factory PostPollOptionModel.fromJson(Map<String, dynamic> json) {
    return PostPollOptionModel(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      votesCount: json['votes_count'] as int? ?? (json['votesCount'] as int? ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'votes_count': votesCount,
  };

  PostPollOptionModel copyWith({
    String? id,
    String? text,
    int? votesCount,
  }) {
    return PostPollOptionModel(
      id: id ?? this.id,
      text: text ?? this.text,
      votesCount: votesCount ?? this.votesCount,
    );
  }
}

/// Threads-style interactive poll model embedded within a post
@immutable
class PostPollModel {
  final String id;
  final List<PostPollOptionModel> options;
  final int totalVotes;
  final bool isMultipleChoice;
  final bool allowChangeVote;
  final DateTime? expiresAt;
  final bool isClosed;
  final List<String> userVotedOptionIds;

  const PostPollModel({
    required this.id,
    required this.options,
    this.totalVotes = 0,
    this.isMultipleChoice = false,
    this.allowChangeVote = true,
    this.expiresAt,
    this.isClosed = false,
    this.userVotedOptionIds = const [],
  });

  /// Check if poll deadline has passed or poll was manually closed
  bool get isExpired {
    if (isClosed) return true;
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Whether current logged in user has voted in this poll
  bool get hasVoted => userVotedOptionIds.isNotEmpty;

  /// Calculate percentage of votes for an option (0.0 to 1.0)
  double getPercentage(PostPollOptionModel option) {
    if (totalVotes <= 0) return 0.0;
    return (option.votesCount / totalVotes).clamp(0.0, 1.0);
  }

  /// Formatted integer percentages mapped by option ID using Largest Remainder Method (Hare-Niemeyer)
  /// ensuring the sum of all percentages always equals exactly 100% when totalVotes > 0.
  Map<String, int> get calculatedPercentageMap {
    if (totalVotes <= 0 || options.isEmpty) {
      return {for (final opt in options) opt.id: 0};
    }

    final Map<String, int> floorPercentages = {};
    final List<MapEntry<String, double>> remainders = [];
    int sumFloors = 0;

    for (final opt in options) {
      final exact = (opt.votesCount / totalVotes) * 100.0;
      final floorVal = exact.floor();
      floorPercentages[opt.id] = floorVal;
      remainders.add(MapEntry(opt.id, exact - floorVal));
      sumFloors += floorVal;
    }

    int remainingVotesToDistribute = 100 - sumFloors;
    // Sort remainders descending
    remainders.sort((a, b) => b.value.compareTo(a.value));

    for (int i = 0; i < remainingVotesToDistribute && i < remainders.length; i++) {
      final optId = remainders[i].key;
      floorPercentages[optId] = (floorPercentages[optId] ?? 0) + 1;
    }

    return floorPercentages;
  }

  /// Formatted integer percentage (e.g. 64) with sum-to-100% guarantee
  int getPercentageInt(PostPollOptionModel option) {
    return calculatedPercentageMap[option.id] ?? 0;
  }

  /// Returns a new PostPollModel with the user's optimistic vote applied
  PostPollModel applyOptimisticVotes(List<String> newVotedOptionIds) {
    if (isExpired) return this;
    if (hasVoted && !allowChangeVote) return this;

    final prevVotes = userVotedOptionIds;
    if (setEquals(prevVotes.toSet(), newVotedOptionIds.toSet())) {
      return this;
    }

    final updatedOptions = options.map((opt) {
      int count = opt.votesCount;
      if (prevVotes.contains(opt.id) && !newVotedOptionIds.contains(opt.id)) {
        count = (count - 1).clamp(0, 999999);
      } else if (!prevVotes.contains(opt.id) && newVotedOptionIds.contains(opt.id)) {
        count += 1;
      }
      return opt.copyWith(votesCount: count);
    }).toList();

    int total = updatedOptions.fold(0, (sum, opt) => sum + opt.votesCount);

    return copyWith(
      options: updatedOptions,
      totalVotes: total,
      userVotedOptionIds: newVotedOptionIds,
    );
  }

  /// Whether an option has the highest votes among all options
  bool isWinning(PostPollOptionModel option) {
    if (option.votesCount <= 0) return false;
    for (final other in options) {
      if (other.votesCount > option.votesCount) return false;
    }
    return true;
  }

  /// Human-readable remaining time string (e.g. "23 jam lagi" or "Polling ditutup")
  String get remainingTimeLabel {
    if (isExpired) return 'Polling ditutup';
    if (expiresAt == null) return '24 jam lagi';
    final diff = expiresAt!.difference(DateTime.now());
    if (diff.isNegative) return 'Polling ditutup';

    if (diff.inDays > 0) {
      return '${diff.inDays} hari lagi';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} jam lagi';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} menit lagi';
    } else {
      return 'Sebentar lagi';
    }
  }

  factory PostPollModel.fromJson(
    Map<String, dynamic> json, {
    List<String> userVotedOptionIds = const [],
  }) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    final parsedOptions = rawOptions
        .map((e) => PostPollOptionModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    DateTime? expires;
    if (json['expires_at'] != null) {
      expires = DateTime.tryParse(json['expires_at'].toString())?.toLocal();
    } else if (json['expiresAt'] != null) {
      expires = DateTime.tryParse(json['expiresAt'].toString())?.toLocal();
    }

    return PostPollModel(
      id: json['id'] as String? ?? 'poll-${DateTime.now().millisecondsSinceEpoch}',
      options: parsedOptions,
      totalVotes: json['total_votes'] as int? ?? (json['totalVotes'] as int? ?? 0),
      isMultipleChoice: json['is_multiple_choice'] as bool? ?? (json['isMultipleChoice'] as bool? ?? false),
      allowChangeVote: json['allow_change_vote'] as bool? ?? (json['allowChangeVote'] as bool? ?? true),
      expiresAt: expires,
      isClosed: json['is_closed'] as bool? ?? (json['isClosed'] as bool? ?? false),
      userVotedOptionIds: userVotedOptionIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'options': options.map((e) => e.toJson()).toList(),
    'total_votes': totalVotes,
    'is_multiple_choice': isMultipleChoice,
    'allow_change_vote': allowChangeVote,
    if (expiresAt != null) 'expires_at': expiresAt!.toUtc().toIso8601String(),
    'is_closed': isClosed,
  };

  PostPollModel copyWith({
    String? id,
    List<PostPollOptionModel>? options,
    int? totalVotes,
    bool? isMultipleChoice,
    bool? allowChangeVote,
    DateTime? expiresAt,
    bool? isClosed,
    List<String>? userVotedOptionIds,
  }) {
    return PostPollModel(
      id: id ?? this.id,
      options: options ?? this.options,
      totalVotes: totalVotes ?? this.totalVotes,
      isMultipleChoice: isMultipleChoice ?? this.isMultipleChoice,
      allowChangeVote: allowChangeVote ?? this.allowChangeVote,
      expiresAt: expiresAt ?? this.expiresAt,
      isClosed: isClosed ?? this.isClosed,
      userVotedOptionIds: userVotedOptionIds ?? this.userVotedOptionIds,
    );
  }
}
