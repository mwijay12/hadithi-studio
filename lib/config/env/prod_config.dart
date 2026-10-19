import 'env_config.dart';

/// Usanidi wa mazingira ya beta (staging).
///
/// Hutumika kwa "closed beta" ya watumiaji 100 wa Tanzania kabla ya
/// kutolewa rasmi. Logging imewashwa ili tupate hitilafu mapema, lakini
/// analytics na crash reporting pia zinawashwa.
class StagingConfig extends EnvConfig {
  const StagingConfig();

  @override
  Environment get environment => Environment.staging;

  @override
  String get name => 'staging';

  @override
  String get apiBaseUrl => 'https://staging.hadithistudio.co.tz';

  @override
  String get webUrl => 'https://staging.hadithistudio.co.tz';

  @override
  bool get enableLogging => true;

  @override
  bool get enableAnalytics => true;

  @override
  bool get enableCrashReporting => true;

  @override
  bool get useMockData => false;

  @override
  bool get verboseNetworkLogs => true;

  @override
  Duration get slowNetworkWarningThreshold => const Duration(seconds: 8);
}

/// Usanidi wa mazingira ya uzalishaji (production).
///
/// **Sheria za usalama:** hakuna logging ya data nyeti, hakuna mock data,
/// analytics na crash reporting zinawashwa. Sheria hizi zinalinda
/// watumiaji na zinatii mahitaji ya ulinzi wa data (§11 ya spec).
class ProdConfig extends EnvConfig {
  const ProdConfig({this.baseUrlOverride});

  /// Inaruhusu CI/CD kubadilisha base URL bila kubadilisha code
  /// (mfano kwa "hotfix" ya domain mpya).
  final String? baseUrlOverride;

  @override
  Environment get environment => Environment.prod;

  @override
  String get name => 'prod';

  @override
  String get apiBaseUrl => baseUrlOverride ?? 'https://hadithistudio.co.tz';

  @override
  String get webUrl => 'https://hadithistudio.co.tz';

  /// Imewekwa `false` kwa makusudi: namba za simu na token hazipaswi
  /// kuachwa kwenye logs za kifaa cha mtumiaji.
  @override
  bool get enableLogging => false;

  @override
  bool get enableAnalytics => true;

  @override
  bool get enableCrashReporting => true;

  @override
  bool get useMockData => false;

  @override
  bool get verboseNetworkLogs => false;

  /// Tanzania ina maeneo yenye 2G/3G — tunaonya mapema ili mtumiaji
  /// aelewe kwa nini picha au sauti inachelewa.
  @override
  Duration get slowNetworkWarningThreshold => const Duration(seconds: 6);
}
