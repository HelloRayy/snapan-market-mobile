import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snapan_market/core/constants/supabase_constants.dart';

class SupabaseAuthService {
  SupabaseAuthService(this._client);
  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  bool? _isAdminCache;
  String? _isAdminCachedUserId;

  /// Trigger Google OAuth flow via deep link
  Future<bool> signInWithGoogle() async {
    try {
      final success = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: '${SupabaseConstants.authCallbackUrlScheme}://login-callback',
      );
      return success;
    } catch (e) {
      debugPrint('Error signInWithGoogle: $e');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _isAdminCache = null;
      _isAdminCachedUserId = null;
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Error signOut: $e');
      rethrow;
    }
  }

  /// Check if the currently logged-in user has an admin role
  Future<bool> isCurrentUserAdmin() async {
    final user = currentUser;
    if (user == null) return false;
    if (_isAdminCachedUserId == user.id && _isAdminCache != null) {
      return _isAdminCache!;
    }

    try {
      final res = await _client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      final role = res?['role'] as String?;
      _isAdminCache = role == 'admin';
      _isAdminCachedUserId = user.id;
      return _isAdminCache!;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }
}
