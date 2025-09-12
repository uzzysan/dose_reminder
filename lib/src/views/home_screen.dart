import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/providers/medicine_provider.dart';
import 'package:dose_reminder/src/providers/settings_provider.dart';
import 'package:dose_reminder/src/services/database_service.dart';
import 'package:dose_reminder/src/views/add_edit_medicine_screen.dart';
import 'package:dose_reminder/src/views/settings_screen.dart';
import 'package:dose_reminder/src/widgets/scaffold_with_banner.dart';
import 'package:dose_reminder/src/widgets/medicine_card.dart';
import 'package:dose_reminder/src/widgets/ui/background_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dose_reminder/l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesAsyncValue = ref.watch(medicinesProvider);
    final l10n = AppLocalizations.of(context)!;

    return ScaffoldWithBanner(
      appBar: AppBar(
        title: Text(l10n.yourMedicines),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const BackgroundLogo(),
          // The actual content of the screen
          medicinesAsyncValue.when(
            data: (medicines) {
              if (medicines.isEmpty) {
                return Center(
                  child: Text(l10n.noMedicinesAdded),
                );
              }
              return ListView.separated(
                itemCount: medicines.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return MedicineCard(medicine: medicines[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditMedicineScreen()),
          );
        },
        tooltip: l10n.addMedicine,
        child: const Icon(Icons.add),
      ),
    );
  }
}