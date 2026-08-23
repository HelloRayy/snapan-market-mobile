# Lightbox Bugfix & Redesign Todo

- [x] 1. Update `MediaLightboxModal.tsx` backdrop to solid opaque white (`bg-white z-[99999]`)
- [x] 2. Update image viewport to full-frame `object-contain` (no cropping for landscape/portrait)
- [x] 3. Fine-tune top header and bottom floating action capsule with safe area insets
- [x] 4. Verify touch swipe gestures (vertical dismiss + horizontal photo slide)
- [x] 5. Run build and typecheck (`npx tsc --noEmit && npm run build`)
- [x] 6. Git commit & push to main
