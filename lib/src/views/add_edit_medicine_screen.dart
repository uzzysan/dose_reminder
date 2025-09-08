import 'dart:io';
import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/services/database_service.dart';
import 'package:dose_reminder/src/services/notification_service.dart';
import 'package:dose_reminder/src/services/scheduling_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddEditMedicineScreen extends ConsumerStatefulWidget {
  const AddEditMedicineScreen({super.key});

  @override
  ConsumerState<AddEditMedicineScreen> createState() => _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends ConsumerState<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  // ... (state variables)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                final dbService = ref.read(databaseServiceProvider);
                final schedulingService = ref.read(schedulingServiceProvider);
                final notificationService = ref.read(notificationServiceProvider);

                // 1. Create medicine object without doses
                final newMedicine = Medicine(
                  // ... (properties from form state)
                );

                // 2. Save to DB to get a key
                final medicineKey = await dbService.addMedicine(newMedicine);

                // 3. Get the managed instance from Hive
                final managedMedicine = await dbService.getMedicine(medicineKey);

                if (managedMedicine != null) {
                  // 4. Generate doses and add them to the HiveList
                  final doses = schedulingService.generateDoses(managedMedicine);
                  managedMedicine.doseHistory?.addAll(doses);
                  await managedMedicine.save();

                  // 5. Schedule notifications
                  for (var dose in managedMedicine.doseHistory!) {
                    final notificationId = dose.scheduledTime.millisecondsSinceEpoch.remainder(100000);
                    await notificationService.scheduleDoseNotification(
                      notificationId,
                      managedMedicine.name,
                      medicineKey, // Pass the key
                      dose.scheduledTime,
                    );
                  }
                }

                if (mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        // ... (Form UI)
        child: ListView(),
      ),
    );
  }
}
