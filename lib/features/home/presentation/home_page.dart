import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // まずはダミーデータ。後で Firebase の読み取りに置き換える想定
  static const floors = [
    ('7F', 2, 2),
    ('6F', 1, 2),
    ('5F', 0, 2),
    ('4F', 2, 2),
    ('3F', 0, 2),
    ('2F', 0, 2),
    ('1F', 1, 2),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('混雑一覧')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: floors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final (label, occupied, total) = floors[i];
          final full = occupied >= total;
          return Card(
            child: ListTile(
              leading: Icon(
                full ? Icons.stop_circle : Icons.check_circle,
                color: full ? Colors.red : Colors.green,
              ),
              title: Text(label),
              subtitle: Text('$occupied / $total'),
              trailing: FilledButton.tonal(
                onPressed: () {
                  // 待ち通知（後で FCM の subscribe に差し替え）
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('通知をセット（ダミー）')),
                  );
                },
                child: const Text('待ち通知'),
              ),
            ),
          );
        },
      ),
    );
  }
}
