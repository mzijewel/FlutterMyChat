import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mychat/models/User.dart';
import 'package:mychat/utils/constants.dart';

class CustomWidgets {
  static Widget circleAvatar(String imgUrl) {
    return ClipOval(
      child: CachedNetworkImage(
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        imageUrl: imgUrl ?? Constants.tmpImgUrl,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  static Widget inputField(String hint, Function(String) onChange,
      {bool isPassword = false}) {
    return TextFormField(
      obscureText: isPassword,
      style: TextStyle(color: Colors.white),
      onChanged: (_value) => onChange(_value),
      decoration: InputDecoration(
          hintText: hint,
          filled: true,
          contentPadding: EdgeInsets.only(left: 20),
          fillColor: Constants.primaryColor,
          hintStyle: TextStyle(color: Constants.txtColor2),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(36),
              borderSide: BorderSide(color: Colors.white54)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(36),
          )),
    );
  }

  static Widget userWidget(MUser user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        circleAvatar(user.photoUrl),
        SizedBox(
          width: 16,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  user.name ?? "",
                  style: TextStyle(
                      color: Constants.txtColor1,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 10,
                ),
                user.isOnline != null && user.isOnline
                    ? CircleAvatar(
                        radius: 6,
                        backgroundColor: Constants.primaryColor,
                      )
                    : Container()
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              'Hi there! I am using MyChat',
              style: TextStyle(fontSize: 14, color: Constants.txtColor2),
            ),
          ],
        )
      ],
    );
  }
}
