import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mychat/models/User.dart';
import 'package:mychat/models/mMessage.dart';
import 'package:mychat/models/mRoom.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/constants.dart';
import 'package:mychat/utils/firebaseStorageService.dart';
import 'package:mychat/utils/firestoreService.dart';
import 'package:mychat/utils/utils.dart';

class ChatScreen extends StatefulWidget {
  final MUser toUser;
  final MRoom room;

  const ChatScreen({Key key, this.toUser, this.room}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final TextEditingController _messageController = TextEditingController();
  List<MMessage> messges = [];
  File pickedImgFile;
  MUser currentUser;
  MRoom room;

  @override
  void initState() {
    super.initState();
    currentUser = LocatorService.authService().getUser();
    room = widget.room;
    if (room == null || room.docId == null)
      _getRoom();
    else {
      _setActivityInRoom(true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _setActivityInRoom(false);
  }

  String _getName() {
    if (widget.room != null) return room.title;
    return widget.toUser.name;
  }

  void _openImage(String url) async {
    final bytes = await FirebaseStorageService.imageDownload(url);
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.white,
      content: Image.memory(
        bytes,
        fit: BoxFit.fill,
      ),
      duration: Duration(hours: 100),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Constants.bodyColor,
      appBar: AppBar(
        backgroundColor: Constants.primaryColor,
        title: Text(
          _getName(),
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [Expanded(child: _buildList()), _buildSendMessage()],
      ),
    );
  }

  Widget _buildList() {
    if (room == null || room.docId == null)
      return Center(
        child: Text('Loading...'),
      );
    else
      return StreamBuilder<QuerySnapshot>(
        stream: FirestoreService.getMessages(room.docId),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError)
            return Center(child: Text('Something went wrong'));
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: Text('Loading...'));

          return ListView.builder(
            reverse: true,
            shrinkWrap: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              MMessage message =
                  MMessage.parseMessage(snapshot.data.docs[index]);

              return _buildRow(message);
            },
          );
        },
      );
  }

  _updateMessageSeen(MMessage message) {
    if (message.fromId != currentUser.docId && !message.isSeen()) {
      FirestoreService.updateMessageSeen(
          room.docId, message.docId, currentUser.docId);
    }
  }

  Widget _buildRow(MMessage message) {
    _updateMessageSeen(message);

    return Container(
      padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: Align(
        alignment: message.fromId == currentUser.docId
            ? Alignment.topRight
            : Alignment.topLeft,
        child: Container(
          decoration: BoxDecoration(
            color: message.fromId == currentUser.docId
                ? Colors.teal.shade900
                : Constants.primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: message.fromId == currentUser.docId
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.imgUrl != null && message.imgUrl.isNotEmpty)
                InkWell(
                  onTap: () => _openImage(message.imgUrl),
                  child: CachedNetworkImage(
                    imageUrl: message.imgUrl,
                    width: Get.width * 0.6,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              SizedBox(
                height: 5,
              ),
              if (room.isGroup && message.fromId != currentUser.docId)
                Text(
                  message.fromName ?? '',
                  style: TextStyle(color: Constants.txtColor1),
                ),
              Text(
                message.message,
                style: TextStyle(color: Constants.txtColor1),
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Utils.getDateTimeStr(message.createdAt),
                    style: TextStyle(color: Constants.txtColor2, fontSize: 10),
                  ),
                  if (message.fromId == currentUser.docId)
                    Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Image.asset(
                        message.isSeen()
                            ? Constants.assetTikDouble
                            : Constants.assetTik,
                        width: 10,
                        height: 10,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendMessage() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: Row(
        children: [
          Expanded(
              child: TextFormField(
            controller: _messageController,
            decoration: InputDecoration(
                hintText: 'Message...',
                filled: true,
                fillColor: Constants.primaryColor,
                hintStyle: TextStyle(color: Constants.txtColor2),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(36),
                    borderSide: BorderSide(color: Constants.txtColor2)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(36),
                    borderSide: BorderSide(color: Colors.white))),
          )),
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              _pickImage();
            },
          ),
          IconButton(
            color: _messageController.text.isEmpty ? Colors.grey : Colors.teal,
            icon: Icon(Icons.send),
            onPressed: () {
              _sendMessage();
            },
          )
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (room == null) return;
    String msg = _messageController.text;
    if (msg.isEmpty) {
      Fluttertoast.showToast(msg: 'Empty msg!');
      return;
    }
    _messageController.clear();

    MMessage message = MMessage(
        fromId: currentUser.docId,
        fromName: LocatorService.authService().getUser().name,
        message: msg,
        createdAt: DateTime.now());
    await FirestoreService.sendMessage(
        room.docId, message, pickedImgFile, false);

    pickedImgFile = null;

    _pushToInactiveMembers(msg);
  }

  void _pickImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      pickedImgFile = File(pickedImage.path);
    }
  }

  void _getRoom() async {
    room =
        await FirestoreService.getRoom(currentUser.docId, widget.toUser.docId);
    if (room != null) {
      _setActivityInRoom(true);
      setState(() {});
    }
  }

  void _setActivityInRoom(bool isActive) async {
    if (room != null)
      await FirestoreService.setActivityInRoom(
          room.docId, currentUser.docId, isActive);
  }

  void _pushToInactiveMembers(String msg) async {
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
        MUser user = await FirestoreService.getUser(id);
        if (user != null) {
          LocatorService.fcmService()
              .pushTo('New message from ${currentUser.name}', msg, user.token);
        }
      }
    }
  }
}
