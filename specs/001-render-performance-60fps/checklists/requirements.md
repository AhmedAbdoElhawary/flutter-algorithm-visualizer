# Specification Quality Checklist: Render Performance — Smooth 60 FPS Across the App

**Purpose**: Validate specification completeness and quality before proceeding to planning
**Created**: 2026-09-11
**Feature**: [spec.md](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Notes

**Status: 16/16 items pass. Spec is ready for `/speckit-plan`.**

> Success-criteria numbering changed in iteration 3. Pixel-identical appearance is now **SC-007**
> (it was SC-008); the warm-device criterion is now **SC-008** (it was SC-011). References in the
> iteration-2 note below are preserved as written at the time.

### Iteration 1 (2026-09-11) — 15/16, two open questions

- **FR-009** — is pixel-identical appearance a hard constraint, or may fidelity be traded for frames?
- **Assumptions / baseline device** — which device and build configuration define a pass?

### Iteration 2 (2026-09-11) — 16/16, both resolved

- **FR-009 → Option A**: pixel-identical appearance is a **hard constraint**. Cheaper blur, fewer
  glass layers, and a simplified aurora background are all off the table. FR-009a was added so a
  shortfall gets reported with measurements instead of resolved by silent visual degradation.
  SC-008 was tightened from "no unintended differences" to **zero** differences.
- **Baseline device → Option A, Oppo A5i**: an entry-level Android phone, release/profile build.
  Android is the only gating platform; iOS and desktop must not regress but are not measured for
  pass/fail. Two additions followed from this choice: a thermal-throttling edge case and SC-011,
  which requires the target to hold on a *warm* device — sustained performance on entry-level
  hardware is what users actually experience.

### Iteration 3 (2026-09-11) — `/speckit-clarify`, 5 questions, still 16/16

No checkbox changed state, but two items are now materially stronger rather than merely passing:

- *"Success criteria are measurable"* — SC-004 was an undefined metric ("rendering operations") and
  SC-007 required a ten-person tester panel. SC-004 is now a countable widget rebuild reduction;
  the tester panel is gone. Both were previously passing on generosity, not evidence.
- *"Requirements are testable and unambiguous"* — FR-015/016/017 assumed a measurement harness that
  does not exist in the repo. The gap is now explicit and specified (FR-018 through FR-021).

Five clarifications resolved: measurement method, warm-up/shader-jank tolerance, pixel-identity
verification method, rebuild-cleanup scope, and unverifiable success criteria. FR count 17 → 28;
SC count 10 → 11.

### Standing notes

- Frame-rate figures (60 FPS, 16.67 ms) are treated as *user-facing* metrics, not implementation
  detail: perceived smoothness is the whole point of this feature, so the metric is the outcome.
- Named widgets from the user's report (glass container, aurora background) are referenced in
  FR-007 descriptively, as the confirmed hot spots to fix — no solution is prescribed.
- **Carry into planning**: the combination of pixel-identical real-time backdrop blur and a
  zero-dropped-frame target on entry-level hardware is demanding. The plan must prove it with
  real measurements on the Oppo A5i early, before the bulk of the work is committed.
- **Hard sequencing constraint**: golden reference images and the "before" performance baseline
  must both be captured **before the first optimisation commit**. Once the code changes, neither
  the original appearance nor the original frame numbers can be recovered. The plan must put these
  first.
- **Two harnesses are net-new work**: the automated performance suite and the golden-test suite
  both have to be built from nothing — the repo has 7 test files, no `integration_test/`, and no
  visual tests. This is a real chunk of the feature, not setup overhead to wave through.
