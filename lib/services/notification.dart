import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_management_app/main.dart';

Future<void> showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'task_channel', // Channel ID
    'Task Notifications', // Channel Name
    channelDescription: 'Notifications for tasks',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails();
  const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    title, // Title
    body, // Body
    platformChannelSpecifics,
  );
}
