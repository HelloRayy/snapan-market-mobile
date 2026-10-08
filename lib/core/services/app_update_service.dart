import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
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
      final int rawCurrentBuild = int.tryParse(packageInfo.buildNumber) ?? 1;
      // Normalisasi build number jika APK berasal dari split-per-abi (e.g. 2021 -> 21, 1021 -> 21)
      final int currentBuildNumber = rawCurrentBuild >= 1000 ? (rawCurrentBuild % 1000) : rawCurrentBuild;

      final response = await SupabaseService.instance.client
          .from('app_versions')
          .select()
          .eq('is_active', true)
          .order('version_code', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      final latest = AppVersionModel.fromJson(response);
      final int remoteBuildNumber = latest.versionCode >= 1000 ? (latest.versionCode % 1000) : latest.versionCode;

      final bool hasNewerBuild = remoteBuildNumber > currentBuildNumber;
      final bool hasNewerVersion = _isVersionHigher(latest.versionName, packageInfo.version);

      // Check if remote version is strictly higher than current installed app
      if (hasNewerBuild || hasNewerVersion || latest.versionCode > rawCurrentBuild) {
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

  /// Memeriksa apakah semantic version [remote] lebih tinggi dari [local] (misal '1.0.21' > '1.0.19')
  static bool _isVersionHigher(String remote, String local) {
    try {
      final remoteParts = remote.replaceAll(RegExp(r'[^0-9.]'), '').split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final localParts = local.replaceAll(RegExp(r'[^0-9.]'), '').split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final maxLength = remoteParts.length > localParts.length ? remoteParts.length : localParts.length;
      for (int i = 0; i < maxLength; i++) {
        final r = i < remoteParts.length ? remoteParts[i] : 0;
        final l = i < localParts.length ? localParts[i] : 0;
        if (r > l) return true;
        if (r < l) return false;
      }
    } catch (_) {}
    return false;
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

  /// Safely cleans up obsolete OTA APK installer files to free up disk space (SNAPS-36).
  Future<void> cleanObsoleteInstallers() async {
    try {
      final List<Directory> targetDirs = [];

      // 1. Files directory (where ota_update stores /files/ota_update/*.apk)
      try {
        final filesDir = await getApplicationSupportDirectory();
        targetDirs.add(filesDir);
        final otaDir = Directory('${filesDir.path}/ota_update');
        if (await otaDir.exists()) {
          targetDirs.add(otaDir);
        }
      } catch (e) {
        debugPrint('[AppUpdateService] Error locating support dir: $e');
      }

      // 2. Cache directory
      try {
        final cacheDir = await getTemporaryDirectory();
        targetDirs.add(cacheDir);
        final cacheOtaDir = Directory('${cacheDir.path}/ota_update');
        if (await cacheOtaDir.exists()) {
          targetDirs.add(cacheOtaDir);
        }
      } catch (_) {}

      // 3. External storage directory if present on Android
      try {
        final extDir = await getExternalStorageDirectory();
        if (extDir != null) {
          targetDirs.add(extDir);
          final extOtaDir = Directory('${extDir.path}/ota_update');
          if (await extOtaDir.exists()) {
            targetDirs.add(extOtaDir);
          }
        }
      } catch (_) {}

      int deletedCount = 0;
      int reclaimedBytes = 0;

      for (final dir in targetDirs) {
        if (!await dir.exists()) continue;
        try {
          final entities = dir.listSync();
          for (final entity in entities) {
            if (entity is File && entity.path.toLowerCase().endsWith('.apk')) {
              try {
                final size = await entity.length();
                await entity.delete();
                deletedCount++;
                reclaimedBytes += size;
                debugPrint('[AppUpdateService] Deleted stale APK: ${entity.path} (${(size / (1024 * 1024)).toStringAsFixed(1)} MB)');
              } catch (e) {
                debugPrint('[AppUpdateService] Could not delete ${entity.path}: $e');
              }
            }
          }
        } catch (e) {
          debugPrint('[AppUpdateService] Error scanning directory ${dir.path}: $e');
        }
      }

      if (deletedCount > 0) {
        debugPrint('[AppUpdateService] Cleaned up $deletedCount installer APK(s). Total reclaimed: ${(reclaimedBytes / (1024 * 1024)).toStringAsFixed(1)} MB');
      }
    } catch (e) {
      debugPrint('[AppUpdateService] Failed to clean obsolete installers: $e');
    }
  }

  AppVersionModel? get cachedUpdate => _cachedLatestUpdate;
  bool get hasAvailableUpdate => _cachedLatestUpdate != null;
}
