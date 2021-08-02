import 'dart:developer';

import 'package:get/get.dart';
import 'package:mychat/models/mRoom.dart';
import 'package:mychat/models/unseenMessage.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/firestoreService.dart';

class ChatHistoryController extends GetxController {
  var todoList = RxList<MRoom>();
  var unseenList = RxList<UnseenMessage>();

  List<MRoom> get rooms {
    for (UnseenMessage unseenMessage in unseenList) {
      MRoom room = todoList
          .firstWhere((element) => element.docId == unseenMessage.roomId);
      room.unseenCount = unseenMessage.count;
      print('ROOM COUNT: ${room.unseenCount}');
    }
    print('rooms: ${todoList.length}');
    log('unseen count: ${unseenList.length}', name: 'Unseen');
    return todoList.value;
  }

  @override
  void onInit() {
    String userId = LocatorService.authService().getUser().docId;
    todoList.bindStream(FirestoreService.roomsStream(userId));
    unseenList.bindStream(FirestoreService.unseenMessagesStream(userId));
  }
}
