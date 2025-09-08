import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/services/database_service.dart';
import 'package:dose_reminder/src/views/add_edit_medicine_screen.dart';
import 'package:dose_reminder/src/widgets/medicine_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to fetch the list of medicines from the database
final medicinesProvider = FutureProvider<List<Medicine>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.getMedicines();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesAsyncValue = ref.watch(medicinesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Medicines'),
        centerTitle: true,
      ),
      body: medicinesAsyncValue.when(
        data: (medicines) {
          if (medicines.isEmpty) {
            return const Center(
              child: Text('No medicines added yet. Press \'+\' to add one!'),
            );
          }
          return ListView.builder(
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              return MedicineCard(medicine: medicines[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate and wait for a result. If the user saved a new medicine,
          // the form will pop. We then invalidate the provider to refresh the list.
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditMedicineScreen()),
          );
          ref.invalidate(medicinesProvider);
        },
        tooltip: 'Add Medicine',
        child: const Icon(Icons.add),
      ),
    );
  }
}
