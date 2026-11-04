import 'package:relay_mobile/config/app_config.dart';
import 'package:relay_mobile/data/services/cicd_data_source.dart';
import 'package:relay_mobile/domain/models/release_models.dart';
import 'package:relay_mobile/domain/repositories/release_repository.dart';

/// Concrete implementation of [ReleaseRepository] backed by [CiCdDataSource].
class CiCdReleaseRepository implements ReleaseRepository {
  const CiCdReleaseRepository({
    CiCdDataSource dataSource = const CiCdDataSource(),
  }) : _dataSource = dataSource;

  final CiCdDataSource _dataSource;

  @override
  List<PipelineStage> getDefaultStages() => _dataSource.fetchDefaultStages();

  @override
  Future<List<PipelineRun>> getPipelineRuns(
    AppConfig config, {
    bool forceRefresh = false,
  }) => _dataSource.fetchLivePipelineRuns(config);

  @override
  Future<List<ReleaseArtifact>> getReleaseArtifacts(
    AppConfig config, {
    bool forceRefresh = false,
  }) => _dataSource.fetchLiveArtifacts(config);

  @override
  List<FeatureFlag> getInitialFeatureFlags() =>
      _dataSource.fetchDefaultFeatureFlags();

  @override
  List<KpiMetric> getKpiMetrics(
    AppConfig config, {
    List<PipelineRun>? runs,
    List<PipelineStage>? stages,
  }) => _dataSource.computeKpiMetrics(config, runs: runs, stages: stages);
}
