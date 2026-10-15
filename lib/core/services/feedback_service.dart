import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:snapan_market/core/services/media_upload_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service responsible for gathering device diagnostics, uploading feedback screenshots,
/// and storing bug reports/feature suggestions in the Supabase `app_feedbacks` table.
class FeedbackService {
  FeedbackService._();
  static final FeedbackService instance = FeedbackService._();

  static const String adminWhatsAppNumber = '6281234567890';

  /// Prepares metadata snapshot (app version, build number, OS)
  Future<Map<String, dynamic>> getAppDiagnostics() async {
    String version = '1.0.30';
    String buildNumber = '33';
    try {
      final info = await PackageInfo.fromPlatform();
      version = info.version;
      buildNumber = info.buildNumber;
    } catch (e) {
      debugPrint('Error getting package info: $e');
    }

    final platformName = kIsWeb
        ? 'Web'
        : Platform.isAndroid
            ? 'Android'
            : Platform.isIOS
                ? 'iOS'
                : Platform.operatingSystem;

    return {
      'app_version': 'v$version+$buildNumber',
      'platform': platformName,
      'is_web': kIsWeb,
    };
  }

  /// Submit feedback report to Supabase
  Future<bool> submitFeedback({
    required String category,
    required String description,
    String? customTopic,
    XFile? screenshotFile,
  }) async {
    try {
      String? screenshotUrl;
      if (screenshotFile != null) {
        screenshotUrl = await MediaUploadService.instance.uploadXFile(
          screenshotFile,
          bucket: 'feedback_attachments',
        );
      }

      final diagnostics = await getAppDiagnostics();
      final currentUserId = SupabaseService.instance.currentUser?.id;
      final profile = SupabaseService.instance.currentUserProfileNotifier.value;

      final Map<String, dynamic> payload = {
        'category': category,
        'description': description.trim(),
        'app_version': diagnostics['app_version'],
        'device_info': {
          'platform': diagnostics['platform'],
          'user_role': profile?['role'] ?? 'guest',
          'user_nis': profile?['nis'],
          'user_name': profile?['display_name'] ?? profile?['username'],
          'submitted_at': DateTime.now().toIso8601String(),
        },
      };

      if (customTopic != null && customTopic.trim().isNotEmpty) {
        payload['custom_topic'] = customTopic.trim();
      }

      if (screenshotUrl != null && screenshotUrl.isNotEmpty) {
        payload['screenshot_url'] = screenshotUrl;
      }

      if (currentUserId != null) {
        payload['user_id'] = currentUserId;
      }

      await SupabaseService.instance.client
          .from('app_feedbacks')
          .insert(payload);

      return true;
    } catch (e) {
      debugPrint('Error submitFeedback: $e');
      return false;
    }
  }

  /// Launch WhatsApp with prefilled issue description
  Future<void> launchWhatsAppAdmin({
    String? category,
    String? customTopic,
    String? description,
  }) async {
    try {
      final diagnostics = await getAppDiagnostics();
      final appVer = diagnostics['app_version'] ?? 'v1.0.30';
      final platform = diagnostics['platform'] ?? 'Mobile';
      final profile = SupabaseService.instance.currentUserProfileNotifier.value;
      final studentName = profile?['display_name'] ?? profile?['username'] ?? '';
      final studentNis = profile?['nis'] ?? '-';
      final studentInfo = profile != null ? ' ($studentName / NIS $studentNis)' : '';

      final buffer = StringBuffer('Halo Admin Snaps Mobile, saya ingin melaporkan kendala:$studentInfo\n\n');
      buffer.writeln('• Versi: $appVer ($platform)');
      if (category != null && category.isNotEmpty) {
        buffer.writeln('• Kategori: $category');
      }
      if (customTopic != null && customTopic.isNotEmpty) {
        buffer.writeln('• Topik: $customTopic');
      }
      if (description != null && description.isNotEmpty) {
        buffer.writeln('• Rincian: $description');
      }

      final encodedText = Uri.encodeComponent(buffer.toString());
      final uri = Uri.parse('https://wa.me/$adminWhatsAppNumber?text=$encodedText');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }
}
