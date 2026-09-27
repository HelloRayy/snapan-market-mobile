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

4. **Default Codebase Navigation with Graphify (`graphify-out/`)**:
   - Query Graphify first for file searches, symbol locations, and architecture relationship discovery:
     ```bash
     uv tool run --from graphifyy graphify query "<search query>"
     ```

5. **Mandatory Git Commit & Push**:
   - Run `git add .`, commit, and push after completing tasks.

