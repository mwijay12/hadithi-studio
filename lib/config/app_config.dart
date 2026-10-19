import 'package:flutter/foundation.dart';

import 'env/dev_config.dart';
import 'env/env_config.dart';
import 'env/prod_config.dart';

/// Usanidi mkuu wa app — huchagua mazingira na kutoa values zinazotumika
/// kote kwenye app.
///
/// Mazingira huchaguliwa kwa `--dart-define=ENV=dev|staging|prod` wakati
/// wa kujenga app (build flavors, §14 ya spec). Kama hakuna value
/// iliyotolewa, tunatumia `dev`.
///
/// Mfano wa kujenga kwa production:
/// ```bash
/// flutter build apk --release --dart-define=ENV=prod
/// ```
abstract final class AppConfig {
  /// Jina la mazingira kutoka build (`dev`, `staging`, `prod`).
  static const String environmentName = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  /// Base URL ya API inayoweza kubadilishwa wakati wa build.
  /// Hii huruhusu CI/CD kutumia domain tofauti bila kubadilisha code.
  static const String apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
  );

  /// Namba ya build (hutumwa kwa backend kwa `X-App-Version`).
  static const String buildNumber = String.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: '1',
  );

  static final EnvConfig _active = _resolve();

  /// Mazingira yanayotumika sasa.
  static EnvConfig get env => _active;

  /// Base URL ya API inayotumika sasa (pamoja na override ya build).
  static String get apiBaseUrl =>
      apiBaseUrlOverride.isNotEmpty ? apiBaseUrlOverride : _active.apiBaseUrl;

  /// Base URL ya tovuti.
  static String get webUrl => _active.webUrl;

  /// `true` kama tunatumia mazingira ya msanidi.
  static bool get isDev => _active.environment == Environment.dev;

  /// `true` kama tunatumia mazingira ya uzalishaji.
  static bool get isProd => _active.environment == Environment.prod;

  /// Kama data ya majaribio inatumika badala ya API halisi.
  static bool get useMockData => _active.useMockData;

  /// Kama logs zinaandikwa.
  static bool get enableLogging => _active.enableLogging;

  /// Jina la app linavyoonekana kwa backend / logs: `hadithi_studio@dev`.
  static String get clientIdentifier => 'hadithi_studio@${_active.name}';

  /// Jukwaa (platform) — hutumwa kwa backend kwa `X-Platform`.
  static String get platform => switch (defaultTargetPlatform) {
        TargetPlatform.android => 'android',
        TargetPlatform.iOS => 'ios',
        TargetPlatform.macOS => 'macos',
        TargetPlatform.windows => 'windows',
        TargetPlatform.linux => 'linux',
        TargetPlatform.fuchsia => 'fuchsia',
      };

  static EnvConfig _resolve() {
    switch (environmentName.toLowerCase()) {
      case 'prod':
      case 'production':
        return const ProdConfig();
      case 'staging':
      case 'stage':
        return const StagingConfig();
      case 'dev':
      case 'development':
      default:
        return const DevConfig();
    }
  }
}
