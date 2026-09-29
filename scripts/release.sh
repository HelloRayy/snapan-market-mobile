#!/usr/bin/env bash
set -e

# ========================================================
# 🚀 Snaps Mobile Release & Update Helper Script
# ========================================================
# Usage:
#   ./scripts/release.sh <version_name> <version_code> "<changelog>"
# Example:
#   ./scripts/release.sh 1.0.2 3 "Sidebar drawer baru & perbaikan navigasi profil"
# ========================================================

VERSION_NAME=$1
VERSION_CODE=$2
CHANGELOG=$3

if [ -z "$VERSION_NAME" ] || [ -z "$VERSION_CODE" ]; then
  echo "Usage: ./scripts/release.sh <version_name> <version_code> [\"changelog\"]"
  echo "Contoh: ./scripts/release.sh 1.0.2 3 \"Sidebar drawer baru dan perbaikan profil\""
  exit 1
fi

if [ -z "$CHANGELOG" ]; then
  CHANGELOG="Pembaruan sistem, fitur baru, dan peningkatan performa."
fi

echo "=========================================="
echo "📦 Menyiapkan Rilis Snaps v${VERSION_NAME} (Build ${VERSION_CODE})"
echo "=========================================="

# 1. Update pubspec.yaml version
echo "1. Memperbarui pubspec.yaml ke version: ${VERSION_NAME}+${VERSION_CODE}..."
sed -i -E "s/^version: .*/version: ${VERSION_NAME}+${VERSION_CODE}/" pubspec.yaml

echo "2. Menyimpan perubahan ke Git & membuat Git Tag..."
git add pubspec.yaml
git commit -m "chore(release): bump version to v${VERSION_NAME}+${VERSION_CODE}" || true
git tag -a "v${VERSION_NAME}" -m "Release v${VERSION_NAME}" || true

echo "3. Mendorong tag ke GitHub..."
git push origin main
git push origin "v${VERSION_NAME}"

DOWNLOAD_URL="https://github.com/HelloRayy/snapan-market-mobile/releases/download/v${VERSION_NAME}/app-release.apk"

echo ""
echo "========================================================"
echo "✅ GitHub Tag v${VERSION_NAME} terkirim!"
echo "GitHub Actions akan otomatis membangun APK dan merilisnya di:"
echo "https://github.com/HelloRayy/snapan-market-mobile/releases"
echo ""
echo "📲 UNTUK MENERAPKAN KE PERANGKAT YANG SUDAH DOWNLOAD:"
echo "Jalankan SQL berikut di Supabase Dashboard -> SQL Editor:"
echo "--------------------------------------------------------"
cat <<EOF
INSERT INTO public.app_versions (version_code, version_name, download_url, title, changelog, is_mandatory, is_active)
VALUES (
  ${VERSION_CODE},
  '${VERSION_NAME}',
  '${DOWNLOAD_URL}',
  'Pembaruan Snaps v${VERSION_NAME}',
  '${CHANGELOG}',
  false,
  true
);
EOF
echo "--------------------------------------------------------"
echo "Begitu query di atas dijalankan, semua HP siswa yang membuka"
echo "aplikasi akan otomatis menerima popup pembaruan OTA!"
echo "========================================================"
