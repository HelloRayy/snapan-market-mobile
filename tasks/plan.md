# Implementation Plan: Fullscreen Media Lightbox Redesign & Bugfix

## 1. Overview
Fix visual bleeding and image cropping bugs in `MediaLightboxModal.tsx` when viewing media detail. Replace translucent/cut-off layout with a solid 100% opaque light background, full-frame `object-contain` scaling (zero cropping for landscape & portrait images), clean safe-area insets, and fluid touch gestures.

---

## 2. Key Architecture & Design Decisions
- **100% Opaque Solid Backdrop**: Set `bg-white z-[99999]` with zero opacity bleeding so underlying feed text never leaks through.
- **Full-Frame `object-contain`**: Center image in viewport with `w-full h-full max-h-[82vh] max-w-full object-contain` to show 100% of the photo without cropping.
- **Dual-Axis Touch Physics**:
  - Horizontal swipe with CSS snap scroll for multi-image switching.
  - Vertical drag-to-dismiss when pulling down/up.
- **Safe Area Integration**: Top bar respects `env(safe-area-inset-top)` and bottom floating pill respects `env(safe-area-inset-bottom)`.

---

## 3. Task List & Phases

### Phase 1: Core Lightbox Layout & Image Scaling
- [ ] Task 1: Update `MediaLightboxModal.tsx` backdrop to solid opaque white (`bg-white z-[99999]`) and eliminate background bleed.
- [ ] Task 2: Standardize image viewport with responsive `object-contain` scaling for landscape and portrait photos.

### Phase 2: Floating Header, Action Capsule & Gesture Tuning
- [ ] Task 3: Adjust top bar (Close X + Counter Pill) and bottom floating action capsule (Like, Reply, Repost, Share, Zoom toggle, Pagination dots) with iOS safe area insets.
- [ ] Task 4: Tune vertical drag-to-dismiss gesture and zoom scale toggle (1x / 1.5x / 2x).

### Phase 3: Verification & Integration
- [ ] Task 5: Run TypeScript checks (`tsc --noEmit`) and production build test (`npm run build`).
- [ ] Task 6: Push changes to GitHub and trigger Vercel deployment.
