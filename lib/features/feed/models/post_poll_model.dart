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
    return option.votesCount / totalVotes;
  }

  /// Formatted integer percentage (e.g. 64)
  int getPercentageInt(PostPollOptionModel option) {
    return (getPercentage(option) * 100).round();
  }

  /// Whether an option has the highest votes among all options
  bool isWinning(PostPollOptionModel option) {
    if (option.votesCount <= 0) return false;
    for (final other in options) {
      if (other.votesCount > option.votesCount) return false;
    }
    return true;
  }

  /// Human-readable remaining time string (e.g. "Berakhir dalam 18 jam" or "Polling ditutup")
  String get remainingTimeLabel {
    if (isExpired) return 'Polling ditutup';
    if (expiresAt == null) return 'Berakhir dalam 24 jam';
    final diff = expiresAt!.difference(DateTime.now());
    if (diff.isNegative) return 'Polling ditutup';

    if (diff.inDays > 0) {
      return 'Berakhir dalam ${diff.inDays} hari';
    } else if (diff.inHours > 0) {
      return 'Berakhir dalam ${diff.inHours} jam';
    } else if (diff.inMinutes > 0) {
      return 'Berakhir dalam ${diff.inMinutes} menit';
    } else {
      return 'Berakhir sebentar lagi';
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
