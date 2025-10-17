// // ============================================
// // FILE: lib/services/firebase_service.dart
// // ============================================

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'notification_service.dart';

// class FirebaseService {
//   static Future<void> initialize() async {
//     await Firebase.initializeApp();
//     await NotificationService.initialize();
//     await _setupFCM();
//   }

//   static Future<void> _setupFCM() async {
//     final messaging = FirebaseMessaging.instance;
    
//     // Request permission
//     await messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       provisional: false,
//     );

//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (message.notification != null) {
//         NotificationService.showNotification(
//           title: message.notification!.title ?? 'New Ping',
//           body: message.notification!.body ?? 'You have a new message',
//           payload: message.data['pingId'],
//         );
//       }
//     });

//     // Handle background message tap
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       // Handle navigation when notification is tapped
//       if (message.data['pingId'] != null) {
//         // Navigate to ping details
//       }
//     });
//   }

//   static Future<String?> getFCMToken() async {
//     try {
//       return await FirebaseMessaging.instance.getToken();
//     } catch (e) {
//       print('Error getting FCM token: $e');
//       return null;
//     }
//   }
// }


//2-WEB

import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    await NotificationService.initialize();
    
    // Only setup FCM on mobile
    if (!kIsWeb) {
      await _setupFCM();
    }
  }

  static Future<void> _setupFCM() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        NotificationService.showNotification(
          title: message.notification!.title ?? 'New Ping',
          body: message.notification!.body ?? 'You have a new message',
          payload: message.data['pingId'],
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['pingId'] != null) {
        print('Navigate to ping: ${message.data['pingId']}');
      }
    });
  }

  static Future<String?> getFCMToken() async {
    try {
      if (kIsWeb) {
        // Web doesn't use FCM tokens in the same way
        return 'web_token_${DateTime.now().millisecondsSinceEpoch}';
      }
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }
}