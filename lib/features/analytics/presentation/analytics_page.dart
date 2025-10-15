import 'package:flutter/material.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int? selectedDayIndex; // 選択された日のインデックス

  // 日ごとのダミーデータ（実際はFirestoreから取得）
  final Map<int, List<Map<String, dynamic>>> dailyData = {
    0: [
      {'floor': '7F', 'count': 5, 'time': '3h 20m'},
      {'floor': '5F', 'count': 4, 'time': '2h 40m'},
      {'floor': '3F', 'count': 3, 'time': '2h 00m'},
    ],
    1: [
      {'floor': '6F', 'count': 6, 'time': '4h 00m'},
      {'floor': '4F', 'count': 5, 'time': '3h 20m'},
      {'floor': '2F', 'count': 2, 'time': '1h 20m'},
    ],
    2: [
      {'floor': '7F', 'count': 8, 'time': '5h 20m'},
      {'floor': '5F', 'count': 7, 'time': '4h 40m'},
      {'floor': '1F', 'count': 3, 'time': '2h 00m'},
    ],
    3: [
      {'floor': '6F', 'count': 4, 'time': '2h 40m'},
      {'floor': '4F', 'count': 3, 'time': '2h 00m'},
      {'floor': '2F', 'count': 2, 'time': '1h 20m'},
    ],
    4: [
      {'floor': '5F', 'count': 2, 'time': '1h 20m'},
      {'floor': '3F', 'count': 2, 'time': '1h 20m'},
      {'floor': '1F', 'count': 1, 'time': '0h 40m'},
    ],
    5: [
      {'floor': '7F', 'count': 3, 'time': '2h 00m'},
      {'floor': '4F', 'count': 2, 'time': '1h 20m'},
      {'floor': '2F', 'count': 1, 'time': '0h 40m'},
    ],
    6: [
      {'floor': '6F', 'count': 1, 'time': '0h 40m'},
      {'floor': '5F', 'count': 1, 'time': '0h 40m'},
      {'floor': '3F', 'count': 1, 'time': '0h 40m'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.now().subtract(const Duration(days: 6));
    final endDate = DateTime.now();
    final days = List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      return '${date.month}/${date.day}';
    });

    String formatDateRange() {
      if (startDate.year == endDate.year) {
        return '${startDate.year}/${startDate.month}/${startDate.day} 〜 ${endDate.month}/${endDate.day}';
      } else {
        return '${startDate.year}/${startDate.month}/${startDate.day} 〜 ${endDate.year}/${endDate.month}/${endDate.day}';
      }
    }

    final counts = [21, 18, 25, 12, 6, 7, 3];

    // 全期間のランキングデータ
    final allPeriodRanking = [
      {'floor': '7F', 'count': 21, 'time': '14h 00m'},
      {'floor': '6F', 'count': 18, 'time': '12h 10m'},
      {'floor': '5F', 'count': 15, 'time': '10h 20m'},
      {'floor': '4F', 'count': 14, 'time': '9h 20m'},
      {'floor': '3F', 'count': 12, 'time': '8h 00m'},
      {'floor': '2F', 'count': 10, 'time': '6h 40m'},
      {'floor': '1F', 'count': 8, 'time': '5h 20m'},
    ];

    // 表示するランキングデータを選択
    final displayRanking = selectedDayIndex != null
        ? dailyData[selectedDayIndex]!
        : allPeriodRanking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('データ集計'),
        actions: [
          if (selectedDayIndex != null)
            TextButton(
              onPressed: () {
                setState(() {
                  selectedDayIndex = null;
                });
              },
              child: const Text('全期間に戻る', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text(
            selectedDayIndex != null
                ? days[selectedDayIndex!]
                : formatDateRange(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          // 簡易バー
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(counts.length, (i) {
                final isSelected = selectedDayIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        // 同じ日を再度タップしたら選択解除して週データに戻る
                        if (selectedDayIndex == i) {
                          selectedDayIndex = null;
                        } else {
                          selectedDayIndex = i;
                        }
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 22,
                              height: (counts[i] * 4).toDouble(),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.orange : Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                                border: isSelected
                                    ? Border.all(color: Colors.orangeAccent, width: 2)
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          days[i],
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.orange : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            selectedDayIndex != null
                ? '${days[selectedDayIndex!]} のランキング'
                : 'ランキング（全期間）',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: DataTable(
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('階')),
                DataColumn(label: Text('使用回数')),
                DataColumn(label: Text('累計使用時間')),
                DataColumn(label: Text('ランキング')),
              ],
              rows: List.generate(displayRanking.length, (index) {
                final data = displayRanking[index];
                return DataRow(
                  cells: [
                    DataCell(Text(data['floor'].toString())),
                    DataCell(Text('${data['count']}回')),
                    DataCell(Text(data['time'].toString())),
                    DataCell(Text('${index + 1}位')),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}