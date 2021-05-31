import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/constants.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Text(
                Constants.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Constants.primaryColor,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 100,
            ),
            SignInButton(
              Buttons.GoogleDark,
              elevation: 10,
              onPressed: () => LocatorService.authService().signInWithGoogle(),
            ),
            SignInButton(
              Buttons.Facebook,
              onPressed: () => LocatorService.authService().signInWithFacebook(),
            ),
            SizedBox(
              height: 20,
            ),
            // Visibility(visible: _success, child: Center(child: CircularProgressIndicator()))
          ],
        ),
      ),
    );
  }
}
