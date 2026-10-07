#!/usr/bin/env bash
set -e

# ==========================================
# Snapan Market (Snaps) Release Build Script
# ==========================================

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

echo "=========================================="
echo "🚀 Memulai Build Release Snaps Mobile..."
echo "=========================================="

# 1. Pastikan dependencies bersih & up to date
echo "📦 Mengambil dependensi Flutter..."
flutter pub get

# 2. Verifikasi analisis kode
echo "🔍 Menjalankan analisa kode auth..."
flutter analyze lib/features/auth/ || true

# 3. Jalankan pengujian inti
echo "🧪 Menjalankan pengujian..."
flutter test test/student_registry_service_test.dart
flutter test test/auth_controller_nis_test.dart

# 4. Build APK Release
echo "⚙️ Membangun APK Release..."
flutter build apk --release

echo ""
echo "=========================================="
echo "✅ Build Release Berhasil Selesai!"
echo "=========================================="
echo "Hasil APK tersimpan di:"
echo "📁 build/app/outputs/flutter-apk/"
ls -lh build/app/outputs/flutter-apk/*.apk 2>/dev/null || true
echo "=========================================="
