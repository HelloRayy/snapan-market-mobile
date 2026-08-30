# Repository Guidelines

## Project Overview
**Snapan Market Mobile** is a mobile-first Progressive Web App (PWA) that integrates an e-commerce marketplace with a Threads-style social networking forum designed exclusively for the **SMKN 8 Jakarta** school ecosystem. The platform enables students and staff to circulate preloved school supplies, commercialize creative vocational works (PPLG, DKV, Kuliner), place COD orders with designated campus meeting points, and interact in academic community discussion threads.


## ⚠️ Strict Agent Execution Directives (Prohibited Commands)

1. **DO NOT Run Verification & Analysis Commands**:
   - **STRICTLY PROHIBITED**: Running `flutter test`, `flutter analyze`, or routine test/verification commands.
   - Do not waste tool calls, round-trips, or token budget on running repetitive analyzers, test runners, or test suites.
2. **100% Focus on Direct Codebase Generation**:
   - Focus directly on generating, refactoring, and updating codebase files (`lib/`, `src/`, `docs/`, etc.) with high taste and strict syntactic/architectural correctness.
   - Directly write correct, clean, and production-ready code in one pass.

---

## Architecture & Data Flow

### High-Level Architecture
The application is built on **React 18 + TypeScript + Vite 5 + Tailwind CSS v4 + Zustand + Supabase**.

```
┌────────────────────────────────────────────────────────┐
│                   React 18 Frontend                    │
│   App.tsx (Stateful Router & DOM Restoration)          │
│   ├── ui/pages/ (Home, PostDetail, Search, Profile)    │
│   ├── ui/components/ (Marketplace, Chat, Atomic UI)    │
│   └── ui/store/ & ui/hooks/ (Zustand & Supabase Auth)  │
└───────────────────────────┬────────────────────────────┘
                            │ (Typed API Calls & Realtime)
┌───────────────────────────▼────────────────────────────┐
│               Service Layer (src/services/)             │
│   ├── api/ (Auth, Posts, Orders, Comments, Storage)    │
│   └── cache/ (feedCache.ts In-Memory Fast Cache)       │
└───────────────────────────┬────────────────────────────┘
                            │
┌───────────────────────────▼────────────────────────────┐
│                 Supabase Cloud Backend                 │
│   PostgreSQL DB + GoTrue Auth + Realtime + Storage     │
└────────────────────────────────────────────────────────┘
```

### Data Flow Patterns
1. **Client Service Invocations**: UI components call modular repository services in `src/services/api/` rather than querying Supabase directly.
2. **Database to Domain Transformation**: PostgreSQL database rows (`snake_case` defined in `src/types/supabase.ts`) are mapped to clean frontend domain models (`camelCase` defined in `src/types/marketFeed.ts`, `src/types/product.ts`, `src/types/order.ts`).
3. **Optimistic UI & Debounced Mutations**: Likes, reposts, and bookmarks update client state instantly with haptic feedback, while persisting changes to Supabase asynchronously.
4. **Cache-First Feed Hydration**: `src/services/cache/feedCache.ts` loads in-memory cached posts for 0ms initial render, merging fresh asynchronous Supabase posts with mock fallback data.
5. **Real-time Synchronization**: Supabase Channels (`realtimeService.ts`) listen for order updates, comment notifications, and live feed updates.

---

## Key Directories

- **`src/ui/pages/`**: Full screen page views (`HomePage.tsx`, `PostDetailPage.tsx`, `ProfilePage.tsx`, `SearchPage.tsx`, `DirectMessagesPage.tsx`, `CampusMapPage.tsx`, `CheckoutPage.tsx`).
- **`src/ui/components/`**:
  - `ui/`: Atomic reusable primitives (`Button.tsx`, `Card.tsx`, `Input.tsx`, `Badge.tsx`, `ToastNotification.tsx`, `ConfirmActionModal.tsx`, `chat-bubble.tsx`).
  - `marketplace/`: E-commerce & social thread cards (`MarketPostCard.tsx`, `CreatePostModal.tsx`, `BuyBottomSheet.tsx`, `MarketBottomNav.tsx`, `MarketHeader.tsx`).
  - `chat/`: Direct messaging components (`ChatComposerBar.tsx`, `ChatTopBar.tsx`, `ChatProductCard.tsx`).
  - `onboarding/`: Interactive onboarding carousel slides and splash screens.
  - `navigation/`: Side drawer menu (`NavigationDrawer.tsx`).
  - `pwa/`: PWA installation banner, landing page, and offline status bars.
- **`src/ui/store/`**: Global state management via Zustand (`cartStore.ts`).
- **`src/ui/hooks/`**: Custom hooks for auth (`useAuth.ts`), PWA install triggers (`usePWA.ts`), virtual keyboard detection (`useVirtualKeyboard.ts`), and smooth scroll physics (`useSmoothScroll.ts`).
- **`src/services/api/`**: Supabase client (`supabase.ts`) and modular API services (Auth, Posts, Orders, Comments, Profiles, Storage, Notifications, Meeting Points, Realtime).
- **`src/services/cache/`**: In-memory caching layer with TTL (`feedCache.ts`).
- **`src/types/`**: Strict TypeScript interfaces (`supabase.ts`, `marketFeed.ts`, `product.ts`, `order.ts`, `user.ts`).
- **`src/utils/`**: Pure utilities (`cn.ts` class merger, `formatters.ts` currency/timestamp helpers, `haptics.ts` tactile vibrations).
- **`docs/`**: Comprehensive specifications, data contracts (`fe-to-be-data-contract.md`), and database SQL setup guides (`supabase-guide.md`, `complete-migration-seed.sql`).
- **`public/`**: Static public assets, PWA manifest, and app icons.

---

## Development Commands

### Daily Workflow
```bash
# 1. Install dependencies
npm install

# 2. Copy environment template
cp .env.example .env

# 3. Start local development server
npm run dev

# 4. Start local development server accessible on local network (mobile debugging)
npm run dev:host
```

### Build & Quality Gates
```bash
# Type check without emitting JavaScript
npx tsc --noEmit

# Production build (Runs typecheck + Vite build)
npm run build

# Preview production build locally
npm run preview

# Run backend integration test against Supabase
npx ts-node test-backend.ts
```

---

## Code Conventions & Common Patterns

### 1. Naming & File Conventions
- **React Components**: PascalCase (e.g., `MarketPostCard.tsx`, `CreatePostModal.tsx`, `ButtonPrimary.tsx`).
- **Hooks**: camelCase prefixed with `use` (e.g., `useAuth.ts`, `usePWA.ts`, `useVirtualKeyboard.ts`).
- **Services & Helpers**: camelCase (e.g., `marketPostsService.ts`, `formatters.ts`, `cn.ts`).
- **Types & Interfaces**: PascalCase (e.g., `MarketPostItem`, `SellerProfile`, `Database`).

### 2. Path Aliases
- **Mandatory `@/*` Alias**: Always use the path alias `@/` mapped to `src/`. Relative directory traversal (e.g., `../../../../`) is strictly prohibited.
  ```typescript
  // Correct
  import { Button } from '@/ui/components/ui/Button';
  import { formatRupiah } from '@/utils/formatters';

  // Prohibited
  import { Button } from '../../../ui/components/ui/Button';
  ```

### 3. Styling & Tailwind CSS v4
- Styled using Tailwind CSS v4 with design tokens defined under `@theme` in `src/index.css`:
  - **Brand Signature**: Electric Indigo (`--color-brand-primary: #3d38f5`, hover `#312bd9`, pastel `#eef0ff`, ring `rgba(61, 56, 245, 0.15)`).
  - **Neutral Canvas**: Canvas mist `#f2f4f5`, pure white `#ffffff`, ink black `#000000`, slate ink `#332f2d`, muted gray `#787574`.
  - **Typography**: Inter font with tabular numbers (`cv02, cv03, cv04, cv11, tnum`).
- Use the `cn(...)` utility (`clsx` + `tailwind-merge`) for dynamic class combination:
  ```typescript
  import { cn } from '@/utils/cn';

  export function CustomBadge({ className, isVerified }: Props) {
    return (
      <span className={cn('px-2 py-0.5 rounded-full text-xs font-semibold', isVerified ? 'bg-blue-100 text-blue-700' : 'bg-gray-100 text-gray-700', className)}>
        {isVerified ? 'Terverifikasi' : 'Reguler'}
      </span>
    );
  }
  ```

### 4. GPU Performance & 120 FPS Mobile Optimization
- Feeds and animated cards utilize `@utility feed-card-perf` (`contain: layout paint; transform: translateZ(0)`) to isolate GPU composite layers.
- Form inputs enforce `font-size: 16px` on mobile screens to prevent disruptive iOS Safari viewport zoom.
- Tactile feedback is triggered on interactive actions via `triggerHaptic('light' | 'medium' | 'selection' | 'error')` from `@/utils/haptics`.

### 5. Routing & State Preservation (`App.tsx`)
- Navigation relies on lightweight URL path + hash routing (`/@:username/post/:postId`, `/search`, `/messages`, `/profile`).
- `HomePage` and `SearchPage` instances stay preserved in the DOM using conditional `block`/`hidden` classes, preserving scroll positions, active tab states, and search queries across page visits.
- Double-back press within 2 seconds at the root route is guarded to prevent accidental PWA window exits.

---

## Important Files

| File Path | Role & Importance |
| :--- | :--- |
| **`src/App.tsx`** | Application root managing stateful routing, deep linking, history back guards, scroll restoration, and navigation drawers. |
| **`src/index.css`** | Primary stylesheet containing Tailwind v4 `@theme` design tokens, font features, keyframes, and GPU compositor utilities. |
| **`vite.config.ts`** | Bundler configuration defining React, Tailwind v4, PWA service worker caching rules, manual chunk splitting, and `@/` path alias. |
| **`src/services/api/supabase.ts`** | Supabase client instance configuration and social OAuth handlers. |
| **`src/types/supabase.ts`** | Complete TypeScript database table contract matching the Supabase PostgreSQL schema. |
| **`src/ui/store/cartStore.ts`** | Zustand persistent shopping cart store with LocalStorage hydration. |
| **`docs/fe-to-be-data-contract.md`** | Official field transformation guide between database rows and frontend interface models. |

---

## Runtime & Tooling Preferences

- **JavaScript Runtime**: Node.js (version `>= 18.0.0`) or Bun.
- **Package Manager**: `npm` (strictly maintained with `package-lock.json`).
- **Module System**: Pure ECMAScript Modules (`"type": "module"` in `package.json`).
- **Bundler**: Vite 5 targeting `ES2020` with `cssCodeSplit: true` and vendor chunk splitting (`vendor-react`, `vendor-motion`, `vendor-icons`, `vendor-supabase`, `vendor-state`, `vendor-mappedin`, `vendor-three`).
- **Compiler Mode**: TypeScript 5.5 in strict mode with `isolatedModules: true` and `noEmit: true`.

---

## Testing & QA

### Quality Assurance & Verification Policy
1. **Zero Test/Analyzer Command Execution**: Do not invoke `flutter test`, `flutter analyze`, or ad-hoc verification scripts. Focus entirely on direct code generation and editing.
2. **Strict Type Safety in Code**: Maintain strict type safety and code correctness directly in the source files without depending on continuous test command executions.
3. **No Fake Local Mocks When Backend Exists**: Use typed API queries in `src/services/api/` with graceful fallback handling.

### Mandatory Multi-Workstation Git Workflow
When working across workstations:
1. **Pre-Task**: Always run `git pull origin main` before analyzing or modifying files.
2. **Post-Task**: Run `git add .`, commit with conventional commit format (`git commit -m "<type>(<scope>): <description>"`), and push (`git push -u origin main`).
