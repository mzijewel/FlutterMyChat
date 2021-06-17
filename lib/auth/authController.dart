import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/views/signupScreen.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  String email, pass, name;

  Future onLogin() async {
    if (email == null || email.isEmpty || pass == null || pass.isEmpty) {
      Fluttertoast.showToast(msg: "Email & Password can not be empty");
      return;
    }
    LocatorService.authService().signInEmail(email, pass);
  }

  void goToSignup() {
    Get.to(SignupScreen());
  }

  void onSignup() {
    if (email == null ||
        email.isEmpty ||
        pass == null ||
        pass.length < 6 ||
        name == null ||
        name.isEmpty) {
      Fluttertoast.showToast(msg: "Name, Email & Password can not be empty");
      return;
    }
    LocatorService.authService().signupEmail(name, email, pass);
  }
}
