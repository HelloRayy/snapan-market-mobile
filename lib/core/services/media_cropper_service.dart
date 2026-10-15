import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:snapan_market/core/components/cropper/image_crop_editor_modal.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

/// Clean image cropper service (SNAPS-81)
/// Prioritizes Pure Flutter In-App Modal (Image 2 style) for seamless UX and brand consistency,
/// with fallback to native uCrop / TOCropViewController if no context is provided.
class MediaCropperService {
  MediaCropperService._();
  static final MediaCropperService instance = MediaCropperService._();

  /// Crop image khusus untuk Avatar Profil (1:1 Lingkaran Simetris ala WhatsApp/Twitter/Instagram)
  Future<CroppedFile?> cropAvatar(
    String sourcePath, {
    BuildContext? context,
  }) async {
    // 1. Prioritaskan In-App Pure Flutter Modal jika context tersedia
    if (context != null && context.mounted) {
      try {
        final result = await ImageCropEditorModal.open(
          context: context,
          imagePath: sourcePath,
          title: 'Sesuaikan Foto Profil',
          isCircle: true,
        );
        return result;
      } catch (e) {
        debugPrint('[MediaCropperService] In-App crop error, trying fallback: $e');
      }
    }

    // 2. Fallback ke ImageCropper native jika context tidak tersedia
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        compressQuality: 85,
        maxWidth: 720,
        maxHeight: 720,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Sesuaikan Foto Profil',
            toolbarColor: const Color(0xFF0F172A),
            toolbarWidgetColor: Colors.white,
            statusBarLight: false,
            backgroundColor: const Color(0xFF0B0F17),
            activeControlsWidgetColor: AppColors.primary,
            dimmedLayerColor: const Color(0xCC000000),
            cropFrameColor: AppColors.primary,
            cropGridColor: Colors.white38,
            cropFrameStrokeWidth: 2,
            cropGridStrokeWidth: 1,
            showCropGrid: true,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: CropStyle.circle,
            hideBottomControls: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: 'Sesuaikan Foto Profil',
            cropStyle: CropStyle.circle,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            doneButtonTitle: 'Selesai',
            cancelButtonTitle: 'Batal',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
          ),
        ],
      );
      return cropped;
    } catch (e) {
      debugPrint('[MediaCropperService] Error cropping avatar: $e');
      return null;
    }
  }

  /// Crop image umum untuk media postingan/produk (Preset 1:1, 4:3, 16:9, atau original)
  Future<CroppedFile?> cropPostMedia(String sourcePath) async {
    try {
      final cropped = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        compressQuality: 85,
        maxWidth: 1280,
        maxHeight: 1280,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Sesuaikan Foto',
            toolbarColor: const Color(0xFF0F172A),
            toolbarWidgetColor: Colors.white,
            statusBarLight: false,
            backgroundColor: const Color(0xFF0B0F17),
            activeControlsWidgetColor: AppColors.primary,
            dimmedLayerColor: const Color(0xCC000000),
            cropFrameColor: AppColors.primary,
            cropGridColor: Colors.white38,
            cropFrameStrokeWidth: 2,
            cropGridStrokeWidth: 1,
            showCropGrid: true,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            cropStyle: CropStyle.rectangle,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
          IOSUiSettings(
            title: 'Sesuaikan Foto',
            cropStyle: CropStyle.rectangle,
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            doneButtonTitle: 'Selesai',
            cancelButtonTitle: 'Batal',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
          ),
        ],
      );
      return cropped;
    } catch (e) {
      debugPrint('[MediaCropperService] Error cropping media: $e');
      return null;
    }
  }
}
