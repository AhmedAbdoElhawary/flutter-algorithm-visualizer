<!--
Thanks for contributing to AlgoDive!

Two quick reminders before you submit:
  • This PR should target `develop`. CI will reject other targets.
  • This repo is PUBLIC. Run `git diff` and confirm no keystore,
    google-services.json, or secret file is in your changes.
-->

## What does this change?

<!-- One or two sentences. What is different after this PR? -->

## Why?

<!-- The problem this solves. If an issue covers it, just link the issue. -->

Closes #

## Type of change

- [ ] 🧮 New algorithm
- [ ] ✨ New feature
- [ ] 🐛 Bug fix
- [ ] ♻️ Refactor (no behavior change)
- [ ] ✅ Tests
- [ ] 📝 Documentation
- [ ] 🌍 Translation
- [ ] 🔧 Build / CI

## Screenshots

<!--
For any UI change, please include before/after images or a short GIF.
Dark mode shots are appreciated — it's the easiest thing to break.
Delete this section for non-UI changes.
-->

| Before | After |
| --- | --- |
|  |  |

## Checklist

- [ ] `flutter analyze` is clean
- [ ] `flutter test --dart-define-from-file=dart_define/dev.json` passes
- [ ] New behavior is covered by a test
- [ ] Tested in **both light and dark** mode
- [ ] This PR targets `develop`
- [ ] If this PR should ship a dev build, it carries **one** commit whose
      subject is `release: vX.Y.Z-dev.N` (its body becomes the tag message).
      Leave it out and the PR merges without shipping anything.

### Conventions

<!-- See CONTRIBUTING.md for the full list and the reasoning behind each. -->

- [ ] Widget **classes**, not builder functions
- [ ] `AdaptiveText` / padding widgets instead of raw `Text` and `Padding`
- [ ] Sizes use ScreenUtil (`.w` `.h` `.r` `.sp`), no raw pixel values
- [ ] Colors come from `ThemeEnum`, never hard-coded
- [ ] User-facing strings come from `StringsManager`
- [ ] Providers watched with `.select()` where it narrows rebuilds

### Safety

- [ ] No secrets, keystores, or Firebase config files in this diff

## Anything else?

<!-- Open questions, tradeoffs you weren't sure about, things to review closely. -->
