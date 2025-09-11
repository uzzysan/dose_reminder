import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

const String medicineBoxName = 'medicines';
const String doseBoxName = 'doses';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  Future<int> addMedicine(Medicine medicine) async {
    final box = await Hive.openBox<Medicine>(medicineBoxName);
    final medicineKey = await box.add(medicine);
    
    // Initialize the doseHistory HiveList after the medicine is saved
    final managedMedicine = box.get(medicineKey);
    if (managedMedicine != null) {
      final doseBox = await Hive.openBox<Dose>(doseBoxName);
      managedMedicine.doseHistory = HiveList(doseBox);
      await managedMedicine.save();
    }
    
    return medicineKey;
  }

  Future<List<Medicine>> getMedicines() async {
    final box = await Hive.openBox<Medicine>(medicineBoxName);
    return box.values.toList();
  }

  Stream<List<Medicine>> watchMedicines() async* {
    final box = await Hive.openBox<Medicine>(medicineBoxName);
    yield box.values.toList();

    await for (final _ in box.watch()) {
      yield box.values.toList();
    }
  }

  Future<Medicine?> getMedicine(int key) async {
    final box = await Hive.openBox<Medicine>(medicineBoxName);
    return box.get(key);
  }

  Future<void> updateMedicine(int key, Medicine medicine) async {
    final box = await Hive.openBox<Medicine>(medicineBoxName);
    await box.put(key, medicine);
  }

  Future<void> updateDose(Dose dose) async {
    await dose.save();
  }

  Future<Dose?> getDose(int key) async {
    final box = await Hive.openBox<Dose>(doseBoxName);
    return box.get(key);
  }

  Future<Medicine?> getMedicineForDose(int doseKey) async {
    final medicineBox = await Hive.openBox<Medicine>(medicineBoxName);
    for (var medicine in medicineBox.values) {
      if (medicine.doseHistory?.any((dose) => dose.key == doseKey) ?? false) {
        return medicine;
      }
    }
    return null;
  }

  Future<void> addDoseToMedicine(dynamic medicineKey, Dose dose) async {
    final medicineBox = await Hive.openBox<Medicine>(medicineBoxName);
    final medicine = medicineBox.get(medicineKey);
    if (medicine != null) {
      final doseBox = await Hive.openBox<Dose>(doseBoxName);
      await doseBox.add(dose);
      medicine.doseHistory?.add(dose);
      await medicine.save();
    }
  }
}