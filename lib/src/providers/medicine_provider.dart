import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final medicinesProvider = StreamProvider<List<Medicine>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.watchMedicines();
});