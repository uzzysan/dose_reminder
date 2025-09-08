import 'dart:convert';
import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/services/database_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const String takenActionId = 'TAKEN_ACTION';
const String snoozeActionId = 'SNOOZE_ACTION';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  // Pass the ref to the service to allow it to read other providers.
  return NotificationService(ref);
});

class NotificationService {
  final Ref _ref;
  NotificationService(this._ref);

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _initTimezones();

    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  Future<void> _initTimezones() async { 
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> _onDidReceiveNotificationResponse(NotificationResponse response) async {
    if (response.payload == null) return;

    final payload = jsonDecode(response.payload!);
    final medicineKey = payload['medicineKey'] as int;
    final scheduledTimeString = payload['scheduledTime'] as String;
    final scheduledTime = DateTime.parse(scheduledTimeString);

    final dbService = _ref.read(databaseServiceProvider);

    switch (response.actionId) {
      case takenActionId:
        await dbService.updateDoseStatus(medicineKey, scheduledTime, DoseStatus.taken);
        break;
      case snoozeActionId:
        final snoozedTime = DateTime.now().add(const Duration(minutes: 30));
        // We need medicine name for the notification body
        final medicine = await dbService.getMedicine(medicineKey);
        if (medicine != null) {
          await scheduleDoseNotification(
            response.id! + 1000000, // Create a new unique ID for the snoozed notification
            medicine.name,
            medicineKey,
            snoozedTime,
          );
        }
        break;
    }
  }

  Future<void> scheduleDoseNotification(int id, String medicineName, int medicineKey, DateTime scheduledTime) async {
    final payload = jsonEncode({
      'medicineKey': medicineKey,
      'scheduledTime': scheduledTime.toIso8601String(),
    });

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'dose_reminder_channel_id',
        'Dose Reminders',
        channelDescription: 'Channel for medicine dose reminders',
        importance: Importance.max,
        priority: Priority.high,
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(takenActionId, 'Taken'),
          const AndroidNotificationAction(snoozeActionId, 'Snooze (30 min)'),
        ],
      ),
      iOS: const DarwinNotificationDetails(categoryIdentifier: 'doseCategory'),
    );

    await _plugin.zonedSchedule(
      id,
      'Time for your dose!',
      'It\'s time to take your $medicineName.',
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }
}
