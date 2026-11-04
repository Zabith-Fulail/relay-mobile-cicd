import 'package:flutter/material.dart';
import 'package:relay_mobile/ui/features/dashboard/view_models/dashboard_view_model.dart';
import 'package:relay_mobile/ui/features/dashboard/views/tabs/artifacts_tab_view.dart';
import 'package:relay_mobile/ui/features/dashboard/views/tabs/flavors_tab_view.dart';
import 'package:relay_mobile/ui/features/dashboard/views/tabs/overview_tab_view.dart';
import 'package:relay_mobile/ui/features/dashboard/views/tabs/pipelines_tab_view.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.viewModel,
    required this.title,
  });

  final DashboardViewModel viewModel;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final env = viewModel.config.environment;
        final primaryColor = env.primaryColor;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final cardBg = isDark ? const Color(0xFF131B2E) : Colors.white;
        final borderCol = isDark
            ? const Color(0xFF23304F)
            : const Color(0xFFE2E8F0);

        final themeTooltip = switch (viewModel.themeMode) {
          ThemeMode.system => 'Theme: System (Auto)',
          ThemeMode.light => 'Theme: Light',
          ThemeMode.dark => 'Theme: Dark',
        };

        final themeIcon = switch (viewModel.themeMode) {
          ThemeMode.system => Icons.brightness_auto,
          ThemeMode.light => Icons.light_mode,
          ThemeMode.dark => Icons.dark_mode,
        };

        return Scaffold(
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF0B0F19) : primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 16,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, env.secondaryColor],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(env.icon, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        'CI/CD Release Command Center',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  key: const Key('env_badge'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: primaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        env.label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                key: const Key('refresh_button'),
                onPressed: viewModel.isLoading ? null : viewModel.refreshData,
                tooltip: 'Fetch Live GitHub Telemetry',
                icon: viewModel.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.refresh, size: 20),
              ),
              IconButton(
                key: const Key('theme_mode_button'),
                onPressed: viewModel.cycleThemeMode,
                tooltip: themeTooltip,
                icon: Icon(themeIcon, size: 20),
              ),
            ],
          ),
          body: IndexedStack(
            index: viewModel.selectedTab,
            children: [
              OverviewTabView(
                viewModel: viewModel,
                cardBg: cardBg,
                borderCol: borderCol,
                isDark: isDark,
              ),
              PipelinesTabView(
                viewModel: viewModel,
                cardBg: cardBg,
                borderCol: borderCol,
                isDark: isDark,
              ),
              FlavorsTabView(
                viewModel: viewModel,
                cardBg: cardBg,
                borderCol: borderCol,
                isDark: isDark,
              ),
              ArtifactsTabView(
                viewModel: viewModel,
                cardBg: cardBg,
                borderCol: borderCol,
                isDark: isDark,
              ),
            ],
          ),
          floatingActionButton: viewModel.selectedTab == 0
              ? FloatingActionButton.extended(
                  onPressed: viewModel.incrementCounter,
                  tooltip: 'Increment',
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Verify Build',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                )
              : null,
          bottomNavigationBar: NavigationBar(
            selectedIndex: viewModel.selectedTab,
            onDestinationSelected: viewModel.selectTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.space_dashboard_outlined),
                selectedIcon: Icon(Icons.space_dashboard),
                label: 'Overview',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_tree_outlined),
                selectedIcon: Icon(Icons.account_tree),
                label: 'Pipelines',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune),
                label: 'Flavors',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: 'Artifacts',
              ),
            ],
          ),
        );
      },
    );
  }
}
