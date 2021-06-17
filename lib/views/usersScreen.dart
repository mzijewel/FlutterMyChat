import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mychat/controller/controllerUsers.dart';
import 'package:mychat/models/User.dart';
import 'package:mychat/utils/constants.dart';
import 'package:mychat/utils/customWidgets.dart';
import 'package:mychat/views/chatScreen.dart';

class UsersScreen extends StatelessWidget {
  final controller = Get.put(ControllerUsers());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.bodyColor,
      body: Obx(() => _buildListView(controller.users)),
    );
  }

  Widget _buildListView(List<MUser> users) {
    if (users == null || users.isEmpty)
      return Center(
        child: Text('No users are there'),
      );
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(
        color: Constants.txtColor2,
      ),
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
