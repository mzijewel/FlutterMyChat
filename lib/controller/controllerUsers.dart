import 'package:get/get.dart';
import 'package:mychat/models/User.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/firestoreService.dart';

class ControllerUsers extends GetxController {
  var userList = RxList<MUser>();
  var name = 'Jewel'.obs;

  List<MUser> get users => userList.value;

  @override
  void onInit() {
    String userId = LocatorService.authService().getUser().docId;
    userList.bindStream(FirestoreService.usersStream(userId));
  }
}
