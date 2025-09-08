import 'dart:io';
// import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/models/medicine.dart';
import 'package:dose_reminder/src/services/database_service.dart';
import 'package:dose_reminder/src/services/notification_service.dart';
import 'package:dose_reminder/src/services/scheduling_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dose_reminder/l10n/app_localizations.dart';

class AddEditMedicineScreen extends ConsumerStatefulWidget {
  const AddEditMedicineScreen({super.key});

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

  Widget _buildFrequencyFields() {
    final l10n = AppLocalizations.of(context)!;
    switch (_frequencyType) {
      case FrequencyType.daily:
        return TextFormField(
          decoration: InputDecoration(labelText: l10n.timesPerDay),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty)
              return l10n.pleaseEnterHowManyTimesPerDay;
            if (int.tryParse(value) == null || int.parse(value) <= 0)
              return l10n.invalidNumber;
            return null;
          },
          onSaved: (value) => _timesPerDay = int.tryParse(value!),
        );
      case FrequencyType.everyXDays:
        return TextFormField(
          decoration: InputDecoration(labelText: l10n.everyXDays),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value == null || value.isEmpty)
              return l10n.pleaseEnterTheIntervalInDays;
            if (int.tryParse(value) == null || int.parse(value) <= 0)
              return l10n.invalidNumber;
            return null;
          },
          onSaved: (value) => _everyXDays = int.tryParse(value!),
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

                final dbService = ref.read(databaseServiceProvider);
                final schedulingService = ref.read(schedulingServiceProvider);
                final notificationService = ref.read(
                  notificationServiceProvider,
                );

                // 1. Create medicine object without doses
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

                // 2. Save to DB to get a key
                final medicineKey = await dbService.addMedicine(newMedicine);

                // 3. Get the managed instance from Hive
                final managedMedicine = await dbService.getMedicine(
                  medicineKey,
                );

                if (managedMedicine != null) {
                  // 4. Generate doses and add them to the HiveList
                  final doses = schedulingService.generateDoses(
                    managedMedicine,
                  );
                  managedMedicine.doseHistory?.addAll(doses);
                  await managedMedicine.save();

                  // 5. Schedule notifications
                  for (var dose in managedMedicine.doseHistory!) {
                    final notificationId = dose
                        .scheduledTime
                        .millisecondsSinceEpoch
                        .remainder(100000);
                    await notificationService.scheduleDoseNotification(
                      notificationId,
                      managedMedicine.name,
                      medicineKey, // Pass the key
                      dose.scheduledTime,
                    );
                  }
                }

                if (!mounted) return; // Early exit if widget is unmounted
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
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
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FrequencyType>(
                decoration: InputDecoration(
                  labelText: l10n.frequency,
                  border: const OutlineInputBorder(),
                ),
                value: _frequencyType,
                items: FrequencyType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
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
              const SizedBox(height: 16),
              _buildFrequencyFields(),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: l10n.durationInDays,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return l10n.pleaseEnterTheDuration;
                  if (int.tryParse(value) == null || int.parse(value) <= 0)
                    return l10n.pleaseEnterAValidNumberOfDays;
                  return null;
                },
                onSaved: (value) => _durationInDays = int.tryParse(value!),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.preferredHours}: ${_preferredHours.start.round()}:00 - ${_preferredHours.end.round()}:00',
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
