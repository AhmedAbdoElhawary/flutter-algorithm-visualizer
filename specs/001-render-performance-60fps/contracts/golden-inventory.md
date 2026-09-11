# Contract: Golden Surface Inventory

**Feature**: 001-render-performance-60fps | **Satisfies**: FR-009b, FR-009c, FR-009d, SC-007

This is the enumerated, complete list of surfaces that must have golden reference images. FR-009b requires all of them; a missing golden is an unguarded surface.

> **Hard sequencing constraint**: every golden below must be recorded on an **unmodified tree, before the first optimisation commit**. Once rendering code changes, the original appearance is gone and the pixel-identical constraint becomes unverifiable forever.

---

## Pass rule

**Exact match. Zero pixel tolerance.**

A golden that needs updating is a **failed change**, not a golden to re-record (FR-009c). The only exception is a visual change explicitly approved under FR-009a.

These goldens stay in the repository permanently after this feature ships, as the guard against a future refactor silently altering the glass or aurora look (FR-009d).

---

## Component surfaces

Every surface is captured in **both light and dark themes** — 2 goldens per row.

| # | Surface ID | What it captures | Why it matters |
|---|---|---|---|
| 1 | `glass.recessed` | `GlassContainer` at `GlassDepth.recessed` | Lowest blur sigma + recessed fill + hairline |
| 2 | `glass.card` | `GlassContainer` at `GlassDepth.card` | The most-used depth (majority of the 24 call sites) |
| 3 | `glass.floating` | `GlassContainer` at `GlassDepth.floating` | Highest blur + strongest border + e3 elevation; used by the nav bar |
| 4 | `glass.card.noTopShadow` | `allowCardTopShadow: false` variant | Changes top border width to 2px — a distinct visual path |
| 5 | `glass.card.animated` | `durationForAnimation` variant | Takes the `AnimatedContainer` branch instead of `Container`; used by `ProblemTile` |
| 6 | `glass.track` | `GlassTrack` | The no-blur recessed rail — must stay blur-free |
| 7 | `aurora.ground` | `AuroraGround` full-screen | Base colour + 2 radial bands + dot grid. **The surface most at risk** from the R4 caching change |
| 8 | `glass.on.aurora` | A card composited over the aurora | Catches backdrop-read regressions that isolated component goldens miss |
| 9 | `glass.grouped.list` | Three stacked cards inside a `BackdropGroup` | **The R3 acceptance golden** — proves grouped blur is visually identical to separate blurs |

**Subtotal: 9 surfaces × 2 themes = 18 goldens.**

---

## Screen surfaces

All five main tab screens, both themes, with deterministic seeded content.

| # | Surface ID | Screen |
|---|---|---|
| 10 | `screen.home` | Home |
| 11 | `screen.visualize` | Visualize |
| 12 | `screen.code` | Code |
| 13 | `screen.practice` | Practice / Challenge — the grouped-blur list in situ |
| 14 | `screen.profile` | Profile |

**Subtotal: 5 screens × 2 themes = 10 goldens.**

---

## Total: 28 golden images

---

## Determinism requirements

A golden that varies between runs is worse than no golden — it trains you to re-record on failure. Each capture must therefore:

1. **Freeze animation.** Pump to a fixed, settled frame. No golden may be taken mid-transition.
2. **Freeze content.** Seeded fixture data only — no live Firestore, no clock-dependent text, no random ordering.
3. **Freeze size.** One fixed surface size per golden, with a fixed device pixel ratio, so ScreenUtil resolves identically every run.
4. **Freeze the Home ticker.** `movable_pins.dart` runs a continuous particle `Ticker`; `screen.home` must pump to a fixed elapsed time or stub the ticker, or it will never match twice.
5. **Freeze fonts.** `google_fonts` must not attempt a network fetch during tests — use the bundled/cached font path so glyph metrics are stable.

---

## Known limitation — and the backstop

Goldens render on the **host test renderer**, which does not reproduce the Oppo A5i's GPU blur output. They prove *widget-level composition* is unchanged; they cannot alone prove on-device pixels are unchanged.

**Backstop (required, once)**: capture device screenshots of all five main screens in both themes on the A5i before optimisation, and compare after with `tool/compare_screenshots.py` — an exact pixel diff that crops the status bar and reports a differing-pixel count per pair. Pairs reporting `0 px` are proven unchanged and are not inspected by a person; only flagged pairs are. Goldens are the automated gate; the device check is the one-time confirmation.

The Home particle ticker and the aurora background animate, so those two pairs will always flag and are judged by eye against the design rather than by pixel count.

Both are in scope. Neither replaces the other.
