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

5. **Default Codebase Navigation with Graphify (`graphify-out/`)**:
   - Query Graphify first for file searches, symbol locations, and architecture relationship discovery:
     ```bash
     uv tool run --from graphifyy graphify query "<search query>"
     ```

6. **Mandatory Git Commit & Push**:
   - Run `git add .`, commit, and push after completing tasks.

7. **Strict File Size Cap (Max 250–300 Lines)**:
   - Decompose any UI screen or service >250 lines into atomic sub-components in `<feature>/components/`.

8. **Screenshot-to-Code SOP (Zero Unnecessary File Reads)**:
   - Always run `git grep -i "visible_text" lib/` or check `docs/UI_MAP.md` first. Read ONLY the specific sub-widget, never the entire 1000-line screen file.

