import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Toilet Congestion App'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language Setting'**
  String get languageSetting;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @restartRequired.
  ///
  /// In en, this message translates to:
  /// **'Restart Required'**
  String get restartRequired;

  /// No description provided for @restartDescription.
  ///
  /// In en, this message translates to:
  /// **'Please restart the app to apply language changes.'**
  String get restartDescription;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Building 1 - Toilet Status'**
  String get homeTitle;

  /// No description provided for @crowdTitle.
  ///
  /// In en, this message translates to:
  /// **'toilet'**
  String get crowdTitle;

  /// No description provided for @waitingNotification.
  ///
  /// In en, this message translates to:
  /// **'Notify Me'**
  String get waitingNotification;

  /// No description provided for @toiletAvailable.
  ///
  /// In en, this message translates to:
  /// **'Toilet is available'**
  String get toiletAvailable;

  /// No description provided for @floorAvailable.
  ///
  /// In en, this message translates to:
  /// **'{floor} is available.'**
  String floorAvailable(Object floor);

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsTitle;

  /// No description provided for @termsBody.
  ///
  /// In en, this message translates to:
  /// **'Please read the following terms carefully before using this app.\n\n1. We are not responsible for any damages.\n2. Usage data may be collected to improve the service.\n3. You must not misuse this application.\n\nBy checking the box below, you agree to these terms.'**
  String get termsBody;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service'**
  String get agreeTerms;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @termsShortcutDescription.
  ///
  /// In en, this message translates to:
  /// **'Open terms of service'**
  String get termsShortcutDescription;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTitle;

  /// No description provided for @maleCrowdTitle.
  ///
  /// In en, this message translates to:
  /// **'Men\'s'**
  String get maleCrowdTitle;

  /// No description provided for @femaleCrowdTitle.
  ///
  /// In en, this message translates to:
  /// **'Women\'s'**
  String get femaleCrowdTitle;

  /// No description provided for @waitingNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting Notification Set'**
  String get waitingNotificationTitle;

  /// No description provided for @waitingNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'You will be notified when a stall becomes available.'**
  String get waitingNotificationDescription;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Feature Restricted'**
  String get errorTitle;

  /// No description provided for @femaleCrowdDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Cannot move to the women\'s congestion screen at this time.'**
  String get femaleCrowdDisabledMessage;

  /// No description provided for @femaleAnalyticsDisabledMessage.
  ///
  /// In en, this message translates to:
  /// **'Cannot move to the women\'s analytics screen at this time.'**
  String get femaleAnalyticsDisabledMessage;

  /// No description provided for @refreshData.
  ///
  /// In en, this message translates to:
  /// **'Reload Data'**
  String get refreshData;

  /// No description provided for @selectPeriod.
  ///
  /// In en, this message translates to:
  /// **'Select Period'**
  String get selectPeriod;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @floor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get floor;

  /// No description provided for @usageCount.
  ///
  /// In en, this message translates to:
  /// **'Usage Count'**
  String get usageCount;

  /// No description provided for @totalUsageTime.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get totalUsageTime;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @ranking.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get ranking;

  /// No description provided for @dailyHistory.
  ///
  /// In en, this message translates to:
  /// **'Usage History for {day}'**
  String dailyHistory(Object day);

  /// No description provided for @periodHistory.
  ///
  /// In en, this message translates to:
  /// **'Usage History for {range}'**
  String periodHistory(Object range);

  /// No description provided for @rankingDay.
  ///
  /// In en, this message translates to:
  /// **'Ranking for {day}'**
  String rankingDay(Object day);

  /// No description provided for @rankingDateRange.
  ///
  /// In en, this message translates to:
  /// **'Ranking from {start} to {end}'**
  String rankingDateRange(Object start, Object end);

  /// No description provided for @getDailyDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Details for {day}'**
  String getDailyDetailTitle(Object day);

  /// No description provided for @countUnit.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String countUnit(Object count);

  /// No description provided for @rankingUnit.
  ///
  /// In en, this message translates to:
  /// **'Rank {rank}'**
  String rankingUnit(Object rank);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ja': return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
