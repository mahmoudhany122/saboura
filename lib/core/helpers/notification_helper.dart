import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      String? token = await messaging.getToken();
      log("FCM Token: $token");

      // Use @mipmap/logo since we renamed the app icons
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/logo');

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await _localNotificationsPlugin.initialize(initializationSettings);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log("Foreground Message received: ${message.notification?.title}");
        _showLocalNotification(message);
      });
    } catch (e) {
      log("Notification Init Error: $e");
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'saboura_channel_id',
      'Saboura Notifications',
      channelDescription: 'Notifications for Saboura LMS',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      // Note: Sound file must be in res/raw/notification_sound.mp3
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      // Also use the correct icon here
      icon: '@mipmap/logo',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
    );
  }

  static Future<void> sendPushNotification({
    required String title,
    required String body,
    required String targetToken,
  }) async {
    try {
      const String serverKey = "YOUR_FCM_SERVER_KEY"; 

      await Dio().post(
        'https://fcm.googleapis.com/fcm/send',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey',
          },
        ),
        data: jsonEncode({
          'notification': {
            'title': title,
            'body': body,
            'sound': 'notification_sound.mp3',
          },
          'priority': 'high',
          'to': targetToken,
        }),
      );
      log("Notification sent successfully");
    } catch (e) {
      log("Error sending notification: $e");
    }
  }
}
