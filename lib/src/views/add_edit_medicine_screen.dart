import 'dart:io';
import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/services/database_service.dart';
import 'package:dose_reminder/src/services/notification_service.dart';
import 'package:dose_reminder/src/services/scheduling_service.dart';
import 'package:dose_reminder/src/widgets/ui/app_tile.dart';
import 'package:dose_reminder/src/widgets/ui/background_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dose_reminder/l10n/app_localizations.dart';
class AddEditMedicineScreen extends ConsumerStatefulWidget {
  const AddEditMedicineScreen({super.key, this.medicine});

  final Medicine? medicine;

  @override
  ConsumerState<AddEditMedicineScreen> createState() =>
      _AddEditMedicineScreenState();
}

class _AddEditMedicineScreenState extends ConsumerState<AddEditMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  // Form state variables
  String _name = '';
  File? _imageFile;
  FrequencyType? _frequencyType;
  int? _timesPerDay;
  int? _everyXDays;
  final Set<int> _weeklyFrequency = {};
  int? _durationInDays;
  DateTime _startDateTime = DateTime.now();
  RangeValues _preferredHours = const RangeValues(7, 21);

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _name = widget.medicine!.name;
      _imageFile = widget.medicine!.photoPath != null ? File(widget.medicine!.photoPath!) : null;
      _frequencyType = widget.medicine!.frequencyType;
      _timesPerDay = widget.medicine!.timesPerDay;
      _everyXDays = widget.medicine!.everyXDays;
      _weeklyFrequency.addAll(widget.medicine!.weeklyFrequency ?? []);
      _durationInDays = widget.medicine!.durationInDays;
      _startDateTime = widget.medicine!.startDateTime;
      _preferredHours = RangeValues(widget.medicine!.preferredStartHour.toDouble(), widget.medicine!.preferredEndHour.toDouble());
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectImageSource),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.camera),
              label: Text(l10n.camera),
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.photo_library),
              label: Text(l10n.gallery),
              onPressed: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDateTime) {
      setState(() {
        _startDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _startDateTime.hour,
          _startDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startDateTime),
    );
    if (picked != null) {
      setState(() {
        _startDateTime = DateTime(
          _startDateTime.year,
          _startDateTime.month,
          _startDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Widget _buildWeeklyDayPicker() {
    final l10n = AppLocalizations.of(context)!;
    final days = [
      l10n.mon,
      l10n.tue,
      l10n.wed,
      l10n.thu,
      l10n.fri,
      l10n.sat,
      l10n.sun,
    ];
    return Wrap(
      spacing: 8.0,
      children: List<Widget>.generate(7, (int index) {
        return FilterChip(
          label: Text(days[index]),
          selected: _weeklyFrequency.contains(index + 1),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _weeklyFrequency.add(index + 1);
              } else {
                _weeklyFrequency.remove(index + 1);
              }
            });
          },
        );
      }).toList(),
    );
  }

  String _getTranslatedFrequencyType(FrequencyType type, AppLocalizations l10n) {
    switch (type) {
      case FrequencyType.daily:
        return l10n.daily;
      case FrequencyType.everyXDays:
        return l10n.everyXDays;
      case FrequencyType.weekly:
        return l10n.weekly;
    }
  }

  Widget _buildFrequencyFields() {
    final l10n = AppLocalizations.of(context)!;
    switch (_frequencyType) {
      case FrequencyType.daily:
        return TextFormField(
          decoration: InputDecoration(labelText: l10n.timesPerDay),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.pleaseEnterHowManyTimesPerDay;
            }
            if (int.tryParse(value) == null || int.parse(value) <= 0) {
              return l10n.invalidNumber;
            }
            return null;
          },
          onSaved: (value) => _timesPerDay = int.tryParse(value ?? ''),
        );
      case FrequencyType.everyXDays:
        return TextFormField(
          decoration: InputDecoration(labelText: l10n.everyXDays),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.pleaseEnterTheIntervalInDays;
            }
            if (int.tryParse(value) == null || int.parse(value) <= 0) {
              return l10n.invalidNumber;
            }
            return null;
          },
          onSaved: (value) => _everyXDays = int.tryParse(value ?? ''),
        );
      case FrequencyType.weekly:
        return _buildWeeklyDayPicker();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addMedicine),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final l10n = AppLocalizations.of(context)!;

                try {
                                    final dbService = ref.read(databaseServiceProvider);
                  final schedulingService =
                      ref.read(schedulingServiceProvider);
                  final notificationService =
                      ref.read(notificationServiceProvider);

                  final newMedicine = Medicine(
                    name: _name,
                    photoPath: _imageFile?.path,
                    frequencyType: _frequencyType!,
                    timesPerDay: _timesPerDay,
                    everyXDays: _everyXDays,
                    weeklyFrequency: _weeklyFrequency.toList(),
                    durationInDays: _durationInDays!,
                    startDateTime: _startDateTime,
                    preferredStartHour: _preferredHours.start.round(),
                    preferredEndHour: _preferredHours.end.round(),
                  );

                  if (widget.medicine == null) {
                    // Adding new medicine
                    final medicineKey = await dbService.addMedicine(newMedicine);
                    final managedMedicine =
                        await dbService.getMedicine(medicineKey);

                    if (managedMedicine != null) {
                      final doses =
                          schedulingService.generateDoses(managedMedicine);
                      if (managedMedicine.doseHistory != null) {
                        final doseBox = await Hive.openBox<Dose>('doses');
                        for (final dose in doses) {
                          await doseBox.add(dose);
                        }
                        managedMedicine.doseHistory!.addAll(doses);
                        await managedMedicine.save();

                        for (var dose in managedMedicine.doseHistory!) {
                          await notificationService.scheduleDoseNotification(
                            dose.key,
                            managedMedicine.name,
                            dose.key,
                            dose.scheduledTime,
                          );
                        }
                      }
                    }
                  } else {
                    // Editing existing medicine
                    final oldMedicine = widget.medicine!;

                    // Preserve past doses
                    final preservedDoses = oldMedicine.doseHistory
                            ?.where((d) =>
                                d.status == DoseStatus.taken ||
                                d.status == DoseStatus.skipped)
                            .toList() ??
                        [];

                    // Cancel future notifications for old schedule
                    for (var dose in oldMedicine.doseHistory ?? []) {
                      if (dose.status == DoseStatus.pending &&
                          dose.scheduledTime.isAfter(DateTime.now())) {
                        await notificationService.cancelNotification(dose.key);
                      }
                    }

                    // Generate new doses
                    final newGeneratedDoses =
                        schedulingService.generateDoses(newMedicine);

                    // Combine preserved doses with new future doses
                    final combinedDoses = <Dose>[];
                    combinedDoses.addAll(preservedDoses);
                    combinedDoses.addAll(newGeneratedDoses.where((d) =>
                        d.scheduledTime.isAfter(DateTime.now()) &&
                        !preservedDoses.any((pd) =>
                            pd.scheduledTime == d.scheduledTime))); // Avoid duplicates

                    // Update the existing medicine object
                    oldMedicine.name = newMedicine.name;
                    oldMedicine.photoPath = newMedicine.photoPath;
                    oldMedicine.frequencyType = newMedicine.frequencyType;
                    oldMedicine.timesPerDay = newMedicine.timesPerDay;
                    oldMedicine.everyXDays = newMedicine.everyXDays;
                    oldMedicine.weeklyFrequency = newMedicine.weeklyFrequency;
                    oldMedicine.durationInDays = newMedicine.durationInDays;
                    oldMedicine.startDateTime = newMedicine.startDateTime;
                    oldMedicine.preferredStartHour = newMedicine.preferredStartHour;
                    oldMedicine.preferredEndHour = newMedicine.preferredEndHour;

                    // Clear old dose history and add combined doses
                    oldMedicine.doseHistory?.clear();
                    final doseBox = await Hive.openBox<Dose>('doses');
                    for (final dose in combinedDoses) {
                      await doseBox.add(dose);
                    }
                    oldMedicine.doseHistory?.addAll(combinedDoses);
                    await oldMedicine.save();

                    // Schedule notifications for new future doses
                    for (var dose in combinedDoses) {
                      if (dose.status == DoseStatus.pending &&
                          dose.scheduledTime.isAfter(DateTime.now())) {
                        await notificationService.scheduleDoseNotification(
                          dose.key,
                          oldMedicine.name,
                          dose.key,
                          dose.scheduledTime,
                        );
                      }
                    }
                  }
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(l10n.medicineSavedSuccessfully),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(l10n.failedToSaveMedicine),
                      backgroundColor: Colors.red,
                    ),
                  );
                } finally {
                  if (mounted) {
                    navigator.pop();
                  }
                }
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const BackgroundLogo(),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.separated(
                itemCount: 5,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  return AppTile(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : null,
                            child: _imageFile == null
                                ? const Icon(
                                    Icons.camera_alt,
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: l10n.medicineName,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseEnterAMedicineName;
                            }
                            return null;
                          },
                          onSaved: (value) => _name = value ?? '',
                        ),
                      ],
                    ),
                  );
                case 1:
                  return AppTile(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.frequency,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<FrequencyType>(
                          decoration: InputDecoration(
                            labelText: l10n.frequency,
                            border: const OutlineInputBorder(),
                          ),
                          initialValue: _frequencyType,
                          items: FrequencyType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(_getTranslatedFrequencyType(type, l10n)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _frequencyType = value;
                            });
                          },
                          validator: (value) =>
                              value == null ? l10n.pleaseSelectAFrequency : null,
                        ),
                        const SizedBox(height: 12),
                        _buildFrequencyFields(),
                      ],
                    ),
                  );
                case 2:
                  return AppTile(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.duration,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: l10n.durationInDays,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseEnterTheDuration;
                            }
                            if (int.tryParse(value) == null || int.parse(value) <= 0) {
                              return l10n.pleaseEnterAValidNumberOfDays;
                            }
                            return null;
                          },
                          onSaved: (value) => _durationInDays = int.tryParse(value ?? ''),
                        ),
                      ],
                    ),
                  );
                case 3:
                  return AppTile(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.startDate,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.startDate),
                            TextButton(
                              onPressed: _selectDate,
                              child: Text(DateFormat.yMd().format(_startDateTime)),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.startTime),
                            TextButton(
                              onPressed: _selectTime,
                              child: Text(DateFormat.jm().format(_startDateTime)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                case 4:
                  return AppTile(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.preferredHours}: ${_preferredHours.start.round()}:00 - ${_preferredHours.end.round()}:00',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        RangeSlider(
                          values: _preferredHours,
                          min: 0,
                          max: 23,
                          divisions: 23,
                          labels: RangeLabels(
                            '${_preferredHours.start.round()}:00',
                            '${_preferredHours.end.round()}:00',
                          ),
                          onChanged: (values) {
                            setState(() {
                              _preferredHours = values;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        ),
      ),
        ],
      ),
    );
  }
}
