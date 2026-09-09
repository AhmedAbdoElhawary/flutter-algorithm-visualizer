# How the app knows which flavor it is

A **simple explanation** of how `dart_define/dev.json` ends up inside the
running app as `FlavorConfig.instance`.

## The idea in one sentence

You pass a small JSON file when you build the app. Flutter bakes its values
into the app at **build time**. The app reads them back once, at startup,
and remembers them for the rest of the run.

Think of it like baking a cake. `dart_define` is a label you put on the
batter *before* it goes in the oven — "this one is chocolate." Once it's
baked, you can't relabel it. The app only finds out what flavor it is the
moment it's built, not while it's running.

## The 4 steps

### 1. A JSON file holds the settings

**[dart_define/dev.json](../../dart_define/dev.json):**
```json
{
  "FLAVOR": "dev",
  "APP_NAME": "AlgoDive Dev",
  "API_BASE_URL": "https://dev.api.algodive.app"
}
```

Three flavors, three files: `dev.json`, `staging.json`, `prod.json`.

### 2. You hand that file to `flutter run`/`flutter build`

```bash
flutter run --flavor dev -t lib/main_dev.dart --dart-define-from-file=dart_define/dev.json
```

`--dart-define-from-file` turns every key in the JSON into a
`--dart-define=KEY=value` flag, as if you'd typed each one by hand.

### 3. The app reads those flags with `String.fromEnvironment`

**[lib/core/flavor/flavor_config.dart](../../lib/core/flavor/flavor_config.dart):**
```dart
factory FlavorConfig.fromEnvironment({Flavor fallbackFlavor = Flavor.dev}) {
  const rawFlavor = String.fromEnvironment('FLAVOR');
  return FlavorConfig(
    flavor: /* matches rawFlavor to a Flavor enum value */,
    appName: const String.fromEnvironment('APP_NAME', defaultValue: 'AlgoDive'),
    apiBaseUrl: const String.fromEnvironment('API_BASE_URL'),
    sentryDsn: const String.fromEnvironment('SENTRY_DSN'),
  );
}
```

`String.fromEnvironment('FLAVOR')` is not a normal function call. It's a
**compile-time constant** — a special Flutter feature. The compiler looks
for a matching `--dart-define` flag and writes the value directly into the
compiled app. There is no file being read while the app runs.

### 4. The app stores it once, at startup

**[lib/bootstrap.dart](../../lib/bootstrap.dart):**
```dart
FlavorConfig.initialize(config);
```

Every other part of the app then reads it back with:
```dart
FlavorConfig.instance.apiBaseUrl
FlavorConfig.instance.appName
```

If something tries to read `FlavorConfig.instance` before `initialize()` ran,
it throws right away — on purpose, so a missing setup is loud, not a silent
bug later.

## Picture it

```
dart_define/dev.json
      │  (--dart-define-from-file turns each key into a flag)
      ▼
--dart-define=FLAVOR=dev --dart-define=APP_NAME=... --dart-define=API_BASE_URL=...
      │  (baked into the app at compile time)
      ▼
FlavorConfig.fromEnvironment()   →   FlavorConfig.initialize(config)
      │
      ▼
FlavorConfig.instance   ← read from anywhere in the app
```

## Why 3 separate `main_*.dart` files, if they all do the same thing?

They don't contain different *logic* — each is one line:
```dart
Future<void> main() => bootstrap(FlavorConfig.fromEnvironment());
```

They exist so Flutter has a distinct **entry point per flavor** (needed by
the native Android/iOS build tooling), and so each flavor has an obvious
`-t lib/main_<flavor>.dart` target to point at. The real decision — which
flavor, which API URL — always comes from the JSON file you pass alongside
it, never from which `main_*.dart` you picked.

## One important limit, not a bug

Because the value is baked into the compiled binary, **anyone can extract it**
by unzipping the built APK/IPA. That's fine for `FLAVOR`, `APP_NAME`,
`API_BASE_URL` — none of those are secret. It's *why* real secrets
(`SENTRY_DSN`, Firebase keys) get extra care in this project — see
[dart_define/README.md](../../dart_define/README.md) and
[FIREBASE_CHECKLIST.md](FIREBASE_CHECKLIST.md).
