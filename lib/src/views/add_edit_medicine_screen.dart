import 'dart:io';
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

                final newMedicine = Medicine(
                  // ... (medicine properties)
                );

                // Save to DB
                final dbService = ref.read(databaseServiceProvider);
                await dbService.addMedicine(newMedicine);

                // Schedule Notifications
                final schedulingService = ref.read(schedulingServiceProvider);
                final notificationService = ref.read(notificationServiceProvider);
                final doses = schedulingService.generateDoses(newMedicine);

                for (var dose in doses) {
                  // Use a unique ID for each notification
                  final notificationId = dose.scheduledTime.millisecondsSinceEpoch.remainder(100000);
                  await notificationService.scheduleDoseNotification(
                    notificationId,
                    newMedicine.name,
                    dose.scheduledTime,
                  );
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