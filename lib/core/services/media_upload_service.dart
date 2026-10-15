import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapan_market/core/services/supabase_service.dart';

/// Service for picking and uploading media files to Supabase Storage
/// with built-in automatic downscaling (960p) and compression (quality 70%)
/// to minimize bandwidth and storage consumption.
class MediaUploadService {
  MediaUploadService._();
  static final MediaUploadService instance = MediaUploadService._();

  final ImagePicker _picker = ImagePicker();

  /// Pick multiple images from gallery with automatic compression (960p, quality 70)
  Future<List<XFile>> pickMultiImages({
    int maxWidth = 960,
    int maxHeight = 960,
    int imageQuality = 70,
    int limit = 5,
  }) async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );
      if (picked.length > limit) {
        return picked.sublist(0, limit);
      }
      return picked;
    } catch (e) {
      debugPrint('Error picking multi images: $e');
      return [];
    }
  }

  /// Pick a single image from camera or gallery (960p, quality 70)
  Future<XFile?> pickSingleImage({
    ImageSource source = ImageSource.gallery,
    int maxWidth = 960,
    int maxHeight = 960,
    int imageQuality = 70,
  }) async {
    try {
      return await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Upload an XFile directly to Supabase Storage and return its public URL
  Future<String?> uploadXFile(
    XFile file, {
    String bucket = 'market-media',
  }) async {
    try {
      final bytes = await file.readAsBytes();
      return await SupabaseService.instance.uploadImage(
        bytes: bytes,
        fileName: file.name,
        bucket: bucket,
      );
    } catch (e) {
      debugPrint('Error uploadXFile: $e');
      return null;
    }
  }

  /// Upload multiple XFiles concurrently to Supabase Storage with progress reporting
  Future<List<String>> uploadMultipleXFiles(
    List<XFile> files, {
    String bucket = 'market-media',
    void Function(int completed, int total, double progress)? onProgress,
  }) async {
    if (files.isEmpty) return [];

    final total = files.length;
    int completed = 0;
    onProgress?.call(0, total, 0.0);

    // Parallel upload with progress reporting as each finishes
    final futures = files.map((f) async {
      final url = await uploadXFile(f, bucket: bucket);
      completed++;
      onProgress?.call(completed, total, completed / total);
      return url;
    }).toList();

    final results = await Future.wait(futures);
    return results.whereType<String>().where((u) => u.isNotEmpty).toList();
  }
}
