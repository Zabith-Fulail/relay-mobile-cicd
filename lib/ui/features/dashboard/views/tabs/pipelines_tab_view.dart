import 'package:flutter/material.dart';
import 'package:vault_ops/domain/models/release_models.dart';
import 'package:vault_ops/ui/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:vault_ops/ui/features/dashboard/views/widgets/dashboard_widgets.dart';

class PipelinesTabView extends StatelessWidget {
  const PipelinesTabView({
    super.key,
    required this.viewModel,
    required this.cardBg,
    required this.borderCol,
    required this.isDark,
  });

  final DashboardViewModel viewModel;
  final Color cardBg;
  final Color borderCol;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final env = viewModel.config.environment;
    final primaryColor = env.primaryColor;
    final stages = viewModel.stages;
    final runs = viewModel.runs;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Interactive Pipeline Simulator Card
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.5),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.play_circle_fill, color: primaryColor),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Live CI/CD Pipeline Simulator',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: viewModel.isSimulatingPipeline
                              ? null
                              : viewModel.triggerPipelineSimulation,
                          style: FilledButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: viewModel.isSimulatingPipeline
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.replay, size: 16),
                          label: Text(
                            viewModel.isSimulatingPipeline
                                ? 'Running...'
                                : 'Run CI/CD',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < stages.length; i++)
                      _SimulatedStageRow(
                        stage: stages[i],
                        isCompleted: i < viewModel.simulatedStageIndex,
                        isRunning:
                            viewModel.isSimulatingPipeline &&
                            i == viewModel.simulatedStageIndex,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Recent GitHub Actions Workflow Runs',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
              const SizedBox(height: 10),
              for (final run in runs)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderCol),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF10B981),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '#${run.runNumber} • ${run.title}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            run.timeAgo,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          MiniChip(
                            icon: Icons.sell_outlined,
                            label: run.branchOrTag,
                          ),
                          MiniChip(icon: Icons.commit, label: run.commitSha),
                          MiniChip(
                            icon: Icons.timer_outlined,
                            label: run.duration,
                          ),
                          MiniChip(
                            icon: Icons.analytics_outlined,
                            label: '${run.coverage}% cov',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimulatedStageRow extends StatelessWidget {
  const _SimulatedStageRow({
    required this.stage,
    required this.isCompleted,
    required this.isRunning,
  });

  final PipelineStage stage;
  final bool isCompleted;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (isRunning)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            )
          else if (isCompleted)
            const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 18)
          else
            const Icon(
              Icons.radio_button_unchecked,
              color: Colors.grey,
              size: 18,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  stage.command,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isCompleted ? stage.duration : (isRunning ? 'running' : 'queued'),
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: isCompleted ? const Color(0xFF10B981) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
