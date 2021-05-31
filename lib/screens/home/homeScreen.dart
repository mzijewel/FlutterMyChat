import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mychat/screens/chat/chatHistoryScreen.dart';
import 'package:mychat/screens/friend/usersScreen.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/constants.dart';
import 'package:mychat/utils/firestoreService.dart';

class HomeScreen extends StatelessWidget {
  updateUser(bool isOnline) async {
    await FirestoreService.updateUserStatus(isOnline);
    if (!isOnline) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              Constants.appName,
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: new IconThemeData(color: Colors.white),
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: handleClick,
                itemBuilder: (BuildContext context) {
                  return {'Sign out'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              ),
            ],
            bottom: new TabBar(
              isScrollable: false,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: ['CHATS', 'FRIENDS'].map((choice) {
                return new Tab(
                  text: choice,
                );
              }).toList(),
            ),
          ),
          body: WillPopScope(
            child: TabBarView(children: [ChatHistoryScreen(), UsersScreen()]),
            onWillPop: _onWillPop,
          ),
        ));
  }

  Future<bool> _onWillPop() async {
    await FirestoreService.updateUserStatus(false);
    return true;
  }

  void handleClick(String value) {
    switch (value) {
      case 'Sign out':
        LocatorService.authService().signout();

        break;
    }
  }
}
