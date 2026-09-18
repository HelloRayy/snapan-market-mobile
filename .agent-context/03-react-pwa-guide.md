# 03 - React 18 PWA Architecture Guide

## Directory Structure
The Progressive Web App (`src/`) is built with React 18, TypeScript, Vite 5, and Tailwind CSS v4:

```
src/
├── services/                    # API repository & caching layer
│   ├── api/                     # Supabase modular services (auth, posts, orders)
│   └── cache/                   # feedCache.ts (In-memory fast TTL cache)
├── types/                       # TypeScript interfaces
│   ├── supabase.ts              # Database table rows (snake_case)
│   ├── marketFeed.ts            # Frontend feed models (camelCase)
│   ├── product.ts               # Product domain interfaces
│   └── order.ts                 # Order & transaction types
├── ui/                          # Presentation layer
│   ├── components/
│   │   ├── chat/                # Direct messaging UI
│   │   ├── marketplace/         # MarketPostCard, CreatePostModal, BuyBottomSheet
│   │   ├── navigation/          # NavigationDrawer, BottomNav
│   │   ├── pwa/                 # Install banner, landing page
│   │   └── ui/                  # Atomic buttons, badges, modals, toast
│   ├── hooks/                   # useAuth, usePWA, useVirtualKeyboard
│   ├── pages/                   # HomePage, PostDetailPage, ProfilePage, SearchPage
│   └── store/                   # Zustand stores (cartStore.ts)
├── utils/                       # cn.ts, formatters.ts, haptics.ts
├── App.tsx                      # Root stateful router and scroll preservation
└── index.css                    # Tailwind CSS v4 @theme tokens & GPU utilities
```

---

## Key Conventions

1. **Path Aliasing**: Always import via `@/` alias (e.g., `@/ui/components/ui/Button`).
2. **Tailwind v4 `@theme`**: Design tokens are configured in `src/index.css`.
3. **State Management**: Zustand for global client state (`cartStore.ts`).
4. **Cache Hydration**: `src/services/cache/feedCache.ts` guarantees 0ms initial render with optimistic local memory.
