
// // ============================================
// // FILE: lib/services/notification_service.dart
// // ============================================

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:permission_handler/permission_handler.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notifications =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     // Request permission
//     await Permission.notification.request();

//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );

//     await _notifications.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: _onNotificationTap,
//     );
//   }

//   static void _onNotificationTap(NotificationResponse response) {
//     // Handle notification tap
//     final payload = response.payload;
//     if (payload != null) {
//       // Navigate to ping details
//       print('Notification tapped with payload: $payload');
//     }
//   }

//   static Future<void> showNotification({
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     const androidDetails = AndroidNotificationDetails(
//       'pings_channel',
//       'Pings',
//       channelDescription: 'Gentle notifications for new pings',
//       importance: Importance.high,
//       priority: Priority.high,
//       playSound: true,
//       enableVibration: false, // Gentle notification
//     );

//     const iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     const details = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await _notifications.show(
//       DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       title,
//       body,
//       details,
//       payload: payload,
//     );
//   }

//   static Future<void> cancelAll() async {
//     await _notifications.cancelAll();
//   }
// }


//2 web 


import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Skip notification setup on web
    if (kIsWeb) {
      print('Notifications not available on web');
      return;
    }

    // Request permission (mobile only)
    await Permission.notification.request();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  static void _onNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      print('Notification tapped with payload: $payload');
    }
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) {
      // For web, use browser notifications or show in-app toast
      print('Notification: $title - $body');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'pings_channel',
      'Pings',
      channelDescription: 'Gentle notifications for new pings',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static Future<void> cancelAll() async {
    if (!kIsWeb) {
      await _notifications.cancelAll();
    }
  }
}