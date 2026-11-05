import 'package:flutter/material.dart';
import 'package:vault_ops/config/app_config.dart';
import 'package:vault_ops/ui/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:vault_ops/ui/features/dashboard/views/widgets/dashboard_widgets.dart';

class OverviewTabView extends StatelessWidget {
  const OverviewTabView({
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Hero Gradient Release Banner
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withValues(alpha: isDark ? 0.32 : 0.9),
                      env.secondaryColor.withValues(
                        alpha: isDark ? 0.15 : 0.75,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt,
                                size: 14,
                                color: Color(0xFFFBBF24),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'CI/CD Build Metadata (--dart-define)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.verified,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    HeroMetadataRow(
                      label: 'Environment',
                      value: env.label,
                      valueKey: const Key('meta_env'),
                    ),
                    HeroMetadataRow(
                      label: 'Release Version',
                      value: viewModel.config.fullVersionString,
                      valueKey: const Key('meta_version'),
                    ),
                    HeroMetadataRow(
                      label: 'API Endpoint',
                      value: viewModel.config.apiBaseUrl,
                      valueKey: const Key('meta_api'),
                    ),
                    HeroMetadataRow(
                      label: 'Distribution',
                      value: env.distributionChannel,
                      valueKey: const Key('meta_dist'),
                    ),
                    const SizedBox(height: 14),
                    SegmentedButton<AppEnvironment>(
                      showSelectedIcon: false,
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 4),
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return primaryColor;
                          }
                          return Colors.black.withValues(alpha: 0.25);
                        }),
                        foregroundColor: const WidgetStatePropertyAll(
                          Colors.white,
                        ),
                      ),
                      segments: AppEnvironment.values.map((targetEnv) {
                        return ButtonSegment<AppEnvironment>(
                          value: targetEnv,
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              targetEnv.shortLabel,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                          icon: Icon(targetEnv.icon, size: 14),
                        );
                      }).toList(),
                      selected: {env},
                      onSelectionChanged: (selected) {
                        viewModel.switchEnvironment(selected.first);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. DevOps KPI Metrics Grid (2x2)
              if (viewModel.kpiMetrics.length >= 4) ...[
                Row(
                  children: [
                    Expanded(
                      child: KpiMetricCard(
                        title: viewModel.kpiMetrics[0].title,
                        value: viewModel.kpiMetrics[0].value,
                        subtitle: viewModel.kpiMetrics[0].subtitle,
                        icon: viewModel.kpiMetrics[0].icon,
                        accentColor: viewModel.kpiMetrics[0].accentColor,
                        cardBg: cardBg,
                        borderCol: borderCol,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KpiMetricCard(
                        title: viewModel.kpiMetrics[1].title,
                        value: viewModel.kpiMetrics[1].value,
                        subtitle: viewModel.kpiMetrics[1].subtitle,
                        icon: viewModel.kpiMetrics[1].icon,
                        accentColor: viewModel.kpiMetrics[1].accentColor,
                        cardBg: cardBg,
                        borderCol: borderCol,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: KpiMetricCard(
                        title: viewModel.kpiMetrics[2].title,
                        value: viewModel.kpiMetrics[2].value,
                        subtitle: viewModel.kpiMetrics[2].subtitle,
                        icon: viewModel.kpiMetrics[2].icon,
                        accentColor: viewModel.kpiMetrics[2].accentColor,
                        cardBg: cardBg,
                        borderCol: borderCol,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KpiMetricCard(
                        title: viewModel.kpiMetrics[3].title,
                        value: viewModel.kpiMetrics[3].value,
                        subtitle: viewModel.kpiMetrics[3].subtitle,
                        icon: viewModel.kpiMetrics[3].icon,
                        accentColor: viewModel.kpiMetrics[3].accentColor,
                        cardBg: cardBg,
                        borderCol: borderCol,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),

              // 3. Automated Quality Gates Card
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 19,
                          color: Color(0xFF10B981),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Automated CI/CD Quality Gates',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final stage in viewModel.stages)
                      PipelineStepTile(
                        title: stage.name,
                        subtitle: stage.subtitle,
                        badgeText: stage.duration,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Interactive Smoke Test & Deployment Verification Card
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderCol),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 18,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 6),
                        const Flexible(
                          child: Text(
                            'Interactive Widget Smoke Test Counter',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'You have pushed the button this many times:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${viewModel.counter}',
                      key: const Key('counter_text'),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: primaryColor,
                          ),
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
