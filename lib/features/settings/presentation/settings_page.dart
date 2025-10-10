import 'package:flutter/material.dart';
import '../../data/settings_repository.dart';
import '../../domain/settings_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsRepository _repo = SettingsRepository();

  bool _notificationsEnabled = true;
  String _theme = 'light';
  String _language = 'ja';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Firestoreから設定を読み込む
  void _loadSettings() async {
    await _repo.signInAnonymously(); // 匿名ログイン
    final settings = await _repo.loadSettings();
    if (settings != null) {
      setState(() {
        _notificationsEnabled = settings.notificationsEnabled;
        _theme = settings.theme;
        _language = settings.language;
      });
    }
  }

  /// Firestoreに設定を保存
  void _saveSettings() async {
    final settings = SettingsModel(
      notificationsEnabled: _notificationsEnabled,
      theme: _theme,
      language: _language,
    );
    await _repo.saveSettings(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          // 通知ON/OFF
          SwitchListTile(
            title: const Text('通知'),
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
              _saveSettings();
              // TODO: Firebase Messaging購読制御もここで
            },
          ),

          // テーマ選択
          ListTile(
            title: const Text('テーマ'),
            trailing: DropdownButton<String>(
              value: _theme,
              items: const [
                DropdownMenuItem(value: 'light', child: Text('ライト')),
                DropdownMenuItem(value: 'dark', child: Text('ダーク')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _theme = val);
                  _saveSettings();
                  // TODO: アプリ全体テーマ切替はProviderなどで実装可能
                }
              },
            ),
          ),

          // 言語選択
          ListTile(
            title: const Text('言語'),
            trailing: DropdownButton<String>(
              value: _language,
              items: const [
                DropdownMenuItem(value: 'ja', child: Text('日本語')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _language = val);
                  _saveSettings();
                  // TODO: アプリ全体言語切替
                }
              },
            ),
          ),

          // 規約表示
          const ListTile(
            title: Text('規約'),
            subtitle: Text('利用規約やプライバシーポリシーをここに表示'),
          ),

          // バージョン表示
          const ListTile(
            title: Text('バージョン'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
