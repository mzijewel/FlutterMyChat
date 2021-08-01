import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mychat/utils/utils.dart';

class MMessage {
  String docId;
  String message;
  String fromId;
  String imgUrl;
  DateTime createdAt;
  DateTime updatedAt;
  String fromName;
  List<String> seen;

  MMessage(
      {this.message,
      this.fromId,
      this.imgUrl,
      this.createdAt,
      this.updatedAt,
      this.fromName});

  MMessage.fromMap(Map<String, dynamic> json) {
    docId = Utils.getData(json, 'docId');
    message = Utils.getData(json, 'message');
    fromId = Utils.getData(json, 'fromId');
    fromName = Utils.getData(json, 'fromName');
    imgUrl = Utils.getData(json, 'imgUrl');
    seen = json['seen']?.cast<String>();
    createdAt = Utils.getDateTime(json['createdAt']);
    createdAt = Utils.getDateTime(json['updatedAt']);
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'fromId': fromId,
      'fromName': fromName,
      'imgUrl': imgUrl,
      'seen': seen,
      'createdAt': createdAt ?? DateTime.now(),
      'updatedAt': updatedAt ?? DateTime.now()
    };
  }

  bool isSeen() {
    return seen != null && seen.isNotEmpty;
  }

  static List<MMessage> parseList(List<QueryDocumentSnapshot> snapshots) {
    List<Map<String, dynamic>> mapList = snapshots.map((e) {
      Map<String, dynamic> data = e.data();
      data['docId'] = e.id;
      return data;
    }).toList();
    return mapList.map((e) => MMessage.fromMap(e)).toList();
  }

  static MMessage parseMessage(QueryDocumentSnapshot documentSnapshot) {
    MMessage message = MMessage.fromMap(documentSnapshot.data());
    message.docId = documentSnapshot.id;
    return message;
  }
}

class Seen {
  DateTime seenAt;

  Seen({this.seenAt});

  Seen.fromMap(Map<String, dynamic> map) {
    seenAt = Utils.getDateTime(map['seenAt']);
  }

  Map<String, dynamic> toMap() {
    return {'seenAt': seenAt ?? DateTime.now()};
  }
}
