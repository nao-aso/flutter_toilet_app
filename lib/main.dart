import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'shared/widgets/bottom_nav_scaffold.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FlutterLocalNotificationsPlugin localNotifications =
FlutterLocalNotificationsPlugin();

Future<void> _initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: android);
  await localNotifications.initialize(initSettings);
  await FirebaseMessaging.instance.requestPermission();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _initLocalNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'トイレ混雑モニター',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const BottomNavScaffold(),
    );
  }
Future<void> main() async {
  // Firebase を後で入れるなら、ここに initialize を追加します
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null);
  runApp(const ToiletApp());
}
