// import 'package:flutter/material.dart';
//
// class LanguageProvider extends ChangeNotifier {
//   Locale _locale = const Locale('ja');
//
//   Locale get locale => _locale;
//
//   void setLocale(Locale locale) {
//     _locale = locale;
//     notifyListeners();   // ← これで MaterialApp が再描画される
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ★追加

class LanguageProvider extends ChangeNotifier {
  // ★キー定義
  static const String _languageKey = 'app_language_code';

  Locale _locale = const Locale('ja');

  Locale get locale => _locale;

  // ★修正: コンストラクタで初期値を読み込む
  LanguageProvider() {
    _loadLocale();
  }

  // ★追加: ロケールの読み込み
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);

    if (languageCode != null) {
      _locale = Locale(languageCode);
    } else {
      // 読み込みに失敗または初回の場合は、デフォルトの'ja'を使用
      _locale = const Locale('ja');
    }
    notifyListeners(); // 読み込み完了を通知
  }

  // ★修正: 言語変更時に保存処理を追加
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _saveLocale(locale); // 保存を呼び出す
    notifyListeners();   // ← これで MaterialApp が再描画される
  }

  // ★追加: ロケールの保存
  Future<void> _saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
  }
}