import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        children: [
          _item(context, title: 'テーマ変更', onTap: () {}),
          _item(context, title: '言語設定', trailing: const Text('日本語  >'), onTap: () {}),
          _item(context, title: '利用規約', onTap: () {}),
          const Divider(height: 24),
          const ListTile(
            title: Text('バージョン'),
            trailing: Text('v0.1.0'),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context,
      {required String title, Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
