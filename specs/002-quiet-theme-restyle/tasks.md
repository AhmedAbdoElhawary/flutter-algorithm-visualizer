# Tasks: Quiet Theme Restyle

**Input**: Design documents from `/specs/002-quiet-theme-restyle/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/theme-and-widget-contract.md, quickstart.md

**Organization**: Per the user's explicit instruction, tasks are organized by the plan's
seven phases (theme → deletion → shell/nav → shared widgets → screens → chart/heat-map
corrections → sweep), each in commit order. Where a task primarily serves one user
story from `spec.md`, it carries that story's label for traceability:
`[US1]` = Uninterrupted focus in the Visualizer (P1), `[US2]` = Consistent quiet
appearance app-wide (P2), `[US3]` = Confidence the restyle is visual-only and the two
pre-existing bugs are fixed (P3). Phases 1–2 are infrastructure shared by all stories
and carry no label. No test-writing, unrelated-refactor, or documentation tasks are
included beyond what verification itself requires, per the user's explicit exclusion.

**Revision note (post `/speckit-analyze`)**: This revision fixes findings I1 (T027's
promise to wire the live-session widget's `expanded`/`pill` sizes in Phase 5 was never
kept by any Phase 5 task), I2 (T037 bundled four separate screen files into one task,
violating "give every screen its own task"), C1 (no final repo-wide literal-scan task
for SC-002), and C2 (no single-definition-per-pattern check for SC-003). Task IDs
T037 onward are renumbered accordingly — see the mapping at the bottom of this note if
you have the pre-revision IDs cross-referenced elsewhere:
`old T038→T041, T039→T042, T040→T043, T041→T044, T042→T045, T043→T046, T044→T048,
T045→T050, T046→T051, T047→T052, T048→T053, T049→T054, T050→T055, T051→T056`
(T047 and T049 in the new numbering are newly inserted, not renamed).

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- Every task names an exact file path

---

## Phase 1: Theme (single, independently reviewable task)

**Purpose**: Every Quiet role, both brightnesses, in the existing theme class. No call
site changes — the app still looks identical after this task; only the values behind
each `ThemeEnum` member change (plus the small number of brand-new members).

- [X] T001 In `lib/core/resources/color_manager.dart` and `lib/core/resources/theme_manager.dart`, apply the full role mapping from `research.md` R2–R4 for both dark and light: repoint the existing `cd*` constants behind `ThemeEnum.primary` (background base → `#0B0B0D`/`#FBFBFC`), `mainCard` (surface → `#121317`/`#FFFFFF`), `bgRaised` (surface raised → `#181A1F`/`#F4F5F7`), `borderSubtle` (→ solid `#1C1D22`/`#E8E9ED`, remove the alpha), `border` (→ solid `#24262C`/`#DCDEE3`), `borderStrong` (→ solid `#3A3D46`/`#B9BCC4`), `onPrimary` (→ `#0B0B0D`/`#FFFFFF`), `primaryTint` (→ solid `#24262C`/`#ECEDF0`), `primaryRing` (focus ring → white @ 55% / `#101114` @ 45% — alpha is allowed here per the spec, it is not a surface fill), `textPrimary` (→ `#F2F3F5`/`#101114`), `textBody` (→ `#9A9FAB`/`#4A4F5A`), `textDisabled` (→ `#4A4E5A`/`#A0A5AE`), `textBright` (repoint per research.md R3 to serve the "primary" ink/action role → `#FFFFFF`/`#101114` — **note**: `ThemeEnum.primary` itself keeps meaning "background base"; `textBright` is the codebase's stand-in for the design doc's white/black "primary" action colour, to avoid a name collision — see research.md R3), `difficultyEasy`/`barDone` (→ `#79C9A4`/`#11704E`), `difficultyMedium` (→ `#D9AE72`/`#8A5D12`), `difficultyHard`/`barSwap` (→ `#DE8189`/`#A83F49`), `comparing`/`barCompare` (→ `#FFFFFF`/`#101114`, retiring the cyan), `barIdle` (→ solid `#2A2D35`/`#DCDEE3`), `barExcluded` (→ `#181A1F`/`#EDEEF1`), and `heat0..heat4` (→ `#181A1F`/`#21312B`/`#375749`/`#548871`/`#79C9A4` dark, `#EDEEF1`/`#DBEBE2`/`#B5D8C6`/`#7FBBA0`/`#11704E` light). Add new members `track` (→ `#2A2D35`/`#E2E4E9`), `chipEasyFill`/`chipMediumFill`/`chipHardFill`/`chipNeutralFill` (dark: `#17241F`/`#25200F`/`#291619`/`#1C1D22`; light: `#E7F3EC`/`#F6EFE2`/`#F9EAEB`/`#F0F1F4`, each paired with its existing label-color role — `difficultyEasy`/`difficultyMedium`/`difficultyHard`/`textBody` respectively). Do not touch any widget or screen file in this task.

**Checkpoint**: `flutter analyze` clean; app renders unchanged (old aurora colors just happen to have new hex values that are visually close enough at this stage, or visually already show the shift — this is expected and corrected by later phases). This task is fully reviewable in isolation against `research.md` R2–R4.

---

## Phase 2: Deletion (deletion-only diff — no new styling added)

**Purpose**: Remove every banned technique (`BackdropFilter`, `BoxShadow`/`elevation`,
`Gradient`) and the four retired accent hues, with **no replacement** decoration added
anywhere. Any file left looking visually plain after this phase is expected — its
proper restyle happens in Phase 4/5.

- [X] T002 In `lib/core/widgets/custom_widgets/glass_card.dart`, delete the `BackdropFilter`/blur construction, the `BoxShadow`/`CdElevation` branches, the sheen/gradient layers, and the dead commented-out glow/dot-grid lines (~160–162) from `GlassContainer`. Do not add any replacement decoration — leave the container as a bare `Container`/`DecoratedBox` with only a solid fill for now; its proper `surface card` styling is applied in Phase 4/5.
- [X] T003 [P] Delete the unused files `lib/core/widgets/custom_widgets/aurora_progress.dart` and `lib/core/widgets/custom_widgets/aurora_segmented_control.dart` in full — confirmed zero call sites in `research.md` R10.
- [X] T004 [P] In `lib/core/widgets/custom_widgets/algorithm_control.dart`, delete its `Gradient(...)` construction and any `BackdropFilter`/`BoxShadow` usage found by `grep -n 'BackdropFilter\|BoxShadow\|Gradient(' lib/core/widgets/custom_widgets/algorithm_control.dart`, with no replacement styling.
- [X] T005 [P] In `lib/core/widgets/custom_widgets/aurora_buttons.dart`, delete its `Gradient(...)` construction (the button glow) only — do not otherwise modify the file; its widgets are replaced wholesale in Phase 4.
- [X] T006 [P] In `lib/core/resources/dimensions_manager.dart` and `lib/core/widgets/custom_widgets/animated_popup.dart` and `lib/features/auth/presentation/common/widget/auth_text_field.dart`, delete every `BackdropFilter`/`BoxShadow` construction found by `grep -n 'BackdropFilter\|BoxShadow'` on each file, with no replacement.
- [X] T007 Delete the `cardShadow` getter from `lib/core/resources/theme_manager.dart` and every `boxShadow: context.cardShadow` call site: `lib/core/widgets/custom_widgets/confirmation_dialog_card.dart:42`, `lib/features/profile/presentation/widgets/profile_stats_grid.dart:73`, `lib/features/profile/presentation/widgets/profile_category_chart.dart:31`, `lib/features/profile/presentation/widgets/profile_logout_card.dart:100`, `lib/features/profile/presentation/widgets/profile_practice_history.dart:37`, `lib/features/challenge/presentation/widgets/challenges/challenges_filter_tabs.dart:45`, `lib/features/challenge/presentation/widgets/challenges/loading_state.dart:41`, `lib/features/challenge/presentation/widgets/challenges/challenges_search_field.dart:40` (remove the `boxShadow:` property entirely at each site, not just its value).
- [X] T008 [P] Delete the dead `ThemeEnum` members `glowIndigo`, `glowCyan`, `dotGrid`, and `accentAzure` from `lib/core/resources/theme_manager.dart`, plus their backing `cd*` constants in `lib/core/resources/color_manager.dart` (`cdGlowIndigoDk/Lt`, `cdGlowCyanDk/Lt`, `cdDotGridDk/Lt`, `cdAccentAzureDk/Lt`) — confirmed zero call sites outside the theme files in `research.md` R2.

**Checkpoint**: `grep -rn 'BackdropFilter\|BoxShadow\|Gradient(' lib --include='*.dart' | grep -v theme_manager.dart` returns zero. `flutter analyze` clean. No new decoration was added anywhere in this phase.

---

## Phase 3: Shell and nav (the one structural fix)

- [X] T009 [US2] Rewrite `lib/features/base/view/base_navigation.dart`'s `MainNavigationShell` from its current `Stack` (with `AuroraGround` as the base layer and the floating pill `_AuroraNavBar` overlaid via `AlignmentDirectional.bottomCenter`) into a `Column`: an `Expanded` + `ClipRect` content slot holding `navigationShell`, and a new non-flexible nav bar widget as the child below it. Rebuild the private nav-bar widget (rename from `_AuroraNavBar`) to: height 64, full width, no margin, no radius, no fill, a 1px `border subtle` top rule against `background base`, internal padding `0 6 6`, five equal items each a 20px real vector icon (from the icon set already in the project — no new dependency) over a 9.5px label with a 5px gap, active item in `textBright` (primary ink/action role, stroke 1.8, label weight 500, no pill/fill behind it), inactive in `textSecond` (text secondary, stroke 1.6, weight 400). Keep the five destinations, their order, and their routing exactly as they are. Delete the `AuroraGround` class and its deprecated wrapper (`glass_card.dart` lines ~144 and ~333–338) now that this is its last call site.
- [X] T010 [P] [US2] Grep every screen file for a bottom-padding reserve added to dodge the old floating pill nav (e.g. `grep -rn 'SafeArea(bottom\|padding.*bottom.*6[0-9]\|kBottomPageSpacing' lib/features --include='*.dart'`) and remove each one now that the nav in T009 is a real, non-overlapping layout child.

**Checkpoint**: The app no longer builds a `Stack`-based nav overlay anywhere; content and nav are siblings in one `Column`.

---

## Phase 4: Shared widgets (one commit each, `PROMPT_QUIET.md` Step 4 order)

Each widget lives in `lib/core/widgets/custom_widgets/` (the existing shared-widget
location) and takes only semantic parameters — never a raw `Color` (Contract 2 in
`contracts/theme-and-widget-contract.md`).

- [X] T011 [P] [US2] Create `lib/core/widgets/custom_widgets/surface_card.dart` (`SurfaceCard`: `surface` fill, 1px `border subtle`, radius 14, no shadow/blur/sheen). Will be called from: `home_continue_card.dart`, `lib/features/profile/presentation/view/profile_page.dart`'s cards, `lib/features/challenge/presentation/view/problem_page.dart`'s constraints row, `lib/features/challenge/presentation/view/code_editor_page.dart`'s test-cases card, `lib/features/challenge/presentation/view/celebration_page.dart`'s level card.
- [X] T012 [P] [US2] Create `lib/core/widgets/custom_widgets/section_header.dart` (`SectionHeader`: title text row, optional trailing meta). Will be called from `lib/features/home/view/widgets/home_recent_activity.dart`, `lib/features/home/view/widgets/home_category_grid.dart`, `lib/features/profile/presentation/view/profile_page.dart` section titles.
- [X] T013 [P] [US2] Create `lib/core/widgets/custom_widgets/titled_card.dart` (`TitledCard`: header row of title + trailing meta over a body). Will be called from `lib/features/home/view/widgets/home_continue_card.dart` and `lib/features/profile/presentation/view/profile_page.dart` cards with trailing meta.
- [X] T014 [P] [US2] Create `lib/core/widgets/custom_widgets/stat_tile.dart` (`StatTile`: label + value, optional emphasis border). Will be called from `lib/features/home/view/widgets/home_stats_strip.dart`, `lib/features/profile/presentation/widgets/profile_stats_grid.dart`, `lib/features/challenge/presentation/view/celebration_page.dart`.
- [X] T015 [P] [US2] Create `lib/core/widgets/custom_widgets/quiet_progress_bar.dart` (a 3px-height progress bar, one implementation for every progress use). Will be called from `lib/features/home/view/widgets/home_difficulty_progress.dart`, `lib/features/home/view/widgets/home_continue_card.dart` (live progress row), the Visualizer step progress in `lib/features/visualize/view/visualize_page.dart`, `lib/features/challenge/presentation/view/celebration_page.dart`'s level bar.
- [X] T016 [P] [US2] Create `lib/core/widgets/custom_widgets/difficulty_chip.dart` (`DifficultyChip(difficulty: Difficulty)`, solid tint fill from `chipEasyFill`/`chipMediumFill`/`chipHardFill`). Will be called from `lib/features/challenge/presentation/view/problem_page.dart`, `lib/features/profile/presentation/widgets/bookmark_row.dart`, `lib/features/profile/presentation/view/sub_views/practice_history_page.dart`, `lib/features/home/view/widgets/home_difficulty_progress.dart`.
- [X] T017 [P] [US2] Create `lib/core/widgets/custom_widgets/tag_chip.dart` (`TagChip`, neutral tint fill from `chipNeutralFill`). Will be called from `lib/features/challenge/presentation/view/problem_page.dart` and `lib/features/profile/presentation/widgets/bookmark_row.dart`.
- [X] T018 [P] [US2] Create `lib/core/widgets/custom_widgets/filter_chip_quiet.dart` (`selected: bool` parameter, never a color). Will be called from `lib/features/challenge/presentation/widgets/challenges/challenges_filter_tabs.dart` and the Visualizer's algorithm-chip row in `lib/features/visualize/view/visualize_page.dart`.
- [X] T019 [P] [US2] Create `lib/core/widgets/custom_widgets/segmented_control_quiet.dart` (`selectedIndex: int`, solid-white selected segment at radius 7). Will be called from the Visualizer's speed selector (`lib/features/visualize/view/visualize_page.dart`) and any category selector in `lib/features/challenge/presentation/widgets/challenges/challenges_filter_tabs.dart`.
- [X] T020 [P] [US2] Create `lib/core/widgets/custom_widgets/problem_row.dart` (`ProblemRow`, replacing hand-rolled row decoration). Will be called from `lib/features/challenge/presentation/widgets/challenges/problem_tile.dart` (Practice), `lib/features/profile/presentation/widgets/bookmark_row.dart` (Bookmarks), `lib/features/profile/presentation/view/sub_views/practice_history_page.dart` (History).
- [X] T021 [P] [US2] Create `lib/core/widgets/custom_widgets/icon_button_quiet.dart` (32px/44px outlined icon button). Will be called from `lib/features/challenge/presentation/view/problem_page.dart` (back button), the Visualizer transport controls (`lib/features/visualize/view/visualize_page.dart`), `lib/features/challenge/presentation/view/code_editor_page.dart` (copy button).
- [X] T022 [P] [US2] Create `lib/core/widgets/custom_widgets/primary_button_quiet.dart` (solid white / `textBright`-role fill, `onPrimary` label, no glow). Will be called from `lib/features/challenge/presentation/view/problem_page.dart` (pinned CTA), `lib/features/challenge/presentation/view/code_editor_page.dart` (Run & submit), `lib/features/challenge/presentation/view/celebration_page.dart` (Next problem), and the auth screens' submit buttons.
- [X] T023 [P] [US2] Create `lib/core/widgets/custom_widgets/secondary_button_quiet.dart` (outlined, `border strong`). Will be called from `lib/features/challenge/presentation/view/code_editor_page.dart` (Reset) and `lib/features/challenge/presentation/view/celebration_page.dart` (See the visual trace).
- [X] T024 [P] [US2] Create `lib/core/widgets/custom_widgets/bottom_cta_bar.dart` (pinned action area, `background base` fill, 1px `border subtle` top rule, no scrim). Will be called from `lib/features/challenge/presentation/view/problem_page.dart`, `lib/features/challenge/presentation/view/code_editor_page.dart`, `lib/features/challenge/presentation/view/celebration_page.dart`.
- [X] T025 [P] [US1] Create `lib/core/widgets/custom_widgets/bar_chart_quiet.dart` (one implementation serving both the Visualizer plot and the Home sparkline via a compact-mode flag; 3px bar radius, flat top/bottom). Will be called from `lib/features/visualize/sub_view/sorting/view/sorting_view.dart` and `lib/features/home/view/widgets/home_continue_card.dart` (sparkline).
- [X] T026 [P] [US2] Create `lib/core/widgets/custom_widgets/heat_grid.dart` (`HeatGrid` + its legend, both reading the single `heatLevels` list per Contract 3 in `contracts/theme-and-widget-contract.md`). Will be called from `lib/features/profile/presentation/widgets/profile_heatmap.dart`.
- [X] T027 [P] [US2] Create `lib/core/widgets/custom_widgets/live_session_card.dart` (`LiveSessionCard(size: LiveSessionSize)` with a `home` variant, all reading `lib/features/visualize/view_model/live_session_provider.dart`, carrying no color of its own). **Scope note (per `/speckit-analyze` finding U1, unresolved)**: only build and wire the `home` size in this pass — confirmed in `research.md` R10 as the only size with an existing call site (`home_continue_card.dart`); it's unresolved whether `expanded` (lock-screen) means an in-app Flutter view or a native OS widget extension (which would be a new architecture layer, out of scope per the plan). Do **not** build `expanded`/`pill` variants or claim they're wired anywhere until FR-017 is clarified (run `/speckit-clarify` on FR-017, or get an explicit answer, first) — leave a `// TODO(FR-017):` comment naming the open question instead of a stub implementation.
- [X] T028 [P] [US2] Create `lib/core/widgets/custom_widgets/empty_state_quiet.dart` (the one dashed-border block: 1px dashed `border`, radius 14, padding `22 × 18`). Will be called from `lib/features/profile/presentation/view/sub_views/practice_history_page.dart` and `lib/features/challenge/presentation/widgets/challenges/empty_state.dart`.

**Checkpoint**: 18 new widget files exist in `lib/core/widgets/custom_widgets/`; none is called from a screen yet (that's Phase 5); each compiles standalone. `LiveSessionCard` intentionally ships with only its `home` size — this is a known, tracked gap (FR-017), not an oversight.

---

## Phase 5: Screens (one task per screen — local styling swapped for shared widgets, nothing else)

**Acceptance criterion for every task in this phase**: the screen's widget sequence and
every user-visible string are identical to `develop`; the file contains no colour,
radius, or border literal after the change (verified per-task by
`grep -nE '0x[0-9A-Fa-f]{6,8}|Color\(|BorderRadius|Colors\.' <file>` returning zero, and
by a manual diff confirming no widget added/removed/reordered/moved and no string
changed).

- [X] T029 [US1] Refactor `lib/features/visualize/view/visualize_page.dart` and `lib/features/visualize/sub_view/sorting/view/sorting_view.dart`: replace local decoration with `BarChartQuiet` (T025), `FilterChipQuiet`/`SegmentedControlQuiet` (T018/T019), `IconButtonQuiet` (T021), `QuietProgressBar` (T015). Same acceptance criterion as above.
- [X] T030 [US2] Refactor `lib/features/home/view/home_page.dart` and its widgets (`home_header.dart`, `home_stats_strip.dart`, `home_difficulty_progress.dart`, `home_continue_card.dart`, `home_category_grid.dart`, `home_recent_activity.dart`) to call `SectionHeader` (T012), `StatTile` (T014), `QuietProgressBar` (T015), `DifficultyChip` (T016), `LiveSessionCard` (T027, home size only — see T027's scope note), `SurfaceCard`/`TitledCard` (T011/T013). Same acceptance criterion as above.
- [X] T031 [US2] Refactor `lib/features/challenge/presentation/view/problem_page.dart` to call `IconButtonQuiet` (T021), `DifficultyChip`/`TagChip` (T016/T017), `SurfaceCard` (T011), `PrimaryButtonQuiet` (T022), `BottomCtaBar` (T024). Same acceptance criterion as above.
- [X] T032 [US2] Refactor `lib/features/challenge/presentation/view/code_editor_page.dart` to call `IconButtonQuiet` (T021), `SurfaceCard` (T011), `SecondaryButtonQuiet`/`PrimaryButtonQuiet` (T023/T022), `BottomCtaBar` (T024). Same acceptance criterion as above.
- [X] T033 [US2] Refactor `lib/features/challenge/presentation/view/challenge_page.dart` and `lib/features/challenge/presentation/widgets/challenges/problem_tile.dart` to call `ProblemRow` (T020), `FilterChipQuiet` (T018) in `challenges_filter_tabs.dart`. Same acceptance criterion as above.
- [X] T034 [US2] Refactor `lib/features/profile/presentation/view/profile_page.dart` and its widgets (`profile_header.dart`, `profile_stats_grid.dart`, `profile_difficulty_progress.dart`, `profile_weekly_chart.dart`, `profile_category_chart.dart`, `profile_practice_history.dart`, `profile_heatmap.dart`, `profile_logout_card.dart`) to call `StatTile` (T014), `SurfaceCard` (T011), `HeatGrid` (T026), `SectionHeader` (T012). Same acceptance criterion as above.
- [X] T035 [US2] Refactor `lib/features/profile/presentation/view/sub_views/bookmarked_problems_page.dart` and `bookmark_row.dart` to call `ProblemRow` (T020), `DifficultyChip`/`TagChip` (T016/T017). Same acceptance criterion as above.
- [X] T036 [US2] Refactor `lib/features/profile/presentation/view/sub_views/practice_history_page.dart` to call `ProblemRow` (T020), `DifficultyChip` (T016), `EmptyStateQuiet` (T028). Same acceptance criterion as above.
- [X] T037 [US2] Refactor `lib/features/auth/presentation/login/view/login_page.dart` (and shared `auth_common_bits.dart`/`auth_text_field.dart` where this screen is their only remaining caller) to call `PrimaryButtonQuiet` (T022). Same acceptance criterion as above.
- [X] T038 [US2] Refactor `lib/features/auth/presentation/signup/view/sign_up_page.dart` to call `PrimaryButtonQuiet` (T022). Same acceptance criterion as above.
- [X] T039 [US2] Refactor `lib/features/auth/presentation/forgot_password/view/forgot_password_page.dart` to call `PrimaryButtonQuiet` (T022). Same acceptance criterion as above.
- [X] T040 [US2] Refactor `lib/features/auth/presentation/reset_password/view/reset_password_page.dart` to call `PrimaryButtonQuiet` (T022). Same acceptance criterion as above.
- [X] T041 [US2] Refactor the logout confirmation dialog (`lib/core/widgets/custom_widgets/confirmation_dialog_card.dart`, triggered from `lib/features/profile/presentation/widgets/profile_logout_card.dart`) to call `SurfaceCard` (T011)/`PrimaryButtonQuiet`/`SecondaryButtonQuiet` (T022/T023) at dialog radius 18. Same acceptance criterion as above.
- [X] T042 [US1] Refactor `lib/features/challenge/presentation/view/celebration_page.dart` to call `StatTile` (T014), `SurfaceCard` (T011), `QuietProgressBar` (T015), `PrimaryButtonQuiet`/`SecondaryButtonQuiet` (T022/T023), `BottomCtaBar` (T024) — keep its entrance-sequence and ring/pop animations, wired to reduce-motion per FR-019. Same acceptance criterion as above.

**Checkpoint**: every screen file's diff against `develop` is a decoration-for-shared-widget swap only.

---

## Phase 6: Visualiser chart and heat map corrections (`PROMPT_QUIET.md` Steps 6–7)

- [X] T043 [US1] In `lib/features/visualize/sub_view/sorting/view/sorting_view.dart` and `lib/core/widgets/custom_widgets/bar_chart_quiet.dart` (T025): implement the fixed bar-state priority — `sorted` → `barDone`, `excluded` → `barExcluded`, `key`/held (currently `SortingStatus.temporary => ThemeEnum.accentViolet` at `sorting_view.dart:335`) → `comparing` role, `swap` → `barSwap`, `comparing` → `comparing` role, `idle` → `barIdle`; enforce at most one `key` bar and at most two `comparing`/`swap` bars per frame, never both categories at once. Restructure each column into a fixed-height label row followed by the bar in its own flexible track aligned to the bottom, per `research.md` R8, so the `value/max` fraction always resolves against the track height alone (already the case per the height formula, but the column layout must not let label + gap + bar overflow the allotted box). Remove the now-dead `ThemeEnum.accentViolet` call site — this makes it a candidate for the Phase 7 sweep.
- [X] T044 [US3] In `lib/core/widgets/custom_widgets/heat_grid.dart` (T026) and `lib/features/profile/presentation/widgets/profile_heatmap.dart`: confirm/wire the legend widget to read from the same `heatLevels` list the grid cells use (Contract 3) rather than any separately declared legend list; per `research.md` R9 the grid already derives real per-day levels, so this task's scope is the legend single-source wiring plus asserting the empty-day cell equals the legend's first swatch.

**Checkpoint**: no frame ever colors two bars white for two different reasons; the heat-grid legend cannot drift from the grid because they share one list.

---

## Phase 7: Verification (one task per verification item — each fails loudly with a measured number, never "looks fine") + sweep

- [X] T045 [US3] Run `flutter analyze` repo-wide; report the exact warning/error count. Task fails if the count is not zero (or not equal to the documented pre-existing baseline, if one is recorded in `research.md`).
- [ ] T046 [US3] Run the ban-grep from `quickstart.md` §2: `grep -rn 'BackdropFilter\|BoxShadow\|elevation:\|Gradient(' lib --include='*.dart' | grep -v lib/core/resources/theme_manager.dart`, plus a `withOpacity`/`withValues(alpha:` grep restricted to surface-fill call sites, plus a grep for every retired hex in `PROMPT_QUIET.md` Step 9 (both the aurora and brass columns) and `#8B7CF6`/`#5C6CF2`/`#3FA9F5`/`#46D8E6`, excluding `lib/core/resources/color_manager.dart`. Report the exact line count found. Task fails if the count is not zero.
- [ ] T047 [US3] **(New — addresses SC-002's final gate, `/speckit-analyze` finding C1)** Run a repo-wide literal scan for colour/radius/border values outside the theme files: `grep -rnE '0x[0-9A-Fa-f]{6,8}|Color\(|BorderRadius\.circular\([0-9]|Colors\.' lib/features lib/core/widgets --include='*.dart'`. Report the exact line count found, distinct from the per-screen checks already run in Phase 5 (this re-scans everything at once, including the Phase 4 shared-widget files, which is what SC-002 actually asks for). Task fails if the count is not zero.
- [ ] T048 [US3] Run `grep -rln 'BoxDecoration(' lib/features --include='*.dart'`. Report the exact file count. Task fails if the count is not zero (decoration construction must live only in `lib/core/widgets/custom_widgets/`).
- [ ] T049 [US3] **(New — addresses SC-003's single-definition requirement, `/speckit-analyze` finding C2)** For each of the 18 visual patterns named in `PROMPT_QUIET.md` Step 4 (surface card, section header, titled card, stat tile, progress bar, difficulty chip, tag chip, filter chip, segmented control, problem row, icon button, primary button, secondary button, bottom CTA bar, bar chart, heat grid, live session card, empty/end state), grep for its widget class name across `lib/` and report the number of class *declarations* found (not call sites). Task fails if any pattern has zero or more than one declaration.
- [ ] T050 [US3] For every tabbed screen (Home, Visualizer, Practice, Profile), at the smallest supported device height, measure the nav bar's top-edge `dy` and the content's max painted `dy`; report the overlap in logical pixels for each screen in both themes. Task fails if any measured overlap is greater than 0.
- [ ] T051 [US1] For a fixed `values`/`max` fixture run through `bar_chart_quiet.dart`, measure each bar's rendered height against `value / max * trackHeight`; report the maximum delta in logical pixels across all bars. Task fails if the max delta exceeds 1px.
- [ ] T052 [US1] Run one sorting algorithm to completion at 1× speed while recording, per frame, which bars are painted white and why (`key` vs `comparing`); report any frame where two bars are white for two different reasons simultaneously. Task fails if any such frame is found.
- [ ] T053 [US3] Feed the activity provider a per-day count sequence spanning its full range; report how many of the 5 heat levels actually render in the grid, and whether the legend's first swatch color equals the grid's empty-day (`heat0`) color. Task fails if fewer than 4 of 5 levels render, or if the legend's first swatch does not match.
- [ ] T054 [US3] Compute the WCAG contrast ratio for every (text role × surface role) pair that co-occurs on screen — text primary/body/secondary/disabled against background base/surface/surface raised — in both themes; report the minimum ratio found and which pair it belongs to. Task fails if any body-text pair is below 4.5:1 or any ≥19px pair is below 3:1.
- [ ] T055 [US3] With the platform reduce-motion flag simulated on, render the celebration entrance, the live-session pulse, and the celebration rings; report which of the three, if any, still animate. Task fails if any of the three still animates, or if any other element in the app animates in either reduce-motion state.
- [ ] T056 [US3] Grep the whole repo for every retired hex listed in `PROMPT_QUIET.md` Step 9 (both the aurora column and the brass column) and for every dead `ThemeEnum` member/alias identified across `research.md` (`glassRecessedFill`, `glassRecessedFill100`, `glassCardFill`, `glassCardFill2`, `glassFloatingFill`, `glassSheenRecessed`, `glassSheenCard`, `glassSheenFloating`, `glassHairlineRecessed`, `accentViolet` (confirm dead after T043), the alpha-based `accentGreenBg`/`accentYellowBg`/`accentRedBg`/`accentBlueBg`/`borderAccent`/`borderAccentBlue`, `primaryHover`/`primaryPress` if confirmed zero call sites, and `surfaceAlt` if confirmed zero call sites) in `lib/core/resources/theme_manager.dart` and `lib/core/resources/color_manager.dart`; delete every hex and every member/alias found with zero remaining call sites. Report exactly what was deleted. Run this task last, after T045–T055, since it deletes code those checks may still want to grep for as "confirmed retired."

**Checkpoint**: `quickstart.md` passes end to end, both themes, all screens; the branch is ready for the constitution's "Compliance review." FR-017's `expanded`/`pill` sizes remain an open, explicitly tracked gap (see T027) — resolve via `/speckit-clarify` before considering this feature fully done, or accept the gap and update `spec.md` FR-017 to scope it to the `home` size only.

---

## Dependencies & Execution Order

- **Phase 1** has no dependencies; it is one task, must land first, and is reviewable alone.
- **Phase 2** depends on Phase 1 (values must be correct before literal removal, so no visual regression is introduced by coincidence). T003, T004, T005, T006, T008 are `[P]` (disjoint files); T002 and T007 touch shared files (`glass_card.dart`, `theme_manager.dart`) so run them before their `[P]` siblings if editing the same file.
- **Phase 3** depends on Phase 2 (T009 deletes `AuroraGround`, which Phase 2 left in place). T010 is `[P]` with T009 only after T009's new shell exists (so run T009 first).
- **Phase 4** depends on Phase 1 (roles must exist) but not on Phase 2/3 — all 18 widget tasks (T011–T028) are `[P]`, disjoint new files.
- **Phase 5** depends on the specific Phase 4 widgets each screen task cites (see each task's "Will be called from" reverse-reference) and on Phase 3 for any screen inside the tabbed shell. Screen tasks are `[P]` against each other (disjoint files) once their cited widgets exist. T037–T040 (the four auth screens) are `[P]` against each other — each is its own file.
- **Phase 6** depends on T025 (bar chart widget) and T026 (heat grid widget) from Phase 4, and on T029 (Visualizer screen) for T043.
- **Phase 7** depends on all prior phases being complete; T045–T055 are `[P]` (read-only checks); T056 runs last, after every verification task, since it deletes code the verification tasks may still want to grep for as "confirmed retired."

## Parallel Example: Phase 4

```bash
Task: "Create lib/core/widgets/custom_widgets/surface_card.dart"
Task: "Create lib/core/widgets/custom_widgets/section_header.dart"
Task: "Create lib/core/widgets/custom_widgets/stat_tile.dart"
Task: "Create lib/core/widgets/custom_widgets/heat_grid.dart"
```

## Implementation Strategy

Follow the seven phases strictly in order — this restyle is not independently
deliverable per user story the way a feature build is; each phase is a prerequisite
for the next (theme values → dead-code removal → structural nav fix → shared widgets →
screen wiring → chart/heat-map correctness → measured verification and sweep). Commit
once per phase (Phase 1: 1 commit; Phase 2: 1 commit covering T002–T008; Phase 3: 1
commit; Phase 4: 18 commits, one per widget; Phase 5: 14 commits, one per screen; Phase
6: 1–2 commits; Phase 7: 1 commit with all verification numbers in the PR description
plus the sweep). Do not skip ahead to Phase 5 before Phase 4's cited widget exists for
that screen. Before closing out the feature, resolve the FR-017 gap flagged in T027/T030
— either via `/speckit-clarify` and a follow-up implementation task, or by narrowing
FR-017's wording in `spec.md` to match what was actually built.
