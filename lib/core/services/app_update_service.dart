import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapan_market/core/models/app_version_model.dart';
import 'package:snapan_market/core/services/supabase_service.dart';

/// Service for checking app updates and querying latest releases from Supabase
///
/// Features persistent cooldown management and session protection to prevent annoying repeat popups.
class AppUpdateService {
  AppUpdateService._();
  static final AppUpdateService instance = AppUpdateService._();

  static const _kDismissedCodeKey = 'app_update_dismissed_code';
  static const _kDismissedTimeKey = 'app_update_dismissed_time';

  AppVersionModel? _cachedLatestUpdate;
  PackageInfo? _cachedPackageInfo;

  bool _hasPromptedThisSession = false;

  /// Returns package info of currently running app
  Future<PackageInfo> getPackageInfo() async {
    _cachedPackageInfo ??= await PackageInfo.fromPlatform();
    return _cachedPackageInfo!;
  }

  /// Mark the update as dismissed with persistent disk cooldown (24 hours)
  Future<void> dismissUpdate(int versionCode) async {
    _hasPromptedThisSession = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kDismissedCodeKey, versionCode);
      await prefs.setInt(_kDismissedTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error saving update dismissal to SharedPreferences: $e');
    }
  }

  /// Mark that a prompt was shown in this session
  void markPrompted() {
    _hasPromptedThisSession = true;
  }

  /// Checks if a newer version is registered in the database
  ///
  /// Set [isManual] to true when user explicitly taps "Periksa pembaruan".
  Future<AppVersionModel?> checkForUpdate({bool isManual = false}) async {
    try {
      if (isManual) {
        _cachedPackageInfo = null;
      }
      final packageInfo = await getPackageInfo();
      final int currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;

      final response = await SupabaseService.instance.client
          .from('app_versions')
          .select()
          .eq('is_active', true)
          .order('version_code', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      final latest = AppVersionModel.fromJson(response);

      // Check if remote version code is strictly higher than current installed app
      if (latest.versionCode > currentBuildNumber) {
        _cachedLatestUpdate = latest;

        // If automatic check and not mandatory: respect dismissal & session limits
        if (!isManual && !latest.isMandatory) {
          if (_hasPromptedThisSession) {
            debugPrint('Update available (v${latest.versionName}) but already prompted this session.');
            return null;
          }
          try {
            final prefs = await SharedPreferences.getInstance();
            final int? dismissedCode = prefs.getInt(_kDismissedCodeKey);
            final int? dismissedTime = prefs.getInt(_kDismissedTimeKey);

            if (dismissedCode == latest.versionCode && dismissedTime != null) {
              final difference = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(dismissedTime));
              if (difference.inHours < 24) {
                debugPrint('Update v${latest.versionName} was dismissed ${difference.inHours}h ago. 24h cooldown active.');
                return null;
              }
            }
          } catch (e) {
            debugPrint('Error reading update dismissal from SharedPreferences: $e');
          }
        }

        return latest;
      }

      _cachedLatestUpdate = null;
      return null;
    } catch (e) {
      debugPrint('Error checking app update: $e');
      return null;
    }
  }

  /// Ambil info versi aktif terbaru langsung dari database Supabase
  Future<AppVersionModel?> getLatestActiveVersion() async {
    try {
      final response = await SupabaseService.instance.client
          .from('app_versions')
          .select()
          .eq('is_active', true)
          .order('version_code', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return AppVersionModel.fromJson(response);
    } catch (e) {
      debugPrint('Error getting latest active version: $e');
      return null;
    }
  }

  /// Invalidate cached package info & update state to reflect true disk/runtime state
  void clearCache() {
    _cachedLatestUpdate = null;
    _cachedPackageInfo = null;
    _hasPromptedThisSession = false;
  }

  AppVersionModel? get cachedUpdate => _cachedLatestUpdate;
  bool get hasAvailableUpdate => _cachedLatestUpdate != null;
}
