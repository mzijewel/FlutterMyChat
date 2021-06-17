import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mychat/auth/authController.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/constants.dart';
import 'package:mychat/utils/customWidgets.dart';

class LoginScreen extends StatelessWidget {
  final AuthController _authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      backgroundColor: Constants.primaryColor,
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 60,
              ),
              Center(
                child: Text(
                  Constants.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Constants.txtColor1,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 100,
              ),
              CustomWidgets.inputField(
                  'Email', (value) => _authController.email = value),
              SizedBox(
                height: 10,
              ),
              CustomWidgets.inputField(
                  'Password', (value) => _authController.pass = value,
                  isPassword: true),
              SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: () => _authController.goToSignup(),
                child: Text(
                  "Don't have an account? SignUp",
                  style: TextStyle(color: Constants.txtColor2),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Obx(
                () => _authController.isLoading.value
                    ? SizedBox(
                        height: 50,
                        width: 50,
                        child: CircularProgressIndicator(),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _authController.onLogin(),
                          child: Text('Login'),
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(36)),
                              primary: Constants.primaryColorDark),
                        )),
              ),

              SizedBox(
                height: 20,
              ),
              Text(
                'OR',
                style: TextStyle(color: Constants.txtColor2, fontSize: 18),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () =>
                        LocatorService.authService().signInWithGoogle(),
                    child: Container(
                      width: 50,
                      height: 50,
                      child: Image.asset('assets/google.png'),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () =>
                        LocatorService.authService().signInWithFacebook(),
                    child: Container(
                      width: 50,
                      height: 50,
                      child: Image.asset('assets/facebook.png'),
                    ),
                  ),
                ],
              ),
              // Visibility(visible: _success, child: Center(child: CircularProgressIndicator()))
            ],
          ),
        ),
      ),
    );
  }
}
