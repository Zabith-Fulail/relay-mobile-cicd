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

  String get shortLabel {
    switch (this) {
      case AppEnvironment.dev:
        return 'DEV';
      case AppEnvironment.staging:
        return 'STG';
      case AppEnvironment.prod:
        return 'PROD';
    }
  }

  String get defaultApiUrl {
    switch (this) {
      case AppEnvironment.dev:
        return 'https://api.dev.vaultops.internal';
      case AppEnvironment.staging:
        return 'https://api.staging.vaultops.internal';
      case AppEnvironment.prod:
        return 'https://api.vaultops.io';
    }
  }

  String get distributionChannel {
    switch (this) {
      case AppEnvironment.dev:
        return 'Local ADB / Debug Simulator';
      case AppEnvironment.staging:
        return 'Firebase App Distribution (QA Group)';
      case AppEnvironment.prod:
        return 'Google Play & Apple TestFlight';
    }
  }

  String get signingIdentity {
    switch (this) {
      case AppEnvironment.dev:
        return 'Android Debug Keystore (SHA-1: 4A:9F...2C)';
      case AppEnvironment.staging:
        return 'CI Staging Key (upload-staging.jks)';
      case AppEnvironment.prod:
        return 'Prod Release Keystore (upload-keystore.jks)';
    }
  }

  Color get primaryColor {
    switch (this) {
      case AppEnvironment.dev:
        return const Color(0xFF3B82F6); // Electric Cyber Blue
      case AppEnvironment.staging:
        return const Color(0xFFF59E0B); // Sunset Amber
      case AppEnvironment.prod:
        return const Color(0xFF10B981); // Emerald Neon Green
    }
  }

  Color get secondaryColor {
    switch (this) {
      case AppEnvironment.dev:
        return const Color(0xFF6366F1); // Indigo
      case AppEnvironment.staging:
        return const Color(0xFFEA580C); // Deep Orange
      case AppEnvironment.prod:
        return const Color(0xFF059669); // Deep Emerald
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
    this.githubOwner = 'Zabith-Fulail',
    this.githubRepo = 'relay-mobile-cicd',
  });

  /// Reads `--dart-define` values injected during `flutter build` or `flutter run`.
  factory AppConfig.fromEnvironment() {
    const rawEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    const appVersion = String.fromEnvironment(
      'APP_VERSION',
      defaultValue: '1.2.0',
    );
    const buildNumber = String.fromEnvironment(
      'BUILD_NUMBER',
      defaultValue: '42',
    );
    const gitCommit = String.fromEnvironment(
      'GIT_COMMIT',
      defaultValue: '9fdb61d',
    );
    const customApiUrl = String.fromEnvironment('API_BASE_URL');
    const githubOwner = String.fromEnvironment(
      'GITHUB_OWNER',
      defaultValue: 'Zabith-Fulail',
    );
    const githubRepo = String.fromEnvironment(
      'GITHUB_REPO',
      defaultValue: 'relay-mobile-cicd',
    );

    final env = AppEnvironment.fromString(rawEnv);
    return AppConfig(
      environment: env,
      appVersion: appVersion,
      buildNumber: buildNumber,
      gitCommit: gitCommit,
      apiBaseUrl: customApiUrl.isNotEmpty ? customApiUrl : env.defaultApiUrl,
      githubOwner: githubOwner,
      githubRepo: githubRepo,
    );
  }

  final AppEnvironment environment;
  final String appVersion;
  final String buildNumber;
  final String gitCommit;
  final String apiBaseUrl;
  final String githubOwner;
  final String githubRepo;

  String get githubRepoSlug => '$githubOwner/$githubRepo';

  bool get isProduction => environment == AppEnvironment.prod;
  bool get showDebugBanner => !isProduction;

  String get fullVersionString => 'v$appVersion+$buildNumber ($gitCommit)';
}
