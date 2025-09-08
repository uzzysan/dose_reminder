// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dose Reminder';

  @override
  String get yourMedicines => 'Your Medicines';

  @override
  String get addMedicine => 'Add Medicine';

  @override
  String get noMedicinesAdded =>
      'No medicines added yet. Press \'+\' to add one!';

  @override
  String get medicineName => 'Medicine Name';

  @override
  String get frequency => 'Frequency';

  @override
  String get timesPerDay => 'Times per day';

  @override
  String get everyXDays => 'Every X days';

  @override
  String get durationInDays => 'Duration (in days)';

  @override
  String get startDate => 'Start Date';

  @override
  String get startTime => 'Start Time';

  @override
  String get preferredHours => 'Preferred hours';

  @override
  String get systemDefault => 'System Default';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get polish => 'Polish';

  @override
  String get dose => 'Dose';

  @override
  String get totalDoses => 'Total doses';

  @override
  String get dosesLeft => 'Doses left';

  @override
  String get nextDose => 'Next dose';

  @override
  String get allDosesTaken => 'All doses taken!';

  @override
  String get timeForYourDose => 'Time for your dose!';

  @override
  String itsTimeToTakeYour(Object medicineName) {
    return 'It\'s time to take your $medicineName.';
  }

  @override
  String get taken => 'Taken';

  @override
  String get snooze => 'Snooze (30 min)';

  @override
  String get selectImageSource => 'Select Image Source';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get pleaseEnterHowManyTimesPerDay =>
      'Please enter how many times per day';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get pleaseEnterTheIntervalInDays =>
      'Please enter the interval in days';

  @override
  String get pleaseEnterAMedicineName => 'Please enter a medicine name';

  @override
  String get pleaseSelectAFrequency => 'Please select a frequency';

  @override
  String get pleaseEnterTheDuration => 'Please enter the duration';

  @override
  String get pleaseEnterAValidNumberOfDays =>
      'Please enter a valid number of days';

  @override
  String get noScheduleFoundForThisMedicine =>
      'No schedule found for this medicine.';

  @override
  String get todayDoses => 'Today\'s Doses';

  @override
  String get noDosesScheduledForToday => 'No doses scheduled for today.';

  @override
  String get doseHistory => 'Dose History';

  @override
  String get noDoseHistory => 'No dose history available.';

  @override
  String get weeklyFrequency => 'Weekly Frequency';

  @override
  String get days => 'days';

  @override
  String get duration => 'Duration';
}
