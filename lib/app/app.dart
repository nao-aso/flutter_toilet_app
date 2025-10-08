import 'package:flutter/material.dart';
import '../shared/widgets/bottom_nav_scaffold.dart';

class ToiletApp extends StatelessWidget {
  const ToiletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toilet Monitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const BottomNavScaffold(

      ), // 画面の“合体”はここで行う
    );
  }
}
