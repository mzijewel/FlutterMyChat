import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mychat/models/User.dart';
import 'package:mychat/screens/friend/controllerUsers.dart';
import 'package:mychat/screens/room/chatScreen.dart';
import 'package:mychat/utils/customWidgets.dart';

class UsersScreen extends StatelessWidget {
  final controller = Get.put(ControllerUsers());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _buildListView(controller.users)),
    );
  }

  Widget _buildListView(List<MUser> users) {
    if (users == null || users.isEmpty)
      return Center(
        child: Text('No users are there'),
      );
    return ListView.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) {
        MUser user = users[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: InkWell(
            onTap: () => Get.to(ChatScreen(
              toUser: user,
            )),
            child: CustomWidgets.userWidget(user),
          ),
        );
      },
    );
  }
}
