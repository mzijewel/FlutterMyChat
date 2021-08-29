import 'package:mychat/models/User.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/constants.dart';
import 'package:mychat/utils/utils.dart';

class MRoom {
  String docId;
  String title;
  String lastMsg;
  String lastFromId;
  List<String> members;
  bool isGroup;
  DateTime updatedAt;
  int unseenCount;
  Map<String, dynamic> avatars;

  MUser user;

  MRoom(
      {this.title,
      this.lastFromId,
      this.members,
      this.isGroup = false,
      this.lastMsg,
      this.updatedAt,
      this.docId,
      this.user,
      this.avatars});

  MRoom.fromMap(Map<String, dynamic> json) {
    docId = Utils.getData(json, 'docId');
    isGroup = Utils.getData(json, 'isGroup') ?? false;
    lastFromId = Utils.getData(json, 'lastFromId');
    lastMsg = Utils.getData(json, 'lastMsg');
    members = json.containsKey('members') ? json['members'].cast<String>() : [];

    updatedAt = Utils.getDateTime(json['updatedAt']);
    avatars = json['avatars'] ?? {};
    title = json['title'] ?? getTitle();
    unseenCount = 0;
  }

  String getTitle() {
    String myId = LocatorService.authService().getUser().docId;
    String title = 'No Title';
    avatars.forEach((key, value) {
      if (key != myId) {
        title = value['name'];
      }
    });
    return title;
  }

  String getFriendId() {
    String myId = LocatorService.authService().getUser().docId;
    return members.firstWhere((element) => element != myId);
  }

  String getPhotoUrl() {
    String url = Constants.tmpImgUrl;
    if (!isGroup) {
      String myId = LocatorService.authService().getUser().docId;

      avatars.forEach((key, value) {
        if (key != myId) {
          url = value['photoUrl'];
        }
      });
    }

    return url;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'lastMsg': lastMsg,
      'members': members,
      'isGroup': isGroup,
      'avatars': avatars,
      'updatedAt': DateTime.now(),
    };
  }
}

class Avatar {
  String name;
  String photoUrl;

  Avatar.fromMap(Map<String, dynamic> map) {
    this.name = map['name'];
    this.photoUrl = map['photoUrl'];
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photoUrl': photoUrl,
    };
  }

  Avatar.fromUser(MUser user) {
    this.name = user.name;
    this.photoUrl = user.photoUrl;
  }
}
