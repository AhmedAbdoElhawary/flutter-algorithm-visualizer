import 'package:flutter/foundation.dart';

/// Indirection so release-only behaviour can be forced on in a debug run.
///
/// TODO(ahmed): both must read the real `kReleaseMode` / `kDebugMode` when you
/// tag. Flipped to a literal, a production build either ships with Sentry,
/// Analytics and Play Integrity all switched off, or a debug run starts writing
/// into the production Sentry and Analytics projects.
const bool kCustomReleaseMode = kReleaseMode;
const bool kCustomDebugMode = kDebugMode;
