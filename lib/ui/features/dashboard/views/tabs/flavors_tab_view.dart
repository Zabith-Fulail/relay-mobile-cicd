import 'package:flutter/material.dart';
import 'package:relay_mobile/ui/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:relay_mobile/ui/features/dashboard/views/widgets/dashboard_widgets.dart';

class FlavorsTabView extends StatelessWidget {
  const FlavorsTabView({
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
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                    Row(
                      children: [
                        Icon(Icons.terminal, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Compile-Time Flag Matrix (--dart-define)',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ConfigKeyValueTile(
                      flagKey: 'APP_ENV',
                      flagValue: env.name,
                      accent: primaryColor,
                    ),
                    ConfigKeyValueTile(
                      flagKey: 'APP_VERSION',
                      flagValue: viewModel.config.appVersion,
                      accent: primaryColor,
                    ),
                    ConfigKeyValueTile(
                      flagKey: 'BUILD_NUMBER',
                      flagValue: viewModel.config.buildNumber,
                      accent: primaryColor,
                    ),
                    ConfigKeyValueTile(
                      flagKey: 'GIT_COMMIT',
                      flagValue: viewModel.config.gitCommit,
                      accent: primaryColor,
                    ),
                    ConfigKeyValueTile(
                      flagKey: 'SIGNING_KEY',
                      flagValue: env.signingIdentity,
                      accent: primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
                    const Text(
                      'Runtime Delivery & Feature Flags',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final flag in viewModel.featureFlags)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        activeThumbColor: primaryColor,
                        title: Text(
                          flag.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13.5,
                          ),
                        ),
                        subtitle: Text(
                          flag.subtitle,
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: flag.isEnabled,
                        onChanged: (next) {
                          viewModel.toggleFeatureFlag(flag.id, next);
                        },
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
