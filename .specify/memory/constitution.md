<!--
Sync Impact Report
Version change: 1.0.0 → 1.1.0
Modified principles: none
Added sections:
  - Visual-only changes (new gate for tasks tagged as a restyle)
Removed sections: none
Templates requiring updates:
  - .specify/templates/plan-template.md ⚠ pending manual check (not reviewed in this run)
  - .specify/templates/spec-template.md ⚠ pending manual check (not reviewed in this run)
  - .specify/templates/tasks-template.md ⚠ pending manual check (not reviewed in this run)
Follow-up TODOs:
  - TODO(RATIFICATION_DATE): AGENTS.md conventions predate this constitution and have no
    recorded adoption date. Confirm the real date or keep as the day this file was first
    written (2026-09-11).
-->

# AlgoDive Constitution
<!-- AlgoDive is the shipping name of this Flutter algorithm-visualizer app (see README.md flavors table). -->

## Core Principles

### I. Widget Classes, Not Function Builders
All UI MUST be built with `StatelessWidget` / `StatefulWidget` classes. Function-style
widget builders (e.g. `Widget _buildHeader() => ...`) are NOT permitted. Reusable UI
pieces MUST be extracted into named widget classes instead.
Rationale: widget classes get their own `const` constructors, get skipped by Flutter's
element diffing more cheaply, and are independently testable and reviewable — a private
builder method is none of those things.

### II. Core Adaptive Widgets Only (Text & Padding)
Raw `Text(...)` and raw `Padding(padding: EdgeInsets...)` MUST NOT be used. Text MUST go
through the adaptive text hierarchy in `lib/core/widgets/adaptive/text/`
(`AdaptiveText`, `BoldText`, `MediumText`, `SemiBoldText`, `RegularText`, `LightText`).
Padding MUST go through the directional widgets in `lib/core/widgets/adaptive/padding/`
(`AllPadding`, `HorizontalPadding`, `VerticalPadding`, `StartPadding`, `EndPadding`,
`TopPadding`, `BottomPadding`, `OnlyPadding`, `SymmetricPadding`, `AdaptivePadding`).
Rationale: routing every piece of text and every padding through one shared widget
family is what keeps typography and spacing consistent app-wide, and keeps a future
global change (e.g. a new text scale) a one-file edit instead of a grep-and-replace.

### III. Responsive Sizing via ScreenUtil
Hard-coded pixel values MUST NOT be used for sizing. All dimensions MUST use the
`flutter_screenutil` suffixes: `.w` (width), `.h` (height), `.r` (radius), `.sp` (font
size). Example: `BorderRadius.circular(8.r)`, not `BorderRadius.circular(8)`.
Rationale: the app targets both mobile and desktop (README.md); unscaled pixel values
look correct on one screen size and wrong on every other.

### IV. Theme Colors via ThemeEnum Only
Raw color values (`Color(...)`, `Colors.xxx`, `.withOpacity(...)`, or
`Theme.of(context).primaryColor`) MUST NOT be used. Colors MUST be read through
`context.getColor(ThemeEnum.xxx)`, with mappings defined in
`lib/core/resources/theme_manager.dart`.
Rationale: a single enum-backed source of truth is what makes light/dark mode and
future re-theming possible without hunting down inline color literals.

### V. Centralized Strings via StringsManager
User-facing text MUST NOT be hard-coded inline. Every string MUST be a
`static const` on `StringsManager` (`lib/core/resources/strings_manager.dart`); add the
constant first if it doesn't exist yet, then reference it.
Rationale: centralized strings are the prerequisite for localization and let a copy
change happen in one file instead of a repo-wide text search.

### VI. Scoped State Watching (Riverpod `.select()`)
Widgets MUST prefer `ref.watch(provider.select((s) => s.field))` over
`ref.watch(provider)` so a widget only rebuilds when the specific piece of state it
reads actually changes.
Rationale: broad `ref.watch(provider)` calls cause widgets to rebuild on unrelated
state changes, which is the most common avoidable source of jank in this app.

### VII. Consistency With Existing Code (NON-NEGOTIABLE)
New or modified code MUST match the patterns already established in the surrounding
file: the same import ordering, the same naming style (camelCase / PascalCase), the
same widget composition style, and the same provider pattern used nearby. A new
package, pattern, or architecture MUST NOT be introduced without discussion first.
Rationale: this is what keeps a codebase touched by many contributors (and by AI
coding agents) from drifting into several competing styles over time.

## Environments & Flavors

The app ships in three flavors — `dev`, `staging`, `production` — each with its own
entry point (`lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`), app
id, launcher icon, and Firebase project (README.md). `lib/main.dart` is not launchable
and MUST NOT be used as a run target. Any change that touches environment
configuration, Firebase files, or app identifiers MUST follow
`docs/flavors/PLAYBOOK.md` and the Firebase checklist in
`docs/flavors/FIREBASE_CHECKLIST.md`.

## Development Workflow

- Day-to-day feature work merges into `develop`; it needs no version tag and no
  release gate.
- Promoting code up the release ladder (`develop` → `staging`, `staging` →
  `production`) follows the project's `promote` workflow: verify the merge direction
  is allowed, compute the next tag, merge, then push the tag that ships the build.
- An urgent fix that cannot wait for a full release follows the project's `hotfix`
  workflow: prefer a Shorebird code-push patch when the fix qualifies, otherwise run
  a full release.
- Git commit messages and PR descriptions in this repository MUST NOT include
  `Co-Authored-By: Claude` or similar AI-attribution trailers.
- This repository is PUBLIC. Secrets MUST NOT be committed — never via a `.env`
  file. Follow the project's established three-tier config/secret split, and treat
  the one known previously-leaked keystore as already compromised, not as a pattern
  to repeat.

## Visual-only changes

Any task tagged as a restyle is governed by this section. These rules are non-negotiable.

- **Appearance only.** A restyle MUST NOT add, remove, rename, reorder, or move a widget
  between screens. It MUST NOT change any user-visible string. It MUST NOT touch
  navigation, routing, state, data, or business logic. It MUST NOT add or remove a
  dependency.
- **Values come from the design reference.** Every visual value (colour, radius, size,
  spacing) MUST be read from the approved design reference committed in the repo. The
  agent MUST NOT invent a colour, radius, size, or spacing value, and MUST NOT "round"
  one to a nicer number.
- **Literals stay in the theme file.** Colour, radius, border, and typography literals
  MUST live only in the existing theme file. Screen and widget files MUST contain zero
  such literals.
- **Shared widgets, semantic parameters.** Any visual pattern that appears on more than
  one screen MUST be implemented once as a shared widget and called everywhere it's
  needed. Shared widgets MUST take semantic parameters (e.g. `selected`, `difficulty`,
  `level`, `depth`) and MUST NOT take a raw colour argument.
- **Match the surrounding code.** New code MUST match the surrounding code's naming,
  structure, `const` usage, comment style, and import order. Files not otherwise changed
  by the restyle MUST NOT be reformatted.
- **No dead code left behind.** Dead code from a replaced design MUST be deleted in the
  same PR — not left behind a flag or an alias.
- **Verify by measurement.** Compliance MUST be verified by measurement — greps,
  rendered-geometry assertions, contrast numbers — not by looking at a screenshot and
  calling it good.

Rationale: a restyle is scoped narrowly on purpose. "Looks right" is not sufficient
evidence for this class of change, because an appearance-only claim is exactly what
would hide a smuggled behavior change or an invented design value.

## Governance

This constitution is the source of truth for non-negotiable engineering rules in this
repository; where it conflicts with an older doc or habit, the constitution wins.
`AGENTS.md` is the day-to-day, example-driven companion to Core Principles I–VII above
and MUST be kept in sync with them — if one changes, update the other in the same PR.

**Amendment procedure**: propose the change (what, why), update this file, bump the
version per the policy below, and update `LAST_AMENDED_DATE`. Amendments land as a
normal reviewed PR; no separate approval body exists for a project this size.

**Versioning policy** (semantic versioning applied to this document):
- MAJOR — a principle is removed or redefined in a backward-incompatible way.
- MINOR — a new principle or section is added, or existing guidance is materially
  expanded.
- PATCH — wording, clarification, or typo fixes with no rule change.

**Compliance review**: code review MUST verify compliance with the Core Principles
above (I–VII), and, for any task tagged as a restyle, with the Visual-only changes
section above. Any deviation MUST be called out explicitly in the PR description with
its justification — silent deviation is not permitted.

**Version**: 1.1.0 | **Ratified**: 2026-09-11 | **Last Amended**: 2026-09-11
