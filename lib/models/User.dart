import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mychat/utils/firestoreService.dart';
import 'package:mychat/utils/utils.dart';

class MUser {
  String name, email, phone, docId, photoUrl;
  String token;
  bool isOnline;
  DateTime createdAt, updatedAt, loginAt;

  MUser({this.name, this.token, this.email, this.phone, this.docId, this.photoUrl, this.loginAt, this.isOnline, this.createdAt, this.updatedAt});

  MUser.fromMap(Map<String, dynamic> json) {
    name = Utils.getData(json, 'name');
    email = Utils.getData(json, 'email');
    phone = Utils.getData(json, 'phone');
    token = Utils.getData(json, 'token');
    photoUrl = Utils.getData(json, 'photoUrl');
    isOnline = Utils.getData(json, 'isLogin');
    docId = Utils.getData(json, 'docId');
    createdAt = Utils.getDateTime(json['createdAt']);
    updatedAt = Utils.getDateTime(json['updatedAt']);
    loginAt = Utils.getDateTime(json['loginAt']);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'isLogin': isOnline,
      'loginAt': loginAt,
      'updatedAt': updatedAt,
      'createdAt': createdAt
    };
  }

  static List<MUser> parseList(List<QueryDocumentSnapshot> snapshots) {
    List<Map<String, dynamic>> mapList = snapshots.map((e) => FirestoreService.convertDocumentToMap(e)).toList();
    return mapList.map((e) => MUser.fromMap(e)).toList();
  }
}
