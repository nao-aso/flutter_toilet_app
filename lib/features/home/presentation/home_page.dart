import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ★ 多言語（正しいパス）
import '../../../l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, bool> waitingFloors = {};

  Future<void> _showLocalNotification(String floor, AppLocalizations loc) async {
    const androidDetails = AndroidNotificationDetails(
      'toilet_channel',
      '待ち通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await localNotifications.show(
      0,
      loc.toiletAvailable, // トイレが空きました
      loc.floorAvailable(floor), // {floor} に空きが出ました
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
      final inUse =
          snapshot.docs.where((doc) => doc['door_status'] == 'closed').length;

      if (inUse < total && (waitingFloors[floor] ?? false)) {
        _showLocalNotification(floor, loc);
        waitingFloors[floor] = false;
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.waitingNotification),
        content: Text(loc.toiletAvailable),
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
        title: Text(loc.homeTitle), // ← 多言語化 OK
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
            final floor = doc['floor'] ?? '???';
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // フロア名
                      Text(
                        floor,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                      // 使用数
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
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      // 待ち通知
                      ElevatedButton(
                        onPressed:
                        isFull ? () => _startWaiting(floor, loc) : null,
                        child: Text(loc.waitingNotification),
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
