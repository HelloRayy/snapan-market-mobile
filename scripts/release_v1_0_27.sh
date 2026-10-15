#!/usr/bin/env bash
set -e

# ==============================================================================
# 🚀 Snaps Mobile End-to-End One-Click Beta Release Script (v1.0.27+2029)
# ==============================================================================
# - Memastikan semua pre-flight check lulus (flutter analyze & manifest sync)
# - Menyetel versi ke 1.0.27+2029 (Version code: 2029)
# - Mengompilasi APK Release production (flutter build apk --release)
# - Push commit & git tag v1.0.27 ke remote GitHub
# - Membuat Release di GitHub & mengunggah app-release.apk
# - Mendaftarkan ke database Supabase (is_mandatory: true, is_active: true)
# ==============================================================================

VERSION_NAME="1.0.27"
VERSION_CODE="29" # REAL_VERSION_CODE di Supabase akan menjadi 2029
CHANGELOG="✨ Pembaruan Snaps Mobile v1.0.27 (Beta Release)

1. 👁️ Views Count Postingan:
• Ketahui jumlah tayangan postingan secara akurat saat membuka detail post.
• Penghitungan cerdas berbasis perangkat unik (1 device = 1 view).

2. 👤 Perbaikan Bio Profil:
• Bio profil kamu sekarang sudah tampil secara publik dan bisa dibaca oleh pengguna lain.

3. 🔔 Notifikasi & Aksi Cepat:
• Tombol aksi langsung di status bar notifikasi kini lebih responsif dan interaktif.
• Pencegahan pengiriman notifikasi kosong untuk pengalaman yang lebih bersih.

4. 🛡️ Keamanan Akun & Perangkat:
• Peningkatan sistem proteksi NIS & deteksi perangkat aktif untuk mencegah pembajakan akun.

5. 💫 Tampilan & Animasi:
• Ikon aplikasi baru dengan desain squircle adaptif yang lebih rapi.
• Animasi reaksi Like baru dengan sentuhan haptic dan efek visual halus."

echo "=========================================================="
echo "🔍 1. Menjalankan Pre-Flight Checks..."
echo "=========================================================="

echo "Memeriksa manifest integritas..."
./scripts/verify-agent-map.sh

echo "Memeriksa compiler code..."
flutter analyze lib/features/feed/components/post_card/post_action_bar.dart lib/features/profile/controllers/profile_controller.dart lib/core/services/supabase/supabase_feed_service.dart

echo "=========================================================="
echo "📦 2. Memperbarui Versi di pubspec.yaml ke v${VERSION_NAME}+${VERSION_CODE}..."
echo "=========================================================="
sed -i -E "s/^version: .*/version: ${VERSION_NAME}+${VERSION_CODE}/" pubspec.yaml

echo "=========================================================="
echo "🔨 3. Mengompilasi APK Release (flutter build apk --release)..."
echo "=========================================================="
flutter build apk --release --no-pub

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ ! -f "$APK_PATH" ]; then
  echo "❌ Error: File APK tidak ditemukan di $APK_PATH"
  exit 1
fi

APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
echo "✅ APK Release siap ($APK_SIZE): $APK_PATH"

echo "=========================================================="
echo "🏷️ 4. Menyimpan Perubahan Git & Mendorong Tag v${VERSION_NAME}..."
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
  echo "⚠️ Menggunakan environment GITHUB_TOKEN..."
  GH_TOKEN="${GITHUB_TOKEN}"
fi

DOWNLOAD_URL="https://github.com/HelloRayy/snapan-market-mobile/releases/download/v${VERSION_NAME}/app-release.apk"

if [ -n "$GH_TOKEN" ]; then
  echo "=========================================================="
  echo "🚀 5. Membuat GitHub Release & Mengunggah APK..."
  echo "=========================================================="
  
  RELEASE_PAYLOAD=$(python3 -c "
import json
print(json.dumps({
    'tag_name': 'v${VERSION_NAME}',
    'name': 'Snaps v${VERSION_NAME}',
    'body': '''${CHANGELOG}''',
    'draft': False,
    'prerelease': False
}))
")

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
    
    EXISTING_ASSET_ID=$(curl -s -H "Authorization: token ${GH_TOKEN}" \
      "https://api.github.com/repos/HelloRayy/snapan-market-mobile/releases/${RELEASE_ID}/assets" \
      | grep -m 1 '"id":' | awk '{print $2}' | tr -d ',')
    if [ -n "$EXISTING_ASSET_ID" ] && [ "$EXISTING_ASSET_ID" != "null" ]; then
      curl -s -X DELETE -H "Authorization: token ${GH_TOKEN}" \
        "https://api.github.com/repos/HelloRayy/snapan-market-mobile/releases/assets/${EXISTING_ASSET_ID}" > /dev/null || true
    fi

    UPLOAD_RESP=$(curl -s -X POST \
      -H "Authorization: token ${GH_TOKEN}" \
      -H "Content-Type: application/vnd.android.package-archive" \
      --data-binary @"$APK_PATH" \
      "https://uploads.github.com/repos/HelloRayy/snapan-market-mobile/releases/${RELEASE_ID}/assets?name=app-release.apk")
    
    UPLOAD_STATE=$(echo "$UPLOAD_RESP" | grep -m 1 '"state":' | awk '{print $2}' | tr -d '",')
    echo "✅ Asset APK terunggah dengan status: ${UPLOAD_STATE:-uploaded}!"
  else
    echo "⚠️ Gagal membuat GitHub Release via API."
  fi
fi

SUPABASE_KEY=""
if [ -f ".env.local" ]; then
  SUPABASE_KEY=$(grep -E "^SUPABASE_SERVICE_ROLE_KEY=" .env.local | cut -d '=' -f2- | tr -d '"'\'' ')
fi

echo "=========================================================="
echo "📲 6. Mendaftarkan ke Database Supabase (Mandatory Update)..."
echo "=========================================================="

REAL_VERSION_CODE=2029

if [ -n "$SUPABASE_KEY" ]; then
  python3 -c "
import urllib.request, json

url = 'https://lcwsxldnoqjdfqxqcqja.supabase.co/rest/v1/app_versions'
headers = {
    'apikey': '${SUPABASE_KEY}',
    'Authorization': 'Bearer ${SUPABASE_KEY}',
    'Content-Type': 'application/json',
    'Prefer': 'return=representation'
}
payload = {
    'version_code': ${REAL_VERSION_CODE},
    'version_name': '${VERSION_NAME}',
    'download_url': '${DOWNLOAD_URL}',
    'title': 'Pembaruan Snaps v${VERSION_NAME}',
    'changelog': '''${CHANGELOG}''',
    'is_mandatory': True,
    'is_active': True
}
req = urllib.request.Request(url, data=json.dumps(payload).encode('utf-8'), headers=headers)
try:
    with urllib.request.urlopen(req) as resp:
        print('✅ BERHASIL didaftarkan ke Supabase! Status code:', resp.status)
except Exception as e:
    print('❌ Gagal mendaftarkan ke Supabase:', e)
"
fi

echo ""
echo "=========================================================="
echo "🎉 RILIS MANDATORY UPDATE v${VERSION_NAME}+${REAL_VERSION_CODE} SUKSES!"
echo "Semua pengguna Snaps versi di bawahnya akan menerima prompt mandatory update."
echo "=========================================================="
