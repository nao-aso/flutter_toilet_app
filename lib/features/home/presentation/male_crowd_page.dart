import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../main.dart'; // localNotifications および navigatorKey を使用
import '../../../l10n/app_localizations.dart';

class MaleCrowdPage extends StatefulWidget {
  const MaleCrowdPage({super.key});

  @override
  State<MaleCrowdPage> createState() => _MaleCrowdPageState();
}

class _MaleCrowdPageState extends State<MaleCrowdPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, bool> waitingFloors = {};

  Future<void> _showLocalNotification(String floor, AppLocalizations loc) async {
    final androidDetails = AndroidNotificationDetails(
      'toilet_channel',
      '${loc.waitingNotification}',
      importance: Importance.high,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await localNotifications.show(
      0,
      // ✅ 修正: 汎用的な通知タイトル loc.toiletAvailable に戻す
      loc.toiletAvailable,
      loc.floorAvailable(floor),
      notificationDetails,
    );
  }

  void _startWaiting(String floor, AppLocalizations loc) {
    waitingFloors[floor] = true;

    _firestore
        .collection('toilets')
        .where('floor', isEqualTo: floor)
        .snapshots()
        .listen((snapshot) {
      final total = snapshot.docs.length;
      final inUse = snapshot.docs
          .where((doc) => doc['door_status'] == 'closed')
          .length;

      if (inUse < total && (waitingFloors[floor] ?? false)) {

        final BuildContext? globalContext = navigatorKey.currentContext;

        if (globalContext != null) {
          showDialog(
            context: globalContext,
            builder: (context) => AlertDialog(
              // ✅ 修正: 汎用的な通知タイトル loc.toiletAvailable に戻す
              title: Text(loc.toiletAvailable),
              content: Text(loc.floorAvailable(floor)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.ok),
                ),
              ],
            ),
          );
        }

        _showLocalNotification(floor, loc);

        waitingFloors[floor] = false;
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.waitingNotificationTitle),
        content: Text(loc.waitingNotificationDescription),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.homeTitle),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('toilets').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text(loc.noData));
          }

          final docs = snapshot.data!.docs;
          final floors = <String, List<QueryDocumentSnapshot>>{};

          for (var doc in docs) {
            final floor = doc['floor'] ?? '不明';
            floors.putIfAbsent(floor, () => []).add(doc);
          }

          final sortedFloors =
          floors.keys.toList()..sort((a, b) => b.compareTo(a));

          return ListView.builder(
            itemCount: sortedFloors.length,
            itemBuilder: (context, index) {
              final floor = sortedFloors[index];
              final toilets = floors[floor]!;
              final total = toilets.length;
              final inUse =
                  toilets.where((d) => d['door_status'] == 'closed').length;
              final isFull = inUse == total;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    // ダークモード対応
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        // ダークモード対応
                        color: Theme.of(context).shadowColor.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 左：フロア名
                      SizedBox(
                        width: 50,
                        child: Text(
                          floor,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // 中央：人アイコンと使用数
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.person,
                            color: isFull ? Colors.red : Colors.green,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$inUse / $total',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // 右：待ち通知ボタン
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          // ダークモード対応
                          backgroundColor:
                          isFull
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          side: BorderSide(
                            // ダークモード対応
                            color: isFull
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade600,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        onPressed:
                        isFull ? () => _startWaiting(floor, loc) : null,
                        child: Text(
                          loc.waitingNotification,
                          style: TextStyle(
                            // ダークモード対応
                            color: isFull
                                ? Theme.of(context).colorScheme.onPrimary
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}