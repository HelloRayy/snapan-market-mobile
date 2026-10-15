#!/usr/bin/env python3
"""
Generate Snaps PWA, Favicon, and Android Launcher Icons with modern Apple-style squircle corner radius.
"""
from PIL import Image, ImageDraw
import os
import shutil

def generate_icons():
    logo_path = 'public/snaps-logo.png'
    if not os.path.exists(logo_path):
        raise FileNotFoundError(f"Logo not found at {logo_path}")

    orig = Image.open(logo_path).convert('RGBA')

    # Bounding box of the main 'snaps' logotype
    crop_box = (130, 220, 675, 545)
    wordmark = orig.crop(crop_box)

    def create_squircle_icon(dimension, padding_ratio=0.76, radius_ratio=0.225):
        scale = 4
        high_dim = dimension * scale
        radius = int(high_dim * radius_ratio)

        # 1. High-res white canvas
        high_canvas = Image.new('RGBA', (high_dim, high_dim), (255, 255, 255, 255))

        # 2. Resized wordmark centered
        target_w = int(high_dim * padding_ratio)
        scale_wm = target_w / wordmark.width
        target_h = int(wordmark.height * scale_wm)
        resized_wm = wordmark.resize((target_w, target_h), Image.Resampling.LANCZOS)

        pos_x = (high_dim - target_w) // 2
        pos_y = (high_dim - target_h) // 2
        high_canvas.paste(resized_wm, (pos_x, pos_y), resized_wm)

        # 3. High-res squircle mask
        high_mask = Image.new('L', (high_dim, high_dim), 0)
        draw = ImageDraw.Draw(high_mask)
        draw.rounded_rectangle([0, 0, high_dim - 1, high_dim - 1], radius=radius, fill=255)
        high_canvas.putalpha(high_mask)

        # 4. Anti-aliased downscale
        return high_canvas.resize((dimension, dimension), Image.Resampling.LANCZOS)

    # 1. PWA Icons (Squircle)
    print("Generating PWA icons with smooth squircle corner radius...")
    icon_512 = create_squircle_icon(512, 0.76, 0.225)
    icon_512.save('public/pwa-512x512.png', 'PNG')

    icon_192 = create_squircle_icon(192, 0.76, 0.225)
    icon_192.save('public/pwa-192x192.png', 'PNG')

    icon_apple = create_squircle_icon(180, 0.76, 0.225)
    icon_apple.save('public/apple-touch-icon.png', 'PNG')

    # 2. Favicon.ico with multiple embedded resolutions & alpha corners
    print("Generating multi-resolution favicon.ico with squircle radius...")
    icon_16 = create_squircle_icon(16, 0.85, 0.225)
    icon_32 = create_squircle_icon(32, 0.82, 0.225)
    icon_48 = create_squircle_icon(48, 0.80, 0.225)
    icon_64 = create_squircle_icon(64, 0.78, 0.225)
    icon_48.save(
        'public/favicon.ico',
        format='ICO',
        sizes=[(16, 16), (32, 32), (48, 48), (64, 64)],
        append_images=[icon_16, icon_32, icon_64]
    )

    # 3. Favicon.svg (Crisp Vector with Squircle)
    print("Generating public/favicon.svg...")
    clean_svg_path = 'public/snaps-logo-clean.svg'
    if os.path.exists(clean_svg_path):
        with open(clean_svg_path, 'r') as f:
            orig_svg = f.read()
        start = orig_svg.find('>') + 1
        end = orig_svg.rfind('</svg>')
        inner = orig_svg[start:end]
        svg_content = f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="512" height="512">
  <rect width="512" height="512" rx="115" ry="115" fill="#FFFFFF" />
  <svg x="56" y="139" width="400" height="234" viewBox="130 325 760 445">
{inner}
  </svg>
</svg>
'''
        with open('public/favicon.svg', 'w') as f:
            f.write(svg_content)

    # Sync to dist/ if dist folder exists
    if os.path.exists('dist'):
        print("Syncing icons to dist/ directory...")
        for name in ['favicon.ico', 'favicon.svg', 'apple-touch-icon.png', 'pwa-192x192.png', 'pwa-512x512.png']:
            src = os.path.join('public', name)
            dst = os.path.join('dist', name)
            if os.path.exists(src):
                shutil.copy2(src, dst)

    # 4. Android Mipmap Icons
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
            ic = create_squircle_icon(dim, 0.78, 0.225)
            ic.save(path, 'PNG')
            print(f"Saved: {path} ({dim}x{dim})")

    print("All Snaps icons successfully generated with Option 2 (Apple-style squircle)!")

if __name__ == '__main__':
    generate_icons()
