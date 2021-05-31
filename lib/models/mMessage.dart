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

  MMessage({this.message, this.fromId, this.imgUrl, this.createdAt, this.updatedAt, this.fromName});

  MMessage.fromMap(Map<String, dynamic> json) {
    docId = Utils.getData(json, 'docId');
    message = Utils.getData(json, 'message');
    fromId = Utils.getData(json, 'fromId');
    fromName = Utils.getData(json, 'fromName');
    imgUrl = Utils.getData(json, 'imgUrl');
    createdAt = Utils.getDateTime(json['createdAt']);
    createdAt = Utils.getDateTime(json['updatedAt']);
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'fromId': fromId,
      'fromName': fromName,
      'imgUrl': imgUrl,
      'createdAt': createdAt ?? DateTime.now(),
      'updatedAt': updatedAt ?? DateTime.now()
    };
  }

  static List<MMessage> parseList(List<QueryDocumentSnapshot> snapshots) {
    List<Map<String, dynamic>> mapList = snapshots.map((e) {
      Map<String, dynamic> data = e.data();
      data['docId'] = e.id;
      return data;
    }).toList();
    return mapList.map((e) => MMessage.fromMap(e)).toList();
  }
}
