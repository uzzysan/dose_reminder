import 'package:hive/hive.dart';
import 'dose.dart';

part 'medicine.g.dart';

@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? photoPath;

  @HiveField(2)
  FrequencyType frequencyType;

  @HiveField(3)
  int? timesPerDay; // For daily frequency

  @HiveField(4)
  int? everyXDays; // For every X days frequency

  @HiveField(5)
  List<int>? weeklyFrequency; // For weekly, e.g., [1, 3, 5] for Mon, Wed, Fri

  @HiveField(6)
  int durationInDays;

  @HiveField(7)
  DateTime startDateTime;

  @HiveField(8)
  int preferredStartHour; // e.g., 7 for 7am

  @HiveField(9)
  int preferredEndHour; // e.g., 21 for 9pm

  @HiveField(10)
  HiveList<Dose>? doseHistory;

  Medicine({
    required this.name,
    this.photoPath,
    required this.frequencyType,
    this.timesPerDay,
    this.everyXDays,
    this.weeklyFrequency,
    required this.durationInDays,
    required this.startDateTime,
    this.preferredStartHour = 7,
    this.preferredEndHour = 21,
  });
}

@HiveType(typeId: 1)
enum FrequencyType {
  @HiveField(0)
  daily,

  @HiveField(1)
  everyXDays,

  @HiveField(2)
  weekly,
}
