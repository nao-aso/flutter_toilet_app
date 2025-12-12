// import 'package:flutter/material.dart';
//
// class ThemeProvider extends ChangeNotifier {
//   // 現在のテーマモードを管理
//   ThemeMode _themeMode = ThemeMode.light;
//
//   ThemeMode get themeMode => _themeMode;
//
//   bool get isDarkMode => _themeMode == ThemeMode.dark;
//
//   // テーマ切り替え
//   void toggleTheme(bool isOn) {
//     _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ★追加

class ThemeProvider extends ChangeNotifier {
  // ★キー定義
  static const String _themeKey = 'theme_mode';

  // 現在のテーマモードを管理
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // ★修正: コンストラクタで初期値を読み込む
  ThemeProvider() {
    _loadThemeMode();
  }

  // ★追加: テーマモードの読み込み
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey);

    if (themeString == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system; // 保存されていない場合はデフォルト
    }
    notifyListeners(); // 読み込み完了を通知
  }

  // ★修正: テーマ切り替え時に保存処理を追加
  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    _saveThemeMode(_themeMode); // 保存を呼び出す
    notifyListeners();
  }

  // ★追加: テーマモードの保存
  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeString;
    if (mode == ThemeMode.light) {
      themeString = 'light';
    } else if (mode == ThemeMode.dark) {
      themeString = 'dark';
    } else {
      themeString = 'system';
    }
    await prefs.setString(_themeKey, themeString);
  }
}