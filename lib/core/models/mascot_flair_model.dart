/// Supported mascot bundles and emotions from page-mascot (SNAPS-13)
enum MascotBundle {
  koala('Koala', 'assets/mascots/koala'),
  fox('Fox', 'assets/mascots/fox');

  final String label;
  final String basePath;
  const MascotBundle(this.label, this.basePath);

  static MascotBundle? fromString(String? val) {
    if (val == null) return null;
    for (final b in MascotBundle.values) {
      if (b.name.toLowerCase() == val.toLowerCase()) return b;
    }
    return null;
  }
}

enum MascotEmotion {
  blink('Blink', 'blink.webp'),
  heart('Love', 'heart.webp'),
  sparkle('Sparkle', 'sparkle.webp'),
  surprised('Surprised', 'surprised.webp'),
  wink('Wink', 'wink.webp'),
  bashful('Bashful', 'bashful.webp'),
  sleepy('Sleepy', 'sleepy.webp'),
  dizzy('Dizzy', 'dizzy.webp'),
  delighted('Happy', 'delighted.webp');

  final String label;
  final String fileName;
  const MascotEmotion(this.label, this.fileName);

  static MascotEmotion? fromString(String? val) {
    if (val == null) return null;
    for (final e in MascotEmotion.values) {
      if (e.name.toLowerCase() == val.toLowerCase()) return e;
    }
    return null;
  }
}

/// Metadata model for user flair mascot badge
class MascotFlairModel {
  final MascotBundle bundle;
  final MascotEmotion emotion;

  const MascotFlairModel({
    required this.bundle,
    required this.emotion,
  });

  String get assetPath => '${bundle.basePath}/${emotion.fileName}';

  factory MascotFlairModel.fromJson(Map<String, dynamic> json) {
    final b = MascotBundle.fromString(json['bundle']?.toString()) ?? MascotBundle.koala;
    final e = MascotEmotion.fromString(json['emotion']?.toString()) ?? MascotEmotion.delighted;
    return MascotFlairModel(bundle: b, emotion: e);
  }

  Map<String, dynamic> toJson() {
    return {
      'bundle': bundle.name,
      'emotion': emotion.name,
    };
  }
}
