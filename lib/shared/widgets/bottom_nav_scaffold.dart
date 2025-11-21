import 'package:flutter/material.dart';
import '../../../features/home/presentation/home_page.dart';
import '../../../features/analytics/presentation/analytics_page.dart';
import '../../../features/settings/presentation/settings_page.dart';

// ★ 多言語
import '../../../l10n/app_localizations.dart';

class BottomNavScaffold extends StatefulWidget {
  const BottomNavScaffold({super.key});

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  int _index = 0;

  final _pages = const [
    HomePage(),
    AnalyticsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.wc),
            label: loc.homeTitle,     // ←混雑
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart),
            label: loc.analyticsTitle, // ←集計（後でARB追加する）
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: loc.settingsTitle, // ←設定
          ),
        ],
      ),
    );
  }
}
