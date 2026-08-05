# Implementation Plan: React Vite PWA Marketplace Boilerplate (Supabase Integrated)

## Overview
Menyediakan setup dasar (boilerplate) React + Vite dengan Tailwind CSS, PWA (`vite-plugin-pwa`), integrasi Supabase (Database & Google OAuth Auth), Cart Store (Zustand), komponen Marketplace primitives, struktur folder simpel (`ui`, `services`, `types`, `utils`), serta 5 dokumentasi AI Agent lengkap di `/docs`.

## Task List

### Phase 1: Foundation & Package Setup
- [ ] Task 1: Inisialisasi Vite React TypeScript project dengan `package.json`, `vite.config.ts`, `tsconfig.json`, `.env.example`, dan `@supabase/supabase-js`
- [ ] Task 2: Setup Tailwind CSS, `clsx`, `tailwind-merge`, `lucide-react`, dan `src/index.css`
- [ ] Task 3: Setup `vite-plugin-pwa` dengan Web App Manifest, Service Worker, `usePWA` hook, & PWA Install Banner

### Phase 2: Supabase Integration & Marketplace Primitives
- [ ] Task 4: Inisialisasi Client Supabase (`src/services/api/supabase.ts`), Auth Hook (`useAuth.ts` dengan Google OAuth), & ProtectedRoute
- [ ] Task 5: Buat Model Tipe Data Marketplace di `src/types/` (`product.ts`, `seller.ts`, `order.ts`, `user.ts`, `supabase.ts`)
- [ ] Task 6: Buat Cart Store Zustand di `src/ui/store/cartStore.ts`
- [ ] Task 7: Buat Komponen Marketplace Primitives di `src/ui/components/marketplace/` (`ProductCard.tsx`, `QuantitySelector.tsx`, `RatingStars.tsx`, `MobileBottomNav.tsx`)

### Phase 3: AI Agent Documentation (`/docs`)
- [ ] Task 8: Buat `/docs/architecture.md` (Folder Architecture & Organization Rules)
- [ ] Task 9: Buat `/docs/coding-standards.md` (React, TypeScript & Tailwind Rules)
- [ ] Task 10: Buat `/docs/ai-instructions.md` (Rules for AI Agents)
- [ ] Task 11: Buat `/docs/pwa-guide.md` (PWA Setup & Deployment Guide)
- [ ] Task 12: Buat `/docs/supabase-guide.md` (Supabase Marketplace Schema & Google OAuth Setup)

### Phase 4: Verification
- [ ] Task 13: Verifikasi build Vite dan keberadaan seluruh komponen, Supabase client, serta 5 file dokumentasi
