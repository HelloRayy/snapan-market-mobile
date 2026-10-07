import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/navigation/navigation_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';

/// Centralized Suspension Orchestrator (SNAPS-16)
///
/// Responsibilities:
/// 1. Realtime listener on `public:profiles:{userId}`
/// 2. Instant verification on critical user actions (change tab, comment, post, buy, etc.)
/// 3. Immediate state broadcasting and modal/screen tear-down back to Login / AuthScreen with suspension reason
class SuspensionService {
  SuspensionService._();
  static final SuspensionService instance = SuspensionService._();

  RealtimeChannel? _profileChannel;
  StreamSubscription<AuthState>? _authSub;

  final ValueNotifier<Map<String, dynamic>?> suspensionNotifier =
      ValueNotifier<Map<String, dynamic>?>(null);
  final ValueNotifier<bool> accountDeletedNotifier = ValueNotifier<bool>(false);

  bool get isSuspended => suspensionNotifier.value != null;
  bool get isAccountDeleted => accountDeletedNotifier.value;

  /// Initialize suspension watchers and auth state subscription
  void init() {
    _authSub?.cancel();
    _authSub = SupabaseService.instance.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user ?? SupabaseService.instance.currentUser;
      if (user != null) {
        _subscribeToProfile(user.id);
        checkStatus();
      } else {
        _unsubscribe();
      }
    });

    final currentUser = SupabaseService.instance.currentUser;
    if (currentUser != null) {
      _subscribeToProfile(currentUser.id);
      checkStatus();
    }
  }

  void _subscribeToProfile(String userId) {
    if (_profileChannel != null) return;

    _profileChannel = SupabaseService.instance.client
        .channel('public:profiles_suspension:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: userId,
          ),
          callback: (payload) {
            if (payload.eventType == PostgresChangeEvent.delete) {
              handleDeletedAccountTriggered();
              return;
            }
            final record = payload.newRecord;
            if (record.isNotEmpty && record['is_suspended'] == true) {
              handleSuspensionTriggered(record);
            }
          },
        )
        .subscribe();
  }

  void _unsubscribe() {
    _profileChannel?.unsubscribe();
    _profileChannel = null;
  }

  /// Perform active health & suspension check against Supabase
  Future<bool> checkStatus() async {
    try {
      final health = await SupabaseService.instance.auth.checkCurrentUserAccountHealth();
      if (health == null) return false;

      final status = health['status'] as String?;
      if (status == 'deleted') {
        await handleDeletedAccountTriggered();
        return true;
      } else if (status == 'suspended') {
        final data = health['data'] as Map<String, dynamic>? ?? {};
        await handleSuspensionTriggered(data);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checkStatus: $e');
      return false;
    }
  }

  /// Handles account deletion triggered when a user session exists but profile is gone
  Future<void> handleDeletedAccountTriggered() async {
    _unsubscribe();

    try {
      await SupabaseService.instance.signOut();
    } catch (_) {}

    HapticFeedback.heavyImpact();
    NavigationService.popToRoot();

    accountDeletedNotifier.value = true;
  }

  /// Handles suspension triggered either by Realtime event or direct query check
  Future<void> handleSuspensionTriggered(Map<String, dynamic> status) async {
    final reason = status['suspend_reason'] as String? ??
        'Pelanggaran terhadap tata tertib komunitas SMKN 8 Semarang.';
    final untilStr = status['suspended_until'] as String?;
    final until = untilStr != null ? DateTime.tryParse(untilStr) : null;
    final untilFormatted = until == null
        ? 'Permanen (Tanpa Batas Waktu)'
        : 'Berlaku hingga ${until.day}/${until.month}/${until.year} ${until.hour.toString().padLeft(2, '0')}:${until.minute.toString().padLeft(2, '0')} WIB';

    // 1. Unsubscribe immediately to prevent looping
    _unsubscribe();

    // 2. Sign out active session
    try {
      await SupabaseService.instance.signOut();
    } catch (_) {}

    // 3. Tactile alert & pop all active dialogs/modals/subpages back to root
    HapticFeedback.heavyImpact();
    NavigationService.popToRoot();

    // 4. Update notifier state so UI switches immediately to AuthScreen with Suspension Banner
    suspensionNotifier.value = {
      'reason': reason,
      'untilText': untilFormatted,
    };
  }

  /// Clears suspension state (e.g. after user dismisses or logs out)
  void clear() {
    suspensionNotifier.value = null;
  }

  /// Clears account deleted notice state
  void clearAccountDeleted() {
    accountDeletedNotifier.value = false;
  }

  void dispose() {
    _unsubscribe();
    _authSub?.cancel();
    suspensionNotifier.dispose();
    accountDeletedNotifier.dispose();
  }
}
