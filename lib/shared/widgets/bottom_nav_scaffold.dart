import 'package:flutter/material.dart';
import '../../../features/home/presentation/home_page.dart';
import '../../../features/analytics/presentation/analytics_page.dart';
import '../../../features/settings/presentation/settings_page.dart';

class BottomNavScaffold extends StatefulWidget {
  const BottomNavScaffold({super.key});

  @override
  State<BottomNavScaffold> createState() => _BottomNavScaffoldState();
}

class _BottomNavScaffoldState extends State<BottomNavScaffold> {
  int _index = 0;

  // 各画面をリストで保持（混雑・集計・設定）
  final _pages = const [
    HomePage(),
    AnalyticsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wc), // 🚻 トイレアイコン（混雑）
            label: '混雑',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart), // 📊 棒グラフアイコン（集計）
            label: '集計',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings), // ⚙️ 設定アイコン
            label: '設定',
          ),
        ],
      ),
    );
  }
}
