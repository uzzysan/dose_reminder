import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/views/medicine_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MedicineCard extends ConsumerWidget {
  const MedicineCard({super.key, required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = medicine.doseHistory ?? [];
    final dosesLeft = schedule.where((d) => d.status == DoseStatus.pending).length;
    final totalDoses = schedule.length;
    final l10n = AppLocalizations.of(context)!;

    // Find the next dose
    Dose? nextDose;
    try {
      nextDose = schedule.firstWhere((d) => d.status == DoseStatus.pending);
    } catch (e) {
      nextDose = null; // No pending doses
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MedicineDetailsScreen(medicine: medicine),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(medicine.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('${l10n.dosesLeft}: $dosesLeft ${l10n.of} $totalDoses'),
              const SizedBox(height: 4),
              if (nextDose != null)
                // This is a placeholder for a countdown timer widget
                Text('${l10n.nextDose}: ${nextDose.scheduledTime.toString()}')
              else
                Text(l10n.allDosesTaken),
            ],
          ),
        ),
      ),
    );
  }
}