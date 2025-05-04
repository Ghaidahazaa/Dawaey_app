// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';
import 'database_service.dart';
import 'adherence_page.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    final iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );

    final settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        final payload = response.payload ?? '';
        final parts = payload.split('|');

        if (parts.length >= 2) {
          final medName = parts[0];
          final scheduledTime = parts[1];

          final taken = response.actionId == 'taken';
          await DatabaseService().insertAdherenceLog(
            medName,
            scheduledTime,
            DateTime.now(),
            taken,
          );
          print("تم تسجيل الالتزام للدواء: $medName في $scheduledTime");
        } else {
          print("خطأ في تحليل الحمولة: $payload");
        }
      },
    );

    // iOS فقط: إعداد زر التفاعل
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleMedication({
    required String name,
    required String dosage,
    required DateTime firstDose,
    required int dosesPerDay,
    required int durationInDays,
    required bool isPermanent,
    required int intervalHours,
    required String frequency,
    required List<int> selectedDays,
  }) async {
    final interval = Duration(hours: intervalHours);

    for (int i = 0; i < dosesPerDay; i++) {
      final baseTime = firstDose.add(interval * i);

      for (int d = 0; isPermanent || d < durationInDays; d++) {
        final scheduled = baseTime.add(Duration(days: d));

        // تحقق من الأيام المحددة للتكرار
        if (frequency == 'weekly' && !selectedDays.contains(scheduled.weekday)) continue;
        if (frequency == 'monthly' && !selectedDays.contains(scheduled.day)) continue;

        final id = i + d * dosesPerDay;
        await _plugin.zonedSchedule(
          id,
          'جرعة $name',
          'الرجاء تناول الجرعة: $dosage',
          tz.TZDateTime.from(scheduled, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'med_channel_id',
              'Medication Reminders',
              importance: Importance.max,
              priority: Priority.high,
              actions: [
                AndroidNotificationAction('taken', 'تم التناول'),
                AndroidNotificationAction('skipped', 'تخطي'),
              ],
            ),
            iOS: DarwinNotificationDetails(
              categoryIdentifier: 'med_category',
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: '$name|${DateFormat('yyyy-MM-dd HH:mm').format(scheduled)}',
        );

        print("تم جدولة إشعار للدواء: $name في $scheduled");
      }
    }
  }
}
