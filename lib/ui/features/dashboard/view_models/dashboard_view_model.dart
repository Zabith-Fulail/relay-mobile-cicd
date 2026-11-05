import 'package:flutter/material.dart';
import 'package:vault_ops/config/app_config.dart';
import 'package:vault_ops/domain/models/release_models.dart';
import 'package:vault_ops/domain/repositories/release_repository.dart';

/// ViewModel managing UI state for the DevOps Command Center.
/// Adheres to Single Responsibility (Presentation logic & state).
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({
    required ReleaseRepository releaseRepository,
    AppConfig? initialConfig,
    ThemeMode initialThemeMode = ThemeMode.system,
    this.autoRefresh = true,
  }) : _releaseRepository = releaseRepository,
       _config = initialConfig ?? AppConfig.fromEnvironment(),
       _themeMode = initialThemeMode {
    _initData();
  }

  final ReleaseRepository _releaseRepository;
  final bool autoRefresh;

  AppConfig _config;
  AppConfig get config => _config;

  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;

  int _counter = 0;
  int get counter => _counter;

  int _simulatedStageIndex = 4;
  int get simulatedStageIndex => _simulatedStageIndex;

  bool _isSimulatingPipeline = false;
  bool get isSimulatingPipeline => _isSimulatingPipeline;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  late List<PipelineStage> _stages;
  List<PipelineStage> get stages => _stages;

  late List<PipelineRun> _runs;
  List<PipelineRun> get runs => _runs;

  late List<ReleaseArtifact> _artifacts;
  List<ReleaseArtifact> get artifacts => _artifacts;

  late List<FeatureFlag> _featureFlags;
  List<FeatureFlag> get featureFlags => _featureFlags;

  late List<KpiMetric> _kpiMetrics;
  List<KpiMetric> get kpiMetrics => _kpiMetrics;

  void _initData() {
    _stages = _releaseRepository.getDefaultStages();
    _featureFlags = _releaseRepository.getInitialFeatureFlags();

    // Initialize baseline values immediately
    _runs = [
      PipelineRun(
        runNumber: int.tryParse(_config.buildNumber) ?? 42,
        title:
            'Release v${_config.appVersion} (${_config.environment.shortLabel})',
        branchOrTag: 'v${_config.appVersion}',
        commitSha: _config.gitCommit,
        duration: '1m 42s',
        coverage: 98.0,
        timeAgo: 'Just now',
        stages: _stages,
      ),
    ];
    _artifacts = const [];
    _kpiMetrics = _releaseRepository.getKpiMetrics(
      _config,
      runs: _runs,
      stages: _stages,
    );

    // Trigger live network fetch from GitHub API asynchronously if enabled
    if (autoRefresh) {
      refreshData();
    }
  }

  /// Refreshes live telemetry from the GitHub Actions & Releases REST API.
  Future<void> refreshData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final liveRuns = await _releaseRepository.getPipelineRuns(
        _config,
        forceRefresh: true,
      );
      final liveArtifacts = await _releaseRepository.getReleaseArtifacts(
        _config,
        forceRefresh: true,
      );

      _runs = liveRuns;
      _artifacts = liveArtifacts;
      _kpiMetrics = _releaseRepository.getKpiMetrics(
        _config,
        runs: _runs,
        stages: _stages,
      );
    } catch (_) {
      // Retain baseline data on network/offline errors
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTab(int index) {
    if (_selectedTab != index) {
      _selectedTab = index;
      notifyListeners();
    }
  }

  void switchEnvironment(AppEnvironment env) {
    _config = AppConfig(
      environment: env,
      appVersion: _config.appVersion,
      buildNumber: _config.buildNumber,
      gitCommit: _config.gitCommit,
      apiBaseUrl: env.defaultApiUrl,
      githubOwner: _config.githubOwner,
      githubRepo: _config.githubRepo,
    );
    _kpiMetrics = _releaseRepository.getKpiMetrics(
      _config,
      runs: _runs,
      stages: _stages,
    );
    notifyListeners();
    if (autoRefresh) {
      refreshData();
    }
  }

  void cycleThemeMode() {
    switch (_themeMode) {
      case ThemeMode.system:
        _themeMode = ThemeMode.light;
      case ThemeMode.light:
        _themeMode = ThemeMode.dark;
      case ThemeMode.dark:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }

  void toggleFeatureFlag(String flagId, bool value) {
    _featureFlags = [
      for (final flag in _featureFlags)
        if (flag.id == flagId) flag.copyWith(isEnabled: value) else flag,
    ];
    notifyListeners();
  }

  Future<void> triggerPipelineSimulation() async {
    if (_isSimulatingPipeline) return;

    _isSimulatingPipeline = true;
    _simulatedStageIndex = 0;
    notifyListeners();

    for (var i = 0; i < _stages.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      _simulatedStageIndex = i + 1;
      notifyListeners();
    }

    _isSimulatingPipeline = false;
    notifyListeners();
  }
}
