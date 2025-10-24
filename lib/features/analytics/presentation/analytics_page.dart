import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int? selectedDayIndex; // 選択された日のインデックス
  DateTimeRange? selectedDateRange; // カレンダーで選択された期間
  final DateFormat dateFormat = DateFormat('yyyy年MM月dd日');

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

  // カレンダーで期間選択したときのダミーデータ
  final List<Map<String, dynamic>> customRangeData = [
    {'floor': '7F', 'count': 15, 'time': '10h 00m'},
    {'floor': '5F', 'count': 12, 'time': '8h 00m'},
    {'floor': '3F', 'count': 10, 'time': '6h 40m'},
    {'floor': '2F', 'count': 8, 'time': '5h 20m'},
  ];

  Future<void> _pickDateRange(BuildContext context) async {
    final result = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) => const CustomDateRangePicker(),
    );

    if (result != null) {
      setState(() {
        selectedDateRange = result;
        selectedDayIndex = null; // バーグラフの選択をクリア
      });
    }
  }

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
    final displayRanking = selectedDateRange != null
        ? customRangeData
        : (selectedDayIndex != null
        ? dailyData[selectedDayIndex]!
        : allPeriodRanking);

    // ランキングタイトルの表示テキスト
    String getRankingTitle() {
      if (selectedDateRange != null) {
        return '${dateFormat.format(selectedDateRange!.start)} 〜 ${dateFormat.format(selectedDateRange!.end)} のランキング';
      } else if (selectedDayIndex != null) {
        return '${days[selectedDayIndex!]} のランキング';
      } else {
        return 'ランキング（全期間）';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('データ集計'),
        actions: [
          if (selectedDayIndex != null || selectedDateRange != null)
            TextButton(
              onPressed: () {
                setState(() {
                  selectedDayIndex = null;
                  selectedDateRange = null;
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
                        selectedDateRange = null; // カレンダー選択をクリア
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
          // タップ可能なランキングタイトル
          GestureDetector(
            onTap: () => _pickDateRange(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: selectedDateRange != null
                    ? Colors.blue.shade50
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedDateRange != null
                      ? Colors.blue
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: selectedDateRange != null
                        ? Colors.blue
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      getRankingTitle(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: selectedDateRange != null
                            ? Colors.blue.shade700
                            : null,
                        fontWeight: selectedDateRange != null
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: selectedDateRange != null
                        ? Colors.blue
                        : Colors.grey.shade600,
                  ),
                ],
              ),
            ),
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

// カスタム期間選択カレンダー
class CustomDateRangePicker extends StatefulWidget {
  const CustomDateRangePicker({Key? key}) : super(key: key);

  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime _focusedDay = DateTime.now();
  final DateFormat dateFormat = DateFormat('yyyy年MM月dd日');

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '期間を選択',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_rangeStart != null || _rangeEnd != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _rangeStart != null
                            ? dateFormat.format(_rangeStart!)
                            : '開始日',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('〜'),
                      const SizedBox(width: 8),
                      Text(
                        _rangeEnd != null
                            ? dateFormat.format(_rangeEnd!)
                            : '終了日',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              TableCalendar(
                firstDay: DateTime(DateTime
                    .now()
                    .year - 3),
                lastDay: DateTime.now(),
                focusedDay: _focusedDay,
                locale: 'ja_JP',
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                rangeSelectionMode: RangeSelectionMode.toggledOn,
                onDaySelected: (selectedDay, focusedDay) {
                  if (selectedDay.isAfter(DateTime.now())) return;

                  setState(() {
                    _focusedDay = focusedDay;
                    if (_rangeStart == null || _rangeEnd != null) {
                      // 新しい範囲を開始
                      _rangeStart = selectedDay;
                      _rangeEnd = null;
                    } else if (selectedDay.isBefore(_rangeStart!)) {
                      // 選択した日が開始日より前なら、開始日を更新
                      _rangeStart = selectedDay;
                    } else {
                      // 終了日を選択したら自動的に確定
                      _rangeEnd = selectedDay;
                      Navigator.pop(
                        context,
                        DateTimeRange(start: _rangeStart!, end: _rangeEnd!),
                      );
                    }
                  });
                },
                calendarStyle: CalendarStyle(
                  rangeStartDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  rangeEndDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  rangeHighlightColor: Colors.blue.shade100,
                  todayDecoration: BoxDecoration(
                    color: Colors.orange.shade300,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}