import 'package:flutter/material.dart';

enum StageStatus { passed, running, pending, failed }

/// Immutable domain model representing a single CI/CD quality gate stage.
@immutable
class PipelineStage {
  const PipelineStage({
    required this.name,
    required this.subtitle,
    required this.command,
    required this.duration,
    this.status = StageStatus.passed,
  });

  final String name;
  final String subtitle;
  final String command;
  final String duration;
  final StageStatus status;

  PipelineStage copyWith({StageStatus? status, String? duration}) {
    return PipelineStage(
      name: name,
      subtitle: subtitle,
      command: command,
      duration: duration ?? this.duration,
      status: status ?? this.status,
    );
  }
}

/// Immutable domain model representing a historical or active CI/CD workflow run.
@immutable
class PipelineRun {
  const PipelineRun({
    required this.runNumber,
    required this.title,
    required this.branchOrTag,
    required this.commitSha,
    required this.duration,
    required this.coverage,
    required this.timeAgo,
    required this.stages,
  });

  final int runNumber;
  final String title;
  final String branchOrTag;
  final String commitSha;
  final String duration;
  final double coverage;
  final String timeAgo;
  final List<PipelineStage> stages;
}

/// Immutable domain model representing a signed mobile release binary.
@immutable
class ReleaseArtifact {
  const ReleaseArtifact({
    required this.name,
    required this.platform,
    required this.size,
    required this.sha256Short,
    required this.targetStore,
    required this.icon,
    required this.accentColor,
  });

  final String name;
  final String platform;
  final String size;
  final String sha256Short;
  final String targetStore;
  final IconData icon;
  final Color accentColor;
}

/// Immutable domain model representing a runtime feature toggle.
@immutable
class FeatureFlag {
  const FeatureFlag({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
  });

  final String id;
  final String title;
  final String subtitle;
  final bool isEnabled;

  FeatureFlag copyWith({bool? isEnabled}) {
    return FeatureFlag(
      id: id,
      title: title,
      subtitle: subtitle,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

/// Immutable domain model representing a DevOps KPI metric card.
@immutable
class KpiMetric {
  const KpiMetric({
    required this.id,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  final String id;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
}
