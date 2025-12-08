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
  String get waitingNotification => 'Notify Me';

  @override
  String get toiletAvailable => 'Toilet is available';

  @override
  String floorAvailable(Object floor) {
    return '$floor is available.';
  }

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get maleCrowdTitle => 'Men\'s';

  @override
  String get femaleCrowdTitle => 'Women\'s';

  @override
  String get maleToilet => 'The men\'s toilet is now free.';

  @override
  String get femaleToilet => 'The women\'s toilet is now free.';

  @override
  String get waitingNotificationTitle => 'Waiting Notification Set';

  @override
  String get waitingNotificationDescription => 'You will be notified when a stall becomes available.';

  @override
  String get noData => 'No data available';
}
