import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/services/database_service.dart';
import 'package:dose_reminder/src/services/scheduling_service.dart';

void main() {
  group('Notification Integration Tests', () {
    late SchedulingService schedulingService;
    late DatabaseService databaseService;

    setUp(() async {
      // Initialize Hive for testing
      Hive.init('test/hive');

      // Register adapters
      Hive.registerAdapter(MedicineAdapter());
      Hive.registerAdapter(FrequencyTypeAdapter());
      Hive.registerAdapter(DoseAdapter());
      Hive.registerAdapter(DoseStatusAdapter());

      // Initialize services
      schedulingService = SchedulingService();
      databaseService = DatabaseService();

      // Open boxes
      await Hive.openBox<Medicine>('medicines');
      await Hive.openBox<Dose>('doses');
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
    });

    test('End-to-end dose scheduling workflow', () async {
      // Given: Create a new medicine
      final medicine = Medicine(
        name: 'Test Medicine',
        frequencyType: FrequencyType.daily,
        timesPerDay: 3,
        durationInDays: 7,
        startDateTime: DateTime.now(),
        preferredStartHour: 8,
        preferredEndHour: 20,
      );

      // When: Add medicine to database
      final medicineKey = await databaseService.addMedicine(medicine);
      final managedMedicine = await databaseService.getMedicine(medicineKey);

      // Then: Medicine should be properly saved
      expect(managedMedicine, isNotNull);
      expect(managedMedicine!.name, equals('Test Medicine'));
      expect(managedMedicine.frequencyType, equals(FrequencyType.daily));

      // When: Generate doses
      final doses = schedulingService.generateDoses(managedMedicine);

      // Then: Correct number of doses should be generated
      expect(doses.length, equals(21)); // 7 days × 3 doses per day

      // All doses should be in pending status
      for (final dose in doses) {
        expect(dose.status, equals(DoseStatus.pending));
      }

      // When: Save doses to database
      final doseBox = await Hive.openBox<Dose>('doses');
      managedMedicine.doseHistory = HiveList(doseBox);

      for (final dose in doses) {
        await doseBox.add(dose);
        managedMedicine.doseHistory!.add(dose);
      }
      await managedMedicine.save();

      // Then: Dose history should be properly initialized
      expect(managedMedicine.doseHistory, isNotNull);
      expect(managedMedicine.doseHistory!.length, equals(21));
    });

    test('Should handle single dose per day correctly', () async {
      // Given: Medicine with single dose per day
      final medicine = Medicine(
        name: 'Single Dose Medicine',
        frequencyType: FrequencyType.daily,
        timesPerDay: 1,
        durationInDays: 5,
        startDateTime: DateTime.now().add(Duration(days: 1)),
        preferredStartHour: 8,
        preferredEndHour: 20,
      );

      // When: Add medicine and generate doses
      final medicineKey = await databaseService.addMedicine(medicine);
      final managedMedicine = await databaseService.getMedicine(medicineKey);
      final doses = schedulingService.generateDoses(managedMedicine!);

      // Then: Should generate 5 doses
      expect(doses.length, equals(5));

      // All doses should be at preferred hour
      for (final dose in doses) {
        expect(dose.scheduledTime.hour, equals(8));
        expect(dose.scheduledTime.minute, equals(0));
      }
    });

    test('Should handle editing existing medicine correctly', () async {
      // Given: Existing medicine with doses
      final medicine = Medicine(
        name: 'Existing Medicine',
        frequencyType: FrequencyType.daily,
        timesPerDay: 1,
        durationInDays: 3,
        startDateTime: DateTime.now().subtract(Duration(days: 1)),
        preferredStartHour: 9,
        preferredEndHour: 9,
      );

      final medicineKey = await databaseService.addMedicine(medicine);
      final existingMedicine = await databaseService.getMedicine(medicineKey);
      final oldDoses = schedulingService.generateDoses(existingMedicine!);

      // Simulate saving old doses
      final doseBox = await Hive.openBox<Dose>('doses');
      existingMedicine.doseHistory = HiveList(doseBox);

      for (final dose in oldDoses) {
        await doseBox.add(dose);
        existingMedicine.doseHistory!.add(dose);
      }
      await existingMedicine.save();

      // When: Modify medicine and generate new doses
      existingMedicine.durationInDays = 5; // Extend duration
      final newDoses = schedulingService.generateDoses(existingMedicine);

      // Then: New doses should be generated for additional days
      expect(newDoses.length, greaterThan(oldDoses.length));

      // Filter future doses that aren't already in history
      final futureDoses = newDoses.where((dose) =>
        dose.scheduledTime.isAfter(DateTime.now()) &&
        !existingMedicine.doseHistory!.any((existingDose) =>
          existingDose.scheduledTime.isAtSameMomentAs(dose.scheduledTime))
      ).toList();

      // Add future doses to history
      for (final dose in futureDoses) {
        await doseBox.add(dose);
        existingMedicine.doseHistory!.add(dose);
      }
      await existingMedicine.save();

      // Then: History should contain both old and new doses
      expect(existingMedicine.doseHistory!.length, equals(oldDoses.length + futureDoses.length));
    });
  });
}