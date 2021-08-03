import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mychat/models/User.dart';
import 'package:mychat/models/mMessage.dart';
import 'package:mychat/models/mRoom.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/firestoreService.dart';

class ChatController extends GetxController {
  final _status = 'online'.obs;
  final _messages = RxList<MMessage>();
  final TextEditingController messageController = TextEditingController();
  MRoom room;
  File pickedImgFile;
  MUser currentUser, toUser;

  void init(MRoom room, MUser toUser) {
    currentUser = LocatorService.authService().getUser();
    this.toUser = toUser;
    if (room == null) {
      getRoom();
    } else {
      this.room = room;
      _messages.bindStream(FirestoreService.getMessages(this.room.docId));
    }
  }

  String getName() {
    if (room != null) return room.title;
    return toUser.name;
  }

  String getStatus() {
    return _status.value;
  }

  List<MMessage> getMessages() {
    return _messages;
  }

  updateMessageSeen(MMessage message) {
    if (message.fromId != currentUser.docId && !message.isSeen()) {
      FirestoreService.updateMessageSeen(
          room.docId, message.docId, currentUser.docId);
    }
  }

  void sendMessage() async {
    if (room == null) return;
    String msg = messageController.text;
    if (msg.isEmpty && pickedImgFile == null) {
      Fluttertoast.showToast(msg: 'Empty msg!');
      return;
    }
    messageController.clear();

    MMessage message = MMessage(
        fromId: currentUser.docId,
        fromName: LocatorService.authService().getUser().name,
        message: msg,
        imgUrl: pickedImgFile.path,
        createdAt: DateTime.now());
    await FirestoreService.sendMessage(
        room.docId, message, pickedImgFile, false);

    pickedImgFile = null;

    pushToInactiveMembers(msg);
  }

  void pushToInactiveMembers(String msg) async {
    print('call push: ${room.docId}');
    final activeMembers = await FirestoreService.getActiveMembers(room.docId);
    List<String> inactiveMembers = [];
    room.members.forEach((element) {
      if (activeMembers != null && activeMembers.isNotEmpty) {
        if (!activeMembers.contains(element)) inactiveMembers.add(element);
      } else {
        if (element != currentUser.docId) inactiveMembers.add(element);
      }
    });
    if (inactiveMembers.isNotEmpty) {
      for (String id in inactiveMembers) {
        print('user: $id');
        MUser user = await FirestoreService.getUser(id);
        if (user != null) {
          print('send : ${user.docId}');
          LocatorService.fcmService()
              .pushTo('New message from ${currentUser.name}', msg, user.token);
          FirestoreService.incrementUnseen(user.docId, room.docId);
        }
      }
    }
  }

  void setActivityInRoom(bool isActive) async {
    if (room != null)
      await FirestoreService.setActivityInRoom(
          room.docId, currentUser.docId, isActive);
  }

  void getRoom() async {
    room = await FirestoreService.getRoom(currentUser.docId, toUser.docId);
    if (room != null) {
      setActivityInRoom(true);
    }
  }

  void pickImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      pickedImgFile = File(pickedImage.path);
      sendMessage();
      print('image: ${pickedImage.path}');
    }
  }
}
