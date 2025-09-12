import 'dart:io';
import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/providers/dose_provider.dart';
import 'package:dose_reminder/src/widgets/ui/background_logo.dart';
import 'package:dose_reminder/src/widgets/scaffold_with_banner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:dose_reminder/l10n/app_localizations.dart';

class MedicineDetailsScreen extends ConsumerWidget {
  const MedicineDetailsScreen({super.key, required this.medicine});

  final Medicine medicine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(doseProvider(medicine));
    final l10n = AppLocalizations.of(context)!;

    return ScaffoldWithBanner(
      appBar: AppBar(
        title: Row(
          children: [
            if (medicine.photoPath != null && medicine.photoPath!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: _getImageProvider(medicine.photoPath!),
                  backgroundColor: Colors.grey[300],
                ),
              ),
            Expanded(
              child: Text(medicine.name, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          const BackgroundLogo(),
          schedule.isEmpty
              ? Center(child: Text(l10n.noScheduleFoundForThisMedicine))
              : ListView.builder(
                  itemCount: schedule.length,
                  itemBuilder: (context, index) {
                    final dose = schedule[index];
                    final formattedDate =
                        DateFormat.yMMMd().add_jm().format(dose.scheduledTime);
                    final isDue = dose.scheduledTime.isBefore(DateTime.now());
                    final isPending = dose.status == DoseStatus.pending;

                    return ListTile(
                      leading: Text('${l10n.dose} ${index + 1}'),
                      title: Text(formattedDate),
                      trailing: isPending && isDue
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  onPressed: () {
                                    ref.read(doseProvider(medicine).notifier)
                                        .updateDoseStatus(dose, DoseStatus.taken);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () {
                                    ref.read(doseProvider(medicine).notifier)
                                        .updateDoseStatus(dose, DoseStatus.skipped);
                                  },
                                ),
                              ],
                            )
                          : Icon(
                              dose.status == DoseStatus.pending
                                  ? Icons.radio_button_unchecked
                                  : dose.status == DoseStatus.taken
                                      ? Icons.check_circle
                                      : Icons.cancel_outlined,
                              color: dose.status == DoseStatus.pending
                                  ? Colors.grey
                                  : dose.status == DoseStatus.taken
                                      ? Colors.green
                                      : Colors.red,
                            ),
                    );
                  },
                ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider(String photoPath) {
    if (kIsWeb) {
      // For web, photoPath is likely a blob URL
      return NetworkImage(photoPath);
    } else {
      // For mobile, photoPath is a file path
      return FileImage(File(photoPath));
    }
  }
}