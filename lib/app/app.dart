import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/theme/theme_provider.dart';
import '../features/settings/presentation/settings_page.dart';

class ToiletApp extends StatelessWidget {
  const ToiletApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Toilet App',
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const SettingsPage(), // ← ここも問題なし
    );
  }
}
