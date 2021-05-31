import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:mychat/models/User.dart';
import 'package:mychat/screens/friend/controllerUsers.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/customWidgets.dart';
import 'package:mychat/utils/firestoreService.dart';

class GroupScreen extends StatelessWidget {
  String groupName;
  List<String> members = [];
  String myId;
  final ControllerUsers controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            onChanged: (value) => groupName = value,
            decoration: InputDecoration(
              labelText: 'Group Name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
          RaisedButton(
            onPressed: () => _createGroup(),
            child: Text('Create Group'),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Select members for this group',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemCount: controller.users.length,
                itemBuilder: (context, index) {
                  MUser user = controller.users[index];
                  return InkWell(
                    onTap: () => _addToList(user),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomWidgets.userWidget(user),
                    ),
                  );
                })),
          ),
        ],
      ),
    );
  }

  void _addToList(MUser user) {
    String userId = user.docId;
    if (members.contains(userId)) {
      members.remove(userId);
      Fluttertoast.showToast(msg: '${user.name} removed from list');
    } else {
      members.add(userId);

      Fluttertoast.showToast(msg: '${user.name} added to list');
    }
  }

  void _createGroup() async {
    if (members.isEmpty) {
      Fluttertoast.showToast(msg: 'Please select at least one member');
      return;
    }
    if (groupName == null || groupName.isEmpty) {
      Fluttertoast.showToast(msg: 'Please type group name');
      return;
    }
    myId = LocatorService.authService().getUser().docId;
    if (!members.contains(myId)) members.add(myId);
    await FirestoreService.createGroup(groupName, members);
    Fluttertoast.showToast(msg: "Created a new group");
    Get.back();
  }
}
