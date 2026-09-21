enum Flavor {
  dev,
  staging,
  production;

  bool get isDev => this == Flavor.dev;
  bool get isStaging => this == Flavor.staging;
  bool get isProduction => this == Flavor.production;
}
