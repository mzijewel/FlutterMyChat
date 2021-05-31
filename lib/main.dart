import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mychat/screens/splash/splashScreen.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/constants.dart';
import 'package:mychat/utils/firestoreService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);
  setupLocator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        print('APP PAUSED');
        await FirestoreService.updateUserStatus(false);
        break;
      case AppLifecycleState.resumed:
        print('APP RESUMED');
        FirestoreService.updateUserStatus(true);
        break;
      case AppLifecycleState.detached:
        print('APP DETACHED');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appName,
      theme: ThemeData(
        primaryColor: Constants.primaryColor,
        accentColor: Constants.accentColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}
