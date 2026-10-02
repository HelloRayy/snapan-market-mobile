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

5. **Strict Anti-Grep & Architecture Discovery with Graphify (`graphify-out/`)**:
   - **STRICTLY PROHIBITED: Sequential `git grep` looping (>2 times)**. Never perform blind grep spirals across multiple files to trace dependencies or features.
   - MANDATORY: Query Graphify on the first pass for file searches, symbol locations, and architecture relationship discovery:
     ```bash
     uv tool run --from graphifyy graphify query "<search query>"
     ```
   - Use `uv tool run --from graphifyy graphify path "<Source>" "<Target>"` to trace cross-module connections without reading files.

6. **Mandatory Automatic Git Hook Graphify Sync, Commit & Push**:
   - The repository has an active post-commit git hook (`graphify hook install`) that automatically updates `graphify-out/graph.json` in the background after every commit.
   - Run `git add .`, commit, and push after completing tasks.

7. **Strict File Size Cap (Max 250–300 Lines)**:
   - Decompose any UI screen or service >250 lines into atomic sub-components in `<feature>/components/`.

8. **Screenshot-to-Code SOP (Zero Unnecessary File Reads)**:
   - Always run `git grep -i "visible_text" lib/` or check `docs/UI_MAP.md` first. Read ONLY the specific sub-widget, never the entire 1000-line screen file.

9. **Strict Read-Only Directive for Plane.so (`/plane`)**:
   - Plane.so access via MCP tools or `/plane` is 100% read-only (reading issue details, descriptions, requirements).
   - The agent has ZERO authority to update issue states (e.g. moving from Todo/In Progress to Done, or vice versa).
   - State changes and ticket transitions are strictly managed manually by the user.


