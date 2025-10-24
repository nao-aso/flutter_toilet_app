import 'package:flutter/material.dart';
import 'app/app.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  // Firebase を後で入れるなら、ここに initialize を追加します
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null);
  runApp(const ToiletApp());
}
