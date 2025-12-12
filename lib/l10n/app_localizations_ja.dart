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
  String get crowdTitle => 'トイレ';

  @override
  String get waitingNotification => '待ち通知';

  @override
  String get toiletAvailable => 'トイレが空きました';

  @override
  String floorAvailable(Object floor) {
    return '$floor に空きが出ました。';
  }

  @override
  String get termsTitle => '利用規約';

  @override
  String get termsBody => '【利用規約】\n\n本アプリ（以下「当アプリ」）を利用する前に、以下の規約に同意いただく必要があります。\n\n1. 【情報の正確性について】\n当アプリが提供する混雑状況は、センサーやネットワークの状況により実際の状況と異なる場合があります。あくまで目安としてご利用ください。情報の不備により生じた損害（トイレに間に合わなかった等を含む）について、開発者は責任を負いません。\n\n2. 【データの利用について】\nサービス向上のため、トイレの利用状況（日時、滞在時間、場所）のデータを匿名で収集・分析します。個人を特定する情報は収集しません。\n\n3. 【禁止事項】\nサーバーへの過度なアクセスや、システムの解析・改ざん行為を禁止します。\n\n4. 【サービスの変更・終了】\n当アプリは予告なく機能を変更、またはサービスを終了する場合があります。';

  @override
  String get agreeTerms => '利用規約に同意します';

  @override
  String get continueLabel => '続ける';

  @override
  String get termsShortcutDescription => '利用規約を開く';

  @override
  String get analyticsTitle => '集計';

  @override
  String get maleCrowdTitle => '男子トイレ';

  @override
  String get femaleCrowdTitle => '女子トイレ';

  @override
  String get waitingNotificationTitle => '待ち通知を設定しました';

  @override
  String get waitingNotificationDescription => '空きが出た際に通知でお知らせします。';

  @override
  String get noData => 'データがありません';

  @override
  String get errorTitle => '機能制限';

  @override
  String get femaleCrowdDisabledMessage => '現在女子トイレの混雑表示画面に移動することはできません';

  @override
  String get femaleAnalyticsDisabledMessage => '現在女子トイレの集計画面に移動することはできません';

  @override
  String get refreshData => 'データを再読み込み';

  @override
  String get selectPeriod => '期間を選択';

  @override
  String get startDate => '開始日';

  @override
  String get endDate => '終了日';

  @override
  String get floor => '階';

  @override
  String get usageCount => '使用回数';

  @override
  String get totalUsageTime => '累計使用時間';

  @override
  String get totalTime => '累計時間';

  @override
  String get ranking => 'ランキング';

  @override
  String dailyHistory(Object day) {
    return '$day の使用履歴';
  }

  @override
  String periodHistory(Object range) {
    return '$range の使用履歴';
  }

  @override
  String rankingDay(Object day) {
    return '$day のランキング';
  }

  @override
  String rankingDateRange(Object start, Object end) {
    return '$start 〜 $end のランキング';
  }

  @override
  String getDailyDetailTitle(Object day) {
    return '$day の詳細';
  }

  @override
  String countUnit(Object count) {
    return '$count回';
  }

  @override
  String rankingUnit(Object rank) {
    return '$rank位';
  }
}
