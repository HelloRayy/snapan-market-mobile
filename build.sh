#!/usr/bin/env bash
# ==============================================================================
# 🚀 SNAPS MARKET - ALL-IN-ONE FLUTTER APK BUILD & INSTALL SCRIPT
# ==============================================================================
# Cukup jalankan:
#   ./build.sh
#
# Skrip ini otomatis:
# 1. Mengambil dependensi Flutter (flutter pub get)
# 2. Mengompilasi Release APK Android (flutter build apk --release)
# 3. Menyalin APK langsung ke direktori utama (Snaps-Market.apk)
# 4. Mendeteksi HP Android via USB/ADB: Jika tercolok, otomatis langsung ter-install!
# ==============================================================================

set -e

# Warna Terminal
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo -e "${CYAN}${BOLD}"
echo "============================================================"
echo "      🚀 SNAPS MARKET - ALL-IN-ONE APK BUILDER & INSTALLER  "
echo "============================================================"
echo -e "${NC}"

# 1. Baca informasi versi dari pubspec.yaml
if [ -f "pubspec.yaml" ]; then
  APP_VERSION=$(grep -E "^version:" pubspec.yaml | sed -E 's/version:[[:space:]]*//' | tr -d '\r\n')
  VERSION_NAME=$(echo "$APP_VERSION" | cut -d '+' -f1)
  VERSION_CODE=$(echo "$APP_VERSION" | cut -d '+' -f2)
else
  VERSION_NAME="1.0.4"
  VERSION_CODE="5"
fi

echo -e "${BOLD}📱 Versi Aplikasi :${NC} ${GREEN}v${VERSION_NAME} (Build ${VERSION_CODE})${NC}"
echo -e "${BOLD}🕒 Waktu Mulai     :${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo "------------------------------------------------------------"

# 2. Perbarui dependensi Flutter
echo -e "\n${CYAN}📦 [1/4] Memeriksa dependensi Flutter...${NC}"
flutter pub get

# 3. Kompilasi APK Release Flutter
echo -e "\n${YELLOW}⚙️  [2/4] Mengompilasi APK Release Android (Harap tunggu)...${NC}"
flutter build apk --release

SOURCE_APK="build/app/outputs/flutter-apk/app-release.apk"
if [ ! -f "$SOURCE_APK" ]; then
  echo -e "\n${RED}❌ Error: File APK tidak ditemukan di $SOURCE_APK${NC}"
  exit 1
fi

# 4. Salin APK ke folder root agar sangat mudah diakses
echo -e "\n${CYAN}📂 [3/4] Menyalin APK ke folder utama...${NC}"
ROOT_APK="Snaps-Market.apk"
VERSIONED_APK="Snaps-v${VERSION_NAME}-build${VERSION_CODE}.apk"

cp "$SOURCE_APK" "$ROOT_APK"
cp "$SOURCE_APK" "$VERSIONED_APK"

APK_SIZE=$(ls -lh "$ROOT_APK" | awk '{print $5}')

# 5. Cek apakah ada HP Android yang terhubung via ADB/USB
echo -e "\n${CYAN}🔌 [4/4] Memeriksa perangkat Android via USB/ADB...${NC}"
DEVICE_LIST=$(adb devices 2>/dev/null | grep -w "device" | awk '{print $1}' || true)

echo "------------------------------------------------------------"
echo -e "${GREEN}${BOLD}🎉 APK FLUTTER BERHASIL DIBUAT DENGAN SEMPURNA!${NC}\n"
echo -e "${BOLD}📦 File APK Siap Pakai:${NC}"
echo -e "   • ${GREEN}${ROOT_APK}${NC} (${BOLD}${APK_SIZE}${NC})  <-- [Paling Praktis]"
echo -e "   • ${GREEN}${VERSIONED_APK}${NC} (${BOLD}${APK_SIZE}${NC})"
echo -e "   • ${GREEN}${SOURCE_APK}${NC}"
echo ""

if [ -n "$DEVICE_LIST" ]; then
  DEVICE_COUNT=$(echo "$DEVICE_LIST" | wc -l)
  echo -e "${GREEN}📱 Terdeteksi ${DEVICE_COUNT} perangkat HP Android terhubung via USB!${NC}"
  for dev in $DEVICE_LIST; do
    echo -e "${YELLOW}📲 Memasang Snaps-Market.apk ke HP ($dev)...${NC}"
    adb -s "$dev" install -r "$ROOT_APK"
    echo -e "${GREEN}✅ Berhasil terpasang di HP ($dev)!${NC}"
  done
else
  echo -e "${YELLOW}💡 Belum ada HP yang dicolok kabel USB.${NC}"
  echo -e "   Jika ingin langsung pasang ke HP, colok USB & jalankan:"
  echo -e "   ${CYAN}adb install -r ${ROOT_APK}${NC}"
  echo -e "   Atau langsung copy file ${GREEN}${ROOT_APK}${NC} ke HP Anda."
fi

echo "============================================================"
