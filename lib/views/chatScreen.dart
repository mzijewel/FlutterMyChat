import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mychat/auth/chatController.dart';
import 'package:mychat/models/User.dart';
import 'package:mychat/models/mMessage.dart';
import 'package:mychat/models/mRoom.dart';
import 'package:mychat/utils/constants.dart';
import 'package:mychat/utils/firebaseStorageService.dart';
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

  final _controller = Get.put(ChatController());

  @override
  void initState() {
    super.initState();
    _controller.init(widget.room, widget.toUser);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.setActivityInRoom(false);
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

  _appBar() {
    return AppBar(
      backgroundColor: Constants.primaryColor,
      elevation: 0,
      leadingWidth: 25,
      title: Row(
        children: [
          !widget.room.isGroup
              ? ClipOval(
                  child: CachedNetworkImage(
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    imageUrl: widget.room.getPhotoUrl(),
                  ),
                )
              : CircleAvatar(
                  maxRadius: 25,
                  foregroundColor: Colors.red,
                  backgroundColor: Constants.primaryColor,
                  child: Text(
                    '${widget.room.title.substring(0, 1).toUpperCase()}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _controller.getName(),
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Obx(() => Text(
                    _controller.getStatus(),
                    style: TextStyle(fontSize: 12),
                  )),
            ],
          ),
        ],
      ),
      iconTheme: new IconThemeData(color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Constants.bodyColor,
      appBar: _appBar(),
      body: Column(
        children: [
          Expanded(child: _buildList()),
          _buildSendMessage(),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  _buildList() {
    if (widget.room == null || widget.room.docId == null)
      return Center(
        child: Text('Loading...'),
      );
    else
      return Obx(() => ListView.builder(
            reverse: true,
            shrinkWrap: true,
            itemCount: _controller.getMessages().length,
            itemBuilder: (context, index) =>
                _buildRow(_controller.getMessages()[index]),
          ));
  }

  _buildRow(MMessage message) {
    _controller.updateMessageSeen(message);

    return Container(
      padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
      child: Align(
        alignment: message.fromId == _controller.currentUser.docId
            ? Alignment.topRight
            : Alignment.topLeft,
        child: Container(
          decoration: BoxDecoration(
            color: message.fromId == _controller.currentUser.docId
                ? Colors.teal.shade900
                : Constants.primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: message.fromId == _controller.currentUser.docId
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.imgUrl != null && message.imgUrl.isNotEmpty)
                InkWell(
                  onTap: () => _openImage(message.imgUrl),
                  child: message.imgUrl.contains('/data')
                      // https://stackoverflow.com/questions/49835623/how-to-load-images-with-image-file/56431615
                      ? Image.file(
                          File(message.imgUrl),
                          width: Get.width * 0.6,
                        )
                      : CachedNetworkImage(
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
              if (widget.room.isGroup &&
                  message.fromId != _controller.currentUser.docId)
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
                  if (message.fromId == _controller.currentUser.docId)
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

  _buildSendMessage() {
    return Row(
      children: [
        SizedBox(
          width: 10,
        ),
        Expanded(
            child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Row(
            children: [
              Expanded(
                  child: TextFormField(
                    controller: _controller.messageController,
                style: TextStyle(color: Constants.txtColor1),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type a message',
                  filled: true,
                  suffixIcon: InkWell(
                    // borderRadius: BorderRadius.circular(30),
                    splashColor: Colors.transparent,
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                    onTap: () {
                      _controller.pickImage();
                    },
                  ),
                  fillColor: Constants.primaryColor,
                  hintStyle: TextStyle(color: Constants.txtColor2),
                ),
              )),
            ],
          ),
        )),
        SizedBox(
          width: 10,
        ),
        CircleAvatar(
          radius: 25,
          backgroundColor: Constants.primaryColor,
          child: IconButton(
            color: _controller.messageController.text.isEmpty
                ? Colors.grey
                : Colors.teal,
            icon: Icon(Icons.send),
            onPressed: () {
              _controller.sendMessage();
            },
          ),
        ),
        SizedBox(
          width: 10,
        ),
      ],
    );
  }
}
