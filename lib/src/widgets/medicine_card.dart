import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/views/medicine_details_screen.dart';
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
    final now = DateTime.now();
    
    // Helper function to check if two dates are the same day
    bool isSameDay(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }
    
    // Get today's doses
    final todayDoses = schedule.where((dose) => isSameDay(dose.scheduledTime, now)).toList();
    final todayTaken = todayDoses.where((d) => d.status == DoseStatus.taken).length;
    final todayTotal = todayDoses.length;
    
    // Find the next dose (first pending dose today, or next pending dose overall)
    Dose? nextDose;
    try {
      // First try to find next pending dose today
      nextDose = todayDoses.firstWhere((d) => d.status == DoseStatus.pending);
    } catch (e) {
      try {
        // If no pending doses today, find next pending dose overall
        nextDose = schedule.firstWhere((d) => d.status == DoseStatus.pending);
      } catch (e) {
        nextDose = null; // No pending doses at all
      }
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
          Text(medicine.name, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          // Only show dose counter if there are doses scheduled for today
          if (todayTotal > 0) 
            Text('${l10n.dosesLeft}: ${todayTotal - todayTaken} ${l10n.ofWord} $todayTotal')
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