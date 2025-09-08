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
  int? timesPerDay;

  @HiveField(4)
  int? everyXDays;

  @HiveField(5)
  List<int>? weeklyFrequency;

  @HiveField(6)
  int durationInDays;

  @HiveField(7)
  DateTime startDateTime;

  @HiveField(8)
  int preferredStartHour;

  @HiveField(9)
  int preferredEndHour;

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
    // doseHistory is now managed by Hive, not set in constructor
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
