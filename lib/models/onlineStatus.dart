import 'package:mychat/utils/utils.dart';

class OnlineStatus {
  bool active;
  DateTime updatedAt;
  String docId;

  OnlineStatus({this.active = false, this.updatedAt});

  String getStatus() {
    if (active)
      return "Online";
    else
      return "Last seen at ${Utils.getDateTimeStr(updatedAt)}";
  }

  OnlineStatus.fromMap(Map<String, dynamic> json) {
    docId = json['docId'];
    active = json['active'] ?? false;
    updatedAt = Utils.getDateTime(json['updatedAt']);
  }

  Map<String, dynamic> toMap() {
    return {'active': active, 'updatedAt': updatedAt ?? DateTime.now()};
  }
}
