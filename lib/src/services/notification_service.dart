import 'dart:convert';
import 'dart:io';
import 'package:dose_reminder/src/models/dose.dart';
import 'package:dose_reminder/src/services/database_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

const String takenActionId = 'TAKEN_ACTION';
const String snoozeActionId = 'SNOOZE_ACTION';

final notificationServiceProvider = Provider<NotificationService>((ref) {
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

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      // iOS permissions are handled by FlutterLocalNotificationsPlugin
      return true;
    }
    return true;
  }

  Future<void> _onDidReceiveNotificationResponse(NotificationResponse response) async {
    if (response.payload == null) return;

    final payload = jsonDecode(response.payload!);
    final doseKey = payload['doseKey'] as int;

    final dbService = _ref.read(databaseServiceProvider);
    final dose = await dbService.getDose(doseKey);

    if (dose != null) {
      switch (response.actionId) {
        case takenActionId:
          dose.status = DoseStatus.taken;
          dose.takenTime = DateTime.now();
          await dbService.updateDose(dose);
          break;
        case snoozeActionId:
          await cancelNotification(response.id!);
          final snoozedTime = DateTime.now().add(const Duration(minutes: 30));
          final medicine = await dbService.getMedicineForDose(doseKey);
          if (medicine != null) {
            await scheduleDoseNotification(
              -dose.key, // Use negative key for snoozed notification to ensure uniqueness
              medicine.name,
              dose.key,
              snoozedTime,
            );
          }
          break;
      }
    }
  }

  Future<void> scheduleDoseNotification(int id, String medicineName, int doseKey, DateTime scheduledTime) async {
    final payload = jsonEncode({
      'doseKey': doseKey,
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
      payload: payload,
      matchDateTimeComponents: null,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
