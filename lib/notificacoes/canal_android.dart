import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void setupNotificationChannel() {
  if (Platform.isAndroid) {
    const String channelId = 'default_notification_channel';
    const String channelName = 'Default';
    //const String channelDescription = 'Default channel for push notifications';

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      channelName,
      importance: Importance.high, // você pode ajustar isso conforme a necessidade
    );

    final FlutterLocalNotificationsPlugin localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}