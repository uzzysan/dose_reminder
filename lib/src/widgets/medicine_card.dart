import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/services/scheduling_service.dart';
import 'package:dose_reminder/src/views/medicine_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicineCard extends ConsumerWidget {
  const MedicineCard({super.key, required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.read(schedulingServiceProvider).generateDoses(medicine);
    final totalDoses = schedule.length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias, // Ensures the InkWell ripple is contained
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
              Text(
                medicine.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text('Total doses: $totalDoses'),
              const SizedBox(height: 4),
              // Placeholder for next dose time, which requires more complex state
              const Text('Next dose: ...'), 
            ],
          ),
        ),
      ),
    );
  }
}