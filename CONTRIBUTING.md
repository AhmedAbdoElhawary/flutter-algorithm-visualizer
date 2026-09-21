# Contributing to AlgoDive

Thanks for being here. AlgoDive is an algorithm visualizer, so contributions
that **add a new algorithm** are the most valuable kind — but bug fixes,
translations, tests and docs are all very welcome too.

This guide is short on purpose. If anything is unclear, open a
[Discussion](https://github.com/AhmedAbdoElhawary/flutter-algorithm-visualizer/discussions)
and ask.

---

## Table of contents

- [Ways to contribute](#ways-to-contribute)
- [Setting up](#setting-up)
- [Branch model](#branch-model)
- [Coding conventions](#coding-conventions)
- [Walkthrough: add a new algorithm](#walkthrough-add-a-new-algorithm)
- [Before you open a PR](#before-you-open-a-pr)
- [Commit messages](#commit-messages)
- [Code of conduct](#code-of-conduct)

---

## Ways to contribute

**Best first contribution:** five sorting algorithms are already implemented and
tested but not yet reachable in the UI — `Heap`, `Shell`, `Radix`, `Counting`
and `Bucket`. The hard part is done. What's missing is the card and the wiring.
See the [walkthrough](#walkthrough-add-a-new-algorithm) below.

Other good entry points:

| Type | Example |
| --- | --- |
| 🧮 New algorithm | Dijkstra, maze generation, tree traversals |
| 🐛 Bug fix | Something looks wrong mid-animation |
| 🌍 Translation | Arabic strings, or a new language |
| ✅ Tests | Widget or golden tests for an uncovered screen |
| 📝 Docs | Anything in this file that confused you |

Check the
[good first issue](https://github.com/AhmedAbdoElhawary/flutter-algorithm-visualizer/labels/good%20first%20issue)
label first.

> For anything larger than a bug fix, **open an issue before you start coding**.
> It saves you from building something that doesn't fit the direction.

---

## Setting up

Full instructions are in the [README](README.md#getting-started). The short
version:

```bash
git clone https://github.com/<your-username>/flutter-algorithm-visualizer.git
cd flutter-algorithm-visualizer
flutter pub get
```

Then create `android/app/src/dev/google-services.json` from your own free
Firebase project — the Android build will not compile without it. The README
explains why, and lists every other git-ignored file you may want locally.

Run with:

```bash
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=dart_define/dev.json
```

**Use Flutter 3.44.7.** CI pins that exact version, so a different one can pass
locally and fail on your PR.

---

## Branch model

Work happens on `develop`. Code is promoted up a ladder, never sideways.

```
feature/your-thing  ──►  develop  ──►  staging  ──►  production
```

| Rule | Why |
| --- | --- |
| Branch from `develop` | It is the default branch and the integration point |
| **PR into `develop`** | This is the only target you should ever pick |
| Never PR into `staging` or `production` | Those are release branches, guarded by CI |
| Name branches `feature/…` or `fix/…` | Keeps the branch list readable |

A `merge-guard` CI job will reject a PR that targets the wrong branch, so if you
get a red check with that name, this is why.

All three branches refuse a direct push — `git push origin develop` is rejected
by a ruleset, not by convention. A pull request whose `ci-ok` check is green is
the only way in.

Releases are cut by tags, and **nobody creates a tag by hand** — a `v*` tag
ruleset refuses that too. A tag is created by CI after a PR merges. Contributors
never need to do any of this; see `.github/RELEASES.md` if you are curious.

---

## Coding conventions

This project follows a few house rules consistently. They exist so the app stays
responsive, themeable and translatable — please match them.

### 1. Widget classes, not builder functions

```dart
// ✅ Extract a named widget class
class _SortingHeader extends StatelessWidget { ... }

// ❌ Never a function that returns a Widget
Widget _buildHeader() => ...;
```

Function-style widgets break Flutter's rebuild and `const` optimizations.

### 2. Use the adaptive text and padding widgets

Raw `Text(...)` and `Padding(...)` are not used anywhere in this codebase.

```dart
// ✅
BoldText(StringsManager.sorting)
HorizontalPadding(value: 12, child: ...)

// ❌
Text('Sorting')
Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: ...)
```

Available in `lib/core/widgets/adaptive/`:

- **Text:** `AdaptiveText`, `BoldText`, `SemiBoldText`, `MediumText`, `RegularText`, `LightText`
- **Padding:** `AllPadding`, `HorizontalPadding`, `VerticalPadding`, `StartPadding`,
  `EndPadding`, `TopPadding`, `BottomPadding`, `OnlyPadding`, `SymmetricPadding`, `AdaptivePadding`

### 3. Size with ScreenUtil, never raw pixels

```dart
// ✅
RSizedBox(height: 16)
BorderRadius.circular(8.r)
REdgeInsets.symmetric(horizontal: 12)

// ❌
SizedBox(height: 16)
BorderRadius.circular(8)
```

`.w` width · `.h` height · `.r` radius · `.sp` font size.

### 4. Colors only through `ThemeEnum`

```dart
// ✅
context.getColor(ThemeEnum.inkPrimary) // i will boost the preformance and changing them later

// ❌
Colors.white
Color(0xFF123456)
Theme.of(context).primaryColor
```

Hard-coded colors break dark mode. Available values are in
`lib/core/resources/theme_manager.dart`. Need a new one? Add it there with both
its light and dark mapping first.

### 5. User-facing strings only through `StringsManager`

```dart
// ✅
BoldText(StringsManager.allTestsPassed)

// ❌
BoldText('All tests passed')
```

Add a new `static const` to `lib/core/resources/strings_manager.dart`, then
reference it. Hard-coded strings can never be translated.

### 6. Watch providers narrowly with `.select()`

```dart
// ✅ rebuilds only when totalCount changes
final count = ref.watch(problemsProvider.select((s) => s.totalCount));

// ❌ rebuilds on ANY state change
final state = ref.watch(problemsProvider);
```

This matters a lot here — the visualizers rebuild many times per second.

### 7. Match the surrounding code

Follow the import ordering, naming and provider patterns already in the file
you're editing. Don't introduce a new package, pattern or architecture without
opening an issue to discuss it first.

---

## Walkthrough: add a new algorithm

Adding **Heap Sort** to the UI, as a worked example. The notifier already
exists, so this is mostly wiring.

### Step 1 — the algorithm

Sorting notifiers live in
`lib/features/visualize/sub_view/sorting/view_model/sub_sorting/`.

Each one extends `SortingNotifier` and emits a `SortStep` per operation, with a
`SortRole` on each item (`comparing`, `swapping`, `target`, `done`, …). Use
`bubble_sort_notifier.dart` as your reference — it is the smallest one.

Every notifier also declares its own `algorithmComplexity`:

```dart
static const algorithmComplexity = AlgorithmComplexity(
  best: ONotationComplexity.nLogN,
  average: ONotationComplexity.nLogN,
  worst: ONotationComplexity.nLogN,
  space: ONotationComplexity.one,
  stable: false,
);
```

For a brand-new algorithm, create the file here first.

### Step 2 — add the title string

In `lib/core/resources/strings_manager.dart`:

```dart
static const String heapSort = 'Heap Sort';
```

### Step 3 — register it in the enum

In `lib/features/base/view_model/base_view_model.dart`, add your value to
`SortingAlgoCards`:

```dart
enum SortingAlgoCards {
  bubble,
  selection,
  insertion,
  merge,
  quick,
  heap,   // ← new
}
```

### Step 4 — add the switch case

In the same file, `BaseViewModel.sortingCards` maps each enum value to its card.
Add a matching case following the existing shape:

```dart
case SortingAlgoCards.heap:
  return AlgoSortingCard(
    page: SortingAlgoCards.heap,
    title: StringsManager.heapSort,
    instance: NotifierProvider<SortingNotifier, SortingNotifierState>(
      () => HeapSortNotifier(),
    ),
    card: AlgorithmGlassCard(
      algoComplexity: HeapSortNotifier.algorithmComplexity,
      // …match the neighbouring cards
    ),
  );
```

> The switch is **exhaustive on purpose** — no `default` case. Dart will tell you
> at compile time if you added an enum value and forgot its case. That's the
> point; don't add a `default` to silence it.

### Step 5 — test it

Add `test/visualize/sorting/heap_sort_notifier_test.dart`. Copy the structure
from `bubble_sort_notifier_test.dart`. At minimum, assert that:

- the output is actually sorted
- the step count is finite and the run terminates
- roles are assigned sensibly (nothing stays `comparing` at the end)

```bash
flutter test --dart-define-from-file=dart_define/dev.json
```

### Step 6 — update the README roadmap

Move the algorithm from *"Built, not yet wired into the UI"* into *"Live now"*.
Please keep that table honest — it is the first thing reviewers check.

**Pathfinding** algorithms follow the same shape, under
`lib/features/visualize/sub_view/searching/`, with a `SearchingAlgoCards` enum.
New ones should also satisfy the shared contract in
`test/visualize/searching/support/search_contract.dart`.

---

## Before you open a PR

Run both of these. CI runs exactly the same commands.

```bash
flutter analyze
flutter test --dart-define-from-file=dart_define/dev.json
```

Then check:

- [ ] Analyzer is clean — no new warnings
- [ ] All tests pass, and new behavior has a test
- [ ] No raw `Text` / `Padding` / hard-coded colors / hard-coded strings / raw pixel values
- [ ] Tested in **both light and dark** mode
- [ ] UI changes include a screenshot or GIF in the PR
- [ ] Target branch is `develop`
- [ ] No secrets, keystores, or `google-services.json` in the diff

That last one matters: **this repo is public**. Run `git diff --staged` and look
at it before you commit.

---

## Commit messages

Short, imperative, scoped to one thing:

```
Add heap sort to the sorting visualizer
Fix path stagger skipping the final cell
Update tests for new legend order
```

No strict format is enforced. One logical change per commit is appreciated.

---

## Code of conduct

By participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).
Be kind. Assume good intent. Everyone here is learning something.

---

Thanks again. Even a typo fix is a real contribution. ⭐
