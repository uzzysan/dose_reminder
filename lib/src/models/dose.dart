import 'package:hive/hive.dart';

part 'dose.g.dart';

@HiveType(typeId: 2)
class Dose extends HiveObject {
  @HiveField(0)
  final DateTime scheduledTime;

  @HiveField(1)
  DateTime? takenTime;

  @HiveField(2)
  DoseStatus status;

  Dose({
    required this.scheduledTime,
    this.takenTime,
    this.status = DoseStatus.pending,
  });
}

@HiveType(typeId: 3)
enum DoseStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  taken,

  @HiveField(2)
  skipped,
}
