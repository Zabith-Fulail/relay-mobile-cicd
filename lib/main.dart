import 'package:flutter/material.dart';
import 'package:relay_mobile/config/app_config.dart';

void main() {
  final config = AppConfig.fromEnvironment();
  runApp(MyApp(initialConfig: config));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.initialConfig});

  final AppConfig? initialConfig;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppConfig _config;

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig ?? AppConfig.fromEnvironment();
  }

  void _switchEnvironment(AppEnvironment env) {
    setState(() {
      _config = AppConfig(
        environment: env,
        appVersion: _config.appVersion,
        buildNumber: _config.buildNumber,
        gitCommit: _config.gitCommit,
        apiBaseUrl: env.defaultApiUrl,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Relay Mobile (${_config.environment.label})',
      debugShowCheckedModeBanner: _config.showDebugBanner,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _config.environment.primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(
        title: 'Relay Mobile CI/CD',
        config: _config,
        onEnvironmentChanged: _switchEnvironment,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.config,
    required this.onEnvironmentChanged,
  });

  final String title;
  final AppConfig config;
  final ValueChanged<AppEnvironment> onEnvironmentChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final env = widget.config.environment;
    final primaryColor = env.primaryColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            Icon(env.icon, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              key: const Key('env_badge'),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white54),
              ),
              child: Text(
                env.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Environment Switcher Card (for live demo convenience)
                Card(
                  elevation: 0,
                  color: primaryColor.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: primaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.rocket_launch,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'CI/CD Build Metadata (--dart-define)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        _MetadataRow(
                          label: 'Environment',
                          value: env.label,
                          valueKey: const Key('meta_env'),
                        ),
                        _MetadataRow(
                          label: 'Release Version',
                          value: widget.config.fullVersionString,
                          valueKey: const Key('meta_version'),
                        ),
                        _MetadataRow(
                          label: 'API Endpoint',
                          value: widget.config.apiBaseUrl,
                          valueKey: const Key('meta_api'),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Simulate CI Flavor / Environment:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<AppEnvironment>(
                          segments: const [
                            ButtonSegment(
                              value: AppEnvironment.dev,
                              label: Text('DEV'),
                              icon: Icon(Icons.developer_mode, size: 16),
                            ),
                            ButtonSegment(
                              value: AppEnvironment.staging,
                              label: Text('STAGING'),
                              icon: Icon(Icons.science_outlined, size: 16),
                            ),
                            ButtonSegment(
                              value: AppEnvironment.prod,
                              label: Text('PROD'),
                              icon: Icon(Icons.verified_outlined, size: 16),
                            ),
                          ],
                          selected: {env},
                          onSelectionChanged: (selected) {
                            widget.onEnvironmentChanged(selected.first);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Pipeline Status Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Automated Quality Gates',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 10),
                        _PipelineStepTile(
                          title: '1. Code Formatting (dart format)',
                          subtitle: 'Enforces consistent Dart style on PRs',
                        ),
                        _PipelineStepTile(
                          title: '2. Static Analysis (flutter analyze)',
                          subtitle: 'Zero lint warnings or errors allowed',
                        ),
                        _PipelineStepTile(
                          title: '3. Automated Tests & Coverage',
                          subtitle: 'Unit + Widget tests verified before build',
                        ),
                        _PipelineStepTile(
                          title: '4. Multi-Env Release Build & Signing',
                          subtitle: 'APK / AAB / Web artifacts published',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Interactive Feature / Smoke Test Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Deployment Verification Counter',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'You have pushed the button this many times:',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_counter',
                          key: const Key('counter_text'),
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({
    required this.label,
    required this.value,
    required this.valueKey,
  });

  final String label;
  final String value;
  final Key valueKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          Flexible(
            child: Text(
              value,
              key: valueKey,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineStepTile extends StatelessWidget {
  const _PipelineStepTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF059669), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
