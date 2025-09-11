import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Dose Reminder'**
  String get appTitle;

  /// No description provided for @yourMedicines.
  ///
  /// In en, this message translates to:
  /// **'Your Medicines'**
  String get yourMedicines;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get addMedicine;

  /// No description provided for @noMedicinesAdded.
  ///
  /// In en, this message translates to:
  /// **'No medicines added yet. Press \'+\' to add one!'**
  String get noMedicinesAdded;

  /// No description provided for @medicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get medicineName;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @timesPerDay.
  ///
  /// In en, this message translates to:
  /// **'Times per day'**
  String get timesPerDay;

  /// No description provided for @everyXDays.
  ///
  /// In en, this message translates to:
  /// **'Every X days'**
  String get everyXDays;

  /// No description provided for @durationInDays.
  ///
  /// In en, this message translates to:
  /// **'Duration (in days)'**
  String get durationInDays;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @preferredHours.
  ///
  /// In en, this message translates to:
  /// **'Preferred hours'**
  String get preferredHours;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @polish.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get polish;

  /// No description provided for @dose.
  ///
  /// In en, this message translates to:
  /// **'Dose'**
  String get dose;

  /// No description provided for @totalDoses.
  ///
  /// In en, this message translates to:
  /// **'Total doses'**
  String get totalDoses;

  /// No description provided for @dosesLeft.
  ///
  /// In en, this message translates to:
  /// **'Doses left'**
  String get dosesLeft;

  /// No description provided for @ofWord.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofWord;

  /// No description provided for @nextDose.
  ///
  /// In en, this message translates to:
  /// **'Next dose'**
  String get nextDose;

  /// No description provided for @allDosesTaken.
  ///
  /// In en, this message translates to:
  /// **'All doses taken!'**
  String get allDosesTaken;

  /// No description provided for @timeForYourDose.
  ///
  /// In en, this message translates to:
  /// **'Time for your dose!'**
  String get timeForYourDose;

  /// No description provided for @itsTimeToTakeYour.
  ///
  /// In en, this message translates to:
  /// **'It\'s time to take your {medicineName}.'**
  String itsTimeToTakeYour(Object medicineName);

  /// No description provided for @taken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get taken;

  /// No description provided for @snooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze (30 min)'**
  String get snooze;

  /// No description provided for @selectImageSource.
  ///
  /// In en, this message translates to:
  /// **'Select Image Source'**
  String get selectImageSource;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// No description provided for @tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// No description provided for @wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// No description provided for @thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// No description provided for @fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// No description provided for @sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// No description provided for @sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// No description provided for @pleaseEnterHowManyTimesPerDay.
  ///
  /// In en, this message translates to:
  /// **'Please enter how many times per day'**
  String get pleaseEnterHowManyTimesPerDay;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @pleaseEnterTheIntervalInDays.
  ///
  /// In en, this message translates to:
  /// **'Please enter the interval in days'**
  String get pleaseEnterTheIntervalInDays;

  /// No description provided for @pleaseEnterAMedicineName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a medicine name'**
  String get pleaseEnterAMedicineName;

  /// No description provided for @pleaseSelectAFrequency.
  ///
  /// In en, this message translates to:
  /// **'Please select a frequency'**
  String get pleaseSelectAFrequency;

  /// No description provided for @pleaseEnterTheDuration.
  ///
  /// In en, this message translates to:
  /// **'Please enter the duration'**
  String get pleaseEnterTheDuration;

  /// No description provided for @pleaseEnterAValidNumberOfDays.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number of days'**
  String get pleaseEnterAValidNumberOfDays;

  /// No description provided for @noScheduleFoundForThisMedicine.
  ///
  /// In en, this message translates to:
  /// **'No schedule found for this medicine.'**
  String get noScheduleFoundForThisMedicine;

  /// No description provided for @todayDoses.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Doses'**
  String get todayDoses;

  /// No description provided for @noDosesScheduledForToday.
  ///
  /// In en, this message translates to:
  /// **'No doses scheduled for today.'**
  String get noDosesScheduledForToday;

  /// No description provided for @doseHistory.
  ///
  /// In en, this message translates to:
  /// **'Dose History'**
  String get doseHistory;

  /// No description provided for @noDoseHistory.
  ///
  /// In en, this message translates to:
  /// **'No dose history available.'**
  String get noDoseHistory;

  /// No description provided for @weeklyFrequency.
  ///
  /// In en, this message translates to:
  /// **'Weekly Frequency'**
  String get weeklyFrequency;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @medicineSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Medicine saved successfully'**
  String get medicineSavedSuccessfully;

  /// No description provided for @failedToSaveMedicine.
  ///
  /// In en, this message translates to:
  /// **'Failed to save medicine'**
  String get failedToSaveMedicine;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
