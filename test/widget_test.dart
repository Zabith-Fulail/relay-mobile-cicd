import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vault_ops/config/app_config.dart';
import 'package:vault_ops/data/repositories/cicd_release_repository.dart';
import 'package:vault_ops/data/services/cicd_data_source.dart';
import 'package:vault_ops/main.dart';
import 'package:vault_ops/ui/features/dashboard/view_models/dashboard_view_model.dart';

void main() {
  group('Clean Architecture Data & Domain Layer Tests', () {
    test('CiCdDataSource and Repository return valid domain models', () async {
      const dataSource = CiCdDataSource();
      const repository = CiCdReleaseRepository(dataSource: dataSource);
      const config = AppConfig(
        environment: AppEnvironment.staging,
        appVersion: '2.0.0',
        buildNumber: '55',
        gitCommit: 'abc1234',
        apiBaseUrl: 'https://api.staging.relay.internal',
      );

      final stages = repository.getDefaultStages();
      expect(stages.length, 4);
      expect(stages.first.name, contains('Formatting'));

      final runs = await repository.getPipelineRuns(config);
      expect(runs.isNotEmpty, isTrue);
      expect(runs.first.runNumber, isPositive);

      final artifacts = await repository.getReleaseArtifacts(config);
      expect(artifacts.isNotEmpty, isTrue);

      final flags = repository.getInitialFeatureFlags();
      expect(flags.length, 4);
      expect(flags.first.id, 'impeller_vulkan');

      final kpiMetrics = repository.getKpiMetrics(config);
      expect(kpiMetrics.length, 4);
      expect(kpiMetrics.first.id, 'coverage');
    });

    test(
      'DashboardViewModel manages state and adheres to Single Responsibility',
      () async {
        const repository = CiCdReleaseRepository();
        const config = AppConfig(
          environment: AppEnvironment.dev,
          appVersion: '1.0.0',
          buildNumber: '1',
          gitCommit: 'local',
          apiBaseUrl: 'https://api.dev.relay.internal',
        );

        final viewModel = DashboardViewModel(
          releaseRepository: repository,
          initialConfig: config,
          initialThemeMode: ThemeMode.system,
        );

        expect(viewModel.themeMode, ThemeMode.system);
        viewModel.cycleThemeMode();
        expect(viewModel.themeMode, ThemeMode.light);
        viewModel.cycleThemeMode();
        expect(viewModel.themeMode, ThemeMode.dark);
        viewModel.cycleThemeMode();
        expect(viewModel.themeMode, ThemeMode.system);

        viewModel.incrementCounter();
        expect(viewModel.counter, 1);

        viewModel.selectTab(2);
        expect(viewModel.selectedTab, 2);

        viewModel.toggleFeatureFlag('impeller_vulkan', false);
        expect(
          viewModel.featureFlags
              .firstWhere((f) => f.id == 'impeller_vulkan')
              .isEnabled,
          isFalse,
        );

        viewModel.switchEnvironment(AppEnvironment.prod);
        expect(viewModel.config.environment, AppEnvironment.prod);
      },
    );
  });

  group(
    'VaultOpsApp Clean Architecture & System Theme Integration Widget Tests',
    () {
      testWidgets('respects device system theme and switches themes cleanly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const VaultOpsApp(
            initialThemeMode: ThemeMode.system,
            autoRefresh: false,
          ),
        );

        // Verify Counter Smoke test
        expect(find.text('0'), findsAtLeastNWidgets(1));
        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
        expect(find.text('1'), findsAtLeastNWidgets(1));

        // Verify Theme Mode cycling button (System -> Light -> Dark -> System)
        final themeBtn = find.byKey(const Key('theme_mode_button'));
        expect(themeBtn, findsOneWidget);

        await tester.tap(themeBtn);
        await tester.pumpAndSettle();

        await tester.tap(themeBtn);
        await tester.pumpAndSettle();
      });

      testWidgets('switches environments and navigates tabs without errors', (
        WidgetTester tester,
      ) async {
        const initialConfig = AppConfig(
          environment: AppEnvironment.staging,
          appVersion: '1.4.0',
          buildNumber: '88',
          gitCommit: '9f8e7d6',
          apiBaseUrl: 'https://api.staging.relay.internal',
        );

        await tester.pumpWidget(
          const VaultOpsApp(initialConfig: initialConfig, autoRefresh: false),
        );

        expect(find.text('STAGING / QA'), findsAtLeastNWidgets(1));
        expect(find.text('v1.4.0+88 (9f8e7d6)'), findsOneWidget);

        // Switch to PROD environment via SegmentedButton
        await tester.tap(find.text('PROD'));
        await tester.pumpAndSettle();
        expect(find.text('PRODUCTION'), findsAtLeastNWidgets(1));

        // Navigate across tabs
        await tester.tap(find.text('Pipelines'));
        await tester.pumpAndSettle();
        expect(find.text('Live CI/CD Pipeline Simulator'), findsOneWidget);

        await tester.tap(find.text('Flavors'));
        await tester.pumpAndSettle();
        expect(
          find.text('Compile-Time Flag Matrix (--dart-define)'),
          findsOneWidget,
        );

        await tester.tap(find.text('Artifacts'));
        await tester.pumpAndSettle();
        expect(
          find.text('Signed Release Binaries (GitHub Releases)'),
          findsOneWidget,
        );
      });
    },
  );
}
