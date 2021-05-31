import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:get/state_manager.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mychat/models/User.dart';
import 'package:mychat/screens/home/homeScreen.dart';
import 'package:mychat/screens/login/loginScreen.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/firestoreService.dart';

import 'authController.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthController authController = Get.put(AuthController());

  MUser _user;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
//      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  MUser getUser() {
    if (_auth.currentUser == null) return null;
    return _user;
  }

  void setUser(MUser user) {
    _user = user;
  }

  Future<void> signInWithGoogle() async {
    authController.isLoading.value = true;
    try {
      final GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
      final AuthCredential authCredential =
          GoogleAuthProvider.credential(idToken: googleSignInAuthentication.idToken, accessToken: googleSignInAuthentication.accessToken);

      User authUser;

      await _auth.signInWithCredential(authCredential).then((value) {
        // setState(() {
        //   _success = false;
        // });
        if (value.user != null) {
          authUser = value.user;
        } else {
          print("Signed null: ");
        }
      });

      await _signIn(authUser);

      authController.isLoading.value = false;
    } catch (error) {}
  }

  Future<void> signInWithFacebook() async {
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        print('s1');
        User authUser;
        await _auth
            .signInWithCredential(FacebookAuthProvider.credential(result.accessToken.token))
            .catchError((err) => log('$err', name: 'FACEBOOK AUTH'))
            .then((value) {
          if (value != null) authUser = value.user;
        });
        await _signIn(authUser);
        break;
      case FacebookLoginStatus.cancelledByUser:
        // _showCancelledMessage();
        print('Login cancel');
        Fluttertoast.showToast(msg: 'Login cancel');
        break;
      case FacebookLoginStatus.error:
        // _showErrorOnUI(result.errorMessage);
        print('Login err ${result.errorMessage}');
        Fluttertoast.showToast(msg: result.errorMessage);
        break;
    }
  }

  void _signIn(User authUser) async {
    if (authUser != null) {
      _user = await FirestoreService.checkUser(authUser.email);
      if (_user == null) {
        _user = MUser(
          docId: authUser.uid,
          email: authUser.email,
          name: authUser.displayName,
          phone: authUser.phoneNumber,
          photoUrl: authUser.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          loginAt: DateTime.now(),
          isOnline: true,
        );
        await FirestoreService.createUser(_user);
      } else {
        await FirestoreService.updateUserStatus(true);
      }
      LocatorService.fcmService().getToken();
      Get.offAll(HomeScreen());
    } else {
      Fluttertoast.showToast(msg: 'No Authentication found');
    }
  }

  bool isLogged() {
    return _auth.currentUser != null;
  }

  Future<bool> checkUser() async {
    if (_auth.currentUser == null) return false;
    MUser user = await FirestoreService.checkUser(_auth.currentUser.email);
    return user != null;
  }

  void signout() async {
    await FirestoreService.updateUserStatus(false);
    await _googleSignIn.signOut();
    await _auth.signOut();

    Get.offAll(LoginScreen());
  }
}
