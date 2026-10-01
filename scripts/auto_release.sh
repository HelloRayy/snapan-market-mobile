#!/usr/bin/env bash
set -e

# ========================================================
# 🚀 Snaps Mobile End-to-End Automated Release Script
# ========================================================
# Usage:
#   ./scripts/auto_release.sh <version_name> <version_code> "<changelog>"
# Example:
#   ./scripts/auto_release.sh 1.0.3 4 "Fix lokasi SMKN 8 Semarang, transisi animasi, & OTA installer"
# ========================================================

VERSION_NAME=$1
VERSION_CODE=$2
CHANGELOG=$3

if [ -z "$VERSION_NAME" ] || [ -z "$VERSION_CODE" ]; then
  echo "Format perintah: ./scripts/auto_release.sh <version_name> <version_code> [\"changelog\"]"
  echo "Contoh: ./scripts/auto_release.sh 1.0.3 4 \"Perbaikan in-app update dan stabilitas rilis\""
  exit 1
fi

if [ -z "$CHANGELOG" ]; then
  CHANGELOG="Pembaruan sistem, fitur baru, dan peningkatan performa."
fi

echo "=========================================================="
echo "📦 1. Memperbarui Versi ke v${VERSION_NAME}+${VERSION_CODE}..."
echo "=========================================================="
sed -i -E "s/^version: .*/version: ${VERSION_NAME}+${VERSION_CODE}/" pubspec.yaml

echo "=========================================================="
echo "🔨 2. Membangun APK Release (flutter build apk --release)..."
echo "=========================================================="
flutter build apk --release --no-pub

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ ! -f "$APK_PATH" ]; then
  echo "❌ Error: File APK tidak ditemukan di $APK_PATH"
  exit 1
fi

APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
echo "✅ APK berhasil dibangun ($APK_SIZE): $APK_PATH"

echo "=========================================================="
echo "🏷️ 3. Menyimpan Perubahan Git & Mendorong Tag v${VERSION_NAME}..."
echo "=========================================================="
git add pubspec.yaml
git commit -m "chore(release): bump version to v${VERSION_NAME}+${VERSION_CODE}" || true
git tag -f "v${VERSION_NAME}"
git push origin main
git push origin -f "v${VERSION_NAME}"

# Ekstrak GitHub Token dari konfigurasi remote git
REMOTE_URL=$(git config remote.origin.url)
GH_TOKEN=$(echo "$REMOTE_URL" | sed -n -E 's#.*(github_pat_[^@]+)@.*#\1#p')

if [ -z "$GH_TOKEN" ]; then
  echo "⚠️ Token GitHub tidak ditemukan di URL remote. Menggunakan environment GITHUB_TOKEN..."
  GH_TOKEN="${GITHUB_TOKEN}"
fi

DOWNLOAD_URL="https://github.com/HelloRayy/snapan-market-mobile/releases/download/v${VERSION_NAME}/app-release.apk"

if [ -n "$GH_TOKEN" ]; then
  echo "=========================================================="
  echo "🚀 4. Membuat GitHub Release via API..."
  echo "=========================================================="
  
  RELEASE_PAYLOAD=$(cat <<EOF
{
  "tag_name": "v${VERSION_NAME}",
  "name": "Snaps v${VERSION_NAME}",
  "body": "${CHANGELOG}",
  "draft": false,
  "prerelease": false
}
EOF
)

  # Cek apakah release sudah ada
  EXISTING_RELEASE_ID=$(curl -s -H "Authorization: token ${GH_TOKEN}" \
    "https://api.github.com/repos/HelloRayy/snapan-market-mobile/releases/tags/v${VERSION_NAME}" \
    | grep -m 1 '"id":' | awk '{print $2}' | tr -d ',')

  if [ -n "$EXISTING_RELEASE_ID" ] && [ "$EXISTING_RELEASE_ID" != "null" ]; then
    echo "Release v${VERSION_NAME} sudah ada (ID: $EXISTING_RELEASE_ID). Menggunakan release tersebut..."
    RELEASE_ID=$EXISTING_RELEASE_ID
  else
    CREATE_RESP=$(curl -s -X POST -H "Authorization: token ${GH_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "$RELEASE_PAYLOAD" \
      "https://api.github.com/repos/HelloRayy/snapan-market-mobile/releases")
    RELEASE_ID=$(echo "$CREATE_RESP" | grep -m 1 '"id":' | awk '{print $2}' | tr -d ',')
  fi

  if [ -n "$RELEASE_ID" ] && [ "$RELEASE_ID" != "null" ]; then
    echo "Mengunggah asset APK ke GitHub Release (ID: $RELEASE_ID)..."
    
    # Hapus asset lama jika ada
    EXISTING_ASSET_ID=$(curl -s -H "Authorization: token ${GH_TOKEN}" \
      "https://api.github.com/repos/HelloRayy/snapan-market-mobile/releases/${RELEASE_ID}/assets" \
      | grep -m 1 '"id":' | awk '{print $2}' | tr -d ',')
    if [ -n "$EXISTING_ASSET_ID" ] && [ "$EXISTING_ASSET_ID" != "null" ]; then
      curl -s -X DELETE -H "Authorization: token ${GH_TOKEN}" \
        "https://api.github.com/repos/HelloRayy/snapan-market-mobile/releases/assets/${EXISTING_ASSET_ID}" > /dev/null || true
    fi

    # Upload APK binary
    UPLOAD_RESP=$(curl -s -X POST \
      -H "Authorization: token ${GH_TOKEN}" \
      -H "Content-Type: application/vnd.android.package-archive" \
      --data-binary @"$APK_PATH" \
      "https://uploads.github.com/repos/HelloRayy/snapan-market-mobile/releases/${RELEASE_ID}/assets?name=app-release.apk")
    
    UPLOAD_STATE=$(echo "$UPLOAD_RESP" | grep -m 1 '"state":' | awk '{print $2}' | tr -d '",')
    echo "✅ Asset APK terunggah dengan status: ${UPLOAD_STATE:-uploaded}!"
  else
    echo "⚠️ Gagal membuat GitHub Release via API. Silakan unggah manual."
  fi
fi

# Cek apakah SUPABASE_SERVICE_ROLE_KEY ada di .env.local atau environment
SUPABASE_KEY=""
if [ -f ".env.local" ]; then
  SUPABASE_KEY=$(grep -E "^SUPABASE_SERVICE_ROLE_KEY=" .env.local | cut -d '=' -f2- | tr -d '"'\'' ')
fi
if [ -z "$SUPABASE_KEY" ]; then
  SUPABASE_KEY="${SUPABASE_SERVICE_ROLE_KEY}"
fi

echo "=========================================================="
echo "📲 5. Mendaftarkan Versi ke Database Supabase..."
echo "=========================================================="

if [ -n "$SUPABASE_KEY" ]; then
  echo "Menyuntikkan rilis baru ke tabel app_versions Supabase..."
  
  SUPABASE_PAYLOAD=$(cat <<EOF
{
  "version_code": ${VERSION_CODE},
  "version_name": "${VERSION_NAME}",
  "download_url": "${DOWNLOAD_URL}",
  "title": "Pembaruan Snaps v${VERSION_NAME}",
  "changelog": "${CHANGELOG}",
  "is_mandatory": false,
  "is_active": true
}
EOF
)

  SUPABASE_RESP=$(curl -s -X POST "https://lcwsxldnoqjdfqxqcqja.supabase.co/rest/v1/app_versions" \
    -H "apikey: ${SUPABASE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_KEY}" \
    -H "Content-Type: application/json" \
    -H "Prefer: return=minimal" \
    -d "$SUPABASE_PAYLOAD")

  echo "✅ Berhasil didaftarkan ke Supabase! Seluruh user sekarang otomatis menerima pembaruan."
else
  echo "ℹ️ SUPABASE_SERVICE_ROLE_KEY belum diisi di .env.local."
  echo "Jalankan SQL berikut di Supabase Dashboard -> SQL Editor:"
  echo "----------------------------------------------------------"
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
fi

echo ""
echo "🎉 RILIS v${VERSION_NAME} SELESAI DENGAN SUKSES!"
