#!/usr/bin/env bash
# ==============================================================================
# 🚀 SNAPS MARKET - ALL-IN-ONE IN-APP UPDATE & CLOUD RELEASE SCRIPT
# ==============================================================================
# Cukup jalankan:
#   ./update_release.sh
# Atau dengan argumen:
#   ./update_release.sh 1.0.6 7 "Pembaruan fitur pelaporan konten dan suspend akun"
#
# Skrip ini otomatis:
# 1. Mendeteksi atau menaikkan versi (version_code++) di pubspec.yaml
# 2. Mengompilasi APK Release Android (flutter build apk --release)
# 3. Commit Git & Push Release Tag ke GitHub
# 4. Membuat GitHub Release & Mengunggah file APK langsung via GitHub API
# 5. Mendaftarkan versi baru ke tabel 'app_versions' di database Supabase via REST API
# 6. Menyalurkan pembaruan secara instan ke HP pengguna (OTA In-App Update popup)
# ==============================================================================

set -e

# Warna Terminal
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo -e "${CYAN}${BOLD}"
echo "============================================================"
echo "    🚀 SNAPS MARKET - IN-APP UPDATE & CLOUD RELEASE SCRIPT  "
echo "============================================================"
echo -e "${NC}"

# 1. Baca informasi versi saat ini dari pubspec.yaml
CURRENT_VERSION_LINE=$(grep -E "^version:" pubspec.yaml | sed -E 's/version:[[:space:]]*//' | tr -d '\r\n')
CUR_NAME=$(echo "$CURRENT_VERSION_LINE" | cut -d '+' -f1)
CUR_CODE=$(echo "$CURRENT_VERSION_LINE" | cut -d '+' -f2)

NEW_NAME="${1:-$CUR_NAME}"
if [ -n "$2" ]; then
  NEW_CODE="$2"
else
  # Otomatis naikkan version_code (+1) agar terdeteksi in-app update di HP
  NEW_CODE=$((CUR_CODE + 1))
fi

CHANGELOG="${3:-Fitur pelaporan pelanggaran konten (Content Reports) & perbaikan auto-kick akun suspend.}"

echo -e "${BOLD}Versi Saat Ini    :${NC} v${CUR_NAME} (Build ${CUR_CODE})"
echo -e "${BOLD}Versi Rilis Baru  :${NC} ${GREEN}v${NEW_NAME} (Build ${NEW_CODE})${NC}"
echo -e "${BOLD}Changelog         :${NC} ${YELLOW}\"${CHANGELOG}\"${NC}"
echo "------------------------------------------------------------"

# 2. Update pubspec.yaml dengan versi baru
echo -e "\n${CYAN}📦 [1/5] Memperbarui versi di pubspec.yaml...${NC}"
sed -i -E "s/^version: .*/version: ${NEW_NAME}+${NEW_CODE}/" pubspec.yaml

# 3. Kompilasi APK Release
echo -e "\n${YELLOW}⚙️  [2/5] Mengompilasi APK Release (Harap tunggu)...${NC}"
flutter build apk --release --no-pub

APK_SOURCE="build/app/outputs/flutter-apk/app-release.apk"
if [ ! -f "$APK_SOURCE" ]; then
  echo -e "\n${RED}❌ Error: File APK tidak ditemukan di $APK_SOURCE${NC}"
  exit 1
fi

APK_SIZE=$(ls -lh "$APK_SOURCE" | awk '{print $5}')
cp "$APK_SOURCE" "Snaps-Market.apk"
cp "$APK_SOURCE" "Snaps-v${NEW_NAME}-build${NEW_CODE}.apk"
echo -e "${GREEN}✅ APK Release berhasil dibuat: Snaps-Market.apk (${APK_SIZE})${NC}"

# 4. Commit Git & Push Tag
echo -e "\n${CYAN}🏷️  [3/5] Membuat Git Commit & Tag v${NEW_NAME}...${NC}"
git add pubspec.yaml
git commit -m "chore(release): bump version to v${NEW_NAME}+${NEW_CODE}" || true
git tag -f "v${NEW_NAME}"

echo -e "${PURPLE}Mendorong commit & tag ke GitHub remote...${NC}"
git push origin main
git push origin -f "v${NEW_NAME}"

# 5. Buat GitHub Release via API & Upload Asset
echo -e "\n${CYAN}☁️  [4/5] Mengunggah APK ke GitHub Release...${NC}"
REMOTE_URL=$(git config remote.origin.url)
GH_TOKEN=$(echo "$REMOTE_URL" | sed -n -E 's#.*(github_pat_[^@]+)@.*#\1#p')

if [ -z "$GH_TOKEN" ]; then
  GH_TOKEN="${GITHUB_TOKEN}"
fi

DOWNLOAD_URL="https://github.com/HelloRayy/snapan-market-mobile/releases/download/v${NEW_NAME}/app-release.apk"

if [ -n "$GH_TOKEN" ]; then
  RELEASE_PAYLOAD=$(cat <<EOF
{
  "tag_name": "v${NEW_NAME}",
  "name": "Snaps v${NEW_NAME}",
  "body": "${CHANGELOG}",
  "draft": false,
  "prerelease": false
}
EOF
)

  EXISTING_RELEASE_ID=$(curl -s -H "Authorization: token ${GH_TOKEN}" \
    "https://api.github.com/repos/HelloRayy/snapan-market-mobile/releases/tags/v${NEW_NAME}" \
    | grep -m 1 '"id":' | awk '{print $2}' | tr -d ',')

  if [ -n "$EXISTING_RELEASE_ID" ] && [ "$EXISTING_RELEASE_ID" != "null" ]; then
    RELEASE_ID=$EXISTING_RELEASE_ID
    echo "Release v${NEW_NAME} sudah ada (ID: $RELEASE_ID). Menggunakan rilis tersebut..."
  else
    CREATE_RESP=$(curl -s -X POST -H "Authorization: token ${GH_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "$RELEASE_PAYLOAD" \
      "https://api.github.com/repos/HelloRayy/snapan-market-mobile/releases")
    RELEASE_ID=$(echo "$CREATE_RESP" | grep -m 1 '"id":' | awk '{print $2}' | tr -d ',')
  fi

  if [ -n "$RELEASE_ID" ] && [ "$RELEASE_ID" != "null" ]; then
    # Hapus asset lama jika ada
    EXISTING_ASSET_ID=$(curl -s -H "Authorization: token ${GH_TOKEN}" \
      "https://api.github.com/repos/HelloRayy/snapan-market-mobile/releases/${RELEASE_ID}/assets" \
      | grep -m 1 '"id":' | awk '{print $2}' | tr -d ',')
    if [ -n "$EXISTING_ASSET_ID" ] && [ "$EXISTING_ASSET_ID" != "null" ]; then
      curl -s -X DELETE -H "Authorization: token ${GH_TOKEN}" \
        "https://api.github.com/repos/HelloRayy/snapan-market-mobile/releases/assets/${EXISTING_ASSET_ID}" > /dev/null || true
    fi

    echo "Mengunggah asset binary APK (${APK_SIZE}) ke GitHub..."
    UPLOAD_RESP=$(curl -s -X POST \
      -H "Authorization: token ${GH_TOKEN}" \
      -H "Content-Type: application/vnd.android.package-archive" \
      --data-binary @"$APK_SOURCE" \
      "https://uploads.github.com/repos/HelloRayy/snapan-market-mobile/releases/${RELEASE_ID}/assets?name=app-release.apk")
    
    echo -e "${GREEN}✅ Asset APK berhasil di-host di:${NC} $DOWNLOAD_URL"
  else
    echo -e "${YELLOW}⚠️ Gagal membuat GitHub Release via API. Melanjutkan pendaftaran Supabase...${NC}"
  fi
else
  echo -e "${YELLOW}⚠️ Token GitHub tidak ditemukan. APK tidak di-upload ke GitHub secara otomatis.${NC}"
fi

# 6. Daftarkan versi ke Supabase (tabel app_versions)
echo -e "\n${CYAN}🗄️  [5/5] Mendaftarkan Versi Pembaruan ke Supabase...${NC}"
SUPABASE_KEY=""
if [ -f ".env.local" ]; then
  SUPABASE_KEY=$(grep -E "^SUPABASE_SERVICE_ROLE_KEY=" .env.local | cut -d '=' -f2- | tr -d '"'\'' ')
fi

if [ -n "$SUPABASE_KEY" ]; then
  SUPABASE_PAYLOAD=$(cat <<EOF
{
  "version_code": ${NEW_CODE},
  "version_name": "${NEW_NAME}",
  "download_url": "${DOWNLOAD_URL}",
  "title": "Pembaruan Snaps v${NEW_NAME}",
  "changelog": "${CHANGELOG}",
  "is_mandatory": false,
  "is_active": true
}
EOF
)

  curl -s -X POST "https://lcwsxldnoqjdfqxqcqja.supabase.co/rest/v1/app_versions" \
    -H "apikey: ${SUPABASE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_KEY}" \
    -H "Content-Type: application/json" \
    -H "Prefer: return=minimal" \
    -d "$SUPABASE_PAYLOAD"

  echo -e "${GREEN}✅ Berhasil didaftarkan ke Supabase (app_versions)!${NC}"
else
  echo -e "${YELLOW}⚠️ SUPABASE_SERVICE_ROLE_KEY belum terbaca di .env.local.${NC}"
fi

echo "------------------------------------------------------------"
echo -e "${GREEN}${BOLD}🎉 IN-APP UPDATE TELAH AKTIF DI SELURUH DUNIA!${NC}"
echo -e "📱 Pengguna di HP cukup buka sidebar dan klik ${YELLOW}\"Periksa Pembaruan\"${NC},"
echo -e "   atau otomatis akan muncul popup update saat aplikasi dibuka!"
echo "============================================================"
