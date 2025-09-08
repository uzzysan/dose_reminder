import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/providers/settings_provider.dart';
import 'package:dose_reminder/src/services/database_service.dart';
import 'package:dose_reminder/src/views/add_edit_medicine_screen.dart';
import 'package:dose_reminder/src/views/settings_screen.dart';
import 'package:dose_reminder/src/widgets/medicine_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dose_reminder/l10n/app_localizations.dart';

final medicinesProvider = FutureProvider<List<Medicine>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.getMedicines();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicinesAsyncValue = ref.watch(medicinesProvider);
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeNotifierProvider);

    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final logoAsset = isDarkMode ? 'assets/logo_dark.png' : 'assets/logo_bright.png';
    final backgroundColor = isDarkMode ? const Color.fromARGB(255, 18, 27, 36) : Colors.white;

    return Scaffold(
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
          Positioned.fill(
            child: Container(
              color: backgroundColor,
              child: Center(
                child: Opacity(
                  opacity: 0.06, // Very subtle background logo
                  child: Image.asset(
                    logoAsset,
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width * 0.8,
                  ),
                ),
              ),
            ),
          ),
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
          ref.invalidate(medicinesProvider);
        },
        tooltip: l10n.addMedicine,
        child: const Icon(Icons.add),
      ),
    );
  }
}