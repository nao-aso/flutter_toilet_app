// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'トイレ混雑アプリ';

  @override
  String get settingsTitle => '設定';

  @override
  String get darkTheme => 'ダークテーマ';

  @override
  String get languageSetting => '言語設定';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageEnglish => 'English';

  @override
  String get restartRequired => '再起動が必要です';

  @override
  String get restartDescription => '言語設定を反映するにはアプリを再起動してください。';

  @override
  String get ok => 'OK';

  @override
  String get homeTitle => '1号館-トイレ混雑表示';

  @override
  String get waitingNotification => '待ち通知';

  @override
  String get toiletAvailable => 'トイレが空きました';

  @override
  String floorAvailable(Object floor) {
    return '$floor に空きが出ました。';
  }

  @override
  String get analyticsTitle => '集計';

  @override
  String get maleCrowdTitle => '男子トイレ';

  @override
  String get femaleCrowdTitle => '女子トイレ';

  @override
  String get maleToilet => '男子トイレが空きました';

  @override
  String get femaleToilet => '女子トイレが空きました';

  @override
  String get waitingNotificationTitle => '待ち通知を設定しました';

  @override
  String get waitingNotificationDescription => '空きが出た際に通知でお知らせします。';

  @override
  String get noData => 'データがありません';
}
