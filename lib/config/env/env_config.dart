/// Mazingira (environments) ambayo Hadithi Studio inaweza kuendeshwa.
///
/// Tanzania ina mtandao wa kubadilika-badilika, hivyo app hii hujengwa
/// kwa mazingira matatu: `dev` (kwa msanidi), `staging` (kwa beta testers
/// wa Tanzania) na `prod` (kwa Watumiaji wote).
library;

/// Orodha ya mazingira yanayotumika.
enum Environment {
  dev,
  staging,
  prod;

  /// Jina la mazingira kwa maandishi (kwa analytics/logs).
  String get label => switch (this) {
        Environment.dev => 'development',
        Environment.staging => 'staging',
        Environment.prod => 'production',
      };

  /// `true` kama mazingira haya si ya uzalishaji.
  bool get isNonProduction => this != Environment.prod;
}

/// Mkataba (contract) wa usanidi wa mazingira yote.
///
/// Kila mazingira hutoa base URL yake, na hufafanua kama logging,
/// analytics na crash reporting zinawezeshwa. Hii hutumika na
/// [ApiConstants] kupata `baseUrl` sahihi na na [AppConfig] kuchagua
/// mazingira yanayotumika wakati wa kujenga app.
abstract class EnvConfig {
  const EnvConfig();

  /// Mazingira yanayowakilishwa na config hii.
  Environment get environment;

  /// Jina la mazingira: `dev`, `staging`, `prod`.
  String get name;

  /// Base URL ya backend API (bila `/api/v1`).
  String get apiBaseUrl;

  /// Base URL ya tovuti (kwa share links, help pages).
  String get webUrl;

  /// Kama logs za kina zinaandikwa. **Hapana kwenye production** —
  /// data ya mtumiaji (namba ya simu, token) haipaswi kuonekana kwenye logs.
  bool get enableLogging;

  /// Kama Firebase Analytics inatumika.
  bool get enableAnalytics;

  /// Kama crash reporting (Firebase Crashlytics) inatumika.
  bool get enableCrashReporting;

  /// Kama data ya majaribio (mock) inatumika badala ya API halisi.
  ///
  /// Hii huruhusu UI kujengwa na kujaribiwa kabla backend haijakamilika.
  bool get useMockData;

  /// Kama requests zote za mtandao zinarekodiwa (method, path, status).
  bool get verboseNetworkLogs;

  /// Baada ya muda huu (ms) app inaonyesha onyo la mtandao wa polepole.
  Duration get slowNetworkWarningThreshold;
}
