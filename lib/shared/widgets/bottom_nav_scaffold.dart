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

  // ここに各画面を並べる＝“合体”
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
          NavigationDestination(icon: Icon(Icons.wc), label: '混雑'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: '集計'),
          NavigationDestination(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
