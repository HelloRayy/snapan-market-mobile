#!/usr/bin/env bash
# ==============================================================================
# 🚀 SNAPS MARKET MOBILE - APK BUILD SCRIPT
# ==============================================================================
# Skrip mudah & cepat untuk membangun APK Android (Release / Split-ABI / Debug).
#
# Penggunaan:
#   ./scripts/build_apk.sh            # Bangun Release APK standar (default)
#   ./scripts/build_apk.sh release    # Bangun Single Universal Release APK
#   ./scripts/build_apk.sh split      # Bangun APK Split-per-ABI (Ukuran jauh lebih ramping ~20MB)
#   ./scripts/build_apk.sh debug      # Bangun Debug APK untuk testing cepat
#   ./scripts/build_apk.sh --clean    # Bersihkan build cache (flutter clean) lalu build
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

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

MODE="${1:-release}"

echo -e "${CYAN}${BOLD}"
echo "============================================================"
echo "          📱 SNAPS MARKET - ANDROID APK BUILDER             "
echo "============================================================"
echo -e "${NC}"

# Ambil versi dari pubspec.yaml
if [ -f "pubspec.yaml" ]; then
  APP_VERSION=$(grep -E "^version:" pubspec.yaml | sed -E 's/version:[[:space:]]*//' | tr -d '\r\n')
  VERSION_NAME=$(echo "$APP_VERSION" | cut -d '+' -f1)
  VERSION_CODE=$(echo "$APP_VERSION" | cut -d '+' -f2)
else
  APP_VERSION="Unknown"
  VERSION_NAME="1.0.0"
  VERSION_CODE="1"
fi

echo -e "${BOLD}Versi Aplikasi :${NC} ${GREEN}v${VERSION_NAME} (Build ${VERSION_CODE})${NC}"
echo -e "${BOLD}Target Mode    :${NC} ${YELLOW}${MODE}${NC}"
echo "------------------------------------------------------------"

# Cek apakah user ingin clean build
if [ "$MODE" == "--clean" ] || [ "$2" == "--clean" ]; then
  echo -e "\n${YELLOW}🧹 Membersihkan cache flutter (flutter clean)...${NC}"
  flutter clean
  MODE="${1:-release}"
  if [ "$MODE" == "--clean" ]; then
    MODE="release"
  fi
fi

# Pastikan dependencies Flutter terbaru
echo -e "\n${CYAN}📦 Mengambil paket dependensi Flutter (flutter pub get)...${NC}"
flutter pub get

# Jalankan proses build berdasarkan target mode
case "$MODE" in
  debug)
    echo -e "\n${YELLOW}⚙️  Membangun Debug APK (flutter build apk --debug)...${NC}"
    flutter build apk --debug
    APK_DIR="build/app/outputs/flutter-apk"
    TARGET_APK="$APK_DIR/app-debug.apk"
    ;;

  split)
    echo -e "\n${YELLOW}⚙️  Membangun APK Split-per-ABI (flutter build apk --release --split-per-abi)...${NC}"
    echo -e "${PURPLE}💡 Info: Split-per-ABI menghasilkan APK khusus arsitektur (arm64-v8a) dengan ukuran ~60% lebih ramping!${NC}"
    flutter build apk --release --split-per-abi
    APK_DIR="build/app/outputs/flutter-apk"
    TARGET_APK="$APK_DIR/app-arm64-v8a-release.apk"
    ;;

  release|*)
    echo -e "\n${YELLOW}⚙️  Membangun Release APK Universal (flutter build apk --release)...${NC}"
    flutter build apk --release
    APK_DIR="build/app/outputs/flutter-apk"
    TARGET_APK="$APK_DIR/app-release.apk"
    ;;
esac

echo "------------------------------------------------------------"

# Periksa keberadaan output APK
if [ -f "$TARGET_APK" ]; then
  echo -e "${GREEN}${BOLD}🎉 APK BERHASIL DIBANGUN!${NC}\n"
  
  if [ "$MODE" == "split" ]; then
    echo -e "${BOLD}Daftar File APK yang Dihasilkan:${NC}"
    ls -lh "$APK_DIR"/app-*-release.apk | while read -r line; do
      FILE_SIZE=$(echo "$line" | awk '{print $5}')
      FILE_PATH=$(echo "$line" | awk '{print $9}')
      echo -e "  • ${GREEN}$(basename "$FILE_PATH")${NC} (${BOLD}$FILE_SIZE${NC}) -> $FILE_PATH"
    done
    echo ""
    echo -e "${CYAN}💡 Rekomendasi install untuk HP modern (64-bit):${NC}"
    echo -e "  adb install -r $TARGET_APK"
  else
    FILE_SIZE=$(ls -lh "$TARGET_APK" | awk '{print $5}')
    echo -e "${BOLD}Lokasi File :${NC} ${GREEN}$TARGET_APK${NC}"
    echo -e "${BOLD}Ukuran File :${NC} ${YELLOW}$FILE_SIZE${NC}"
    echo ""
    echo -e "${CYAN}💡 Perintah Install ke HP Android (via ADB):${NC}"
    echo -e "  adb install -r \"$TARGET_APK\""
  fi

  echo ""
  echo -e "${BOLD}Salin APK ke direktori root (opsional):${NC}"
  OUT_ROOT="Snaps-v${VERSION_NAME}-build${VERSION_CODE}.apk"
  cp "$TARGET_APK" "$OUT_ROOT"
  echo -e "  Tersedia juga salinan cepat di: ${GREEN}$OUT_ROOT${NC}"

  echo -e "\n${GREEN}Selesai! Aplikasi siap diuji di HP Android.${NC}"
else
  echo -e "${RED}${BOLD}❌ File APK tidak ditemukan di $TARGET_APK.${NC}"
  echo -e "${YELLOW}Periksa log error kompilasi Flutter di atas.${NC}"
  exit 1
fi
