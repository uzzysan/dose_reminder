// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Przypominacz Dawek';

  @override
  String get yourMedicines => 'Twoje Leki';

  @override
  String get addMedicine => 'Dodaj Lek';

  @override
  String get noMedicinesAdded =>
      'Nie dodano jeszcze leków. Naciśnij \'+\' aby dodać!';

  @override
  String get medicineName => 'Nazwa leku';

  @override
  String get frequency => 'Częstotliwość';

  @override
  String get timesPerDay => 'Razy dziennie';

  @override
  String get everyXDays => 'Co X dni';

  @override
  String get durationInDays => 'Czas trwania (w dniach)';

  @override
  String get startDate => 'Data rozpoczęcia';

  @override
  String get startTime => 'Godzina rozpoczęcia';

  @override
  String get preferredHours => 'Preferowane godziny';

  @override
  String get systemDefault => 'Domyślny systemowy';

  @override
  String get light => 'Jasny';

  @override
  String get dark => 'Ciemny';

  @override
  String get settings => 'Ustawienia';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Język';

  @override
  String get english => 'Angielski';

  @override
  String get polish => 'Polski';

  @override
  String get dose => 'Dawka';

  @override
  String get totalDoses => 'Wszystkie dawki';

  @override
  String get dosesLeft => 'Pozostałe dawki';

  @override
  String get nextDose => 'Następna dawka';

  @override
  String get allDosesTaken => 'Wszystkie dawki przyjęte!';

  @override
  String get timeForYourDose => 'Czas na dawkę!';

  @override
  String itsTimeToTakeYour(Object medicineName) {
    return 'Czas na przyjęcie leku $medicineName.';
  }

  @override
  String get taken => 'Przyjęto';

  @override
  String get snooze => 'Drzemka (30 min)';
}
