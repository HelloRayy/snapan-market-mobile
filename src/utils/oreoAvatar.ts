import { createAvatar, shapes, palettes, type ShapeId } from '@oreo-design/avatar';

// 8 curated preset gradients for EditProfilePage and UI choices
export const OREO_PRESET_CONFIGS: Array<{
  id: string;
  label: string;
  shape: ShapeId;
  palette: string;
  appearance: 'light' | 'dark';
}> = [
  { id: 'preset-1', label: 'Aurora Rose', shape: 'bloom', palette: 'rose-milk', appearance: 'light' },
  { id: 'preset-2', label: 'Silk Lavender', shape: 'silk', palette: 'lilac-silk', appearance: 'light' },
  { id: 'preset-3', label: 'Peach Glow', shape: 'flare', palette: 'peach-cream', appearance: 'light' },
  { id: 'preset-4', label: 'Nova Cyan', shape: 'nova', palette: 'blue-cream', appearance: 'light' },
  { id: 'preset-5', label: 'Jade Mint', shape: 'jade', palette: 'mint-milk', appearance: 'light' },
  { id: 'preset-6', label: 'Neon Void', shape: 'void', palette: 'aurora-pink', appearance: 'dark' },
  { id: 'preset-7', label: 'Coral Mist', shape: 'flare', palette: 'coral-mist', appearance: 'light' },
  { id: 'preset-8', label: 'Deep Cosmic', shape: 'nova', palette: 'violet-peach', appearance: 'dark' },
];

/**
 * Cache for generated Data URIs to prevent recomputing SVG on every render
 */
const dataUriCache = new Map<string, string>();

/**
 * Generates an SVG Data URI avatar based on a deterministic seed (name, username, or id).
 * Produces smooth, zero-dependency Figma-method soft gradients.
 */
export function getOreoAvatarUrl(
  seed: string = 'snaps-user',
  options?: {
    size?: number;
    shape?: ShapeId;
    palette?: string;
    appearance?: 'light' | 'dark';
  }
): string {
  const cleanSeed = (seed || 'snaps-user').trim().toLowerCase();
  const cacheKey = `${cleanSeed}-${options?.size || 128}-${options?.shape || 'auto'}-${options?.palette || 'auto'}`;
  
  if (dataUriCache.has(cacheKey)) {
    return dataUriCache.get(cacheKey)!;
  }

  // Derive deterministic shape & palette index from seed hash if not explicitly provided
  let hash = 0;
  for (let i = 0; i < cleanSeed.length; i++) {
    hash = (hash << 5) - hash + cleanSeed.charCodeAt(i);
    hash |= 0;
  }
  const positiveHash = Math.abs(hash);

  const selectedShape: ShapeId =
    options?.shape || shapes[positiveHash % shapes.length].id;
  const selectedPalette =
    options?.palette || palettes[positiveHash % palettes.length].id;

  try {
    const avatar = createAvatar({
      variantId: cleanSeed,
      shape: selectedShape,
      palette: selectedPalette,
      appearance: options?.appearance || 'light',
      size: options?.size || 128,
      drift: 8,
    });

    const dataUri = avatar.toDataUri();
    dataUriCache.set(cacheKey, dataUri);
    return dataUri;
  } catch (e) {
    console.warn('getOreoAvatarUrl failed, falling back to basic SVG:', e);
    return '';
  }
}

/**
 * Pre-generated Data URIs for the 8 preset choices in Edit Profile
 */
export const PRESET_OREO_AVATARS: string[] = OREO_PRESET_CONFIGS.map((config) => {
  return createAvatar({
    variantId: config.id,
    shape: config.shape,
    palette: config.palette,
    appearance: config.appearance,
    size: 140,
    drift: 6,
  }).toDataUri();
});
