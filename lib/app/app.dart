import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../shared/widgets/bottom_nav_scaffold.dart';

class ToiletApp extends StatelessWidget {
  const ToiletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toilet Monitor',
      locale: const Locale('ja', 'JP'), // 日本語ロケール指定
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
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
