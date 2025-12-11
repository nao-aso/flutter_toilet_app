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
      loc.waitingNotification,
      importance: Importance.high,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await localNotifications.show(
      0,
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

        if (globalContext != null && globalContext.mounted) {
          showDialog(
            context: globalContext,
            builder: (context) => AlertDialog(
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

        if (mounted) {
          setState(() {
            waitingFloors[floor] = false;
          });
        } else {
          waitingFloors[floor] = false;
        }
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

  void _showFemaleRestrictedDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.errorTitle),
        content: Text(loc.femaleCrowdDisabledMessage),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.homeTitle),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- 切り替えボタンエリア (右揃え) ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 36,
                  width: 140,
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
                      Expanded(
                        child: InkWell(
                          onTap: () {},
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
                      VerticalDivider(
                          width: 1,
                          color: theme.dividerColor,
                          indent: 6,
                          endIndent: 6
                      ),
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
          ),

          // --- リスト表示部分 ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                  final floor = doc['floor'] ?? '-';
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
                    final inUse = toilets
                        .where((d) => d['door_status'] == 'closed')
                        .length;
                    final isFull = inUse == total;
                    final isWaiting = waitingFloors[floor] ?? false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.dividerColor),
                          color: theme.cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        // ★★★ ここを修正しました (左寄せ対応) ★★★
                        child: Row(
                          // MainAxisAlignment.spaceBetween を削除
                          children: [
                            // 1. フロア名
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

                            // 2. 余白を追加して位置を調整 (ここで左寄せ具合を調整)
                            const SizedBox(width: 20),

                            // 3. 人アイコンと使用数 (中央にあったものを左へ)
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

                            // 4. スペーサーを入れてボタンを右端に飛ばす
                            const Spacer(),

                            // 5. 待ち通知ボタン (右端)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFull
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                side: BorderSide(
                                  color: isFull
                                      ? theme.colorScheme.primary
                                      : theme.disabledColor,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                disabledForegroundColor: theme.disabledColor,
                              ),
                              onPressed: (isFull && !isWaiting)
                                  ? () => _startWaiting(floor, loc)
                                  : null,
                              child: Text(
                                isWaiting ? '設定済' : loc.waitingNotification,
                                style: TextStyle(
                                  color: isFull
                                      ? theme.colorScheme.onPrimary
                                      : theme.disabledColor,
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
          ),
        ],
      ),
    );
  }
}