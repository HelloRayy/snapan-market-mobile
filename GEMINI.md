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

5. **Deterministic Routing via `CODEBASE_AGENT_MAP.md` (Zero Blind Reads)**:
   - **STRICTLY PROHIBITED: Blind search or sequential `git grep` looping in root directory**.
   - **MANDATORY**: Check [`CODEBASE_AGENT_MAP.md`](file:///home/rayhan/Windows-D/project/snapan-market-mobile/CODEBASE_AGENT_MAP.md) first to pinpoint the exact target component and controller.
   - **Scoped Grep Only**: When searching, always scope queries to specific directories (e.g. `lib/features/feed/` or `src/admin/`). Never search globally without directory filters.

6. **Graphify Role (Architectural & Refactoring Tool)**:
   - Graphify (`graphify-out/`) is maintained for visual architecture inspection, dependency tracing, and community clustering.
   - Do NOT run CLI `graphify query` on simple bug fixes or UI updates to avoid CLI latency and token bloat. Use `CODEBASE_AGENT_MAP.md` for direct file navigation.
   - The git hook will continue to update the graph in the background after commits.

7. **Strict File Size Cap (Max 250–300 Lines)**:
   - Decompose any UI screen or service >250 lines into atomic sub-components in `<feature>/components/`.

8. **Screenshot-to-Code SOP (Zero Unnecessary File Reads)**:
   - Always run `git grep -i "visible_text" lib/` or check `docs/UI_MAP.md` first. Read ONLY the specific sub-widget, never the entire 1000-line screen file.

9. **Strict Read-Only Directive for Plane.so (`/plane`)**:
   - Plane.so access via MCP tools or `/plane` is 100% read-only (reading issue details, descriptions, requirements).
   - The agent has ZERO authority to update issue states (e.g. moving from Todo/In Progress to Done, or vice versa).
   - State changes and ticket transitions are strictly managed manually by the user.

10. **Mandatory Build APK Release & In-App Update Response Format**:
    - Whenever the user asks to build an APK release or prepare a release, always output both options:
      - **Cara 1: Otomatis via Script**: `./scripts/auto_release.sh <new_version_name> <new_version_code> "<changelog>"` (1. Bump pubspec, 2. Build APK, 3. Tag & push git, 4. Upload GitHub Release, 5. Inject Supabase `app_versions`).
      - **Cara 2: Manual Langkah demi Langkah**: (1) Naikkan Versi di `pubspec.yaml`, (2) `flutter build apk --release`, (3) Upload File APK ke GitHub Release, (4) Query SQL `INSERT INTO public.app_versions` di Supabase Dashboard.



