// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Toilet Congestion App';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get languageSetting => 'Language Setting';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageEnglish => 'English';

  @override
  String get restartRequired => 'Restart Required';

  @override
  String get restartDescription => 'Please restart the app to apply language changes.';

  @override
  String get ok => 'OK';

  @override
  String get homeTitle => 'Building 1 - Toilet Status';

  @override
  String get crowdTitle => 'toilet';

  @override
  String get waitingNotification => 'Notify Me';

  @override
  String get toiletAvailable => 'Toilet is available';

  @override
  String floorAvailable(Object floor) {
    return '$floor is available.';
  }

  @override
  String get termsTitle => 'Terms of Service';

  @override
  String get termsBody => 'Please read the following terms carefully before using this app.\n\n1. We are not responsible for any damages.\n2. Usage data may be collected to improve the service.\n3. You must not misuse this application.\n\nBy checking the box below, you agree to these terms.';

  @override
  String get agreeTerms => 'I agree to the Terms of Service';

  @override
  String get continueLabel => 'Continue';

  @override
  String get termsShortcutDescription => 'Open terms of service';

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get maleCrowdTitle => 'Men\'s';

  @override
  String get femaleCrowdTitle => 'Women\'s';

  @override
  String get waitingNotificationTitle => 'Waiting Notification Set';

  @override
  String get waitingNotificationDescription => 'You will be notified when a stall becomes available.';

  @override
  String get noData => 'No data available';

  @override
  String get errorTitle => 'Feature Restricted';

  @override
  String get femaleCrowdDisabledMessage => 'Cannot move to the women\'s congestion screen at this time.';

  @override
  String get femaleAnalyticsDisabledMessage => 'Cannot move to the women\'s analytics screen at this time.';

  @override
  String get refreshData => 'Reload Data';

  @override
  String get selectPeriod => 'Select Period';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get floor => 'Floor';

  @override
  String get usageCount => 'Usage Count';

  @override
  String get totalUsageTime => 'Duration';

  @override
  String get totalTime => 'Total Time';

  @override
  String get ranking => 'Rank';

  @override
  String dailyHistory(Object day) {
    return 'Usage History for $day';
  }

  @override
  String periodHistory(Object range) {
    return 'Usage History for $range';
  }

  @override
  String rankingDay(Object day) {
    return 'Ranking for $day';
  }

  @override
  String rankingDateRange(Object start, Object end) {
    return 'Ranking from $start to $end';
  }

  @override
  String getDailyDetailTitle(Object day) {
    return 'Details for $day';
  }

  @override
  String countUnit(Object count) {
    return '$count times';
  }

  @override
  String rankingUnit(Object rank) {
    return 'Rank $rank';
  }
}
