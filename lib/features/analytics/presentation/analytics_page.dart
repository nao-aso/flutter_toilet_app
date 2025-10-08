import 'package:flutter/material.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ダミーの棒グラフ風データ。後で集計データ読取に置換
    final days = ['25日', '26日', '27日', '28日', '29日'];
    final counts = [21, 18, 25, 12, 6];

    return Scaffold(
      appBar: AppBar(title: const Text('データ集計')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text('直近5日', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          // 簡易バー（最初はContainerで。後で fl_chart 等に差し替え）
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(counts.length, (i) {
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 22,
                            height: (counts[i] * 4).toDouble(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(days[i]),
                    ],
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Text('ランキング（ダミー）', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('階')),
                DataColumn(label: Text('使用回数')),
                DataColumn(label: Text('累計使用時間')),
              ],
              rows: const [
                DataRow(cells: [DataCell(Text('7F')), DataCell(Text('21回')), DataCell(Text('14h 00m'))]),
                DataRow(cells: [DataCell(Text('6F')), DataCell(Text('18回')), DataCell(Text('12h 10m'))]),
                DataRow(cells: [DataCell(Text('5F')), DataCell(Text('15回')), DataCell(Text('10h 20m'))]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
