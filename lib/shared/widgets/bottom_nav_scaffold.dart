import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // ★追加

// ★ インポートパスを修正・追加
import '../../../features/home/presentation/male_crowd_page.dart';
import '../../../features/home/presentation/female_crowd_page.dart';
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
    MaleCrowdPage(),   // 0: 男子
    AnalyticsPage(),   // 2: 分析
    SettingsPage(),    // 3: 設定
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
            // Font Awesome のトイレアイコンに変更
            icon: const Icon(FontAwesomeIcons.person),
            label: loc.maleCrowdTitle, // ARBのキー
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart),
            label: loc.analyticsTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: loc.settingsTitle,
          ),
        ],
      ),
    );
  }
}