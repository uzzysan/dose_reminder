import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/services/scheduling_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MedicineDetailsScreen extends ConsumerWidget {
  const MedicineDetailsScreen({super.key, required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulingService = ref.read(schedulingServiceProvider);
    final List<Dose> schedule = schedulingService.generateDoses(medicine);

    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name),
      ),
      body: ListView.builder(
        itemCount: schedule.length,
        itemBuilder: (context, index) {
          final dose = schedule[index];
          final formattedDate = DateFormat.yMMMd().add_jm().format(dose.scheduledTime);
          
          return ListTile(
            leading: Text('Dose ${index + 1}'),
            title: Text(formattedDate),
            trailing: Icon(
              dose.status == DoseStatus.pending ? Icons.radio_button_unchecked :
              dose.status == DoseStatus.taken ? Icons.check_circle :
              Icons.cancel_outlined,
              color: dose.status == DoseStatus.pending ? Colors.grey :
              dose.status == DoseStatus.taken ? Colors.green :
              Colors.red,
            ),
          );
        },
      ),
    );
  }
}
