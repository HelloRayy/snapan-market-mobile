import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:snapan_market/core/models/app_version_model.dart';
import 'package:snapan_market/core/services/supabase_service.dart';

/// Service for checking app updates and querying latest releases from Supabase
///
/// Features cooldown management and session protection to prevent annoying repeat popups.
class AppUpdateService {
  AppUpdateService._();
  static final AppUpdateService instance = AppUpdateService._();

  AppVersionModel? _cachedLatestUpdate;
  PackageInfo? _cachedPackageInfo;

  bool _hasPromptedThisSession = false;
  int? _dismissedVersionCode;
  DateTime? _dismissedTimestamp;

  /// Returns package info of currently running app
  Future<PackageInfo> getPackageInfo() async {
    _cachedPackageInfo ??= await PackageInfo.fromPlatform();
    return _cachedPackageInfo!;
  }

  /// Mark the update as dismissed for this session/cooldown
  void dismissUpdate(int versionCode) {
    _dismissedVersionCode = versionCode;
    _dismissedTimestamp = DateTime.now();
    _hasPromptedThisSession = true;
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
          if (_dismissedVersionCode == latest.versionCode && _dismissedTimestamp != null) {
            final difference = DateTime.now().difference(_dismissedTimestamp!);
            if (difference.inHours < 12) {
              debugPrint('Update v${latest.versionName} was dismissed ${difference.inHours}h ago. Cooldown active.');
              return null;
            }
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

  AppVersionModel? get cachedUpdate => _cachedLatestUpdate;
  bool get hasAvailableUpdate => _cachedLatestUpdate != null;
}
