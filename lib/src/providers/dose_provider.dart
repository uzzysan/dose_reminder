import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/services/database_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final doseProvider = StateNotifierProvider.autoDispose.family<DoseNotifier, List<Dose>, Medicine>((ref, medicine) {
  final databaseService = ref.watch(databaseServiceProvider);
  return DoseNotifier(databaseService, medicine);
});

class DoseNotifier extends StateNotifier<List<Dose>> {
  DoseNotifier(this._databaseService, this._medicine) : super(_medicine.doseHistory ?? []);

  final DatabaseService _databaseService;
  final Medicine _medicine;

  Future<void> updateDoseStatus(Dose dose, DoseStatus status) async {
    dose.status = status;
    if (status == DoseStatus.taken) {
      dose.takenTime = DateTime.now();
    }
    await _databaseService.updateDose(dose);

    if (status == DoseStatus.skipped) {
      final newDose = _calculateNextDose();
      if (newDose != null) {
        await _databaseService.addDoseToMedicine(_medicine.key, newDose);
      }
    }
    state = _medicine.doseHistory ?? [];
  }

  Dose? _calculateNextDose() {
    if (_medicine.doseHistory == null || _medicine.doseHistory!.isEmpty) {
      return null;
    }

    final sortedDoses = List<Dose>.from(_medicine.doseHistory!)
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
    final lastDose = sortedDoses.last;

    Duration interval;
    switch (_medicine.frequencyType) {
      case FrequencyType.daily:
        interval = const Duration(days: 1);
        break;
      case FrequencyType.everyXDays:
        interval = Duration(days: _medicine.everyXDays ?? 1);
        break;
      case FrequencyType.weekly:
        interval = const Duration(days: 7);
        break;
    }

    return Dose(scheduledTime: lastDose.scheduledTime.add(interval));
  }
}