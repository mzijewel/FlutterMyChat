import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/constants.dart';
import 'package:mychat/views/homeScreen.dart';
import 'package:mychat/views/loginScreen.dart';

class SplashScreen extends StatelessWidget {
  void _checkUser() async {
    bool isExist = await LocatorService.authService().checkUser();
    if (isExist) {
      Get.offAll(HomeScreen());
    } else {
      Get.offAll(LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primaryColor,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (LocatorService.authService().isLogged()) {
      _checkUser();
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              Constants.appName,
              style: TextStyle(color: Constants.primaryColor, fontSize: 50),
            ),
          ),
          SizedBox(
            height: 100,
          ),
          CircularProgressIndicator()
        ],
      );
    } else {
      return LoginScreen();
    }
  }
}
