const double kIOSTopPageSpacing = 5;
const double kAndroidTopPageSpacing = 10;
const double kBottomPageSpacing = 20;

/// Public pages served from `docs/` (GitHub Pages). The Play Console listing
/// points at the same two URLs, so they must not drift.
const String kPrivacyPolicyUrl =
    'https://ahmedabdoelhawary.github.io/flutter-algorithm-visualizer/privacy-policy.html';
const String kDeleteAccountUrl =
    'https://ahmedabdoelhawary.github.io/flutter-algorithm-visualizer/delete-account.html';
const String kTermsOfServiceUrl =
    'https://ahmedabdoelhawary.github.io/flutter-algorithm-visualizer/terms.html';
const String kSourceCodeUrl = 'https://github.com/AhmedAbdoElhawary/flutter-algorithm-visualizer';

/// The legal documents carry their **own** version, deliberately separate from
/// the app version in `AppInfo.version`.
///
/// They change on a different clock: a policy can be corrected without shipping
/// a build, and a build ships constantly without touching the policy. Tying
/// them together would mean either a meaningless bump or a stale number.
///
/// One version covers the whole set, so the user has a single number to quote
/// rather than three to reconcile.
///
/// Bump [kLegalVersion] and [kLegalUpdated] together, and change the matching
/// `<p class="meta">` line in **all three** of `docs/terms.html`,
/// `docs/privacy-policy.html` and `docs/delete-account.html` in the same
/// commit — the app states this version to the user, so a drift here is the
/// app telling them something untrue.
const String kLegalVersion = '1.0';
const String kLegalUpdated = 'September 2026';

/// Support and author links, shown in Settings → Contact.
///
/// [kSupportEmail] is also the address named in the privacy policy and the one
/// the Play Console listing must carry, so all three stay in step.
const String kSupportEmail = 'elhawarydev@gmail.com';
const String kGithubProfileUrl = 'https://github.com/AhmedAbdoElhawary';

const String kLinkedInUrl = 'https://www.linkedin.com/in/AhmedAbdoElhawary';

/// Pre-fills the subject line so support mail is filterable on arrival.
const String kSupportEmailSubject = 'AlgoDive support';
