/// Resolves environment-specific config from a `--dart-define=ENV=<env>` flag.
///
/// Run with:
///   `flutter run --dart-define=ENV=dev`
///   `flutter run --dart-define=ENV=staging`
///   `flutter run --dart-define=ENV=prod`
///
/// Defaults to `dev` when not provided.
enum AppEnv { dev, staging, prod }

class Environment {
  static const String _envName =
      String.fromEnvironment('ENV', defaultValue: 'dev');

  static AppEnv get current {
    switch (_envName) {
      case 'prod':
        return AppEnv.prod;
      case 'staging':
        return AppEnv.staging;
      case 'dev':
      default:
        return AppEnv.dev;
    }
  }

  static String get baseUrl {
    switch (current) {
      case AppEnv.prod:
        return const String.fromEnvironment(
          'BASE_URL',
          defaultValue: 'https://admin.moonjoin.com',
        );
      case AppEnv.staging:
        return const String.fromEnvironment(
          'BASE_URL',
          defaultValue: 'https://staging.admin.moonjoin.com',
        );
      case AppEnv.dev:
        return const String.fromEnvironment(
          'BASE_URL',
          defaultValue: 'https://admin.moonjoin.com',
        );
    }
  }

  static String get webHostedUrl {
    switch (current) {
      case AppEnv.prod:
        return 'https://cloud.moonjoin.com';
      case AppEnv.staging:
        return 'https://cloud.staging.moonjoin.com';
      case AppEnv.dev:
        return 'https://cloud.dev.moonjoin.com';
    }
  }

  /// Google Maps API key, separate from the User App's key — restricted per env.
  static String get googleMapsApiKey =>
      const String.fromEnvironment('MAPS_KEY', defaultValue: '');

  /// Toggle to use the in-app mock service layer while backend gaps are filled.
  static bool get useMocks =>
      const bool.fromEnvironment('USE_MOCKS', defaultValue: false);

  static bool get isProd => current == AppEnv.prod;
  static bool get isDev => current == AppEnv.dev;
}
