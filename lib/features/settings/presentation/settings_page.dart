import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_toilet_app/l10n/app_localizations.dart';

import '../../../shared/theme/theme_provider.dart';
import '../../../shared/language/language_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    final loc = AppLocalizations.of(context)!;

    Text(loc.settingsTitle);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ★ ダークテーマ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(loc.darkTheme),
                Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(value),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ★ 言語設定
            Text(loc.languageSetting, style: const TextStyle(fontSize: 18)),

            ListTile(
              title: Text(loc.languageJapanese),
              onTap: () {
                languageProvider.setLocale(const Locale('ja'));
                _showRestartDialog(context, loc);
              },
            ),

            ListTile(
              title: Text(loc.languageEnglish),
              onTap: () {
                languageProvider.setLocale(const Locale('en'));
                _showRestartDialog(context, loc);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRestartDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.restartRequired),
        content: Text(loc.restartDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }
}
