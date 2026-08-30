/// Common string and text utilities for Snapan Market
class StringUtils {
  /// Regular expression matching all Unicode emoji ranges
  static final RegExp _emojiRegex = RegExp(
    r'[\u{1F300}-\u{1FAFF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
    unicode: true,
  );

  /// Strips all Unicode emojis and returns a trimmed clean string
  static String stripEmojis(String text) {
    return text.replaceAll(_emojiRegex, '').trim();
  }

  /// Cleans a tag/chip string by stripping emojis and excess whitespace
  static String cleanTag(String rawTag) {
    return stripEmojis(rawTag).replaceAll(RegExp(r'\s+'), ' ');
  }
}
