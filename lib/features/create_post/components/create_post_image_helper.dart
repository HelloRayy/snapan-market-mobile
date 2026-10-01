import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapan_market/core/services/media_upload_service.dart';
import 'package:snapan_market/core/services/supabase_service.dart';
import 'package:snapan_market/core/theme/app_colors.dart';

class CreatePostImageHelper {
  static Future<List<String>?> pickImages(BuildContext context, {required int remaining}) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 14),
              ListTile(
                leading: const Icon(CupertinoIcons.photo_on_rectangle, color: AppColors.primary),
                title: const Text('Buka Galeri Foto', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pilih foto dari perangkat (Kompres 1080p otomatis)'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.camera, color: AppColors.primary),
                title: const Text('Ambil Foto Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Foto langsung barang jualan atau karya'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return null;

    if (source == ImageSource.gallery) {
      final pickedFiles = await MediaUploadService.instance.pickMultiImages(
        limit: remaining,
      );
      return pickedFiles.map((f) => f.path).toList();
    } else {
      final picked = await MediaUploadService.instance.pickSingleImage(
        source: ImageSource.camera,
      );
      return picked != null ? [picked.path] : null;
    }
  }

  static Future<List<String>> uploadAllImages(List<String> images) async {
    final List<String> uploadedImages = [];
    for (final img in images) {
      if (img.startsWith('http://') || img.startsWith('https://')) {
        uploadedImages.add(img);
      } else {
        try {
          final file = File(img);
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final fileName = img.split(Platform.pathSeparator).last;
            final uploadedUrl = await SupabaseService.instance.uploadImage(
              bytes: bytes,
              fileName: fileName,
              bucket: 'market-media',
            );
            uploadedImages.add(uploadedUrl ?? img);
          }
        } catch (e) {
          debugPrint('Error uploading image $img: $e');
          uploadedImages.add(img);
        }
      }
    }
    return uploadedImages;
  }
}
