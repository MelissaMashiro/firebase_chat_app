import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Future<void> initialize() async {
    //el icono que tendra la notificacion
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher'); //ANDROID
    var iOSInitialize = const DarwinInitializationSettings(); //IOS

    var initializeSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializeSettings,
      onDidReceiveNotificationResponse: (data) {},
    );

    
  }
}
