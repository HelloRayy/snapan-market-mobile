#!/usr/bin/env python3
"""
Generate Snaps PWA and Android Launcher Icons from official logo typography.
"""
from PIL import Image
import os

def generate_icons():
    logo_path = 'public/snaps-logo.png'
    if not os.path.exists(logo_path):
        raise FileNotFoundError(f"Logo not found at {logo_path}")

    orig = Image.open(logo_path).convert('RGBA')

    # Bounding box of the main 'snaps' logotype
    # (130, 220, 675, 545) tightly encompasses the fluid glyphs
    crop_box = (130, 220, 675, 545)
    wordmark = orig.crop(crop_box)

    def create_square_icon(dimension, padding_ratio=0.76):
        canvas = Image.new('RGBA', (dimension, dimension), (255, 255, 255, 255))
        target_w = int(dimension * padding_ratio)
        scale = target_w / wordmark.width
        target_h = int(wordmark.height * scale)
        resized = wordmark.resize((target_w, target_h), Image.Resampling.LANCZOS)
        
        pos_x = (dimension - target_w) // 2
        pos_y = (dimension - target_h) // 2
        canvas.paste(resized, (pos_x, pos_y), resized)
        return canvas

    # 1. PWA Icons
    print("Generating PWA icons...")
    icon_512 = create_square_icon(512, 0.76)
    icon_512.save('public/pwa-512x512.png', 'PNG')

    icon_192 = create_square_icon(192, 0.76)
    icon_192.save('public/pwa-192x192.png', 'PNG')

    icon_apple = create_square_icon(180, 0.76)
    icon_apple.save('public/apple-touch-icon.png', 'PNG')

    # Favicon.ico with multiple embedded resolutions
    icon_16 = create_square_icon(16, 0.85)
    icon_32 = create_square_icon(32, 0.82)
    icon_48 = create_square_icon(48, 0.80)
    icon_64 = create_square_icon(64, 0.78)
    icon_48.save(
        'public/favicon.ico',
        format='ICO',
        sizes=[(16, 16), (32, 32), (48, 48), (64, 64)],
        append_images=[icon_16, icon_32, icon_64]
    )

    # 2. Android Mipmap Icons
    print("Generating Android mipmap launcher icons...")
    android_targets = {
        'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
        'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
        'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
        'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
    }

    for path, dim in android_targets.items():
        if os.path.exists(os.path.dirname(path)):
            ic = create_square_icon(dim, 0.78)
            ic.save(path, 'PNG')
            print(f"Saved: {path} ({dim}x{dim})")

    # Clean up test file if present
    if os.path.exists('public/test-icon-512.png'):
        os.remove('public/test-icon-512.png')

    print("All Snaps icons successfully generated!")

if __name__ == '__main__':
    generate_icons()
