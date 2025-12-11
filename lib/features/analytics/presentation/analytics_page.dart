import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ★ 多言語化：自動生成ではなく自作ファイルを読み込む
import '../../../l10n/app_localizations.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  DateTimeRange? selectedRange;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.analyticsTitle), // ← 多言語化 OK
      ),
      body: Column(
        children: [
          // ─────────────────────────────
          // ① 期間選択 UI
          // ─────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              onTap: () async {
                DateTimeRange? range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );

                if (range != null) {
                  setState(() => selectedRange = range);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range),
                    const SizedBox(width: 12),
                    Text(
                      selectedRange == null
                          ? loc.selectPeriod
                          : "${selectedRange!.start.year}/${selectedRange!.start.month}/${selectedRange!.start.day}"
                          " - "
                          "${selectedRange!.end.year}/${selectedRange!.end.month}/${selectedRange!.end.day}",
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ─────────────────────────────
          // ② Firestore 取得
          // ─────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("toilets_log")
                  .orderBy("timestamp", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text(loc.noData));
                }

                final docs = snapshot.data!.docs;

                // ─────────────────────────────
                // ③ 集計処理
                // ─────────────────────────────
                Map<String, int> usageCount = {};

                for (var doc in docs) {
                  String floor = doc["floor"] ?? "Unknown";

                  if (selectedRange != null) {
                    final timestamp = (doc["timestamp"] as Timestamp).toDate();
                    if (timestamp.isBefore(selectedRange!.start) ||
                        timestamp.isAfter(selectedRange!.end)) {
                      continue;
                    }
                  }

                  usageCount[floor] = (usageCount[floor] ?? 0) + 1;
                }

                final sortedFloors = usageCount.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));

                return Column(
                  children: [
                    // ─────────────────────────────
                    // ④ ヘッダー
                    // ─────────────────────────────
                    Container(
                      color: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          _headerCell(loc.floorLabel),
                          _headerCell(loc.usageCountLabel),
                          _headerCell(loc.rankLabel),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        children: sortedFloors.asMap().entries.map((entry) {
                          int index = entry.key;
                          String floor = entry.value.key;
                          int count = entry.value.value;

                          return Row(
                            children: [
                              _dataCell(floor),
                              _dataCell("$count"),
                              _dataCell("${index + 1}${loc.rankSuffix}"),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────
  // 表のセル Widget
  // ─────────────────────────────
  Widget _headerCell(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _dataCell(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Text(text),
      ),
    );
  }
}
