import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:snapan_market/core/models/app_version_model.dart';
import 'package:snapan_market/core/services/supabase_service.dart';

/// Service for checking app updates and querying latest releases from Supabase
class AppUpdateService {
  AppUpdateService._();
  static final AppUpdateService instance = AppUpdateService._();

  AppVersionModel? _cachedLatestUpdate;
  PackageInfo? _cachedPackageInfo;

  /// Returns package info of currently running app
  Future<PackageInfo> getPackageInfo() async {
    _cachedPackageInfo ??= await PackageInfo.fromPlatform();
    return _cachedPackageInfo!;
  }

  /// Checks if a newer version is registered in the database
  Future<AppVersionModel?> checkForUpdate() async {
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
        return latest;
      }

      return null;
    } catch (e) {
      debugPrint('Error checking app update: $e');
      return null;
    }
  }

  AppVersionModel? get cachedUpdate => _cachedLatestUpdate;
}
