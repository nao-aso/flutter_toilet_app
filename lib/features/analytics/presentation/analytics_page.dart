import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../l10n/app_localizations.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  int? selectedDayIndex;
  DateTimeRange? selectedDateRange;

  // DateFormatはロケールに合わせて後で初期化または取得
  DateFormat get dateFormat => DateFormat('yyyy/MM/dd');

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
          // FirestoreのTimestampをDateTimeに変換 (+9時間の簡易補正)
          'start_time': (data['start_time'] as Timestamp?)?.toDate().add(const Duration(hours: 9)),
          'end_time': (data['end_time'] as Timestamp?)?.toDate().add(const Duration(hours: 9)),
          'created_at': (data['created_at'] as Timestamp?)?.toDate().add(const Duration(hours: 9)),
        });
      }

      if (mounted) {
        setState(() {
          allUsageLogs = logs;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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

    // 累計使用時間でソート
    ranking.sort((a, b) {
      final aDuration = floorStats[a['floor']]!['total_duration'] as double;
      final bDuration = floorStats[b['floor']]!['total_duration'] as double;
      return bDuration.compareTo(aDuration);
    });

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

  Future<void> _showDayDetailDialog(BuildContext context, int dayIndex, String dayLabel) async {
    final loc = AppLocalizations.of(context)!;
    final targetDate = DateTime.now().subtract(Duration(days: 6 - dayIndex));
    final dayLogs = allUsageLogs.where((log) {
      final createdAt = log['created_at'] as DateTime?;
      if (createdAt == null) return false;
      return createdAt.year == targetDate.year &&
          createdAt.month == targetDate.month &&
          createdAt.day == targetDate.day;
    }).toList();

    // 階ごとに集計
    Map<String, Map<String, dynamic>> floorStats = {};
    for (var log in dayLogs) {
      final floor = log['floor'] as String;
      final duration = log['duration_sec'] as double;

      if (!floorStats.containsKey(floor)) {
        floorStats[floor] = {'floor': floor, 'count': 0, 'total_duration': 0.0};
      }

      floorStats[floor]!['count'] = (floorStats[floor]!['count'] as int) + 1;
      floorStats[floor]!['total_duration'] =
          (floorStats[floor]!['total_duration'] as double) + duration;
    }

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

    ranking.sort((a, b) {
      final aDuration = floorStats[a['floor']]!['total_duration'] as double;
      final bDuration = floorStats[b['floor']]!['total_duration'] as double;
      return bDuration.compareTo(aDuration);
    });

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.getDailyDetailTitle(dayLabel),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (ranking.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(loc.noData),
                )
              else
                SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 20,
                    columns: [
                      DataColumn(label: Text(loc.floor)),
                      DataColumn(label: Text(loc.usageCount)),
                      DataColumn(label: Text(loc.totalTime)),
                      DataColumn(label: Text(loc.ranking)),
                    ],
                    rows: List.generate(ranking.length, (index) {
                      final data = ranking[index];
                      return DataRow(
                        cells: [
                          DataCell(Text(data['floor'].toString())),
                          DataCell(Text(loc.countUnit(data['count']))),
                          DataCell(Text(data['time'].toString())),
                          DataCell(Text(loc.rankingUnit(index + 1))),
                        ],
                      );
                    }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFemaleRestrictedDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.errorTitle),
        content: Text(loc.femaleAnalyticsDisabledMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(loc.analyticsTitle),
          centerTitle: true,
        ),
        body: const Center(
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
        final startStr = dateFormat.format(selectedDateRange!.start);
        final endStr = dateFormat.format(selectedDateRange!.end);
        return loc.rankingDateRange(startStr, endStr);
      } else if (selectedDayIndex != null) {
        return loc.rankingDay(days[selectedDayIndex!]);
      } else {
        return loc.selectPeriod;
      }
    }

    final primaryColor = theme.colorScheme.primary;
    final secondaryColor = theme.colorScheme.secondary;
    final unselectedColor = theme.disabledColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.analyticsTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsageLogs,
            tooltip: loc.refreshData,
          ),
        ],
      ),
      // リストビューに統一し、ヘッダーとしてRowを配置
      body: RefreshIndicator(
        onRefresh: _fetchUsageLogs,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ▼▼▼ タイトルテキストと切り替えボタンを横並びに配置 ▼▼▼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // タイトルテキスト
                Expanded(
                  child: Text(
                    selectedDayIndex != null
                        ? loc.dailyHistory(days[selectedDayIndex!])
                        : loc.periodHistory(formatDateRange()),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 切り替えボタン
                Container(
                  height: 36, // 高さ36
                  width: 140, // 幅140
                  decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: theme.dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                  ),
                  child: Row(
                    children: [
                      // --- 男子トイレボタン (選択中表示) ---
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // 既に男子トイレ画面なので何もしない
                          },
                          customBorder: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(30),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.15),
                              borderRadius: const BorderRadius.horizontal(
                                left: Radius.circular(30),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              FontAwesomeIcons.person,
                              color: theme.colorScheme.primary,
                              size: 18,
                            ),
                          ),
                        ),
                      ),

                      // 区切り線
                      VerticalDivider(
                          width: 1,
                          color: theme.dividerColor,
                          indent: 6,
                          endIndent: 6
                      ),

                      // --- 女子トイレボタン (未選択・ダミー) ---
                      Expanded(
                        child: InkWell(
                          onTap: () => _showFemaleRestrictedDialog(context, loc),
                          customBorder: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(30),
                            ),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(30),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              FontAwesomeIcons.personDress,
                              color: theme.disabledColor,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // ▲▲▲ 追加ここまで ▲▲▲

            const SizedBox(height: 16),

            // 簡易バーグラフ
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

                  final barColor = isSelected ? secondaryColor : primaryColor;
                  final textColor = isSelected ? secondaryColor : theme.textTheme.bodyMedium?.color;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedDateRange = null;
                          if (selectedDayIndex == i) {
                            selectedDayIndex = null;
                          } else {
                            selectedDayIndex = i;
                            _showDayDetailDialog(context, i, days[i]);
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
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(4),
                                  border: isSelected
                                      ? Border.all(color: secondaryColor.withOpacity(0.7), width: 2)
                                      : null,
                                ),
                                child: Center(
                                  child: counts[i] > 0
                                      ? Text(
                                    '${counts[i]}',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
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
                              color: textColor,
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
            // 期間選択ボタン
            GestureDetector(
              onTap: () => _pickDateRange(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: selectedDateRange != null
                      ? theme.colorScheme.primaryContainer.withOpacity(0.2)
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selectedDateRange != null
                        ? primaryColor
                        : theme.dividerColor,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: selectedDateRange != null
                          ? primaryColor
                          : unselectedColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        getRankingTitle(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: selectedDateRange != null ? primaryColor : null,
                          fontWeight: selectedDateRange != null
                              ? FontWeight.bold
                              : null,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: selectedDateRange != null
                          ? primaryColor
                          : unselectedColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ランキングテーブル
            if (displayRanking.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.inbox, size: 64, color: unselectedColor),
                      const SizedBox(height: 16),
                      Text(
                        loc.noData,
                        style: TextStyle(
                          fontSize: 16,
                          color: unselectedColor,
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
                  columns: [
                    DataColumn(label: Text(loc.floor)),
                    DataColumn(label: Text(loc.usageCount)),
                    DataColumn(label: Text(loc.totalUsageTime)),
                    DataColumn(label: Text(loc.ranking)),
                  ],
                  rows: List.generate(displayRanking.length, (index) {
                    final data = displayRanking[index];
                    return DataRow(
                      cells: [
                        DataCell(Text(data['floor'].toString())),
                        DataCell(Text(loc.countUnit(data['count']))),
                        DataCell(Text(data['time'].toString())),
                        DataCell(Text(loc.rankingUnit(index + 1))),
                      ],
                    );
                  }),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// CustomDateRangePickerクラスは変更なしのため省略しますが、ファイルには残してください
class CustomDateRangePicker extends StatefulWidget {
  const CustomDateRangePicker({super.key});

  @override
  State<CustomDateRangePicker> createState() => _CustomDateRangePickerState();
}

class _CustomDateRangePickerState extends State<CustomDateRangePicker> {
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime _focusedDay = DateTime.now();
  final DateFormat dateFormat = DateFormat('yyyy/MM/dd');

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Dialog(
      backgroundColor: theme.dialogBackgroundColor,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.selectPeriod,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    color: theme.colorScheme.primaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _rangeStart != null
                            ? dateFormat.format(_rangeStart!)
                            : loc.startDate,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('〜'),
                      const SizedBox(width: 8),
                      Text(
                        _rangeEnd != null
                            ? dateFormat.format(_rangeEnd!)
                            : loc.endDate,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
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
                locale: loc.localeName,
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
                  rangeStartDecoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  rangeEndDecoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  rangeHighlightColor: primaryColor.withOpacity(0.2),
                  todayDecoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  outsideDaysVisible: false,
                  defaultTextStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
                  weekendTextStyle: TextStyle(color: theme.colorScheme.error),
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