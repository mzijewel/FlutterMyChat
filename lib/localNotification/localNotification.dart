import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  var initializationSettings;

  init() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    if (Platform.isIOS) {
      _requestIosPermission();
    }
    initializePlatformSpecifics();
  }

  //notification is icon which is created in drawable
  initializePlatformSpecifics() {
    var initializationSettingsAndroid = AndroidInitializationSettings("@drawable/app_icon");
    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: false,
    );
    initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  _requestIosPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(alert: false, badge: true, sound: true);
  }

  setOnNotificationClick(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String payload) async {
        onNotificationClick(payload);
      },
    );
  }

  Future<void> showNotification(String title, String msg) async {
    var androidChannelSpecifics = AndroidNotificationDetails("CHANNEL_ID", "CHANNEL_NAME", "CHANNEL_DESCRIPTION",
        // icon: "notification",
        importance: Importance.Max,
        priority: Priority.High,
        playSound: true,
        timeoutAfter: 50000,
        styleInformation: DefaultStyleInformation(true, true));
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(androidChannelSpecifics, iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, title, msg, platformChannelSpecifics, payload: "test payload");
  }
}

// Notificati onPlugin notificationPlugin = NotificationPlugin._();
