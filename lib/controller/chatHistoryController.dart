import 'package:get/get.dart';
import 'package:mychat/models/mRoom.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/firestoreService.dart';

class ChatHistoryController extends GetxController {
  var todoList = RxList<MRoom>();

  List<MRoom> get rooms => todoList.value;

  @override
  void onInit() {
    String userId = LocatorService.authService().getUser().docId;
    todoList.bindStream(FirestoreService.roomsStream(userId));
  }
}
