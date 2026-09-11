# Phase 0 Research: Render Performance

**Feature**: 001-render-performance-60fps | **Date**: 2026-09-11

All Technical Context unknowns are resolved below. Each entry follows: **Decision → Rationale → Alternatives considered**.

---

## Root-cause analysis (evidence gathered from the codebase)

Measured facts, not guesses — each is a file:line in the current tree.

| # | Finding | Location | Frame cost |
|---|---|---|---|
| RC1 | Every Practice-list row wraps a `GlassContainer`, i.e. one `BackdropFilter` each | [problem_tile.dart:36](../../lib/features/challenge/presentation/widgets/challenges/problem_tile.dart#L36) inside [challenge_page.dart:34](../../lib/features/challenge/presentation/view/challenge_page.dart#L34) `SliverList.builder` | N visible rows → N backdrop reads + N save-layers per frame |
| RC2 | `_AuroraPainter` draws one `drawCircle` per grid cell, plus two full-screen `MaskFilter.blur` radial bands, with **no `RepaintBoundary`** | [glass_card.dart:199-224](../../lib/core/widgets/custom_widgets/glass_card.dart#L199-L224) | ~6,800 `drawCircle` calls per paint on a 720×1600 screen; repaints whenever anything above it repaints |
| RC3 | `ref.watch(...positions[item.id])` is called **inside** `List.generate` in the parent's `build` | [sorting_view.dart:259](../../lib/features/visualize/sub_view/sorting/view/sorting_view.dart#L259) | Parent subscribes to all N bar positions → one bar moving rebuilds all N bars (O(N²)) |
| RC4 | Floating glass nav sits in a `Stack` above every tab's scrolling content | [base_navigation.dart](../../lib/features/base/view/base_navigation.dart) | Forces a backdrop re-read on every scrolled frame, on all five tabs |
| RC5 | A second per-cell painter loop backs the sorting grid | [grid_squares_view.dart:119-120](../../lib/features/visualize/widgets/grid_squares_view.dart#L119-L120) | Nested `for` loop over width × height, re-running during sort animation |
| RC6 | Only **2** `RepaintBoundary` widgets exist in the entire `lib/` tree | `movable_pins.dart:245, 444` | Almost nothing is isolated; repaints cascade across whole screens |
| RC7 | ~47 unscoped `ref.watch(...)` call sites vs 53 scoped | app-wide | Constitution Principle VI names this "the most common avoidable source of jank in this app" |

---

## R1 — How to measure frame timings automatically

**Decision**: Use the Flutter SDK's `integration_test` package with `IntegrationTestWidgetsFlutterBinding.watchPerformance`, driven in **profile** mode against the physical Oppo A5i, emitting a JSON timeline summary per scenario.

**Rationale**: It is first-party (ships with the Flutter SDK, no third-party dependency), runs the real render pipeline on real hardware, and produces exactly the numbers FR-015 asks for — average frame build/raster time, worst-case, and over-budget frame counts. Being file-based JSON, it satisfies FR-017's "compare against committed baselines" directly.

**Alternatives considered**:
- *Manual DevTools only* — rejected in clarification Q1. Not repeatable, cannot gate a regression, and numbers vary by operator.
- *Third-party benchmark packages* — a larger Constitution VII deviation than a first-party SDK package, for no added capability.
- *Debug-mode measurement* — rejected outright; debug builds carry assertion and unoptimised-code overhead that makes frame numbers meaningless. The spec bans it.

**Consequence**: `integration_test` must be added to `dev_dependencies`. Declared in the plan's Complexity Tracking.

---

## R2 — Whether to gate performance in CI

**Decision**: No. The suite runs on-demand against the attached A5i. `ci.yml` is not modified to gate on frame numbers.

**Rationale**: FR-019. GitHub-hosted runners have no real GPU; blur and raster costs there bear no relation to device behaviour. A green CI number would be actively misleading.

**Alternatives considered**: *Self-hosted runner with a physical device* — correct in principle, disproportionate for a solo side project, and not requested.

---

## R3 — How to make many glass cards cheap without changing appearance

**Decision**: Wrap the Practice list in a `BackdropGroup` and switch the list tiles' `GlassContainer` to use `BackdropFilter.grouped`, so the engine performs **one** backdrop read shared across all visible tiles.

**Rationale**: Verified present in the pinned Flutter 3.44.7 at `packages/flutter/lib/src/widgets/basic.dart:469`. The framework documentation's own worked example is a `ListView.builder` of blurred cards, and states the engine "will perform only one backdrop blur but the results will be visually identical to multiple blurs" — which is precisely the FR-009 pixel-identical requirement. This is the single highest-leverage fix available.

**Critical design rule discovered in the API docs**: *"Backdrop filters that overlap with each other should not use the same backdrop key, otherwise the results may look as if only one filter is applied in the overlapping regions."*

→ **The floating nav bar (RC4) overlaps page content and MUST be excluded from any page-content `BackdropGroup`.** It keeps its own independent backdrop. Violating this would produce a visible rendering difference and fail FR-009.

**Alternatives considered**:
- *Replace blur with a pre-blurred static image* — would not track the scrolling content behind it; visually different. Rejected by FR-009.
- *Lower the blur sigma* — explicitly forbidden by FR-009.
- *Drop glass on list rows* — explicitly forbidden by FR-009.

**Implementation shape**: `GlassContainer` gains an opt-in to grouped mode. It must remain opt-in — applying it blindly to overlapping surfaces would break the rule above.

---

## R4 — How to stop the aurora background repainting

**Decision**: Two changes, both appearance-neutral.
1. Wrap the painter in a `RepaintBoundary` so it occupies its own layer and is not repainted when content above it changes.
2. Cache the expensive dot-grid + band composition into a `ui.Picture`/`ui.Image` keyed on `(size, base, indigo, cyan, dot, dotSpacing)`, replayed on subsequent paints instead of re-running ~6,800 `drawCircle` calls.

**Rationale**: The painter's inputs are already fully enumerated by its own `shouldRepaint` (glass_card.dart:227-232) — size and five values. Nothing else can change its output, so caching on exactly that tuple is safe and provably produces identical pixels.

**Constitution IV interaction**: the cache key **must include the resolved theme colours**, not just a size. Caching on size alone would freeze the light-mode background into dark mode and violate both Principle IV and FR-012. This is covered by a dedicated both-themes golden.

**Alternatives considered**:
- *`RepaintBoundary` alone* — helps with repaint cascades but still pays the full 6,800-call cost on first paint and on every resize. Worth doing, but insufficient alone.
- *Replace the dot grid with a tiled `ImageShader`* — likely faster still, but a shader-tiled grid may differ by a sub-pixel at edges. Held as a fallback only if caching proves insufficient, and gated on the golden test passing.
- *Reduce dot density* — forbidden by FR-009.

---

## R5 — How to fix the sorting view's O(N²) rebuilds

**Decision**: Move the per-bar `ref.watch` out of the parent's `List.generate` loop and into each bar's own `ConsumerWidget`, so a bar subscribes only to its own position and status.

**Rationale**: This is the textbook Principle VI fix and is the direct cause of the user's reported "junk frames when bars change places". Currently the parent watches `state.positions[item.id]` for every `item`, so any single position change invalidates the parent and rebuilds all N subtrees. After the change, a bar's movement rebuilds exactly that bar.

It also moves SC-004 (80% rebuild-count reduction) from aspirational to arithmetically likely: for N bars, per-change rebuilds drop from ~N to ~1.

**Constitution I interaction**: each bar must become a **named widget class**, not an inline builder closure — function-style builders are forbidden.

**Alternatives considered**:
- *Keep the parent watch and add `const` constructors to children* — does not help; the parent rebuild still walks all N children.
- *Move positions into a separate provider per bar* — a bigger architectural change than needed; `.select()` on the existing provider achieves the same isolation within existing conventions (Principle VII).

---

## R6 — Home's continuous particle Ticker vs "idle screens do zero work"

**Decision**: Treat Home's ambient particle animation as **deliberate motion, not idle work**. SC-005 ("a screen at rest performs zero rendering work") is evaluated on screens with no intentional ambient animation. Home's ticker is separately required to (a) stay inside its existing `RepaintBoundary`, (b) remain paused when the app is backgrounded, and (c) respect the OS reduce-motion setting.

**Rationale**: `movable_pins.dart:73` runs a `Ticker` continuously with a deliberate `targetFps` throttle and a `WidgetsBindingObserver` foreground check — this is an intentional design feature, not a leak. Removing it would be a visual change and would violate FR-009. But it does mean Home can never be literally "zero work", so SC-005 needs this stated boundary rather than being silently unmeetable.

**Alternatives considered**:
- *Pause the ticker when idle* — the animation IS the idle state; pausing it is a visible change.
- *Declare SC-005 unmeetable* — unnecessary; the other four screens can and should hit zero.

**Flag**: this interpretation should be confirmed when the first Home measurement lands. If the ticker turns out to cost meaningful frame budget on the A5i, `enableConnections` already exists as a documented low-end escape hatch (the code comments call it "the expensive part of the paint pass — turn it off first on low-end devices") — but using it is a visual change requiring FR-009a approval.

---

## R7 — How to prove pixel-identity

**Decision**: Golden tests via `matchesGoldenFile`, captured **before** any optimisation, covering the surfaces enumerated in [contracts/golden-inventory.md](./contracts/golden-inventory.md). Backed by a one-time A5i device-screenshot comparison, diffed exactly by `tool/compare_screenshots.py` rather than read by eye.

**Rationale**: Goldens are exact, automated, and cheap to re-run, and they persist as the permanent guard FR-009d asks for. The known limitation — goldens render on the host test renderer, which does not reproduce the device GPU's blur output — is why the spec also requires the device backstop. Neither alone is sufficient; together they cover widget-level composition and on-device appearance.

**Hard sequencing constraint**: goldens must be recorded on an unmodified tree. Once optimisation lands, the original appearance is unrecoverable and the constraint becomes unverifiable. This is the first task in the feature, before any rendering change.

**Alternatives considered**:
- *Manual comparison only* — rejected in clarification Q3; misses sub-pixel shifts and is not repeatable.
- *Golden the two shared components only* — misses screen-level composition changes, which is exactly what grouped blur alters.

---

## R8 — Rebuild counting for SC-004

**Decision**: Count rebuilds in a widget test by instrumenting build invocations for the sorting bar subtree, recording the count for a single isolated state change before and after, and comparing.

**Rationale**: SC-004 requires an 80% reduction against a recorded baseline, counted "the same way before and after". A deterministic widget test is repeatable and needs no device — unlike a timeline capture, the rebuild count is hardware-independent, so it is a clean, stable metric.

**Alternatives considered**:
- *DevTools rebuild-count overlay* — a good diagnostic, but read by eye and not committable as a baseline.
- *Timeline frame counts as a proxy* — conflates rebuild cost with raster cost; does not isolate what SC-004 is about.

---

## Open risk (not resolvable by research — only by measurement)

**Can the Oppo A5i sustain grouped real-time backdrop blur at 60 FPS with appearance held pixel-identical?**

Research establishes that grouped blur reduces N backdrop reads to 1 and that this is visually identical by design. It cannot establish that 1 backdrop read per frame, plus the aurora, plus list content, fits in 16.67 ms on that specific entry-level GPU.

**Mitigation built into the plan**: the "before" measurement and a narrow grouped-blur spike on the Practice list are front-loaded, so this surfaces early. If the target proves unreachable with appearance intact, FR-009a governs — report the shortfall with measurements and seek explicit approval for any visual change. Do not silently degrade.

---

## Resolved: no NEEDS CLARIFICATION remain

Every Technical Context field is filled with a concrete value. The five spec-level clarifications were resolved in the `/speckit-clarify` session and are recorded in [spec.md](./spec.md#clarifications).
