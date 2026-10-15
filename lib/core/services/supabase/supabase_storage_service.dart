import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  SupabaseStorageService(this._client);
  final SupabaseClient _client;

  /// Upload an image to Supabase Storage and return its public URL.
  Future<String?> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String bucket = 'market-media',
  }) async {
    try {
      final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
      final mimeType = ext == 'png'
          ? 'image/png'
          : ext == 'webp'
              ? 'image/webp'
              : 'image/jpeg';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = (1000 + (DateTime.now().microsecond % 9000)).toString();
      final path = '$timestamp-$random.$ext';

      await _client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: mimeType,
              upsert: true,
            ),
          );

      final publicUrl = _client.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploadImage to Supabase Storage: $e');
      return null;
    }
  }

  /// Extracts the storage object path from a Supabase Storage public URL.
  /// Example: https://.../storage/v1/object/public/market-media/1728830-1234.jpg -> 1728830-1234.jpg
  static String? extractPathFromUrl(String publicUrl, {String bucket = 'market-media'}) {
    try {
      final marker = '/$bucket/';
      if (!publicUrl.contains(marker)) return null;
      final pathWithQuery = publicUrl.substring(publicUrl.indexOf(marker) + marker.length);
      return pathWithQuery.split('?').first;
    } catch (_) {
      return null;
    }
  }

  /// Delete a single image from Supabase Storage by its public URL or storage path.
  Future<bool> deleteImage({
    required String urlOrPath,
    String bucket = 'market-media',
  }) async {
    return deleteImages(urlsOrPaths: [urlOrPath], bucket: bucket);
  }

  /// Delete multiple images from Supabase Storage.
  Future<bool> deleteImages({
    required List<String> urlsOrPaths,
    String bucket = 'market-media',
  }) async {
    if (urlsOrPaths.isEmpty) return true;
    try {
      final pathsToDelete = <String>[];
      for (final item in urlsOrPaths) {
        if (item.trim().isEmpty) continue;
        if (item.startsWith('http://') || item.startsWith('https://')) {
          final extracted = extractPathFromUrl(item, bucket: bucket);
          if (extracted != null && extracted.isNotEmpty) {
            pathsToDelete.add(extracted);
          }
        } else {
          pathsToDelete.add(item.trim());
        }
      }

      if (pathsToDelete.isEmpty) return true;

      await _client.storage.from(bucket).remove(pathsToDelete);
      return true;
    } catch (e) {
      debugPrint('Error deleteImages from storage bucket ($bucket): $e');
      return false;
    }
  }
}
