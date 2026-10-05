# Repository Guidelines

## Project Overview
**Snapan Market Mobile (sNaps)** is a mobile-first app designed exclusively for the **SMKN 8 Semarang** student ecosystem, integrating an e-commerce vocational marketplace with a Threads-style social networking feed. The platform allows students and staff to circulate preloved school supplies, commercialize vocational works (PPLG, DKV, Kuliner), place COD orders with designated campus meeting points, and interact in academic community discussion threads.

---

## 🎯 Primary Agent Mandate: Exclusive Flutter Mobile Focus

1. **Flutter Mobile App First & Only (`lib/`)**:
   - All feature implementations, UI slicing, bug fixes, refactorings, and optimizations must target the **Flutter codebase (`lib/`)**.
   - **Skip Website / PWA (`src/`)**: Do NOT modify or work on web/PWA files in `src/` unless explicitly instructed by the user.

2. **Source of Truth for Visual Design & Flow**:
   - The React components in `src/ui/` may only be used as a **visual & functional reference** for porting UI/UX flows into Flutter widgets in `lib/`.
   - Target high fidelity (>= 90% visual & spatial parity) with clean idiomatic Flutter code.

---

## ⚠️ Strict Agent Execution Directives (Prohibited Commands)

1. **STRICTLY PROHIBITED: `flutter test` and `flutter analyze`**:
   - Never run `flutter test`, `flutter analyze`, or routine analysis commands.
   - Do not waste tool calls, round-trips, or token budget on running repetitive analyzers or test runners.
   - Guarantee syntactic and architectural correctness directly through clean, production-ready code.

2. **NO Mandatory `flutter build bundle`**:
   - Never mandate or routinely execute `flutter build bundle` after writing code.
   - Do not run `flutter build bundle` on your own initiative; proceed directly with verification through code analysis and immediate commit/push unless the user explicitly asks to run a build.

3. **STRICTLY PROHIBITED: Playwright / Headless Browser Without Explicit Order**:
   - Never launch Playwright, headless browser, or screenshot capture tasks on your own initiative.
   - Only run Playwright IF AND ONLY IF the user explicitly orders it (e.g. "buka playwright", "ambil screenshot").

4. **100% Focus on Direct Flutter Codebase Generation**:
   - Generate, refactor, and update Flutter widgets, models, controllers, and services in `lib/` in one clean pass.
   - Apply clean widget decomposition, idiomatic Dart naming, proper null safety, and const constructor optimization.

5. **Deterministic Routing via `CODEBASE_AGENT_MAP.md` (Zero Blind Reads)**:
   - **STRICTLY PROHIBITED: Blind grep in root directory or sequential grep spirals**. Never search across all 600+ files simultaneously.
   - **MANDATORY**: Consult [`CODEBASE_AGENT_MAP.md`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/CODEBASE_AGENT_MAP.md) first to identify the exact file, controller, and screen before calling `view_file`.
   - **Strictly Scoped Searches**: If searching for a symbol or text, always scope your search pattern to a specific subfolder (e.g. `lib/features/feed/` or `src/admin/`).

6. **Graphify Role (Architectural & Refactoring Tool)**:
   - Graphify (`graphify-out/`) is maintained for visual knowledge graphs, community clustering, and cross-module circular dependency detection.
   - **Do NOT run CLI `graphify query` on standard bug fixes or UI tasks**, as it adds process latency and token overhead. Use `CODEBASE_AGENT_MAP.md` for instant direct file location.
   - Keep the git hook intact for background index updates when commits are made.

7. **Strict File Size Cap (Max 250–300 Lines Per File)**:
   - Every Dart file must be strictly bounded in size (target <= 250 lines, hard cap 300 lines).
   - If a screen, widget, or service exceeds 250 lines, it MUST be decomposed into modular single-responsibility sub-components in `<feature>/components/`.
   - Never write monolithic screens that inline all sub-widgets with private helper methods (`_buildHeader`, `_buildCard`, `_buildForm`). Decompose into separate widget classes in separate files.

8. **Instant Screenshot-to-Code Protocol (Zero Wasted Reads)**:
   - When the user provides a screenshot or asks for a UI fix:
     - **Step 1: Visual Text Grep**: Identify unique visible text/labels from the screenshot (e.g. "Kategori", "Detail Produk", "Kirim Pesan"). Run:
       ```bash
       git grep -i "kata_kunci" lib/
       ```
     - **Step 2: UI Map Reference**: If text is dynamic (e.g. price, user name), consult `docs/UI_MAP.md` to pinpoint the exact screen and sub-component file in one shot.
     - **Step 3: Surgical Target Read**: Open ONLY the identified component file using `view_file`. NEVER read full screen orchestrators when fixing a sub-component.
     - **Step 4: Surgical Edit**: Edit using `replace_file_content` directly on the modular component.

9. **Modular Architecture Structure Convention**:
   - Screens (`<feature>/screens/`) must only serve as orchestrators (Scaffold, AppBar, layout structure, scroll view, state binding).
   - Visual cards, bottom sheets, headers, and form sections must live in `<feature>/components/`.
   - Backend services must follow domain separation under `lib/core/services/supabase/`.

10. **Strict Read-Only Directive for Plane.so (`/plane`)**:
    - All interactions with Plane.so via MCP tools or `/plane` are **STRICTLY READ-ONLY**.
    - The agent is permitted ONLY to read issue summaries, task descriptions, problem contexts, and requirements (e.g. via `get-issue`, `list-issues`, `get-project`).
    - **ZERO AUTHORITY TO MUTATE ISSUE STATES**: The agent is strictly prohibited from mutating issue states or changing statuses (e.g., Todo to In Progress, In Progress to Done, or vice versa).
    - Status transitions and ticket management on Plane.so are the exclusive prerogative of the user.

11. **Mandatory Standard Response Format for Build APK Release & In-App Update**:
    - Whenever the user asks to build an APK release, prepare a release, or requests the release procedure, the agent MUST ALWAYS provide both options (Script Otomatis & Langkah Manual) with dynamic version calculation:
      ```markdown
      ### Cara 1: Otomatis Penuh via Script (Rekomendasi)

      Jalankan satu perintah di terminal:
      ```bash
      ./scripts/auto_release.sh <new_version_name> <new_version_code> "<changelog>"
      ```

      **Urutan proses yang dieksekusi script secara otomatis**:
      1. Memperbarui versi di `pubspec.yaml` ke `version: <new_version_name>+<new_version_code>`.
      2. Menjalankan `flutter build apk --release --no-pub`.
      3. Commit Git, membuat Git Tag `v<new_version_name>`, dan push ke remote (`main` & tag).
      4. Membuat GitHub Release via API dan mengunggah file `app-release.apk` sebagai release asset.
      5. Menyuntikkan rilis baru ke tabel Supabase `public.app_versions` via REST API (otomatis memicu OTA popup di HP siswa).

      ---

      ### Cara 2: Manual Langkah demi Langkah

      1. **Naikkan Versi**:
         Buka `pubspec.yaml`, ubah nomor versi (angka setelah `+` harus lebih besar dari versi terpasang):
         ```yaml
         version: <new_version_name>+<new_version_code>
         ```

      2. **Build APK**:
         ```bash
         flutter build apk --release
         ```

      3. **Upload File APK ke GitHub Release**:
         - Buat release baru di GitHub dengan tag `v<new_version_name>`.
         - Lampirkan file `build/app/outputs/flutter-apk/app-release.apk`.
         - URL download menjadi:
           ```text
           https://github.com/HelloRayy/snapan-market-mobile/releases/download/v<new_version_name>/app-release.apk
           ```

      4. **Aktifkan Pembaruan di Supabase**:
         Buka Supabase Dashboard > SQL Editor, jalankan:
         ```sql
         INSERT INTO public.app_versions (
           version_code,
           version_name,
           download_url,
           title,
           changelog,
           is_mandatory,
           is_active
         ) VALUES (
           <new_version_code>,
           '<new_version_name>',
           'https://github.com/HelloRayy/snapan-market-mobile/releases/download/v<new_version_name>/app-release.apk',
           'Pembaruan Snaps v<new_version_name>',
           '<descriptive changelog of recent features & fixes>',
           false,
           true
         );
         ```
      ```

12. **Waspada Isu & Penyakit Output AI (Panduan Kualitas & Akal Sehat)**:
    - **Jangan Asal Kelihatan Bener tapi Logikanya Ngaco**: Output atau kode jangan cuma yang penting kelihatan rapi atau nggak error di layar, tapi begitu dipakai alurnya malah berantakan. Pastikan **logika** alur dari awal sampai akhir nyambung dan masuk akal (misalnya hitungan harga nggak salah, alur beli barang tepat, dan status nggak nyangkut).
    - **Jangan Suka Ngarang (Halusinasi)**: Jangan pernah mengarang tombol, nama fitur, file, atau data yang aslinya nggak ada di aplikasi. Kalau memang belum tahu atau datanya belum jelas, langsung tanya ke pengguna, jangan sok tahu atau ngarang bebas.
    - **Jangan Bikin Masalah Baru (Efek Domino)**: Waktu disuruh benerin satu bagian kecil, jangan asal utak-atik bagian lain yang sudah jalan normal. Niatnya benerin satu hal, jangan sampai malah ngerusak fitur lain yang sudah rapi.
    - **Jangan Cuma Janji Manis**: Jangan gampang bilang "sudah beres", "sudah aman", atau "sudah ditest" kalau aslinya cuma dikira-kira di kepala doang. Lebih baik jujur dan teliti cek logikanya daripada ngasih rasa aman palsu.
    - **Bicara Jelas, Jangan Bertele-tele**: Jelaskan apa yang dikerjakan dengan bahasa manusia yang santai dan to the point. Hindari ceramah teori panjang lebar atau istilah rumit yang bikin pusing.
    - **Pikirkan Rasa Nyata Pas Dipakai Manusia**: Sadari bahwa AI nggak megang HP langsung. Jangan bikin tombol yang kekecilan buat dipencet jempol, tulisan yang numpuk/kepotong, atau alur yang bikin orang bingung waktu pakai aplikasinya.

---

## Flutter Architecture & Modular Structure (`lib/`)

The mobile application follows a **feature-first modular architecture**:

```
lib/
├── main.dart                          # App bootstrap, MaterialApp, theme, route table
├── core/
│   ├── theme/                         # Global design tokens (app_colors.dart, typography)
│   ├── components/                    # Atomic reusable widgets (snaps_logo.dart, kumo_button.dart)
│   ├── constants/                     # App-wide constants and asset paths
│   ├── navigation/                    # Custom page route transitions (app_slide_page_route.dart)
│   ├── services/                      # Shared global services (Supabase client, local storage)
│   └── utils/                         # Formatters (rupiah, dates), haptics, helpers
└── features/                          # Feature-first modules
    ├── feed/                          # Home feed timeline, thread cards, post detail screens
    ├── locations/                     # Campus COD meeting points picker & spot cards
    ├── checkout/                      # COD checkout flow, price breakdowns, seller cards
    ├── map/                           # 2D campus blueprint interactive map painter
    ├── messages/                      # Direct messages, chat rooms, product cards
    ├── search/                        # Explore screen, tag filters, user discovery
    ├── create_post/                   # Multi-type thread & product creator modal
    ├── profile/                       # Student profile, stats, edit profile screens
    ├── activity/                      # Notifications and interaction history
    ├── auth/                          # Supabase auth screens & login sheets
    └── onboarding/                    # Onboarding walkthrough carousels
```

---

## Design System & Flutter Conventions

### 1. Color Tokens (`lib/core/theme/app_colors.dart`)
- **Brand Signature**: Electric Indigo (`AppColors.primary` / `#3D38F5`, hover `#312BD9`, pastel `#EEF0FF`).
- **Neutral Canvas**: Canvas background `#FFFFFF` / `#F8F9FA`, Slate Ink `#111827`, Muted Gray `#6B7280`, Border `#E5E7EB`.
- **Accents**: Success Emerald `#10B981`, Warning Amber `#F59E0B`, Danger Rose `#EF4444`.

### 2. Typography & Icons
- **Font Family**: GoogleFonts Inter (`google_fonts` package) with tabular figures for numbers/prices.
- **Icons**: `lucide_icons_flutter` (`LucideIcons.*`) for clean, modern line icons matching the app aesthetic.
- **Official Brandmark**: Use `SnapsLogo(height: 24.0)` from `lib/core/components/snaps_logo.dart` for the official vector logo.

### 3. Haptics & Micro-Interactions
- Add subtle tactile feedback on interactive triggers:
  - Button taps: `HapticFeedback.lightImpact()`
  - Navigation tab switches: `HapticFeedback.selectionClick()`
  - Confirm / destructive actions: `HapticFeedback.mediumImpact()`

### 4. Widget Best Practices
- Prefer `const` constructors wherever possible to maximize 60/120 FPS frame rates.
- Isolate state into feature-level `StatefulWidget` or controllers rather than rebuilding large root trees.
- Handle safe area insets cleanly using `SafeArea` with explicit edge control (`bottom: false` when bottom bar handles padding).

---

## Daily Flutter Development Commands

```bash
# 1. Fetch package dependencies
flutter pub get

# 2. Run app in development mode
flutter run

# 3. (Optional / Manual Only) Build bundle check - NOT required for agents
flutter build bundle

# 4. Build release APK for Android
flutter build apk --release
```

---

## Multi-Workstation Git Workflow

1. **Pre-Task**: Run `git pull origin main` before analyzing or modifying files.
2. **Post-Task**: Execute automatic commit and push:
   ```bash
   git add .
   git commit -m "<type>(<scope>): <description>"
   git push
   ```
