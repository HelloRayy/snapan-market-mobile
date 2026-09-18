# 02 - Flutter Mobile App Guide

## Architecture Pattern
The Flutter codebase (`lib/`) strictly implements a **Feature-First Modular Architecture**:

```
lib/
├── core/                        # Cross-cutting foundational layer
│   ├── components/              # Shared atomic buttons, glass toolbars
│   ├── navigation/              # Route builders & transitions (AppSlidePageRoute)
│   ├── theme/                   # AppColors tokens, typography styles
│   └── utils/                   # Formatters (formatRupiah, formatSmartTimestamp)
├── features/                    # Feature modules (self-contained)
│   ├── feed/                    # Home feed, timeline cards, post details
│   ├── profile/                 # Student profile, edit profile, user tabs
│   ├── search/                  # Unified sticky header, account search
│   ├── map/                     # Campus 2D blueprint interactive painter
│   ├── locations/               # COD meeting points picker & models
│   ├── checkout/                # Cart summary, breakdown, COD selection
│   ├── messages/                # Direct messages & chat rooms
│   ├── create_post/             # Multi-part thread and product creator
│   └── auth/                    # Login, register, onboarding flows
└── main.dart                    # App bootstrap & theme definitions
```

---

## Design Tokens & Theme Standards

- **Primary Colors**:
  - `AppColors.primary`: Electric Indigo `#3D38F5`
  - `AppColors.primaryHover`: `#312BD9`
  - `AppColors.primaryPastel`: `#EEF0FF`
- **Neutrals**:
  - Pure White `#FFFFFF` (Card background & light mode canvas)
  - Slate Ink `#0F172A` (Headings & primary copy)
  - Slate Muted `#64748B` / `#94A3B8` (Subtitles, metadata, timestamps)
  - Canvas Border `#E2E8F0` / `#F1F5F9` (Dividers & subtle borders)
- **Status Tokens**:
  - Success `#10B981` (Emerald)
  - Destructive `#EF4444` (Rose / Red)
  - Like Heart `#E11D48` (Rose 600)

---

## Code Quality Boundaries (/tnr)

1. **Max File Size**: **300–400 lines max**. Files exceeding 400 lines must be split into subcomponents within a subfolder.
2. **Icons**: Use `LucideIcons` from `package:lucide_icons_flutter/lucide_icons.dart` for system UI icons.
3. **Typography**: Inter / SF Pro with tabular figures for timestamps and numeric counters (`FontFeature.tabularFigures()`).
4. **Haptics**: Always trigger `HapticFeedback.lightImpact()` on tap/toggle interactions.
