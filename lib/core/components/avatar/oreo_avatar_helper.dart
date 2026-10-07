import 'package:flutter/material.dart';
import 'default_profile_avatar.dart';

export 'default_profile_avatar.dart';

/// Preset soft gradient definitions inspired by @oreo-design/avatar
class OreoGradientPreset {
  final String id;
  final String name;
  final List<Color> colors;
  final Alignment begin;
  final Alignment end;

  const OreoGradientPreset({
    required this.id,
    required this.name,
    required this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });
}

/// 8 curated soft gradient presets mirroring @oreo-design/avatar palettes:
/// rose-milk, lilac-silk, peach-cream, blue-cream, mint-milk, aurora-pink, coral-mist, violet-peach
const List<OreoGradientPreset> kOreoGradientPresets = [
  OreoGradientPreset(
    id: 'rose-milk',
    name: 'Aurora Rose',
    colors: [Color(0xFFFFD1DC), Color(0xFFFFB3C6), Color(0xFFC77DFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  OreoGradientPreset(
    id: 'lilac-silk',
    name: 'Silk Lavender',
    colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  ),
  OreoGradientPreset(
    id: 'peach-cream',
    name: 'Peach Glow',
    colors: [Color(0xFFFFECD2), Color(0xFFFCB69F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  OreoGradientPreset(
    id: 'blue-cream',
    name: 'Nova Cyan',
    colors: [Color(0xFF89F7FE), Color(0xFF66A6FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
  OreoGradientPreset(
    id: 'mint-milk',
    name: 'Jade Mint',
    colors: [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  OreoGradientPreset(
    id: 'aurora-pink',
    name: 'Neon Void',
    colors: [Color(0xFF2E0854), Color(0xFF6A0572), Color(0xFFFF2A8D)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  ),
  OreoGradientPreset(
    id: 'coral-mist',
    name: 'Coral Mist',
    colors: [Color(0xFFFF9A8B), Color(0xFFFF6A88), Color(0xFFFF99AC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  OreoGradientPreset(
    id: 'violet-peach',
    name: 'Deep Cosmic',
    colors: [Color(0xFF1F1C2C), Color(0xFF928DAB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
];

/// Resolves a deterministic soft gradient preset based on user seed (username, name, or id)
OreoGradientPreset getOreoPresetForSeed(String seed) {
  if (seed.isEmpty) return kOreoGradientPresets[0];

  int hash = 0;
  for (int i = 0; i < seed.length; i++) {
    hash = (hash << 5) - hash + seed.codeUnitAt(i);
    hash &= 0x7FFFFFFF;
  }
  return kOreoGradientPresets[hash % kOreoGradientPresets.length];
}

/// Fallback avatar builder that renders the standard gray default profile avatar
class OreoAvatarPlaceholder extends StatelessWidget {
  final String seed;
  final String? displayName;
  final double size;

  const OreoAvatarPlaceholder({
    super.key,
    required this.seed,
    this.displayName,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultProfileAvatar(size: size);
  }
}
