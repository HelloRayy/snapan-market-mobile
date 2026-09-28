/// Model representing an available app release version from Supabase
class AppVersionModel {
  final String id;
  final int versionCode;
  final String versionName;
  final String downloadUrl;
  final String title;
  final String changelog;
  final bool isMandatory;
  final bool isActive;

  const AppVersionModel({
    required this.id,
    required this.versionCode,
    required this.versionName,
    required this.downloadUrl,
    required this.title,
    required this.changelog,
    required this.isMandatory,
    required this.isActive,
  });

  factory AppVersionModel.fromJson(Map<String, dynamic> json) {
    return AppVersionModel(
      id: json['id'] as String? ?? '',
      versionCode: json['version_code'] as int? ?? 1,
      versionName: json['version_name'] as String? ?? '1.0.0',
      downloadUrl: json['download_url'] as String? ?? '',
      title: json['title'] as String? ?? 'Pembaruan Tersedia',
      changelog: json['changelog'] as String? ?? 'Pembaruan sistem dan perbaikan performa.',
      isMandatory: json['is_mandatory'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
