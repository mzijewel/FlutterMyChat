import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/constants.dart';
import 'package:mychat/utils/firestoreService.dart';

class PushNotificationService {
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        log('OnMessage $message', name: 'PUSH');
        print(message);
        String title = message['notification']['title'];
        String msg = message['notification']['body'];
        LocatorService.localNotification().showNotification(title, msg);
        return;
      },
      // onBackgroundMessage: (message) {
      //   log('OnBackground', name: 'PUSH');
      // },
      onLaunch: (message) {
        log('OnLaunch', name: 'PUSH');
        return;
      },
    );
  }

  Future getToken() async {
    firebaseMessaging.getToken().then((value) {
      FirestoreService.saveToken(value);
    });
    firebaseMessaging.onTokenRefresh.listen((token) {
      log('TOKEN REFRESH: ${token}', name: 'TOKEN');
      FirestoreService.saveToken(token);
    });
  }

  void pushTo(String title, String msg, String toToken) async {
    await firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: false),
    );
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=${Constants.serverToken}',
    };
    Map<String, dynamic> body = {
      'notification': {
        'title': title,
        'body': msg,
      },
      'to': toToken,
    };
    String bodyJson = jsonEncode(body);
    print(bodyJson);
    await http.post(
      Constants.fcmUrl,
      headers: headers,
      body: bodyJson,
    );
  }
}
