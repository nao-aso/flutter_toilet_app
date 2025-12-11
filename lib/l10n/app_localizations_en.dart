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
    return 'A stall is now available on $floor.';
  }

  @override
  String get analyticsTitle => 'Analytics';

  @override
  String get selectPeriod => 'Select period';

  @override
  String get floorLabel => 'Floor';

  @override
  String get usageCountLabel => 'Usage Count';

  @override
  String get rankLabel => 'Rank';

  @override
  String get rankSuffix => 'th';

  @override
  String get noData => 'No data available';

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
}
