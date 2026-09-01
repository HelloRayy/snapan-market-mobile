---
name: android-motion-animations
description: "Use when creating advanced Compose animations, shared element transitions, or physics-based motions for Android."
category: ui-ux
risk: low
source: community
date_added: "2026-03-31"
metadata:
  triggers:
    - "@android-animation"
    - "shared-element-transition"
    - "animate-content-size"
    - "lookahead-layout"
    - "physics-animation"
---

# Android Motion & Animations 🎭✨

Expert strategies for building fluid, high-performance, and delightful user experiences using the Jetpack Compose animation system.

## ⚡ When to Use
- **Screen Transitions**: Implementing Shared Element Transitions (Compose 1.7+).
- **Interactive UI**: Creating elastic or physics-based movements.
- **Dynamic Layouts**: Animating content size changes or visibility.
- **Micro-interactions**: Adding subtle "magic" to buttons, icons, or cards.
- **Lottie/Rive**: Integrating complex vector-based animations.

## 🏗️ The 4 Layers of Compose Animation

### 1. High-Level (Simple)
- `AnimatedVisibility`: Slide/Fade in and out.
- `AnimatedContent`: Transition between different UI states.
- `Modifier.animateContentSize()`: Smoothly resize a container as children change.

### 2. Intermediate (Transition)
- `updateTransition`: Manage multiple animation states (e.g., Expanded/Collapsed).
- `rememberInfiniteTransition`: For looping animations (e.g., Shimmer).

### 3. Low-Level (Control)
- `Animatable`: Precise control over a single value (Float, Color).
- `AnimationSpec`: Customizing `spring`, `tween`, or `keyframes`.

### 4. Layout-Level (Lookahead)
- Use **LookaheadLayout** (now built into Compose) to calculate intermediate positions for complex reordering or morphing.

## 🚀 Premium Motion Patterns

### 1. Shared Element Transitions (The Gold Standard)
- Use `SharedTransitionLayout` to morph an image from a list into a detail view.
- **Rule**: Give each shared element a unique `key`.

### 2. Physics-Based Motion (Springs)
- Avoid rigid `tween` (linear/ease). Use `spring` for a natural feel.
- **Damping Ratio**: `Spring.DampingRatioLowBouncy` for personality.
- **Stiffness**: `Spring.StiffnessMedium` for responsiveness.

### 3. Content Shimmer
- Use a `Brush.linearGradient` with an infinite transition to create skeleton loading effects.

## 📦 Performance & Tips

- [ ] **State Read Isolation**: Prefer "Lambda modifiers" (e.g., `Modifier.graphicsLayer { ... }`) to avoid excessive recompositions during high-frequency animations.
- [ ] **Avoid Clipping**: Use `clip = false` on parents if elements need to overlap during transitions.
- [ ] **Hardware Acceleration**: Always use `graphicsLayer` for translations, rotations, and scale to ensure GPU rendering.

## 📏 Design Best Practices

- **Duration**: Keep UI transitions between **200ms and 400ms**.
- **User Control**: Ensure animations can be skipped or disabled via system accessibility settings.
- **Purpose**: Every animation should serve a purpose (e.g., providing feedback or guidance).

## 🧪 Verification & Checklist

- [ ] **No Jank**: Check for dropped frames using the "Profile GPU Rendering" tool.
- [ ] **Accessibility**: Does the animation obey "Reduce Motion" settings?
- [ ] **Recomposition**: Does the animation cause the whole screen to recompose? (Optimize!)
- [ ] **Edge Cases**: What happens if the animation is interrupted?

## 🔗 Related Resources
- [Compose Animation Guide](https://developer.android.com/jetpack/compose/animation)
- [Shared Element Transitions](https://developer.android.com/jetpack/compose/animation/shared-elements)
- [Lottie for Android](https://github.com/airbnb/lottie-android)
