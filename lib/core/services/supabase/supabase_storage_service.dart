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
}
