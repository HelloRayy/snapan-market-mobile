import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapan_market/core/services/supabase_service.dart';

/// Service for picking and uploading media files to Supabase Storage
/// with built-in automatic downscaling (1080p) and compression (quality 80%)
/// to minimize bandwidth and storage consumption.
class MediaUploadService {
  MediaUploadService._();
  static final MediaUploadService instance = MediaUploadService._();

  final ImagePicker _picker = ImagePicker();

  /// Pick multiple images from gallery with automatic compression (1080p, quality 80)
  Future<List<XFile>> pickMultiImages({
    int maxWidth = 1080,
    int maxHeight = 1080,
    int imageQuality = 80,
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

  /// Pick a single image from camera or gallery
  Future<XFile?> pickSingleImage({
    ImageSource source = ImageSource.gallery,
    int maxWidth = 1080,
    int maxHeight = 1080,
    int imageQuality = 80,
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

  /// Upload multiple XFiles sequentially to Supabase Storage
  Future<List<String>> uploadMultipleXFiles(
    List<XFile> files, {
    String bucket = 'market-media',
  }) async {
    final List<String> uploadedUrls = [];
    for (final f in files) {
      final url = await uploadXFile(f, bucket: bucket);
      if (url != null && url.isNotEmpty) {
        uploadedUrls.add(url);
      }
    }
    return uploadedUrls;
  }
}
