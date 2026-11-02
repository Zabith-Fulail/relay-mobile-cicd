import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relay_mobile/config/app_config.dart';
import 'package:relay_mobile/main.dart';

void main() {
  group('AppConfig Unit Tests (CI Environment Injection)', () {
    test('parses dev, staging, and prod environment strings accurately', () {
      expect(AppEnvironment.fromString('dev'), AppEnvironment.dev);
      expect(AppEnvironment.fromString('STAGING'), AppEnvironment.staging);
      expect(AppEnvironment.fromString('prod'), AppEnvironment.prod);
      expect(AppEnvironment.fromString('production'), AppEnvironment.prod);
      expect(AppEnvironment.fromString('unknown'), AppEnvironment.dev);
    });

    test('formats full version string and production flags', () {
      const prodConfig = AppConfig(
        environment: AppEnvironment.prod,
        appVersion: '2.1.0',
        buildNumber: '42',
        gitCommit: 'a1b2c3d',
        apiBaseUrl: 'https://api.relay.io',
      );

      expect(prodConfig.isProduction, isTrue);
      expect(prodConfig.showDebugBanner, isFalse);
      expect(prodConfig.fullVersionString, 'v2.1.0+42 (a1b2c3d)');
      expect(prodConfig.environment.label, 'PRODUCTION');
    });

    test('provides default environment endpoints and colors', () {
      expect(
        AppEnvironment.dev.defaultApiUrl,
        'https://api.dev.relay.internal',
      );
      expect(
        AppEnvironment.staging.defaultApiUrl,
        'https://api.staging.relay.internal',
      );
      expect(AppEnvironment.prod.defaultApiUrl, 'https://api.relay.io');
      expect(AppEnvironment.dev.icon, Icons.developer_mode);
      expect(AppEnvironment.staging.icon, Icons.science_outlined);
      expect(AppEnvironment.prod.icon, Icons.verified_outlined);
    });
  });

  group('Relay Mobile CI/CD Widget Tests', () {
    testWidgets('Counter increments smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('Displays injected CI/CD metadata and switches environments', (
      WidgetTester tester,
    ) async {
      const initialConfig = AppConfig(
        environment: AppEnvironment.staging,
        appVersion: '1.4.0',
        buildNumber: '88',
        gitCommit: '9f8e7d6',
        apiBaseUrl: 'https://api.staging.relay.internal',
      );

      await tester.pumpWidget(const MyApp(initialConfig: initialConfig));

      expect(find.text('STAGING / QA'), findsAtLeastNWidgets(1));
      expect(find.text('v1.4.0+88 (9f8e7d6)'), findsOneWidget);

      // Switch to PROD environment via SegmentedButton
      await tester.tap(find.text('PROD'));
      await tester.pumpAndSettle();

      expect(find.text('PRODUCTION'), findsAtLeastNWidgets(1));
      expect(find.text('https://api.relay.io'), findsOneWidget);
    });
  });
}
