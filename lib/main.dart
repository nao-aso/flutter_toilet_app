import 'package:flutter/material.dart';
import 'app/app.dart';

void main() {
  // Firebase を後で入れるなら、ここに initialize を追加します
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ToiletApp());
}
