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

5. **Strict Anti-Grep & Architecture Discovery Rule with Graphify (`graphify-out/`)**:
   - **STRICTLY PROHIBITED: Sequential `git grep` looping (>2 times in a row)**. Never perform blind grep spirals across multiple files to trace architecture or component relationships.
   - The repository maintains an active knowledge graph (`graphify-out/graph.json`, `graphify-out/GRAPH_REPORT.md`, `graphify-out/graph.html`) containing 4,700+ nodes and 6,800+ edges across both Flutter and React codebases.
   - **MANDATORY**: All AI agents MUST query Graphify on the first pass to locate files, symbols, modules, or trace component relationships faster:
     ```bash
     uv tool run --from graphifyy graphify query "<symbol or concept>"
     ```
   - For tracing connection paths between two modules:
     ```bash
     uv tool run --from graphifyy graphify path "<SourceModule>" "<TargetModule>"
     ```
   - For explaining a specific node or class:
     ```bash
     uv tool run --from graphifyy graphify explain "<NodeName>"
     ```

6. **Mandatory Automatic Git Hook Graphify Sync, Commit & Push Directive**:
   - The repository has an active post-commit git hook (`graphify hook install`) that automatically updates `graphify-out/graph.json` in the background after every commit.
   - For manual incremental sync if needed:
     ```bash
     uv tool run --from graphifyy graphify extract . --code-only
     ```
   - After completing any task or code change:
     1. `git add .`
     2. `git commit -m "<type>(<scope>): <descriptive message>"`
     3. `git push`

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
