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
  String get theme => 'Motyw';

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
  String get ofWord => 'z';

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

  @override
  String get selectImageSource => 'Wybierz źródło obrazu';

  @override
  String get camera => 'Aparat';

  @override
  String get gallery => 'Galeria';

  @override
  String get mon => 'Pon';

  @override
  String get tue => 'Wt';

  @override
  String get wed => 'Śr';

  @override
  String get thu => 'Czw';

  @override
  String get fri => 'Pt';

  @override
  String get sat => 'Sob';

  @override
  String get sun => 'Nd';

  @override
  String get pleaseEnterHowManyTimesPerDay => 'Proszę podać ile razy dziennie';

  @override
  String get invalidNumber => 'Nieprawidłowy numer';

  @override
  String get pleaseEnterTheIntervalInDays => 'Proszę podać interwał w dniach';

  @override
  String get pleaseEnterAMedicineName => 'Proszę podać nazwę leku';

  @override
  String get pleaseSelectAFrequency => 'Proszę wybrać częstotliwość';

  @override
  String get pleaseEnterTheDuration => 'Proszę podać czas trwania';

  @override
  String get pleaseEnterAValidNumberOfDays =>
      'Proszę podać prawidłową liczbę dni';

  @override
  String get noScheduleFoundForThisMedicine =>
      'Nie znaleziono harmonogramu dla tego leku.';

  @override
  String get todayDoses => 'Dzisiejsze Dawki';

  @override
  String get noDosesScheduledForToday => 'Brak dawek zaplanowanych na dziś.';

  @override
  String get doseHistory => 'Historia Dawek';

  @override
  String get noDoseHistory => 'Brak historii dawek.';

  @override
  String get weeklyFrequency => 'Częstotliwość Tygodniowa';

  @override
  String get days => 'dni';

  @override
  String get duration => 'Czas trwania';
}
