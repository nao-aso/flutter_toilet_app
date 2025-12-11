import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/theme/theme_provider.dart';
import '../../../shared/language/language_provider.dart';

// ★ あなたの環境ではこれが正しい！
import '../../../l10n/app_localizations.dart';

import '../../../features/terms/terms_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsTitle), // 「設定」
      ),

      body: ListView(
        children: [
          // -------------------------------------------------------
          // ① ダークテーマ切り替えスイッチ
          // -------------------------------------------------------
          ListTile(
            title: Text(loc.darkTheme),
            trailing: Switch(
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
          ),

          const Divider(),

          // -------------------------------------------------------
          // ② 言語切り替え
          // -------------------------------------------------------
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              loc.languageSetting, // 言語設定
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // 日本語
          ListTile(
            title: Text(loc.languageJapanese),
            onTap: () {
              languageProvider.setLocale(const Locale('ja'));
              _showRestartDialog(context, loc);
            },
          ),

          // 英語
          ListTile(
            title: Text(loc.languageEnglish),
            onTap: () {
              languageProvider.setLocale(const Locale('en'));
              _showRestartDialog(context, loc);
            },
          ),

          const Divider(),

          // -------------------------------------------------------
          // ③ 利用規約ページへのリンク
          // -------------------------------------------------------
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(loc.termsTitle), // 「利用規約」
            subtitle: Text(loc.termsShortcutDescription),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // 言語変更時の「再起動してください」ダイアログ
  // -------------------------------------------------------
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
