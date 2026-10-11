# Project Guidelines & Rules

## ⚠️ Strict Directives for Antigravity AI Agent

1. **100% Exclusive Flutter Mobile App Focus (`lib/`)**:
   - All tasks, feature implementations, and bug fixes must focus solely on Flutter mobile app code in `lib/`.
   - Skip website/PWA (`src/`) unless explicitly requested by the user.

2. **NO Playwright Without Explicit User Command**:
   - **STRICTLY PROHIBITED**: Running Playwright, headless browser, or screenshot capture tasks on your own initiative.
   - ONLY run Playwright if the user explicitly orders: "buka playwright", "ambil screenshot", "take a capture".
   - Execute edits directly, cleanly, and fast.

3. **NO Flutter Test / Analyze**:
   - Do not waste time running `flutter test` or `flutter analyze`. Focus 100% on direct code generation.

4. **NO Mandatory `flutter build bundle`**:
   - Do not run or require `flutter build bundle` routinely. Move directly to commit and push after clean code generation.

5. **Domain Heuristic Routing (Maksimal 2 Tool Calls, Zero-MD Overhead)**:
   - **Zero-MD Reading untuk Task Lokal**: Jika instruksi user menyebut domain (contoh: *checkout*, *feed*, *auth*, *profile*, *chat*, *map*, *notif*), agen **DILARANG membaca file `.md` apa pun**.
   - **Kunci Folder Langsung**:
     - *checkout* $\rightarrow$ `lib/features/checkout/components/`
     - *feed/post/poll/komen* $\rightarrow$ `lib/features/feed/components/`
     - *auth/login/nis* $\rightarrow$ `lib/features/auth/components/`
     - *profil/bio/avatar* $\rightarrow$ `lib/features/profile/components/`
     - *chat/dm* $\rightarrow$ `lib/features/messages/`
     - *lokasi/denah* $\rightarrow$ `lib/features/locations/` atau `lib/features/map/`
   - **Protokol 2 Tool Calls**: Panggilan 1 (`find_by_name` folder domain) $\rightarrow$ Panggilan 2 (`replace_file_content` leaf file). Selesai dalam < 15 detik!
   - **File .MD Sebagai Fallback Saja**: [`AGENT_MANIFEST.md`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/AGENT_MANIFEST.md) HANYA dibuka jika pencarian domain nihil. Dilarang blind grep di root.

6. **Graphify Role (Architectural & Refactoring Tool)**:
   - Graphify (`graphify-out/`) is maintained for visual architecture inspection, dependency tracing, and community clustering.
   - Do NOT run CLI `graphify query` on simple bug fixes or UI updates to avoid CLI latency and token bloat. Use [`AGENT_MANIFEST.md`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/AGENT_MANIFEST.md) for direct file navigation.
   - The git hook will continue to update the graph in the background after commits.

7. **Strict File Size Cap (Max 250–300 Lines)**:
   - Decompose any UI screen or service >250 lines into atomic sub-components in `<feature>/components/`.

8. **Screenshot-to-Code & Visual Grounding SOP (Zero Unnecessary File Reads)**:
   - **Zero .MD Reading**: Dilarang membaca file `.md` saat menerima screenshot UI.
   - **OCR First**: Ekstrak teks/label unik dari screenshot, lalu jalankan `git grep -i "kata_kunci" lib/features/` untuk mengunci widget target.
   - **Dynamic/L10n Fallback**: Jika teks dinamis (harga/user), kenali domain visual layar (Feed, Checkout, Profile, Auth) dan langsung cari di folder `lib/features/<domain>/components/`.
   - **Surgical Edit**: Buka HANYA file leaf component dan edit dengan `replace_file_content`. Jangan pernah mengedit screen orchestrator untuk komponen anak.

9. **Strict Read-Only Directive for Plane.so (`/plane`)**:
   - Plane.so access via MCP tools or `/plane` is 100% read-only (reading issue details, descriptions, requirements).
   - The agent has ZERO authority to update issue states (e.g. moving from Todo/In Progress to Done, or vice versa).
   - State changes and ticket transitions are strictly managed manually by the user.

10. **Mandatory Build APK Release & In-App Update Response Format**:
    - Whenever the user asks to build an APK release or prepare a release, always output both options:
      - **Cara 1: Otomatis via Script**: `./scripts/auto_release.sh <new_version_name> <new_version_code> "<changelog>"` (1. Bump pubspec, 2. Build APK, 3. Tag & push git, 4. Upload GitHub Release, 5. Inject Supabase `app_versions`).
      - **Cara 2: Manual Langkah demi Langkah**: (1) Naikkan Versi di `pubspec.yaml`, (2) `flutter build apk --release`, (3) Upload File APK ke GitHub Release, (4) Query SQL `INSERT INTO public.app_versions` di Supabase Dashboard.

11. **Long-Term Codebase Maintainability & Standards for New AI Agents**:
    - **Single Source of Truth**: Wajib membaca [`docs/coding-standards.md`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/docs/coding-standards.md) dan [`docs/clean-code-architecture.md`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/docs/clean-code-architecture.md).
    - **Anti-Monolith & Separation of Concerns**: Batas maksimal panjang file 250–300 baris. Dilarang menumpuk private helper methods (`_buildX()`) di file screen. Pecah komponen ke `<feature>/components/`.
    - **Zero Raw DB Queries in Widgets**: Semua pemanggilan data melalui `Controller` atau `Service`. UI widget hanya bertanggung jawab merender antarmuka.
    - **Design Tokens**: Selalu gunakan `AppColors.*` (`lib/core/theme/app_colors.dart`), `LucideIcons.*`, dan `SnapsLogo`.
    - **Touch Targets**: Pastikan setiap elemen interaktif memiliki hit area minimal 44x44 dp dengan haptic feedback yang tepat.

12. **Surgical Dual-Read & AGENT_MANIFEST Mandate**:
    - **Single Source of Truth**: Wajib periksa [`AGENT_MANIFEST.md`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/AGENT_MANIFEST.md) di root (<80 baris) jika butuh konteks arsitektur dan peta rute.
    - **Interface-First Dual-Read**:
      - Jika task murni styling/UI visual: Cukup baca Leaf Component (deklarasi konstruktor & method `build()`). Dilarang membaca controller jika props tidak berubah.
      - Jika task mengubah alur data/state: Baca pasangan [Parent Orchestrator / Controller] + [Leaf Component] sekaligus dalam 1 batch call untuk menjaga kontrak parameter.
    - **Pre-Commit Guard**: Skrip `./scripts/verify-agent-map.sh` otomatis memvalidasi manifest di pre-commit hook untuk mencegah path stale.

