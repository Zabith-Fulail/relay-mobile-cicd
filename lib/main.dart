import 'package:flutter/material.dart';
import 'package:vault_ops/config/app_config.dart';
import 'package:vault_ops/data/repositories/cicd_release_repository.dart';
import 'package:vault_ops/domain/repositories/release_repository.dart';
import 'package:vault_ops/ui/core/theme/app_theme.dart';
import 'package:vault_ops/ui/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:vault_ops/ui/features/dashboard/views/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final config = AppConfig.fromEnvironment();
  const repository = CiCdReleaseRepository();

  runApp(VaultOpsApp(initialConfig: config, releaseRepository: repository));
}

/// Root Application Widget adhering to Inversion of Control & Dependency Injection.
class VaultOpsApp extends StatefulWidget {
  const VaultOpsApp({
    super.key,
    this.initialConfig,
    this.releaseRepository = const CiCdReleaseRepository(),
    this.initialThemeMode = ThemeMode.system,
    this.autoRefresh = true,
  });

  final AppConfig? initialConfig;
  final ReleaseRepository releaseRepository;
  final ThemeMode initialThemeMode;
  final bool autoRefresh;

  @override
  State<VaultOpsApp> createState() => _VaultOpsAppState();
}

class _VaultOpsAppState extends State<VaultOpsApp> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel(
      releaseRepository: widget.releaseRepository,
      initialConfig: widget.initialConfig,
      initialThemeMode: widget.initialThemeMode,
      autoRefresh: widget.autoRefresh,
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
          title: 'VaultOps (${env.label})',
          debugShowCheckedModeBanner: _viewModel.config.showDebugBanner,
          // Defaults to system theme mode (automatically adapts to device dark/light setting)
          themeMode: _viewModel.themeMode,
          theme: AppTheme.light(env),
          darkTheme: AppTheme.dark(env),
          home: DashboardScreen(
            viewModel: _viewModel,
            title: 'VaultOps Command Center',
          ),
        );
      },
    );
  }
}

/// Backwards compatibility alias
typedef RelayApp = VaultOpsApp;
