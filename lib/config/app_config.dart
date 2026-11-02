import 'package:flutter/material.dart';

/// Supported deployment environments injected via `--dart-define=APP_ENV=...`.
enum AppEnvironment {
  dev,
  staging,
  prod;

  static AppEnvironment fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      case 'staging':
      case 'stage':
      case 'qa':
        return AppEnvironment.staging;
      case 'dev':
      case 'development':
      default:
        return AppEnvironment.dev;
    }
  }

  String get label {
    switch (this) {
      case AppEnvironment.dev:
        return 'DEVELOPMENT';
      case AppEnvironment.staging:
        return 'STAGING / QA';
      case AppEnvironment.prod:
        return 'PRODUCTION';
    }
  }

  String get defaultApiUrl {
    switch (this) {
      case AppEnvironment.dev:
        return 'https://api.dev.relay.internal';
      case AppEnvironment.staging:
        return 'https://api.staging.relay.internal';
      case AppEnvironment.prod:
        return 'https://api.relay.io';
    }
  }

  Color get primaryColor {
    switch (this) {
      case AppEnvironment.dev:
        return const Color(0xFF2563EB); // Blue for Dev
      case AppEnvironment.staging:
        return const Color(0xFFD97706); // Amber for Staging
      case AppEnvironment.prod:
        return const Color(0xFF059669); // Emerald Green for Production
    }
  }

  IconData get icon {
    switch (this) {
      case AppEnvironment.dev:
        return Icons.developer_mode;
      case AppEnvironment.staging:
        return Icons.science_outlined;
      case AppEnvironment.prod:
        return Icons.verified_outlined;
    }
  }
}

/// Compile-time configuration injected by the CI/CD pipeline using `--dart-define`.
class AppConfig {
  const AppConfig({
    required this.environment,
    required this.appVersion,
    required this.buildNumber,
    required this.gitCommit,
    required this.apiBaseUrl,
  });

  /// Reads `--dart-define` values injected during `flutter build` or `flutter run`.
  factory AppConfig.fromEnvironment() {
    const rawEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    const appVersion = String.fromEnvironment(
      'APP_VERSION',
      defaultValue: '1.0.0',
    );
    const buildNumber = String.fromEnvironment(
      'BUILD_NUMBER',
      defaultValue: '1',
    );
    const gitCommit = String.fromEnvironment(
      'GIT_COMMIT',
      defaultValue: 'local-dev',
    );
    const customApiUrl = String.fromEnvironment('API_BASE_URL');

    final env = AppEnvironment.fromString(rawEnv);
    return AppConfig(
      environment: env,
      appVersion: appVersion,
      buildNumber: buildNumber,
      gitCommit: gitCommit,
      apiBaseUrl: customApiUrl.isNotEmpty ? customApiUrl : env.defaultApiUrl,
    );
  }

  final AppEnvironment environment;
  final String appVersion;
  final String buildNumber;
  final String gitCommit;
  final String apiBaseUrl;

  bool get isProduction => environment == AppEnvironment.prod;
  bool get showDebugBanner => !isProduction;

  String get fullVersionString => 'v$appVersion+$buildNumber ($gitCommit)';
}
