import 'env_config.dart';

/// Usanidi wa mazingira ya msanidi (development).
///
/// Hapa tunatumia data ya majaribio (mock) ili UI iweze kujengwa na
/// kujaribiwa hata bila backend. Logging zote zimewashwa.
class DevConfig extends EnvConfig {
  const DevConfig();

  @override
  Environment get environment => Environment.dev;

  @override
  String get name => 'dev';

  /// Backend ya msanidi. Inaweza kubadilishwa kwa `--dart-define=API_BASE_URL=...`
  @override
  String get apiBaseUrl => 'https://dev.hadithistudio.co.tz';

  @override
  String get webUrl => 'https://dev.hadithistudio.co.tz';

  @override
  bool get enableLogging => true;

  @override
  bool get enableAnalytics => false;

  @override
  bool get enableCrashReporting => false;

  /// App inaweza kuendeshwa bila backend — muhimu sana kwa kazi ya UI.
  @override
  bool get useMockData => true;

  @override
  bool get verboseNetworkLogs => true;

  @override
  Duration get slowNetworkWarningThreshold => const Duration(seconds: 8);
}
