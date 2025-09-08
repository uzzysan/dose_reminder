import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

const String medicineBoxName = 'medicines';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  Future<int> addMedicine(Medicine medicine) async {
    final box = await Hive.openBox<Medicine>(medicineBoxName);
    return await box.add(medicine);
  }

  Future<List<Medicine>> getMedicines() async {
    final box = await Hive.openBox<Medicine>(medicineBoxName);
    return box.values.toList();
  }

  Future<Medicine?> getMedicine(int key) async {
    final box = await Hive.openBox<Medicine>(medicineBoxName);
    return box.get(key);
  }

  Future<void> updateMedicine(int key, Medicine medicine) async {
    final box = await Hive.openBox<Medicine>(medicineBoxName);
    await box.put(key, medicine);
  }

  Future<void> updateDoseStatus(int medicineKey, DateTime scheduledTime, DoseStatus newStatus) async {
    final box = await Hive.openBox<Medicine>(medicineBoxName);
    final medicine = box.get(medicineKey);

    if (medicine != null && medicine.doseHistory != null) {
      final doseIndex = medicine.doseHistory!.indexWhere((d) => d.scheduledTime == scheduledTime);
      
      if (doseIndex != -1) {
        medicine.doseHistory![doseIndex].status = newStatus;
        if (newStatus == DoseStatus.taken) {
          medicine.doseHistory![doseIndex].takenTime = DateTime.now();
        }
        await medicine.save();
      }
    }
  }
}
