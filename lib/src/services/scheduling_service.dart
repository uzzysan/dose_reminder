import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final schedulingServiceProvider = Provider<SchedulingService>((ref) {
  return SchedulingService();
});

class SchedulingService {
  List<Dose> generateDoses(Medicine medicine) {
    final List<Dose> doses = [];
    switch (medicine.frequencyType) {
      case FrequencyType.daily:
        doses.addAll(_generateDailyDoses(medicine));
        break;
      case FrequencyType.everyXDays:
        doses.addAll(_generateEveryXDaysDoses(medicine));
        break;
      case FrequencyType.weekly:
        doses.addAll(_generateWeeklyDoses(medicine));
        break;
    }

    // Sort the doses chronologically to be safe.
    doses.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

    // Filter out any doses that would have been before the user's start time.
    final filteredDoses = doses
        .where((dose) => !dose.scheduledTime.isBefore(medicine.startDateTime))
        .toList();

    return filteredDoses;
  }

  // ... (rest of the service remains the same)
  List<Dose> _generateDosesForDay(Medicine medicine, DateTime date) {
    final List<Dose> dosesForDay = [];
    final int timesPerDay = medicine.timesPerDay ?? 1;
    final dateOnly = DateUtils.dateOnly(date);

    if (timesPerDay == 1) {
      final doseTime = dateOnly.add(Duration(hours: medicine.preferredStartHour));
      dosesForDay.add(Dose(scheduledTime: doseTime));
      return dosesForDay;
    }

    final timeWindowMinutes = (medicine.preferredEndHour - medicine.preferredStartHour) * 60;
    if (timeWindowMinutes <= 0) return []; // Avoid division by zero or negative intervals

    final interval = timeWindowMinutes / (timesPerDay - 1);

    for (int j = 0; j < timesPerDay; j++) {
      final minutesToAdd = j * interval;
      final doseTime = dateOnly
          .add(Duration(hours: medicine.preferredStartHour))
          .add(Duration(minutes: minutesToAdd.round()));
      dosesForDay.add(Dose(scheduledTime: doseTime));
    }
    return dosesForDay;
  }

  List<Dose> _generateDailyDoses(Medicine medicine) {
    final List<Dose> generatedDoses = [];
    for (int i = 0; i < medicine.durationInDays; i++) {
      final date = medicine.startDateTime.add(Duration(days: i));
      generatedDoses.addAll(_generateDosesForDay(medicine, date));
    }
    return generatedDoses;
  }

  List<Dose> _generateEveryXDaysDoses(Medicine medicine) {
    final List<Dose> generatedDoses = [];
    final int everyXDays = medicine.everyXDays ?? 1;
    for (int i = 0; i < medicine.durationInDays; i++) {
      if (i % everyXDays == 0) {
        final date = medicine.startDateTime.add(Duration(days: i));
        generatedDoses.addAll(_generateDosesForDay(medicine, date));
      }
    }
    return generatedDoses;
  }

  List<Dose> _generateWeeklyDoses(Medicine medicine) {
    final List<Dose> generatedDoses = [];
    final weeklyDays = medicine.weeklyFrequency ?? [];
    if (weeklyDays.isEmpty) return [];

    for (int i = 0; i < medicine.durationInDays; i++) {
      final date = medicine.startDateTime.add(Duration(days: i));
      if (weeklyDays.contains(date.weekday)) {
        generatedDoses.addAll(_generateDosesForDay(medicine, date));
      }
    }
    return generatedDoses;
  }
}

abstract class DateUtils {
  static DateTime dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }
}
