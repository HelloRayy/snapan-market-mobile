# AI Agent Master Context System

Welcome to **Snapan Market Mobile**. This directory (`.agent-context/`) serves as the central knowledge hub and architectural compass for AI coding agents (Antigravity, Cursor, Claude, Windsurf, Copilot, Gemini).

Before modifying code or navigating complex tasks, consult these canonical guides to prevent hallucinations, reduce context token load, and ensure instant alignment with the project's strict architectural and security standards.

---

## Master Document Index

| Document | Purpose & Scope |
| :--- | :--- |
| **[01-architecture-overview.md](./01-architecture-overview.md)** | Dual Frontend (Flutter + React 18 PWA), Supabase backend, unified data flow, and directory structure. |
| **[02-flutter-app-guide.md](./02-flutter-app-guide.md)** | Flutter feature-first architecture (`lib/features/`), design tokens, routes, atomic widgets, and state conventions. |
| **[03-react-pwa-guide.md](./03-react-pwa-guide.md)** | React 18 + Vite + Tailwind v4 PWA (`src/ui/`), Zustand cart store, cache layer, and services. |
| **[04-security-and-rls.md](./04-security-and-rls.md)** | Security checklist (/security): Supabase RLS, zero service_role in frontend, auth lifecycle, token protection, and input sanitization. |
| **[05-tnr-code-quality-rules.md](./05-tnr-code-quality-rules.md)** | Maintainability standards (/tnr): Monolith avoidance (<300-400 lines/file), anti-spaghetti branching, code-judo moves, and modularization. |
| **[06-features-directory-map.md](./06-features-directory-map.md)** | Fast lookup cheat-sheet mapping features (Feed, Search, Profile, Map, Messages, Checkout) to exact Flutter and React files. |

---

## Core Directives for AI Agents

1. **Dual Codebase Awareness**:
   - Flutter Mobile App is located in `lib/`.
   - React 18 PWA is located in `src/`.
   - Always confirm whether the user's task targets Flutter, React, or both.
2. **Never Run Prohibited Commands**:
   - **STRICTLY FORBIDDEN**: Running `flutter test`, `flutter analyze`, or routine test runners.
   - **STRICTLY FORBIDDEN**: Launching Playwright or headless browsers unless the user explicitly commands: *"ambil screenshot"*, *"buka playwright"*.
3. **Keep Files Small & Modular (/tnr)**:
   - Maintain file sizes below **300–400 lines**.
   - If a widget or component grows large, immediately decompose sub-widgets into a dedicated subfolder (e.g., `lib/features/<feature>/components/<sub_component>/`).
4. **Strict Security Verification (/security)**:
   - Never expose `SUPABASE_SERVICE_ROLE_KEY` in frontend files or `.env`.
   - Always ensure user inputs (prices, quantities, text) are validated and bound via parameterized queries.
5. **Automatic Git Commit & Push**:
   - Upon completing and verifying any task, automatically execute:
     1. `git add .`
     2. `git commit -m "<descriptive message>"`
     3. `git push`
