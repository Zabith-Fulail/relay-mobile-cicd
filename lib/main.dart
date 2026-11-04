import 'package:flutter/material.dart';
import 'package:relay_mobile/config/app_config.dart';
import 'package:relay_mobile/data/repositories/cicd_release_repository.dart';
import 'package:relay_mobile/domain/repositories/release_repository.dart';
import 'package:relay_mobile/ui/core/theme/app_theme.dart';
import 'package:relay_mobile/ui/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:relay_mobile/ui/features/dashboard/views/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  const repository = CiCdReleaseRepository();

  runApp(RelayApp(initialConfig: config, releaseRepository: repository));
}

/// Root Application Widget adhering to Inversion of Control & Dependency Injection.
class RelayApp extends StatefulWidget {
  const RelayApp({
    super.key,
    this.initialConfig,
    this.releaseRepository = const CiCdReleaseRepository(),
    this.initialThemeMode = ThemeMode.system,
  });

  final AppConfig? initialConfig;
  final ReleaseRepository releaseRepository;
  final ThemeMode initialThemeMode;

  @override
  State<RelayApp> createState() => _RelayAppState();
}

class _RelayAppState extends State<RelayApp> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel(
      releaseRepository: widget.releaseRepository,
      initialConfig: widget.initialConfig,
      initialThemeMode: widget.initialThemeMode,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final env = _viewModel.config.environment;

        return MaterialApp(
          title: 'Relay Mobile (${env.label})',
          debugShowCheckedModeBanner: _viewModel.config.showDebugBanner,
          // Defaults to system theme mode (automatically adapts to device dark/light setting)
          themeMode: _viewModel.themeMode,
          theme: AppTheme.light(env),
          darkTheme: AppTheme.dark(env),
          home: DashboardScreen(viewModel: _viewModel, title: 'Relay DevOps'),
        );
      },
    );
  }
}
