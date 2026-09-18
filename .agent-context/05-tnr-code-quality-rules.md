# 05 - TNR (Thermo-Nuclear Review) Code Quality Standards

This document establishes the non-negotiable structural cleanliness and maintainability standards mandated by the `/tnr` skill.

---

## 1. File Size & Monolith Thresholds

- **Hard Limit**: No single file should exceed **400 lines**.
- **Ideal Size**: Focused modules between **80 and 250 lines**.
- **Decomposition Mandate**:
  - When a component grows past 400 lines, break it down immediately into a subfolder of focused components.
  - Example: `MarketPostCard` (previously 1,100 lines) decomposed into `post_author_avatar.dart`, `post_card_header.dart`, `post_caption_text.dart`, `post_media_section.dart`, and `post_action_bar.dart`.

---

## 2. Anti-Spaghetti Directives

- **Zero "Random If Statements"**: Do not bolt ad-hoc flags or one-off booleans into existing flows. Encapsulate logic into typed models or dedicated helper functions.
- **Code Judo Moves**: Always look for restructurings where entire conditional branches disappear by simplifying the data model or ownership boundary.
- **Direct & Legible**: Prefer boring, straightforward, predictable code over clever "magic" wrappers that hide data assumptions.

---

## 3. Why This Speeds Up AI Agents

1. **Context Window Efficiency**: Reading a 150-line file uses 85% fewer tokens than reading a 1,100-line monolith.
2. **Deterministic Diffs**: Targeted modifications on subcomponents prevent merge errors and eliminate long model generation wait times.
3. **Isolation**: Bug fixes in action bars do not risk breaking avatars or media carousels.
