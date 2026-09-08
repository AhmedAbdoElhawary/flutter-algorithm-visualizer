/// Build flavors this app ships in.
///
/// The active flavor is selected by the entry point that boots the app
/// (`lib/main_dev.dart`, `lib/main_staging.dart`, `lib/main_prod.dart`) and is
/// carried at runtime by [FlavorConfig]. Native code (Android `productFlavors`,
/// iOS build configurations) selects the matching `google-services.json` /
/// `GoogleService-Info.plist`, so `Firebase.initializeApp()` with no options
/// already points at the right Firebase project per flavor.
enum Flavor {
  dev,
  staging,
  production;

  bool get isDev => this == Flavor.dev;
  bool get isStaging => this == Flavor.staging;
  bool get isProduction => this == Flavor.production;

  /// Short label shown in the in-app banner and logs ("DEV" / "STAGING" / "").
  String get bannerLabel => switch (this) {
        Flavor.dev => 'DEV',
        Flavor.staging => 'STAGING',
        Flavor.production => '',
      };
}
