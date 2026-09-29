# Repository Guidelines

## Project Overview
**Snapan Market Mobile (sNaps)** is a mobile-first app designed exclusively for the **SMKN 8 Jakarta** student ecosystem, integrating an e-commerce vocational marketplace with a Threads-style social networking feed. The platform allows students and staff to circulate preloved school supplies, commercialize vocational works (PPLG, DKV, Kuliner), place COD orders with designated campus meeting points, and interact in academic community discussion threads.

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

5. **Default Codebase Search & Navigation with Graphify (`graphify-out/`)**:
   - The repository maintains a pre-built knowledge graph (`graphify-out/graph.json`, `graphify-out/GRAPH_REPORT.md`, `graphify-out/graph.html`) containing 2,500+ nodes and 4,200+ edges across both Flutter and React codebases.
   - **MANDATORY**: All AI agents should query Graphify first to locate files, symbols, modules, or trace component relationships faster:
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
   - To update the graph after introducing new modules:
     ```bash
     uv tool run --from graphifyy graphify --update
     ```

6. **Mandatory Automatic Git Commit & Push Directive**:
   - After completing any task or code change:
     1. `git add .`
     2. `git commit -m "<type>(<scope>): <descriptive message>"`
     3. `git push`

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
