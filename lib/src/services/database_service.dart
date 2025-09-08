import 'package:dose_reminder/src/models/medicine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

const String medicineBoxName = 'medicines';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

class DatabaseService {
  Future<void> addMedicine(Medicine medicine) async {
    final box = await Hive.openBox<Medicine>(medicineBoxName);
    await box.add(medicine);
  }

  Future<List<Medicine>> getMedicines() async {
    final box = await Hive.openBox<Medicine>(medicineBoxName);
    return box.values.toList();
  }
}
