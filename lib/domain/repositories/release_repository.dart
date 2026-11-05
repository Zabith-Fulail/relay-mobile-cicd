import 'package:vault_ops/config/app_config.dart';
import 'package:vault_ops/domain/models/release_models.dart';

/// Abstract repository contract for querying CI/CD pipelines, stages,
/// feature flags, and signed release artifacts (Dependency Inversion Principle).
abstract interface class ReleaseRepository {
  List<PipelineStage> getDefaultStages();

  Future<List<PipelineRun>> getPipelineRuns(
    AppConfig config, {
    bool forceRefresh = false,
  });

  Future<List<ReleaseArtifact>> getReleaseArtifacts(
    AppConfig config, {
    bool forceRefresh = false,
  });

  List<FeatureFlag> getInitialFeatureFlags();

  List<KpiMetric> getKpiMetrics(
    AppConfig config, {
    List<PipelineRun>? runs,
    List<PipelineStage>? stages,
  });
}
