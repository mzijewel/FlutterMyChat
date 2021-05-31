import 'package:get_it/get_it.dart';
import 'package:mychat/auth/authService.dart';
import 'package:mychat/localNotification/localNotification.dart';
import 'package:mychat/service/pushNotificationService.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => PushNotificationService());
  locator.registerLazySingleton(() => LocalNotification());
  locator.registerLazySingleton(() => AuthService());

  // locator<PushNotificationService>().getToken();
  locator<PushNotificationService>().registerNotification();
  locator<LocalNotification>().init();
}

abstract class LocatorService {
  static PushNotificationService fcmService() => locator<PushNotificationService>();

  static LocalNotification localNotification() => locator<LocalNotification>();

  static AuthService authService() => locator<AuthService>();
}
