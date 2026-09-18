# 01 - Architecture Overview

## Project Mission
**Snapan Market Mobile** is a specialized campus commerce and social platform tailored for the **SMKN 8 Jakarta** vocational school ecosystem. It merges:
1. **Threads-style Social Timeline**: Real-time school discussion threads, multimedia carousels, hashtags, and author interactions.
2. **Vocational Campus Marketplace**: Student project showcase, secondhand school supplies, vocational services (PPLG, DKV, Kuliner), and in-campus Cash-on-Delivery (COD) meeting points.

---

## Dual Frontend Architecture

```
                    ┌─────────────────────────────────────────┐
                    │            Snapan Ecosystem             │
                    └────────────────────┬────────────────────┘
                                         │
                 ┌───────────────────────┴───────────────────────┐
                 │                                               │
                 ▼                                               ▼
   ┌───────────────────────────┐                   ┌───────────────────────────┐
   │    Flutter Mobile App     │                   │      React 18 PWA         │
   │    Directory: `lib/`      │                   │    Directory: `src/`      │
   │                           │                   │                           │
   │ • Dart 3 + Flutter 3.24+  │                   │ • React 18 + Vite 5       │
   │ • Feature-First modular   │                   │ • Tailwind CSS v4 (@theme)│
   │ • Native 120 FPS physics  │                   │ • Zustand (cartStore)     │
   │ • Lucide Icons Flutter    │                   │ • Lucide React Icons      │
   └─────────────┬─────────────┘                   └─────────────┬─────────────┘
                 │                                               │
                 └───────────────────────┬───────────────────────┘
                                         │
                                         ▼
                         ┌───────────────────────────────┐
                         │    Supabase Cloud Backend     │
                         │                               │
                         │ • PostgreSQL + RLS Security   │
                         │ • GoTrue Authentication       │
                         │ • Supabase Storage            │
                         │ • Realtime Event Channels     │
                         └───────────────────────────────┘
```

---

## Data Flow Conventions

1. **Database Representation (`snake_case`)**:
   - Supabase PostgreSQL schema (`src/types/supabase.ts`).
   - Foreign keys: `user_id`, `post_id`, `meeting_point_id`, `created_at`.
2. **Domain Representation (`camelCase`)**:
   - Flutter Models (`lib/features/<feature>/models/market_post_model.dart`).
   - TypeScript Domain Interfaces (`src/types/marketFeed.ts`, `src/types/product.ts`, `src/types/order.ts`).
3. **Repository / Service Boundary**:
   - React UI never calls raw `supabase.from()` directly inside UI components; all queries route through `src/services/api/`.
   - Flutter features consume typed domain models (`MarketPostModel`, `ProfileUserModel`, `CampusLocationSpot`).
4. **Optimistic Updates**:
   - Likes, reposts, and bookmarks trigger immediate UI and haptic updates with debounce, while persisting asynchronously.
