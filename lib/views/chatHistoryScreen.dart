import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:mychat/controller/chatHistoryController.dart';
import 'package:mychat/models/mRoom.dart';
import 'package:mychat/utils/constants.dart';
import 'package:mychat/utils/utils.dart';
import 'package:mychat/views/chatScreen.dart';
import 'package:mychat/views/groupScreen.dart';

class ChatHistoryScreen extends StatelessWidget {
  final controller = Get.put<ChatHistoryController>(ChatHistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bodyColor,
      body: Padding(padding: const EdgeInsets.all(8.0), child: _body()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(GroupScreen());
        },
        child: Icon(Icons.add),
        backgroundColor: Constants.primaryColorDark,
      ),
    );
  }

  _body() {
    return Obx(() {
      if (controller.rooms.isNotEmpty)
        return _list(controller.rooms);
      else
        return Center(
            child: Text(
          'No chat history found',
          style: TextStyle(color: Constants.txtColor2),
        ));
    });
  }

  _list(List<MRoom> rooms) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
          // color: Constants.txtColor2,
          ),
      physics: BouncingScrollPhysics(),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        MRoom room = rooms[index];
        return _row(room);
      },
    );
  }

  _row(MRoom room) {
    return InkWell(
      onTap: () => Get.to(ChatScreen(
        room: room,
      )),
      child: Row(
        children: [
          !room.isGroup
              ? ClipOval(
                  child: CachedNetworkImage(
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    imageUrl: room.getPhotoUrl(),
                  ),
                )
              : CircleAvatar(
                  maxRadius: 25,
                  foregroundColor: Colors.red,
                  backgroundColor: Constants.primaryColor,
                  child: Text(
                    '${room.title.substring(0, 1).toUpperCase()}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${room.title}',
                        style: TextStyle(
                            color: Constants.txtColor1,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      Utils.getDateTimeStr(room.updatedAt),
                      style:
                          TextStyle(color: Constants.txtColor2, fontSize: 10),
                    )
                  ],
                ),
                SizedBox(
                  height: 2,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${room.lastMsg ?? 'No message'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Constants.txtColor2,
                        ),
                      ),
                    ),
                    if (room.unseenCount > 0)
                      CircleAvatar(
                        radius: 15,
                        child: Text(
                          '${room.unseenCount}',
                          style: TextStyle(fontSize: 12),
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
