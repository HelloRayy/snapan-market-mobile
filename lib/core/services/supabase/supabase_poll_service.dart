import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/features/feed/models/post_poll_model.dart';

/// Dedicated service for poll voting and management in Supabase
class SupabasePollService {
  SupabasePollService(this._client);
  final SupabaseClient _client;

  User? get _currentUser => _client.auth.currentUser;

  /// Cast or update a vote on a poll
  Future<PostPollModel> votePoll({
    required String postId,
    required List<String> optionIds,
  }) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Anda harus masuk untuk memberikan suara.');
    }

    try {
      final response = await _client.rpc('vote_poll', params: {
        'p_post_id': postId,
        'p_option_ids': optionIds,
      });

      return PostPollModel.fromJson(
        Map<String, dynamic>.from(response as Map),
        userVotedOptionIds: optionIds,
      );
    } catch (e) {
      debugPrint('Error votePoll: $e');
      rethrow;
    }
  }

  /// Close a poll prematurely (only by post creator or admin)
  Future<PostPollModel> closePoll(String postId) async {
    final user = _currentUser;
    if (user == null) {
      throw Exception('Anda harus masuk untuk menutup polling.');
    }

    try {
      final response = await _client.rpc('close_poll', params: {
        'p_post_id': postId,
      });

      return PostPollModel.fromJson(Map<String, dynamic>.from(response as Map));
    } catch (e) {
      debugPrint('Error closePoll: $e');
      rethrow;
    }
  }

  /// Fetch all poll votes cast by current user, mapped by post_id
  Future<Map<String, List<String>>> fetchUserPollVotes() async {
    final user = _currentUser;
    if (user == null) return {};

    try {
      final response = await _client
          .from('post_poll_votes')
          .select('post_id, option_id')
          .eq('user_id', user.id);

      final Map<String, List<String>> result = {};
      if (response is List) {
        for (final row in response) {
          final pid = row['post_id']?.toString();
          final oid = row['option_id']?.toString();
          if (pid != null && oid != null) {
            result.putIfAbsent(pid, () => []).add(oid);
          }
        }
      }
      return result;
    } catch (e) {
      debugPrint('Error fetchUserPollVotes: $e');
      return {};
    }
  }
}
