import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/views/medicine_details_screen.dart';
import 'package:dose_reminder/src/views/add_edit_medicine_screen.dart';
import 'package:dose_reminder/src/widgets/ui/app_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dose_reminder/l10n/app_localizations.dart';

class MedicineCard extends ConsumerWidget {
  const MedicineCard({super.key, required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = medicine.doseHistory ?? [];
    final l10n = AppLocalizations.of(context)!;
    
    // Get all doses statistics
    final totalDoses = schedule.length;
    final pendingDoses = schedule.where((d) => d.status == DoseStatus.pending).length;
    
    // Find the next pending dose
    Dose? nextDose;
    try {
      nextDose = schedule.firstWhere((d) => d.status == DoseStatus.pending);
    } catch (e) {
      nextDose = null; // No pending doses
    }

    return AppTile(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MedicineDetailsScreen(medicine: medicine),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(medicine.name, style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddEditMedicineScreen(medicine: medicine),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Show dose progress if there are any doses in the cycle
          if (totalDoses > 0) 
            Text('${l10n.dosesLeft}: $pendingDoses ${l10n.ofWord} $totalDoses')
          else
            Text(l10n.noScheduleFoundForThisMedicine),
          const SizedBox(height: 4),
          if (nextDose != null)
            // This is a placeholder for a countdown timer widget
            Text('${l10n.nextDose}: ${nextDose.scheduledTime.toString()}')
          else
            Text(l10n.allDosesTaken),
        ],
      ),
    );
  }
}