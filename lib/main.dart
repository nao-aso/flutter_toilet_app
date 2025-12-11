import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';
import 'shared/theme/theme_provider.dart';
import 'shared/language/language_provider.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ★ 多言語化（これでOK）
import 'package:flutter_toilet_app/l10n/app_localizations.dart';

import 'shared/widgets/bottom_nav_scaffold.dart';

import 'features/terms/terms_page.dart';


// 🔔 ローカル通知
final FlutterLocalNotificationsPlugin localNotifications =
FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: android);
  await localNotifications.initialize(initSettings);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ★ 言語切り替え
      locale: languageProvider.locale,

      // ★ AppLocalizations が提供してくれる設定を使用
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),

      home: const TermsPage(),
    );
  }
}
