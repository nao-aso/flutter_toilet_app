import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int? selectedDayIndex;
  DateTimeRange? selectedDateRange;
  final DateFormat dateFormat = DateFormat('yyyy年MM月dd日');

  List<Map<String, dynamic>> allUsageLogs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsageLogs();
  }

  // Firestoreからデータ取得
  Future<void> _fetchUsageLogs() async {
    setState(() {
      isLoading = true;
    });

    try {
      final db = FirebaseFirestore.instance;
      final snapshot = await db
          .collection('usage_logs')
          .orderBy('created_at', descending: true)
          .get();

      List<Map<String, dynamic>> logs = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        logs.add({
          'id': doc.id,
          'floor': data['floor'] ?? '',
          'toilet_id': data['toilet_id'] ?? '',
          'duration_sec': (data['duration_sec'] ?? 0.0).toDouble(),
          'start_time': (data['start_time'] as Timestamp?)?.toDate(),
          'end_time': (data['end_time'] as Timestamp?)?.toDate(),
          'created_at': (data['created_at'] as Timestamp?)?.toDate(),
        });
      }

      setState(() {
        allUsageLogs = logs;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 期間でフィルタリングされたデータを取得
  List<Map<String, dynamic>> _getFilteredLogs() {
    if (selectedDateRange != null) {
      return allUsageLogs.where((log) {
        final createdAt = log['created_at'] as DateTime?;
        if (createdAt == null) return false;
        final startOfDay = DateTime(selectedDateRange!.start.year,
            selectedDateRange!.start.month, selectedDateRange!.start.day);
        final endOfDay = DateTime(selectedDateRange!.end.year,
            selectedDateRange!.end.month, selectedDateRange!.end.day, 23, 59, 59);
        return createdAt.isAfter(startOfDay) && createdAt.isBefore(endOfDay);
      }).toList();
    } else if (selectedDayIndex != null) {
      final targetDate = DateTime.now().subtract(Duration(days: 6 - selectedDayIndex!));
      return allUsageLogs.where((log) {
        final createdAt = log['created_at'] as DateTime?;
        if (createdAt == null) return false;
        return createdAt.year == targetDate.year &&
            createdAt.month == targetDate.month &&
            createdAt.day == targetDate.day;
      }).toList();
    } else {
      // 過去7日間のデータ
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 6));
      final startOfDay = DateTime(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day);
      return allUsageLogs.where((log) {
        final createdAt = log['created_at'] as DateTime?;
        if (createdAt == null) return false;
        return createdAt.isAfter(startOfDay);
      }).toList();
    }
  }

  // 階ごとのランキングデータを生成
  List<Map<String, dynamic>> _generateRanking() {
    final filteredLogs = _getFilteredLogs();

    if (filteredLogs.isEmpty) {
      return [];
    }

    // 階ごとに集計
    Map<String, Map<String, dynamic>> floorStats = {};

    for (var log in filteredLogs) {
      final floor = log['floor'] as String;
      final duration = log['duration_sec'] as double;

      if (!floorStats.containsKey(floor)) {
        floorStats[floor] = {
          'floor': floor,
          'count': 0,
          'total_duration': 0.0,
        };
      }

      floorStats[floor]!['count'] = (floorStats[floor]!['count'] as int) + 1;
      floorStats[floor]!['total_duration'] =
          (floorStats[floor]!['total_duration'] as double) + duration;
    }

    // ランキング用のリストに変換
    List<Map<String, dynamic>> ranking = floorStats.values.map((stats) {
      final totalSeconds = stats['total_duration'] as double;
      final hours = (totalSeconds / 3600).floor();
      final minutes = ((totalSeconds % 3600) / 60).floor();

      return {
        'floor': stats['floor'],
        'count': stats['count'],
        'time': '${hours}h ${minutes}m',
      };
    }).toList();

    // 使用回数でソート
    ranking.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    return ranking;
  }

  // 日ごとの使用回数を取得（バーグラフ用）
  List<int> _getDailyCounts() {
    List<int> counts = List.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      final targetDate = DateTime.now().subtract(Duration(days: 6 - i));
      final count = allUsageLogs.where((log) {
        final createdAt = log['created_at'] as DateTime?;
        if (createdAt == null) return false;
        return createdAt.year == targetDate.year &&
            createdAt.month == targetDate.month &&
            createdAt.day == targetDate.day;
      }).length;
      counts[i] = count;
    }

    return counts;
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final result = await showDialog<DateTimeRange>(
      context: context,
      builder: (context) => const CustomDateRangePicker(),
    );

    if (result != null) {
      setState(() {
        selectedDateRange = result;
        selectedDayIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('データ集計'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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

    final counts = _getDailyCounts();
    final displayRanking = _generateRanking();

    String getRankingTitle() {
      if (selectedDateRange != null) {
        return '${dateFormat.format(selectedDateRange!.start)} 〜 ${dateFormat.format(selectedDateRange!.end)} のランキング';
      } else if (selectedDayIndex != null) {
        return '${days[selectedDayIndex!]} のランキング';
      } else {
        return '期間を選択';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('データ集計'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsageLogs,
            tooltip: 'データを再読み込み',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchUsageLogs,
        child: ListView(
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
                  final maxCount = counts.reduce((a, b) => a > b ? a : b);
                  final barHeight = maxCount > 0
                      ? (counts[i] / maxCount * 120).clamp(8.0, 120.0)
                      : 8.0;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDateRange = null;
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
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.orange : Colors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                  border: isSelected
                                      ? Border.all(color: Colors.orangeAccent, width: 2)
                                      : null,
                                ),
                                child: Center(
                                  child: counts[i] > 0
                                      ? Text(
                                    '${counts[i]}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
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
                              fontSize: 12,
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
            if (displayRanking.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'データがありません',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
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
      ),
    );
  }
}

// カスタム期間選択カレンダー
class CustomDateRangePicker extends StatefulWidget {
  const CustomDateRangePicker({super.key});

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
                firstDay: DateTime(DateTime.now().year - 3),
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
                      _rangeStart = selectedDay;
                      _rangeEnd = null;
                    } else if (selectedDay.isBefore(_rangeStart!)) {
                      _rangeStart = selectedDay;
                    } else {
                      _rangeEnd = selectedDay;
                      Navigator.pop(
                        context,
                        DateTimeRange(start: _rangeStart!, end: _rangeEnd!),
                      );
                    }
                  });
                },
                calendarStyle: CalendarStyle(
                  rangeStartDecoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  rangeEndDecoration: const BoxDecoration(
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