
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../main.dart'; // localNotifications を使用

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, bool> waitingFloors = {};

  Future<void> _showLocalNotification(String floor) async {
    const androidDetails = AndroidNotificationDetails(
      'toilet_channel',
      '待ち通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await localNotifications.show(
      0,
      'トイレが空きました',
      '$floor に空きが出ました。',
      notificationDetails,
    );
  }

  void _startWaiting(String floor) {
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
        _showLocalNotification(floor);
        waitingFloors[floor] = false;
      }
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('待ち通知を設定しました'),
        content: const Text('空きが出た際に通知でお知らせします。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('1号館 - トイレ混雑表示'),
        centerTitle: true,

      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('toilets').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('データがありません'));
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
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
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
                          backgroundColor:
                          isFull ? Colors.white : Colors.grey.shade300,
                          side: BorderSide(
                            color: isFull
                                ? Colors.grey.shade400
                                : Colors.grey.shade300,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                        ),
                        onPressed:
                        isFull ? () => _startWaiting(floor) : null,
                        child: Text(
                          '待ち通知',
                          style: TextStyle(
                            color:
                            isFull ? Colors.black : Colors.grey.shade600,
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
