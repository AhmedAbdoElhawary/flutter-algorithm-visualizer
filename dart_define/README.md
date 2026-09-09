# dart_define — two tiers of config

This repo is **public**. Everything in a committed file here is world-readable
forever, including in git history after a delete. So config is split in two.

## Tier 1 — `<flavor>.json` (committed)

Non-secret selectors only. Safe in public.

```json
{
  "FLAVOR": "dev",
  "APP_NAME": "AlgoDive Dev",
  "API_BASE_URL": "https://dev.api.algodive.app"
}
```

## Tier 2 — `<flavor>.secret.json` (git-ignored, never committed)

Values that must not sit in a public repo. Same shape, different file:

```json
{
  "SENTRY_DSN": "https://<key>@o0.ingest.sentry.io/<project>"
}
```

Ignored by `/dart_define/*.secret.json` in `.gitignore`. In CI it is written
at build time from a GitHub Environment secret and deleted after the build.

## How both get passed

`--dart-define-from-file` can be repeated — Flutter merges them:

```bash
flutter run --flavor dev -t lib/main_dev.dart \
  --dart-define-from-file=dart_define/dev.json \
  --dart-define-from-file=dart_define/dev.secret.json
```

**The secret file is optional.** If it's missing, `SENTRY_DSN` is empty and
Sentry simply stays off. That is the correct state for local development
anyway — monitoring is release-mode-only (see
`lib/core/monitoring/monitoring.dart`), so day-to-day work never needs it.

## Do NOT use `.env` / flutter_dotenv for secrets

`flutter_dotenv` loads `.env` as a **Flutter asset**, which means it ships as
a plain file inside the APK:

```bash
unzip -p app.apk assets/flutter_assets/.env   # prints your "secrets"
```

`--dart-define` compiles values into the binary instead — still extractable
with `strings`, but not handed over in one command.

**Neither is actually secure.** Nothing shipped inside a mobile app can be
kept from a determined user. That is why a real secret (keystore, CI token,
service account) must never be in the app *or* the repo — only in GitHub
Secrets — and why client identifiers like a Sentry DSN or Firebase API key
are protected by **server-side rules**, not by hiding them.
