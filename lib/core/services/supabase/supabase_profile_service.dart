// ignore_for_file: use_null_aware_elements
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileService {
  SupabaseProfileService(this._client);
  final SupabaseClient _client;

  /// Broadcast notifier for the current user's profile
  final ValueNotifier<Map<String, dynamic>?> currentUserProfileNotifier =
      ValueNotifier<Map<String, dynamic>?>(null);

  /// Fetch user profile from public.profiles
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (_client.auth.currentUser?.id == userId && data != null) {
        currentUserProfileNotifier.value = data;
      }
      return data;
    } catch (e) {
      debugPrint('Error getProfile: $e');
      return null;
    }
  }

  /// Fetch user profile by username from public.profiles
  Future<Map<String, dynamic>?> getProfileByUsername(String username) async {
    try {
      final data = await _client
          .from('profiles')
          .select()
          .ilike('username', username)
          .maybeSingle();
      return data;
    } catch (e) {
      debugPrint('Error getProfileByUsername: $e');
      return null;
    }
  }

  /// Subscribe to live realtime changes for a specific user profile
  RealtimeChannel subscribeToProfile(
    String userId,
    void Function(Map<String, dynamic> newRecord) onUpdate,
  ) {
    return _client
        .channel('public:profiles:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (PostgresChangePayload payload) {
            if (payload.newRecord.isNotEmpty) {
              if (_client.auth.currentUser?.id == userId) {
                currentUserProfileNotifier.value = payload.newRecord;
              }
              onUpdate(payload.newRecord);
            }
          },
        )
        .subscribe();
  }

  /// Save or update profile completion and synchronize auth user metadata
  Future<void> updateProfile({
    required String userId,
    required String fullName,
    required String username,
    required String classGroup,
    String? nis,
    String? avatarUrl,
    String? bio,
    List<String>? tags,
    String? link,
  }) async {
    // Immediately update local profile notifier so entire app UI updates with zero delay
    final existing = currentUserProfileNotifier.value ?? {};
    currentUserProfileNotifier.value = {
      ...existing,
      'id': userId,
      'full_name': fullName,
      'username': username,
      'class_group': classGroup,
      if (nis != null && nis.isNotEmpty) 'nis': nis,
      if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
      if (bio != null) 'bio': bio,
      if (tags != null) 'interests': tags.join(','),
      if (link != null) 'link': link,
    };
    // 1. Update Supabase Auth user metadata so session & currentUser stay in sync
    try {
      await _client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': fullName,
            'username': username,
            'class_group': classGroup,
            if (nis != null && nis.isNotEmpty) 'nis': nis,
            if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
            if (bio != null) 'bio': bio,
            if (tags != null) 'tags': tags,
            if (link != null) 'link': link,
          },
        ),
      );
    } catch (authErr) {
      debugPrint('Warning: updateUser metadata failed: $authErr');
    }

    // 2. Prepare payload for public.profiles table
    final fullPayload = <String, dynamic>{
      'full_name': fullName,
      'username': username,
      'class_group': classGroup,
      if (nis != null && nis.isNotEmpty) 'nis': nis,
      if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
      if (bio != null) 'bio': bio,
      if (link != null) 'link': link,
      if (tags != null) 'interests': tags.join(','),
    };

    final corePayload = <String, dynamic>{
      'full_name': fullName,
      'username': username,
      'class_group': classGroup,
      if (nis != null && nis.isNotEmpty) 'nis': nis,
      if (avatarUrl != null && avatarUrl.isNotEmpty) 'avatar_url': avatarUrl,
    };

    // 3. Update public.profiles table (try full payload first, fallback to core payload if columns don't exist)
    try {
      await _client.from('profiles').update(fullPayload).eq('id', userId);
    } catch (e) {
      debugPrint('updateProfile full payload update failed, retrying core payload: $e');
      try {
        await _client.from('profiles').update(corePayload).eq('id', userId);
      } catch (coreErr) {
        debugPrint('Warning updateProfile core update failed: $coreErr');
        final fallbackPayload = {
          'id': userId,
          ...corePayload,
        };
        await _client.from('profiles').upsert(fallbackPayload).catchError((err) {
          debugPrint('Warning updateProfile upsert fallback failed: $err');
        });
      }
    }
  }

  /// Fetch user profile by NIS from public.profiles
  Future<Map<String, dynamic>?> getProfileByNis(String nis) async {
    try {
      final clean = nis.trim();
      if (clean.isEmpty) return null;
      final data = await _client
          .from('profiles')
          .select()
          .eq('nis', clean)
          .maybeSingle();
      return data;
    } catch (e) {
      debugPrint('Error getProfileByNis: $e');
      return null;
    }
  }

  /// Check if an NIS has already been claimed by a registered user
  Future<bool> isNisClaimed(String nis) async {
    try {
      final clean = nis.trim();
      if (clean.isEmpty) return false;
      final res = await _client
          .from('profiles')
          .select('id')
          .eq('nis', clean)
          .maybeSingle();
      return res != null;
    } catch (e) {
      debugPrint('Error isNisClaimed: $e');
      return false;
    }
  }

  /// Check if a username is already taken by another account
  Future<bool> isUsernameTaken(String username) async {
    try {
      final clean = username.toLowerCase().replaceAll('@', '').trim();
      final res = await _client
          .from('profiles')
          .select('id')
          .eq('username', clean)
          .maybeSingle();
      return res != null;
    } catch (e) {
      debugPrint('Error isUsernameTaken: $e');
      return false;
    }
  }

  /// Search user profiles by name or username
  Future<List<Map<String, dynamic>>> searchProfiles(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final clean = query.trim();
      final response = await _client
          .from('profiles')
          .select()
          .or('full_name.ilike.%$clean%,username.ilike.%$clean%')
          .limit(20);

      return (response as List<dynamic>).whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error searchProfiles: $e');
      return [];
    }
  }

  /// Fetch suggested registered student profiles (excluding self)
  Future<List<Map<String, dynamic>>> fetchSuggestedProfiles({int limit = 15}) async {
    try {
      final currentUserId = _client.auth.currentUser?.id;
      var query = _client.from('profiles').select().order('created_at', ascending: false).limit(limit);
      if (currentUserId != null) {
        query = _client.from('profiles').select().neq('id', currentUserId).order('created_at', ascending: false).limit(limit);
      }
      final response = await query;
      return (response as List<dynamic>).whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error fetchSuggestedProfiles: $e');
      return [];
    }
  }
}
