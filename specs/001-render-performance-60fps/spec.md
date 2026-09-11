# Feature Specification: Render Performance — Smooth 60 FPS Across the App

**Feature Branch**: `001-render-performance-60fps`

**Created**: 2026-09-11

**Status**: Draft

**Input**: User description: "i want to enhace the preformance rendreing for the app, the app is so, slow and has several junky frames in main five page, i want to enhance the app widgets rebuild at 60 fps, and no junky frames, i debugged and found that GlassContainer (especially BackdropFilter widget) and AuroraGround are so slow and has expensive build, also when scroll in ChallengePage and visulize page while sorting bars chars when they changes places and getting be sorted it has junk frames. so overall the app right now is so slow and not run on 60fps"

## Overview

The app currently feels slow. Users see visible stutter ("jank") while scrolling and while animations play. The frosted-glass surfaces and the aurora background are the heaviest contributors, and the sorting animation in the Visualize screen drops frames as bars move.

This feature makes the app render smoothly — a steady 60 frames per second with no perceptible stutter — across the five main tab screens and the animations they contain, **without changing what the app looks like or what it does**.

## Clarifications

### Session 2026-09-11

- Q: How should frame performance actually be measured, given the repo currently has no `integration_test/` directory and no timeline-capture tooling? → A: Both — an automated performance suite provides the repeatable pass/fail gate and stored baselines, while manual DevTools timeline inspection is used to diagnose hot spots during the work.
- Q: Does "zero dropped frames" include the very first run of an animation, when the graphics driver is still compiling shaders? → A: No — warm-up frames are excluded from the pass/fail gate, but are measured and reported separately against their own stated first-run allowance.
- Q: How will pixel-identical appearance be proven, given the repo has no golden/screenshot tests today? → A: Golden (screenshot) tests covering the glass container, the aurora background, and all five main screens in both themes — captured before any optimisation and asserted after.
- Q: Should the scoped-rebuild cleanup cover the whole app, or only the five main screens? → A: Profiling-driven, then opportunistic — mandatory wherever profiling proves over-rebuilding is costing frames; the remaining broad-watch call sites are recorded as follow-up debt rather than refactored blind.
- Q: How should the two unverifiable success criteria be handled (SC-004's undefined "rendering operations" metric, and SC-007's ten-person tester panel)? → A: Redefine SC-004 as a concrete widget rebuild-count reduction, and remove SC-007 — objective frame metrics are the evidence, not an opinion poll.

### Session 2026-09-11 (post-analysis remediation)

Raised by `/speckit-analyze` cross-artifact review, resolved without new user input:

- Q: FR-003 required "every supported playback speed" but SC-002 gated only the fastest — which governs? → A: **All five speeds** (slow, normal, fast3, fast5, fast10). Running the full set is cheap, so SC-002 was widened to match FR-003 rather than narrowing the requirement.
- Q: Golden images are platform-specific, but CI runs `flutter test` on Linux while goldens are recorded on macOS — how is the pipeline kept green? → A: Tag the golden suite and exclude it from the Linux quality job (FR-019a), while running it on a macOS job so the FR-009d guard still fires on every PR (FR-019b).
- Q: `watchPerformance` holds results in memory — how does a report reach disk? → A: A driver entry point is required; capturing timings without a write path makes FR-015/016/017 unsatisfiable (FR-022).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Scroll the main screens without stutter (Priority: P1)

A user opens the app and scrolls through each of the five main tab screens (Home, Visualize, Code, Practice, Profile). Lists, cards, and glass surfaces scroll fluidly. Nothing hitches, tears, or lags behind the finger. Scrolling the Practice/Challenge problem list — the worst offender today — feels as smooth as scrolling a native system list.

**Why this priority**: Scrolling is the single most frequent interaction in the app. Stutter here is what makes the whole product feel cheap and slow, and it affects every user on every session.

**Independent Test**: Fling-scroll each of the five main screens end-to-end on the baseline test device while recording frame timings. Every screen delivers the target frame rate with zero frames over budget. Delivers value on its own even if no other story ships.

**Acceptance Scenarios**:

1. **Given** the Practice/Challenge screen with a full problem list, **When** the user fling-scrolls from top to bottom and back, **Then** no dropped or over-budget frames are recorded and the motion tracks the finger with no visible hitch.
2. **Given** any of the five main tab screens, **When** the user scrolls continuously for 10 seconds, **Then** the frame rate stays at the target with no stutter, and scroll velocity stays consistent.
3. **Given** a screen containing multiple glass surfaces on top of the aurora background, **When** the user scrolls, **Then** the glass and background render identically to today while the frame budget is met.
4. **Given** a screen at rest with no user input, **When** nothing on screen is animating, **Then** the app performs no repeated re-rendering work (idle screens stay idle).

---

### User Story 2 - Watch a sorting run at full smoothness (Priority: P2)

A user starts a sorting visualization on the Visualize screen. Bars swap positions, change colour to show comparisons and swaps, and settle into sorted order. The whole run plays back fluidly at every playback speed, including the fastest one and with the largest supported array size.

**Why this priority**: The sorting visualization is the app's signature feature. Stutter during a sort directly undermines the product's core value — showing an algorithm clearly. It is second only to scrolling because it affects a focused session rather than every screen.

**Independent Test**: Run a full sort at the maximum array size at each of the five playback speeds while recording frame timings, and confirm the target frame rate is held for the whole run. The fastest speed is the stress case; all five are gated.

**Acceptance Scenarios**:

1. **Given** a sorting run in progress at the fastest playback speed, **When** bars swap positions and change state, **Then** every frame lands within the frame budget for the full duration of the run.
2. **Given** a sorting run at the maximum supported array size, **When** the animation plays from start to finish, **Then** the target frame rate is sustained with no dropped frames.
3. **Given** a sorting run in progress, **When** a single bar's position or state changes, **Then** only the parts of the screen that actually changed are re-rendered — unaffected bars, controls, and chrome are not.
4. **Given** a user steps forward and backward through the sort manually, **When** each step is applied, **Then** the screen updates within one frame with no visible delay.

---

### User Story 3 - Open screens and switch tabs instantly (Priority: P3)

A user taps between the five bottom-nav tabs and opens sub-screens. Each screen appears immediately with no freeze, no white flash, and no delay before it becomes interactive.

**Why this priority**: Navigation stalls are less frequent than scrolling but still shape the perception that "the app is slow". Fixing the render cost from the first two stories is expected to improve this, so it is sequenced after them.

**Independent Test**: Time first-paint and time-to-interactive for each tab from a cold tab switch and from a repeat switch, on the baseline device.

**Acceptance Scenarios**:

1. **Given** the user is on any tab, **When** they tap a different tab, **Then** the new screen is visible and interactive with no frame exceeding the budget during the transition.
2. **Given** the user taps rapidly through all five tabs in sequence, **When** the transitions play, **Then** the app remains responsive and no frame is dropped.
3. **Given** a screen was previously visited, **When** the user returns to it, **Then** it appears without re-doing work that its state has not invalidated.

---

### User Story 4 - Prove and protect the gains (Priority: P4)

The team can measure the app's frame performance on demand by running an automated suite, see the before/after numbers for each of the five main screens, and catch a future change that makes rendering slower again. Separately, a developer can profile a specific screen by hand to find *why* it is slow.

**Note**: the repository currently has no `integration_test/` directory and no timeline-capture tooling, so this harness is built from scratch as part of this feature.

**Why this priority**: Without measurement, "it feels faster" is an opinion and the gains silently erode. It is last because it depends on the optimisations existing first, but it is what makes the other three durable.

**Independent Test**: Run the performance measurement on a clean checkout and confirm it produces per-screen frame metrics that can be compared against recorded baselines.

**Acceptance Scenarios**:

1. **Given** the automated performance suite, **When** it is run against the baseline device, **Then** it reports per-screen frame timings (average and worst-case) for the five main screens and the sorting animation, with no human input required during the run.
2. **Given** committed baseline numbers, **When** a change regresses frame performance beyond the agreed tolerance, **Then** the regression is detectable by re-running the suite and comparing its output against those baselines.
3. **Given** the optimisation work is complete, **When** the before and after numbers are compared, **Then** the improvement on each target screen is documented with real figures.
4. **Given** a screen that misses its frame budget, **When** the developer profiles it manually on the baseline device, **Then** the specific widget or paint operation consuming the budget can be identified.

---

### Edge Cases

- **Below-baseline devices**: What happens on a device weaker than the Oppo A5i, which may not physically sustain the target even with optimal rendering? The app must degrade gracefully (smooth-but-slower motion) rather than stutter unpredictably, and must never crash or hang. Such devices are not gating targets.
- **Thermal throttling**: What happens when the entry-level baseline device heats up during a long session? Frame targets must be measured on a warm device as well as a cold one, since sustained performance is what users actually experience.
- **High-refresh displays**: What happens on a 90 Hz or 120 Hz screen? Hitting the 60 FPS target must not cap or visibly harm the experience on faster displays.
- **Reduce-motion**: What happens when the OS "reduce motion" accessibility setting is on? The existing reduced-motion behaviour must be preserved exactly, and the reduced path must be at least as smooth as the full path.
- **Theme switching**: What happens when the user switches light/dark theme? Colours must update correctly and immediately — an optimisation must not cache a stale colour or background.
- **Largest data sets**: What happens with the maximum problem-list length and the maximum sorting array size at once? Frame budget must still be met, and memory use must stay within normal bounds.
- **Rapid input**: What happens when the user scrolls and an animation plays simultaneously (e.g. scrolling while a sort is running)? Both must stay smooth; neither may starve the other.
- **Backgrounding**: What happens when the app is backgrounded mid-animation and resumed? No animation work runs while hidden, and resuming does not produce a burst of dropped frames.
- **Orientation / resize**: What happens on rotation or window resize (desktop)? Layout adapts without a long freeze.
- **First launch / shader warm-up**: What happens on the very first cold start and the first play of each animation, before the graphics driver has compiled its shaders? A one-time stutter is expected platform behaviour on entry-level Android, so it is excluded from the pass/fail gate — but it is measured every run and must stay inside the SC-011 allowance. It is a tracked cost, not a free pass.

## Requirements *(mandatory)*

### Functional Requirements

**Frame performance**

- **FR-001**: The app MUST sustain the target frame rate of 60 frames per second on the baseline test device (Oppo A5i, release/profile build) during scrolling, animation, and navigation on all five main tab screens.
- **FR-002**: The app MUST produce zero frames that exceed the 16.67 ms frame budget during a standard scroll pass of each of the five main screens on the baseline device.
- **FR-003**: The sorting visualization MUST sustain the target frame rate for the complete duration of a sort at every supported playback speed and at the maximum supported array size.
- **FR-004**: The problem list on the Practice/Challenge screen MUST scroll at the target frame rate regardless of how many problems the list contains. This MUST be verified against the **worst-case list length**, not only the default fixture — a list that is smooth at 20 items and janky at 200 does not satisfy this.

**Re-render efficiency**

- **FR-005**: When a piece of state changes, only the parts of the screen that display that state MUST be re-rendered; unrelated parts of the screen MUST NOT be re-rendered.
- **FR-005a**: Any widget that profiling shows is re-rendering more often than its displayed state actually changes MUST be narrowed to watch only what it reads. This is **mandatory wherever profiling proves a frame cost**, on any screen — not limited to the five main screens.
- **FR-005b**: Broad state-watching call sites that profiling does **not** implicate MUST NOT be refactored as part of this feature. They MUST instead be inventoried into a follow-up debt list, with the count and locations recorded, so the cleanup is a deliberate later decision rather than untested churn bundled into a performance fix.
- **FR-005c**: No **new** broad, unscoped state-watching may be introduced by this feature's changes. This MUST be verified against the feature's own diff, not asserted.
- **FR-006**: A screen with no user input and no running animation MUST perform no repeated rendering work — idle screens MUST be genuinely idle.
- **FR-007**: The expensive visual surfaces the user identified — the frosted-glass container (including its backdrop blur) and the aurora background — MUST NOT be re-created or re-rendered on every frame when their inputs have not changed.
- **FR-008**: The number of simultaneously rendered expensive blur surfaces on any single screen MUST be bounded, and overlapping/nested blur surfaces MUST be avoided.
- **FR-008a**: That bound is **2** independent backdrop-blur surfaces per screen: one shared group for page content, plus the floating navigation bar, which must stay independent precisely because it overlaps that content. Any screen exceeding 2 MUST be reported.

**Visual and behavioural fidelity**

- **FR-009**: The visual appearance of every screen after optimisation MUST be pixel-identical to the current appearance. This is a **hard constraint**: reducing blur strength, removing glass layers, flattening the aurora background, or otherwise simplifying the design language to buy frame time is NOT permitted. Optimisation must change only *how* the current appearance is produced, never *what* it looks like.
- **FR-009a**: If profiling shows the frame target cannot be met on the baseline device without changing appearance, the shortfall MUST be reported with measurements rather than resolved by silently degrading the visuals. Any proposed visual change requires explicit approval first.
- **FR-009b**: **Golden (screenshot) tests MUST be captured before any optimisation begins** and MUST cover: the glass container at all three depths, the aurora background, and all five main tab screens — each in both light and dark themes. These goldens are the reference for FR-009.
- **FR-009c**: Every optimisation change MUST leave the golden tests passing with **zero** pixel difference. A golden test that needs updating is treated as a **failed** change, not as a golden to re-record, unless the visual change was explicitly approved under FR-009a.
- **FR-009d**: The golden tests MUST remain in the repository after this feature ships, as the permanent guard against a future change silently altering the glass or aurora appearance.
- **FR-010**: All existing functionality MUST continue to work unchanged — algorithm correctness, playback controls, navigation, authentication, and data loading.
- **FR-011**: Existing accessibility behaviour, including the OS reduce-motion setting, MUST be preserved.
- **FR-012**: Light and dark themes MUST both render correctly, and switching between them MUST take effect immediately.

**Scope of coverage**

- **FR-013**: The five main tab screens (Home, Visualize, Code, Practice, Profile) MUST all meet the frame targets; no screen may be left behind.
- **FR-014**: Screens reached from the main tabs (problem detail, code editor, celebration, bookmarks, practice history, auth screens) MUST NOT regress in frame performance as a result of this work.

**Measurement**

- **FR-015**: An **automated** performance suite MUST exist that drives each target screen without human input and reports, per screen, the average frame time, worst-case frame time, and the count of over-budget frames. It MUST be runnable on demand against a physical device and produce machine-readable output.
- **FR-016**: Before-and-after frame measurements for each of the five main screens and the sorting animation MUST be recorded and documented as committed baseline files, so the improvement is reproducible rather than anecdotal.
- **FR-017**: A frame-performance regression beyond the agreed tolerance MUST be detectable by re-running the automated suite and comparing its output against the committed baselines.
- **FR-018**: Manual profiling (DevTools timeline inspection on the baseline device) MUST be used during the work to identify which specific widgets and paint operations consume the frame budget. Manual profiling is a **diagnostic** tool only — it MUST NOT serve as the pass/fail gate, because it is not repeatable.
- **FR-019**: The automated suite MUST run against the physical baseline device. It MUST NOT be gated in CI on hosted runners, whose lack of a real GPU makes their frame numbers meaningless.
- **FR-019a**: Adding these harnesses MUST NOT break the existing CI pipeline. The repository's PR quality gate runs `flutter test` on a **Linux** runner while goldens are recorded on **macOS**; because golden images are platform-specific, the golden suite MUST be excluded from that Linux job rather than allowed to fail it.
- **FR-019b**: Despite FR-019a, the golden suite MUST still run automatically somewhere on every pull request — on a runner matching the OS the goldens were recorded on. Excluding goldens from CI entirely would silently defeat the permanent guard required by FR-009d.
- **FR-022**: The performance harness MUST have a working path from an on-device run to a committed report file. Capturing timings in memory is not sufficient — if the run cannot write its report to disk, FR-015, FR-016 and FR-017 are all unsatisfiable.
- **FR-020**: The automated suite MUST report **steady-state** and **warm-up** frame metrics as two separate figures per screen. Steady state determines pass/fail; warm-up is reported against the allowance in SC-011 and MUST NOT be silently discarded.
- **FR-021**: Warm-up MUST be defined explicitly and identically across every measurement (the same discard window and the same definition of "steady state"), so that results from different runs and different builds are comparable.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All five main screens sustain 60 frames per second during continuous scrolling on the **Oppo A5i in a release/profile build**, with **zero** frames exceeding the 16.67 ms budget across a 10-second **steady-state** scroll pass (warm-up excluded per SC-011).
- **SC-002**: A complete sorting run at the maximum array size finishes with **zero** dropped frames in steady state, at **every** supported playback speed — slow, normal, fast3, fast5 and fast10 (warm-up excluded per SC-011). Aligned with FR-003; the fastest speed is the stress case, but all five are gated because running them is cheap.
- **SC-003**: Worst-case frame time on every target screen drops below 16.67 ms, measured as the 99th-percentile frame time across the standard scroll pass.
- **SC-004**: **Widget rebuild count** for a single isolated state change (for example, one sorting bar swapping position) is reduced by at least **80%** versus the recorded baseline. "Rebuild count" means the number of widgets whose build runs in response to that one change, counted the same way before and after.
- **SC-005**: A screen at rest performs **zero** rendering work per second — no repeated frames are produced when nothing has changed.
- **SC-006**: Tab switching completes with the new screen visible and interactive in under **300 ms**, with no over-budget frames during the transition.
- **SC-007**: Screen-by-screen appearance is **pixel-identical**: the golden test suite — glass container at all three depths, aurora background, and all five main screens in both light and dark themes — passes with **zero** pixel difference after optimisation. Any difference at all is a failure, not a tolerance.
- **SC-008**: Frame targets are met on a **thermally warm** device (after 10 minutes of continuous use), not only on a cold one.
- **SC-009**: Every existing automated test continues to pass, and no functional behaviour changes.
- **SC-010**: Recorded before/after measurements exist for all five main screens plus the sorting animation, showing the improvement in concrete numbers.
- **SC-011**: **First-run (warm-up) allowance** — on the first play of each animation after a cold start, at most **5** frames may exceed the 16.67 ms budget, no single frame may exceed **100 ms**, and the app must reach steady state within **500 ms**. These numbers are measured and reported on every run, never silently discarded.

## Assumptions

- **Target frame rate**: 60 FPS (a 16.67 ms per-frame budget) is the goal, as stated by the user. Matching higher refresh rates (90/120 Hz) is out of scope for this feature, but the work must not prevent it later.
- **Baseline test device**: the **Oppo A5i (Android)**, running a **release/profile build**. All pass/fail judgements in this spec are made against that device. Debug builds are not representative and MUST NOT be used for measurement. iOS and desktop are not gating targets for this feature, but MUST NOT regress.
- **The baseline device is entry-level, and that is deliberate**: it is the hardest bar the app must clear. A fix that only reaches 60 FPS on faster hardware does not satisfy this spec.
- **Known tension (flagged, not resolved)**: sustaining 60 FPS with real-time backdrop blur on entry-level Android hardware while holding appearance pixel-identical (FR-009) is a demanding combination. The implementation plan must confirm with real measurements that it is achievable on the Oppo A5i; if it is not, FR-009a governs what happens next.
- **"Main five pages"** refers to the five bottom-nav tab destinations: Home, Visualize, Code, Practice, and Profile.
- **Behaviour is frozen**: this is a performance feature only. No new user-facing capability, no redesign, no content change.
- **Design language is preserved**: the glass/aurora visual language introduced in the current design work stays. Optimisation changes how it is produced, not how it looks (subject to FR-009).
- **The user's diagnosis is the starting point, not the whole scope**: the glass container's backdrop blur, the aurora background, the Practice list scroll, and the sorting bar animation are confirmed hot spots, but profiling may reveal others that also need addressing to hit the targets.
- **Measurement runs on real hardware**, not an emulator or simulator, since GPU-bound blur cost is not represented faithfully by emulation.
- **Two verification layers, two different jobs**: golden tests run on the host test renderer and catch *widget-level* composition changes exactly and cheaply; they do not reproduce the device GPU's blur output. Device screenshots from the Oppo A5i are therefore still captured once per screen as a final confirmation, since a host-renderer golden cannot by itself prove the on-device pixels are unchanged. That comparison is made by an **exact pixel-diff script** (`tool/compare_screenshots.py`), not by eye: only pairs the script flags as differing are inspected visually. Detecting a change is deterministic and free; describing *what* changed is the only part worth human or model attention, and it is spent only where the diff is non-zero. Goldens are the gate; the device check is the backstop.
- **Data and network behaviour are unchanged**: this feature addresses rendering cost, not data fetching, caching, or startup I/O, except where those directly block a frame.
- **Existing project engineering rules apply**: the optimisation must stay within the project's established widget, sizing, theming, string, and state-watching conventions rather than working around them.
- **Known starting inventory**: at spec time the codebase contains roughly **47 unscoped state-watch call sites** against **53** correctly scoped ones. This is context for where to look first, not a target to drive to zero in this feature (see FR-005b).

## Out of Scope

- App startup/cold-launch time optimisation (beyond not making it worse).
- Network, database, or caching performance.
- Binary size or memory-footprint reduction as goals in their own right.
- Any visual redesign or new UI feature.
- Supporting refresh rates above 60 Hz.
- Web platform performance.
- Making iOS and desktop *gating* targets — they must not regress, but they are not measured for pass/fail here.
- Guaranteeing 60 FPS on devices weaker than the Oppo A5i.
- Blanket refactoring of every unscoped state-watch call site in the app — only profiling-implicated ones are in scope; the rest become recorded follow-up debt (FR-005b).

## Dependencies

- Access to the **Oppo A5i** physical test device for all pass/fail measurement, connected for automated suite runs.
- A new automated performance-test harness must be built — none exists in the repository today (no `integration_test/` directory, no timeline tooling). This is net-new work, not a configuration change.
- A golden-test suite must be created and its reference images captured **before** the first optimisation commit — once the code changes, the original appearance can no longer be recorded. This is a hard sequencing dependency (FR-009b).
- Device screenshots of all five main screens in both themes, captured on the Oppo A5i prior to any change, as the on-device backstop to the goldens.
- The current build must be measurable in a release-equivalent configuration.
- Existing automated tests serve as the regression safety net for FR-010 and SC-009.
