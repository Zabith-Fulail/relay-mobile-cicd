import 'package:flutter/material.dart';
import 'package:vault_ops/ui/features/dashboard/view_models/dashboard_view_model.dart';

class ArtifactsTabView extends StatelessWidget {
  const ArtifactsTabView({
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
    final artifacts = viewModel.artifacts;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Signed Release Binaries (GitHub Releases)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text(
                'Generated automatically in Stage 4 by cd_release.yml',
                style: TextStyle(fontSize: 12.5, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              for (final item in artifacts)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderCol),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: item.accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: item.accentColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${item.platform} • ${item.size}',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Target: ${item.targetStore}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: item.accentColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'SHA-256: ${item.sha256Short}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontFamily: 'monospace',
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
