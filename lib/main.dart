// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
//
// import 'package:provider/provider.dart';
// import 'shared/theme/theme_provider.dart';
// import 'shared/language/language_provider.dart';
//
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// // ★ 多言語化
// import 'package:flutter_toilet_app/l10n/app_localizations.dart';
//
// import 'shared/widgets/bottom_nav_scaffold.dart';
//
// import 'features/terms/terms_page.dart';
//
//
// // 🔔 ローカル通知
// final FlutterLocalNotificationsPlugin localNotifications =
// FlutterLocalNotificationsPlugin();
//
// // 🚨 修正: アプリ全体でナビゲーターのコンテキストにアクセスするためのGlobalKey
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   // 🔔 Local Notifications: iOS/Android の設定を追加 (ここを修正)
//   const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//
//   // iOS/macOS 向けの設定を追加
//   const initializationSettingsDarwin = DarwinInitializationSettings(
//     requestAlertPermission: true,
//     requestBadgePermission: true,
//     requestSoundPermission: true,
//   );
//
//   final initSettings = InitializationSettings(
//     android: android,
//     iOS: initializationSettingsDarwin, // iOS向けの設定を追加
//     macOS: initializationSettingsDarwin, // macOS向けの設定も追加
//   );
//
//   await localNotifications.initialize(initSettings);
//
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ThemeProvider()),
//         ChangeNotifierProvider(create: (_) => LanguageProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final languageProvider = Provider.of<LanguageProvider>(context);
//
//     return MaterialApp(
//       // 🚨 修正: Global KeyをMaterialAppに適用
//       navigatorKey: navigatorKey,
//
//       debugShowCheckedModeBanner: false,
//
//       // ★ 言語切り替え
//       locale: languageProvider.locale,
//
//       // ★ AppLocalizations が提供してくれる設定を使用
//       localizationsDelegates: AppLocalizations.localizationsDelegates,
//       supportedLocales: AppLocalizations.supportedLocales,
//
//       themeMode: themeProvider.themeMode,
//       theme: ThemeData.light(),
//       darkTheme: ThemeData.dark(),
//
//       home: const TermsPage(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';
import 'shared/theme/theme_provider.dart';
import 'shared/language/language_provider.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ★追加: データの永続化用

// ★ 多言語化
import 'package:flutter_toilet_app/l10n/app_localizations.dart';

import 'shared/widgets/bottom_nav_scaffold.dart';

import 'features/terms/terms_page.dart';


// 🔔 ローカル通知
final FlutterLocalNotificationsPlugin localNotifications =
FlutterLocalNotificationsPlugin();

// 🚨 修正: アプリ全体でナビゲーターのコンテキストにアクセスするためのGlobalKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// ★追加: 利用規約の同意フラグを保存するためのキー
const String _termsAgreedKey = 'terms_agreed';

// ★修正: main 関数を async にし、同意フラグを読み込む
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ★追加: 同意フラグの読み込み
  final prefs = await SharedPreferences.getInstance();
  final hasAgreedToTerms = prefs.getBool(_termsAgreedKey) ?? false;

  // 🔔 Local Notifications: iOS/Android の設定を追加 (ここを修正)
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS/macOS 向けの設定を追加
  const initializationSettingsDarwin = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  final initSettings = InitializationSettings(
    android: android,
    iOS: initializationSettingsDarwin, // iOS向けの設定を追加
    macOS: initializationSettingsDarwin, // macOS向けの設定も追加
  );

  await localNotifications.initialize(initSettings);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      // ★修正: MyAppに同意フラグを渡す
      child: MyApp(hasAgreedToTerms: hasAgreedToTerms),
    ),
  );
}

class MyApp extends StatelessWidget {
  // ★追加: 同意フラグを受け取るプロパティ
  final bool hasAgreedToTerms;
  const MyApp({super.key, required this.hasAgreedToTerms});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      // 🚨 修正: Global KeyをMaterialAppに適用
      navigatorKey: navigatorKey,

      debugShowCheckedModeBanner: false,

      // ★ 言語切り替え
      locale: languageProvider.locale,

      // ★ AppLocalizations が提供してくれる設定を使用
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),

      // ★修正: フラグに基づいて表示する最初の画面を切り替える
      home: hasAgreedToTerms
          ? const BottomNavScaffold() // 同意済みならホーム画面
          : const TermsPage(),        // 未同意なら利用規約画面
    );
  }
}