import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mychat/models/User.dart';
import 'package:mychat/models/mMessage.dart';
import 'package:mychat/models/mRoom.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/constants.dart';
import 'package:mychat/utils/customWidgets.dart';
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
    print('Out from Chat room');
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
      appBar: AppBar(
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

  Widget _leading() {
    if (room != null && !room.isGroup)
      return CustomWidgets.circleAvatar(room.getPhotoUrl());
    else
      return CircleAvatar(
        maxRadius: 25,
        foregroundColor: Colors.red,
        backgroundColor: Constants.primaryColor,
        child: Text(
          '${room.title.substring(0, 1).toUpperCase()}',
          style: TextStyle(color: Colors.white),
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
          if (snapshot.hasError) return Center(child: Text('Something went wrong'));
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: Text('Loading...'));

          return ListView.builder(
            reverse: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index) {
              MMessage message = MMessage.fromMap(snapshot.data.docs[index].data());
              return _buildMessage(message);
            },
          );
        },
      );
  }

  Widget _buildMessage(MMessage message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: message.fromId == currentUser.docId ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: message.fromId == currentUser.docId ? Colors.green[200] : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    if (room.isGroup && message.fromId != currentUser.docId)
                      Align(
                        child: Text(
                          message.fromName ?? '',
                          style: TextStyle(color: Colors.green),
                        ),
                        alignment: Alignment.topLeft,
                      ),
                    Align(
                      child: Text(message.message),
                      alignment: Alignment.topLeft,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    if (message.imgUrl != null && message.imgUrl.isNotEmpty)
                      InkWell(
                        onTap: () => _openImage(message.imgUrl),
                        child: CachedNetworkImage(
                          imageUrl: message.imgUrl,
                          width: 50,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 5,
                    ),
                    Align(
                      child: Text(
                        Utils.getDateTimeStr(message.createdAt),
                        style: TextStyle(color: Colors.black, fontSize: 10),
                      ),
                      alignment: Alignment.bottomRight,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.brown))),
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

    MMessage message =
    MMessage(fromId: currentUser.docId, fromName: LocatorService
        .authService()
        .getUser()
        .name, message: msg, createdAt: DateTime.now());
    await FirestoreService.sendMessage(room.docId, message, pickedImgFile, false);

    pickedImgFile = null;

    _pushToInactiveMembers(msg);
  }

  void _pickImage() async {
    final pickedImage = await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      pickedImgFile = File(pickedImage.path);
    }
  }

  void _getRoom() async {
    room = await FirestoreService.getRoom(currentUser.docId, widget.toUser.docId);
    if (room != null) {
      _setActivityInRoom(true);
      setState(() {});
    }
  }

  void _setActivityInRoom(bool isActive) async {
    if (room != null) await FirestoreService.setActivityInRoom(room.docId, currentUser.docId, isActive);
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
          LocatorService.fcmService().pushTo('New message from ${currentUser.name}', msg, user.token);
          log('push sent-${user.name}', name: 'CHAT SCREEN');
        }
      }
    }
  }
}
