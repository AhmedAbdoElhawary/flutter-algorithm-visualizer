# Security Policy

## Supported versions

AlgoDive is pre-1.0 and ships from a single release line. Only the latest
release receives security fixes.

| Version | Supported |
| --- | --- |
| Latest release | ✅ |
| Anything older | ❌ |

## Reporting a vulnerability

**Please do not open a public issue for a security problem.**

Report it privately through GitHub:

1. Go to the [Security tab](https://github.com/AhmedAbdoElhawary/flutter-algorithm-visualizer/security/advisories/new)
2. Click **Report a vulnerability**
3. Describe the issue, the affected version, and steps to reproduce

This creates a private advisory that only you and the maintainer can see.

### What to expect

| Stage | Target |
| --- | --- |
| Acknowledgement | Within 72 hours |
| Initial assessment | Within 7 days |
| Fix or mitigation plan | Within 30 days for confirmed issues |

This is a solo-maintained side project, so these are good-faith targets rather
than a contractual SLA. If you don't hear back within a week, feel free to ping
the advisory thread.

If you'd like credit for the report, say so and you'll be named in the advisory
and release notes.

## How this project handles secrets

This repository is **public**, and it is built on the assumption that anything
committed here is world-readable forever — including after a deletion, via git
history. Config is therefore split into two tiers:

**Committed — non-secret selectors only.** `dart_define/*.json` holds the flavor
name, display name, and public API base URL. Nothing here is sensitive.

**Never committed.** These are git-ignored and injected at build time from
GitHub Environment secrets, then scrubbed after the build:

- `dart_define/*.secret.json` — the Sentry DSN
- `android/app/src/*/google-services.json` and the iOS `GoogleService-Info.plist`
- `android/key.properties` and any `.jks` / `.keystore` signing material

`.env` files are deliberately **not** used. A `.env` bundled as a Flutter asset
is readable in plaintext with `unzip app.apk`, which provides the appearance of
security without the substance. See
[`dart_define/README.md`](dart_define/README.md) for the full reasoning.

## Client-side keys are not secrets

Firebase configuration files (`google-services.json`, `GoogleService-Info.plist`)
contain identifiers that ship inside every installed app and can be extracted
from any APK. They are **not** credentials, and treating them as such is a
mistake.

What actually protects user data here is server-side authorization.
[`firestore.rules`](firestore.rules) scopes every document under
`users/{uid}/**` to the authenticated owner, so possession of a config file
grants no access to anyone else's data.

## Out of scope

The following are known and accepted, and are not treated as vulnerabilities:

- Extracting the Firebase configuration from a shipped APK (see above)
- The on-device interpreter executing code the user typed themselves — it is
  sandboxed to the Dart VM with no filesystem, network or platform-channel
  access, and has an iteration guard against runaway loops
- Reports from automated scanners with no demonstrated impact
- Vulnerabilities in third-party dependencies that are already publicly
  disclosed and have an upstream fix pending — though a heads-up is still welcome
- Missing security headers or configuration on the (not yet published)
  `algodive.app` domain

## Scope

In scope: this repository's source, its GitHub Actions workflows, the Firestore
security rules, and the published Android and iOS applications.

Thank you for helping keep AlgoDive and its users safe.
