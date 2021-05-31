import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mychat/models/User.dart';

class CustomWidgets {
  static Widget circleAvatar(String imgUrl) {
    return ClipOval(
      child: CachedNetworkImage(
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        imageUrl: imgUrl,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(),
        ),
      ),
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
                  user.name,
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),
                SizedBox(
                  width: 10,
                ),
                user.isOnline != null && user.isOnline
                    ? CircleAvatar(
                        radius: 6,
                        backgroundColor: Colors.green,
                      )
                    : Container()
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Text('Hi there! I am using MyChat'),
          ],
        )
      ],
    );
  }
}
