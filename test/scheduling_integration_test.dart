import 'package:flutter_test/flutter_test.dart';
import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/services/scheduling_service.dart';

void main() {
  group('Scheduling Integration Tests', () {
    late SchedulingService schedulingService;

    setUp(() {
      schedulingService = SchedulingService();
    });

    test('Should create correct schedule for mid-day start scenario', () {
      // Scenariusz: Lek 3x dziennie przez 7 dni, zaczęty wczoraj o 11:45
      // Godziny preferowane: 6:00-20:00
      // Obecny system filtruje dawki przed startDateTime, więc dawka o 6:00 zostanie pominięta
      
      final yesterday = DateTime.now().subtract(Duration(days: 1));
      final startTime = DateTime(yesterday.year, yesterday.month, yesterday.day, 11, 45);
      
      final medicine = Medicine(
        name: 'Test Medicine',
        frequencyType: FrequencyType.daily,
        timesPerDay: 3,
        durationInDays: 7,
        startDateTime: startTime,
        preferredStartHour: 6,  // 6:00 AM
        preferredEndHour: 20,   // 8:00 PM
      );

      final doses = schedulingService.generateDoses(medicine);

      // Sprawdzenie ogólnej liczby dawek
      // 7 dni × 3 dawki dziennie = 21 dawek, ale pierwsza dawka o 6:00 zostanie odfiltrowana = 20
      expect(doses.length, equals(20));

      // Sprawdzenie pierwszego dnia (wczoraj)
      final firstDay = DateUtils.dateOnly(startTime);
      final firstDayDoses = doses
          .where((dose) => DateUtils.dateOnly(dose.scheduledTime).isAtSameMomentAs(firstDay))
          .toList();
      
      // Pierwszy dzień powinien mieć 2 dawki (6:00 została odfiltrowana)
      expect(firstDayDoses.length, equals(2));

      // Sprawdzenie czasów pierwszego dnia
      // Tylko dawki o 13:00 i 20:00 (6:00 została odfiltrowana jako przed 11:45)
      expect(firstDayDoses[0].scheduledTime.hour, equals(13));
      expect(firstDayDoses[0].scheduledTime.minute, equals(0));
      
      expect(firstDayDoses[1].scheduledTime.hour, equals(20));
      expect(firstDayDoses[1].scheduledTime.minute, equals(0));

      // Sprawdzenie drugiego dnia
      final secondDay = firstDay.add(Duration(days: 1));
      final secondDayDoses = doses
          .where((dose) => DateUtils.dateOnly(dose.scheduledTime).isAtSameMomentAs(secondDay))
          .toList();
      
      expect(secondDayDoses.length, equals(3));

      // Sprawdzenie ostatniego dnia
      final lastDay = firstDay.add(Duration(days: 6));
      final lastDayDoses = doses
          .where((dose) => DateUtils.dateOnly(dose.scheduledTime).isAtSameMomentAs(lastDay))
          .toList();
      
      expect(lastDayDoses.length, equals(3));

      // Wszystkie dawki powinny być w statusie pending
      for (final dose in doses) {
        expect(dose.status, equals(DoseStatus.pending));
      }

      // Sprawdzenie chronologicznej kolejności
      for (int i = 1; i < doses.length; i++) {
        expect(
          doses[i].scheduledTime.isAfter(doses[i-1].scheduledTime),
          isTrue,
          reason: 'Doses should be in chronological order',
        );
      }
    });

    test('Should handle single dose per day correctly', () {
      // Start jutro rano żeby uniknąć filtrowania
      final tomorrow = DateTime.now().add(Duration(days: 1));
      final startTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 0);
      
      final medicine = Medicine(
        name: 'Single Dose Medicine',
        frequencyType: FrequencyType.daily,
        timesPerDay: 1,
        durationInDays: 5,
        startDateTime: startTime,
        preferredStartHour: 8,
        preferredEndHour: 20,
      );

      final doses = schedulingService.generateDoses(medicine);
      print('Single dose test: generated ${doses.length} doses, start time: $startTime');
      for (int i = 0; i < doses.length; i++) {
        print('  Dose $i: ${doses[i].scheduledTime}');
      }

      expect(doses.length, equals(5));
      
      // All doses should be at 8 AM
      for (final dose in doses) {
        expect(dose.scheduledTime.hour, equals(8));
        expect(dose.scheduledTime.minute, equals(0));
      }
    });

    test('Should handle every X days frequency correctly', () {
      // Start jutro rano dokładnie o preferowanej godzinie
      final tomorrow = DateTime.now().add(Duration(days: 1));
      final startTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0);
      
      final medicine = Medicine(
        name: 'Every 2 Days Medicine',
        frequencyType: FrequencyType.everyXDays,
        everyXDays: 2,
        timesPerDay: 1,
        durationInDays: 10,
        startDateTime: startTime,
        preferredStartHour: 9,
        preferredEndHour: 9,
      );

      final doses = schedulingService.generateDoses(medicine);
      print('Every X days test: generated ${doses.length} doses');
      for (int i = 0; i < doses.length; i++) {
        print('  Dose $i: ${doses[i].scheduledTime}');
      }

      // Every 2 days for 10 days = days 0, 2, 4, 6, 8 = 5 doses
      expect(doses.length, equals(5));
      
      // Check intervals
      for (int i = 1; i < doses.length; i++) {
        final daysDifference = doses[i].scheduledTime.difference(doses[i-1].scheduledTime).inDays;
        expect(daysDifference, equals(2));
      }
    });

    test('Should handle weekly frequency correctly', () {
      // Start w przyszły poniedziałek rano o 10:00
      final now = DateTime.now();
      final daysUntilNextMonday = (8 - now.weekday) % 7;
      final nextMonday = now.add(Duration(days: daysUntilNextMonday == 0 ? 7 : daysUntilNextMonday));
      final startTime = DateTime(nextMonday.year, nextMonday.month, nextMonday.day, 10, 0);
      
      final medicine = Medicine(
        name: 'Weekly Medicine',
        frequencyType: FrequencyType.weekly,
        weeklyFrequency: [1, 3, 5], // Monday, Wednesday, Friday
        timesPerDay: 1,
        durationInDays: 14, // 2 weeks
        startDateTime: startTime,
        preferredStartHour: 10,
        preferredEndHour: 10,
      );

      final doses = schedulingService.generateDoses(medicine);
      print('Weekly test: generated ${doses.length} doses, start: $startTime');
      for (int i = 0; i < doses.length; i++) {
        print('  Dose $i: ${doses[i].scheduledTime} (weekday ${doses[i].scheduledTime.weekday})');
      }

      // 2 weeks × 3 days per week = 6 doses
      expect(doses.length, equals(6));
      
      // Check that all doses fall on correct weekdays
      for (final dose in doses) {
        expect([1, 3, 5].contains(dose.scheduledTime.weekday), isTrue);
      }
    });
  });
}

// Dodać klasy pomocnicze jeśli nie istnieją
abstract class DateUtils {
  static DateTime dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
