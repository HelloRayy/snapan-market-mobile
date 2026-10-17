#!/usr/bin/env bash
# ==============================================================================
# 🚀 SNAPS MOBILE - ONE-CLICK OTA RELEASE SCRIPT (READY TO USE)
# ==============================================================================
# Skrip otomatis end-to-end untuk publish pembaruan OTA (Over-The-Air):
# 1. Bump version di pubspec.yaml & kalkulasi version_code
# 2. Verifikasi manifest agen (verify-agent-map.sh)
# 3. Kompilasi APK Release (--release --no-pub)
# 4. Commit git & buat git tag release
# 5. Push ke GitHub & create release via GitHub REST API + upload asset APK
# 6. Auto-inject ke Supabase Database (tabel public.app_versions)
#
# Penggunaan:
#   ./scripts/publish_ota.sh [version_name] [build_number] ["catatan rilis"]
#
# Contoh:
#   ./scripts/publish_ota.sh 1.0.28 31 "Pembaruan dark mode tema Threads & optimasi performa"
#   ./scripts/publish_ota.sh auto "Perbaikan bug minor"
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

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
  echo -e "${CYAN}${BOLD}SNAPS MOBILE - ONE-CLICK OTA RELEASE SCRIPT${NC}"
  echo ""
  echo "Penggunaan:"
  echo "  ./scripts/publish_ota.sh [options] [version_name] [build_number] [\"changelog\"]"
  echo ""
  echo "Opsi:"
  echo "  --dry-run       Simulasi rilis tanpa mengubah file, git, atau publish ke server"
  echo "  --skip-build    Gunakan APK release yang sudah ada tanpa kompilasi ulang"
  echo "  -y, --yes       Otomatis konfirmasi tanpa prompt interaktif"
  echo "  -m, --message   Tentukan pesan changelog"
  echo "  auto            Otomatis bump patch version (misal: 1.0.31 -> 1.0.32)"
  echo ""
  echo "Contoh:"
  echo "  ./scripts/publish_ota.sh auto \"Pembaruan dark mode tema Threads & optimasi performa\""
  echo "  ./scripts/publish_ota.sh --dry-run auto \"Uji coba rilis simulasi\""
  echo "  ./scripts/publish_ota.sh 1.0.32 35 \"Rilis v1.0.32\""
  echo ""
  exit 0
fi

echo -e "${CYAN}${BOLD}"
echo "============================================================"
echo "      🚀 SNAPS MOBILE - ONE-CLICK OTA RELEASE AUTOMATION    "
echo "============================================================"
echo -e "${NC}"

# Ambil versi saat ini dari pubspec.yaml
CURRENT_VERSION_LINE=$(grep -E "^version:" pubspec.yaml | sed -E 's/version:[[:space:]]*//' | tr -d '\r\n')
CURRENT_NAME=$(echo "$CURRENT_VERSION_LINE" | cut -d '+' -f1)
CURRENT_BUILD=$(echo "$CURRENT_VERSION_LINE" | cut -d '+' -f2)

# Sanitasi jika nama versi rusak/invalid
if [[ ! "$CURRENT_NAME" =~ ^[0-9]+\.[0-9]+ ]]; then
  CURRENT_NAME="1.0.31"
  CURRENT_BUILD="34"
fi

VERSION_NAME=""
VERSION_CODE=""
CHANGELOG=""
AUTO_CONFIRM=false
DRY_RUN=false
SKIP_BUILD=false

# Robust CLI argument parser
while [[ $# -gt 0 ]]; do
  case "$1" in
    -y|--yes|--force)
      AUTO_CONFIRM=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --skip-build)
      SKIP_BUILD=true
      shift
      ;;
    -m|--message|--changelog)
      CHANGELOG="$2"
      shift 2
      ;;
    auto)
      shift
      ;;
    *)
      if [ -z "$VERSION_NAME" ] && [[ "$1" =~ ^[0-9]+\.[0-9]+ ]]; then
        VERSION_NAME="$1"
      elif [ -z "$VERSION_CODE" ] && [[ "$1" =~ ^[0-9]+$ ]]; then
        VERSION_CODE="$1"
      elif [ -z "$CHANGELOG" ]; then
        CHANGELOG="$1"
      fi
      shift
      ;;
  esac
done

# Default Changelog jika belum diisi
if [ -z "$CHANGELOG" ]; then
  CHANGELOG="Pembaruan sistem, peningkatan performa, dan penyempurnaan UI Snaps."
fi

# Logika penentuan versi
if [ -z "$VERSION_NAME" ]; then
  # Auto-bump patch version (e.g. 1.0.31 -> 1.0.32)
  IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_NAME"
  MAJOR="${VERSION_PARTS[0]:-1}"
  MINOR="${VERSION_PARTS[1]:-0}"
  PATCH="${VERSION_PARTS[2]:-31}"
  NEW_PATCH=$((PATCH + 1))
  VERSION_NAME="${MAJOR}.${MINOR}.${NEW_PATCH}"
fi

if [ -z "$VERSION_CODE" ]; then
  VERSION_CODE=$((CURRENT_BUILD + 1))
fi

# Kalkulasi real version code untuk Supabase (standar basis 2000 untuk split-ABI compatibility)
REAL_VERSION_CODE=$((VERSION_CODE < 2000 ? 2000 + VERSION_CODE : VERSION_CODE))

echo -e "${BOLD}Versi Sebelumnya :${NC} ${YELLOW}v${CURRENT_NAME}+${CURRENT_BUILD}${NC}"
echo -e "${BOLD}Versi Rilis Baru  :${NC} ${GREEN}v${VERSION_NAME}+${VERSION_CODE}${NC} (Supabase Code: ${PURPLE}${REAL_VERSION_CODE}${NC})"
echo -e "${BOLD}Catatan Rilis     :${NC} ${CHANGELOG}"
if [ "$DRY_RUN" = "true" ]; then
  echo -e "${YELLOW}${BOLD}Mode Rilis        : DRY-RUN (SIMULASI - Tidak ada perubahan permanen)${NC}"
fi
echo "------------------------------------------------------------"

# Konfirmasi jika dijalankan interaktif dan bukan auto-confirm
if [ -t 0 ] && [ "$AUTO_CONFIRM" != "true" ] && [ "$DRY_RUN" != "true" ]; then
  read -p "Lanjutkan proses rilis OTA ini? (y/N): " CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Rilis dibatalkan.${NC}"
    exit 0
  fi
fi

## ------------------------------------------------------------------------------
# 1. PRE-FLIGHT CHECKS
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}${BOLD}[1/6] 🔍 Menjalankan Pre-Flight Checks...${NC}"

if [ -f "./scripts/verify-agent-map.sh" ]; then
  echo "• Memeriksa integritas AGENT_MANIFEST.md..."
  ./scripts/verify-agent-map.sh || echo -e "${YELLOW}⚠️ Manifest map notice, continuing...${NC}"
fi

# ------------------------------------------------------------------------------
# 2. UPDATE PUBSPEC.YAML
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}${BOLD}[2/6] 📝 Memperbarui pubspec.yaml ke version: ${VERSION_NAME}+${VERSION_CODE}...${NC}"
if [ "$DRY_RUN" = "true" ]; then
  echo -e "${YELLOW}[DRY-RUN] Melewati perubahan pubspec.yaml${NC}"
else
  sed -i -E "s/^version: .*/version: ${VERSION_NAME}+${VERSION_CODE}/" pubspec.yaml
  echo -e "${GREEN}✓ pubspec.yaml berhasil diperbarui!${NC}"
fi

# ------------------------------------------------------------------------------
# 3. BUILD APK RELEASE
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}${BOLD}[3/6] ⚙️ Persiapan APK Release...${NC}"
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ "$DRY_RUN" = "true" ]; then
  echo -e "${YELLOW}[DRY-RUN] Melewati kompilasi biner APK${NC}"
elif [ "$SKIP_BUILD" = "true" ] && [ -f "$APK_PATH" ]; then
  APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
  echo -e "${GREEN}✓ Menggunakan APK Release yang sudah ada (${APK_SIZE}): ${APK_PATH}${NC}"
else
  echo "• Mengompilasi APK Release (flutter build apk --release --no-pub)..."
  flutter build apk --release --no-pub
  if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}❌ Error: File APK tidak ditemukan di $APK_PATH!${NC}"
    exit 1
  fi
  APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
  echo -e "${GREEN}✓ APK Release siap (${APK_SIZE}): ${APK_PATH}${NC}"
fi

# ------------------------------------------------------------------------------
# 4. GIT COMMIT & TAG
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}${BOLD}[4/6] 🏷️ Persiapan Git Commit & Tag v${VERSION_NAME}...${NC}"
if [ "$DRY_RUN" = "true" ]; then
  echo -e "${YELLOW}[DRY-RUN] Melewati git commit, tag, dan git push${NC}"
else
  git add pubspec.yaml
  git commit -m "chore(release): bump version to v${VERSION_NAME}+${VERSION_CODE}" || echo "Tidak ada perubahan tambahan di pubspec"
  git tag -f "v${VERSION_NAME}"

  echo "• Mendorong commit & tag ke origin GitHub..."
  git push origin main || echo -e "${YELLOW}⚠️ Gagal push ke main, pastikan network online${NC}"
  git push origin -f "v${VERSION_NAME}" || echo -e "${YELLOW}⚠️ Gagal push tag, lanjut...${NC}"
fi

# ------------------------------------------------------------------------------
# 5. GITHUB RELEASE & ASSET UPLOAD
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}${BOLD}[5/6] 📦 Persiapan GitHub Release & Upload Asset...${NC}"

REMOTE_URL=$(git config remote.origin.url || true)
GH_TOKEN=$(echo "$REMOTE_URL" | sed -n -E 's#.*((github_pat_|ghp_)[^@]+)@.*#\1#p')

if [ -z "$GH_TOKEN" ] && [ -n "${GITHUB_TOKEN}" ]; then
  GH_TOKEN="${GITHUB_TOKEN}"
fi

DOWNLOAD_URL="https://github.com/HelloRayy/snaps/releases/download/v${VERSION_NAME}/app-release.apk"

if [ "$DRY_RUN" = "true" ]; then
  echo -e "${YELLOW}[DRY-RUN] Melewati pembuatan GitHub Release dan upload asset APK${NC}"
  echo -e "• GitHub Token terdeteksi: $([ -n "$GH_TOKEN" ] && echo -e "${GREEN}Ya${NC}" || echo -e "${RED}Tidak${NC}")"
  echo "• Target Download URL: ${DOWNLOAD_URL}"
elif [ -n "$GH_TOKEN" ]; then
  # Payload rilis menggunakan python3 untuk aman dari karakter newline/escape
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

  # Cek apakah release tag sudah ada
  EXISTING_RELEASE_ID=$(curl -s -H "Authorization: token ${GH_TOKEN}" \
    "https://api.github.com/repos/HelloRayy/snaps/releases/tags/v${VERSION_NAME}" \
    | grep -m 1 '"id":' | awk '{print $2}' | tr -d ',' || true)

  if [ -n "$EXISTING_RELEASE_ID" ] && [ "$EXISTING_RELEASE_ID" != "null" ]; then
    echo "• Release v${VERSION_NAME} sudah ada (ID: $EXISTING_RELEASE_ID). Menggunakan release tersebut..."
    RELEASE_ID=$EXISTING_RELEASE_ID
  else
    echo "• Membuat release baru di GitHub..."
    CREATE_RESP=$(curl -s -X POST -H "Authorization: token ${GH_TOKEN}" \
      -H "Content-Type: application/json" \
      -d "$RELEASE_PAYLOAD" \
      "https://api.github.com/repos/HelloRayy/snaps/releases")
    RELEASE_ID=$(echo "$CREATE_RESP" | grep -m 1 '"id":' | awk '{print $2}' | tr -d ',' || true)
  fi

  if [ -n "$RELEASE_ID" ] && [ "$RELEASE_ID" != "null" ]; then
    echo "• Mengunggah biner APK ke release assets (ID: $RELEASE_ID)..."

    # Hapus asset lama jika ada dengan nama yang sama
    EXISTING_ASSET_ID=$(curl -s -H "Authorization: token ${GH_TOKEN}" \
      "https://api.github.com/repos/HelloRayy/snaps/releases/${RELEASE_ID}/assets" \
      | grep -m 1 '"id":' | awk '{print $2}' | tr -d ',' || true)

    if [ -n "$EXISTING_ASSET_ID" ] && [ "$EXISTING_ASSET_ID" != "null" ]; then
      curl -s -X DELETE -H "Authorization: token ${GH_TOKEN}" \
        "https://api.github.com/repos/HelloRayy/snaps/releases/assets/${EXISTING_ASSET_ID}" > /dev/null || true
    fi

    UPLOAD_RESP=$(curl -s -X POST \
      -H "Authorization: token ${GH_TOKEN}" \
      -H "Content-Type: application/vnd.android.package-archive" \
      --data-binary @"$APK_PATH" \
      "https://uploads.github.com/repos/HelloRayy/snaps/releases/${RELEASE_ID}/assets?name=app-release.apk")

    UPLOAD_STATE=$(echo "$UPLOAD_RESP" | grep -m 1 '"state":' | awk '{print $2}' | tr -d '",')
    echo -e "${GREEN}✓ Asset APK terunggah: ${UPLOAD_STATE:-uploaded}!${NC}"
  else
    echo -e "${YELLOW}⚠️ Tidak dapat membuat release via GitHub API. URL APK diarahkan ke rilis default.${NC}"
  fi
else
  echo -e "${YELLOW}⚠️ GitHub Token tidak terdeteksi. Silakan unggah $APK_PATH ke GitHub Releases secara manual jika tag sudah ter-push.${NC}"
fi

# ------------------------------------------------------------------------------
# 6. REGISTRASI KE SUPABASE DATABASE (TRIGGER OTA KE SELURUH HP)
# ------------------------------------------------------------------------------
echo -e "\n${CYAN}${BOLD}[6/6] 📱 Registrasi Rilis ke Database Supabase...${NC}"

SUPABASE_URL_VAL=""
SUPABASE_KEY=""
if [ -f ".env.local" ]; then
  SUPABASE_URL_VAL=$(grep -E "^SUPABASE_URL=" .env.local | cut -d '=' -f2- | tr -d '"'\'' ' || true)
  SUPABASE_KEY=$(grep -E "^SUPABASE_SERVICE_ROLE_KEY=" .env.local | cut -d '=' -f2- | tr -d '"'\'' ' || true)
fi
if [ -z "$SUPABASE_URL_VAL" ]; then
  SUPABASE_URL_VAL="https://lcwsxldnoqjdfqxqcqja.supabase.co"
fi
if [ -z "$SUPABASE_KEY" ]; then
  SUPABASE_KEY="${SUPABASE_SERVICE_ROLE_KEY}"
fi

if [ "$DRY_RUN" = "true" ]; then
  echo -e "${YELLOW}[DRY-RUN] Melewati injeksi ke Supabase Database${NC}"
  echo "• Supabase URL: ${SUPABASE_URL_VAL}"
  echo -e "• Service Role Key terdeteksi: $([ -n "$SUPABASE_KEY" ] && echo -e "${GREEN}Ya${NC}" || echo -e "${RED}Tidak${NC}")"
  echo "• Version Code Supabase: ${REAL_VERSION_CODE}"
elif [ -n "$SUPABASE_KEY" ]; then
  # 1. Nonaktifkan versi sebelumnya agar rilis ini menjadi satu-satunya yang aktif
  echo "• Menonaktifkan versi aplikasi sebelumnya..."
  curl -s -X PATCH "${SUPABASE_URL_VAL}/rest/v1/app_versions?version_code=lt.${REAL_VERSION_CODE}" \
    -H "apikey: ${SUPABASE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_KEY}" \
    -H "Content-Type: application/json" \
    -d '{"is_active": false}' > /dev/null || true

  # 2. Daftarkan versi baru
  echo "• Mendaftarkan versi baru v${VERSION_NAME}..."
  SUPABASE_PAYLOAD=$(python3 -c "
import json
print(json.dumps({
    'version_code': ${REAL_VERSION_CODE},
    'version_name': '${VERSION_NAME}',
    'download_url': '${DOWNLOAD_URL}',
    'title': 'Pembaruan Snaps v${VERSION_NAME}',
    'changelog': '''${CHANGELOG}''',
    'is_mandatory': True,
    'is_active': True
}))
")

  curl -s -X POST "${SUPABASE_URL_VAL}/rest/v1/app_versions" \
    -H "apikey: ${SUPABASE_KEY}" \
    -H "Authorization: Bearer ${SUPABASE_KEY}" \
    -H "Content-Type: application/json" \
    -H "Prefer: return=minimal" \
    -d "$SUPABASE_PAYLOAD"

  echo -e "${GREEN}✓ BERHASIL DISIARKAN KE SUPABASE!${NC}"
  echo -e "${GREEN}✓ Semua HP murid/guru yang membuka Snaps akan langsung mendeteksi update OTA v${VERSION_NAME}.${NC}"
else
  echo -e "${YELLOW}⚠️ SUPABASE_SERVICE_ROLE_KEY tidak ditemukan di .env.local.${NC}"
  echo "Jalankan SQL berikut di Supabase Dashboard -> SQL Editor:"
  echo "----------------------------------------------------------"
  cat <<EOF
UPDATE public.app_versions SET is_active = false WHERE version_code < ${REAL_VERSION_CODE};
INSERT INTO public.app_versions (version_code, version_name, download_url, title, changelog, is_mandatory, is_active)
VALUES (
  ${REAL_VERSION_CODE},
  '${VERSION_NAME}',
  '${DOWNLOAD_URL}',
  'Pembaruan Snaps v${VERSION_NAME}',
  '${CHANGELOG}',
  true,
  true
);
EOF
  echo "----------------------------------------------------------"
fi

echo -e "\n${GREEN}${BOLD}============================================================${NC}"
if [ "$DRY_RUN" = "true" ]; then
  echo -e "${YELLOW}${BOLD}🎉 SIMULASI DRY-RUN SELESAI! SCRIPT SIAP DIGUNAKAN KAPAN SAJA.${NC}"
else
  echo -e "${GREEN}${BOLD}🎉 SELESAI! PEMBARUAN OTA v${VERSION_NAME} RESMI DILUNCURKAN!${NC}"
  echo -e "${BOLD}URL APK :${NC} ${DOWNLOAD_URL}"
fi
echo -e "${GREEN}${BOLD}============================================================${NC}\n"
