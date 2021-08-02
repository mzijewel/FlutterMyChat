import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mychat/controller/controllerUsers.dart';
import 'package:mychat/models/User.dart';
import 'package:mychat/models/mMessage.dart';
import 'package:mychat/models/mRoom.dart';
import 'package:mychat/models/unseenMessage.dart';
import 'package:mychat/service/locator.dart';
import 'package:mychat/utils/firebaseStorageService.dart';

class FirestoreService {
  static DateTime lastUpdated = DateTime(1900, 1);
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _users = 'myChat/1/users';
  static const String _rooms = 'myChat/1/rooms';
  static const String _updatedAt = 'updatedAt';
  static const String _loginAt = 'loginAt';
  static const String _isOnline = 'isLogin';
  static const String _friends = 'friends';
  static const String _messages = 'messages';
  static const String _unseenMessages = 'unseenMessages';
  static const String _members = 'members';
  static const String _activeMembers = 'activeMembers';
  static final String _chatHistory = 'chatHistory';

  static Stream<List<UnseenMessage>> unseenMessagesStream(String userId) {
    return _firestore
        .collection('$_users/$userId/$_unseenMessages')
        .snapshots()
        .handleError((e) => [])
        .map((query) {
      return query.docs
          .map((e) => UnseenMessage.fromMap(convertDocumentToMap(e)))
          .toList();
    });
  }

  static Stream<List<MRoom>> roomsStream(String userId) {
    return _firestore
        .collection(_rooms)
        .where(_members, arrayContains: userId)
        .orderBy(_updatedAt, descending: true)
        // .where('title',isGreaterThan: '')
        .snapshots()
        .map((query) {
      return query.docs
          .map((e) => MRoom.fromMap(convertDocumentToMap(e)))
          .toList();
    });
  }

  static Stream<List<MUser>> usersStream(String userId) {
    return _firestore.collection(_users).snapshots().map((query) {
      List<MUser> users = query.docs
          .map((e) => MUser.fromMap(convertDocumentToMap(e)))
          .toList();
      users = users.where((e) => e.docId != userId).toList();
      return users;
    });
  }

  static Future<List<MUser>> getUsers(bool isServer) async {
    List<MUser> allUsers;
// get local data
    await _firestore
        .collection(_users)
        .orderBy(_updatedAt, descending: true)
        .get(GetOptions(source: Source.cache))
        .then((snapshot) {
      List<QueryDocumentSnapshot> docs = snapshot.docs;
      allUsers = MUser.parseList(docs);
    });
    if (!isServer) {
      return allUsers;
    }
    if (allUsers != null && allUsers.length > 1)
      lastUpdated = allUsers[1].updatedAt;

    // get updated data
    await _firestore
        .collection(_users)
        .where(_updatedAt, isGreaterThanOrEqualTo: lastUpdated)
        .get(GetOptions(source: Source.server));

    // get combined data
    await _firestore
        .collection(_users)
        .orderBy(_updatedAt, descending: true)
        .get(GetOptions(source: Source.cache))
        .then((snapshot) {
      List<QueryDocumentSnapshot> docs = snapshot.docs;
      allUsers = MUser.parseList(docs);
    });
    if (allUsers != null && allUsers.isNotEmpty) {
      ControllerUsers friendsController = Get.find();
      String userId = LocatorService.authService().getUser().docId;
      allUsers = allUsers.where((e) => e.docId != userId).toList();
      friendsController.userList.value = allUsers;
    }

    return allUsers;
  }

  static Future<List<MUser>> getUnfirendList(String userId) async {
    List<MUser> allUsers = await getUsers(true);
    List<String> friendList = [];
    try {
      await _firestore
          .collection(_users)
          .doc(userId)
          .collection(_friends)
          .get()
          .then((snapshot) {
        List<Map<String, dynamic>> mapList =
            snapshot.docs.map((e) => convertDocumentToMap(e)).toList();
        friendList = mapList.map((e) {
          if (e['fromId'] == userId)
            return e['toId'].toString();
          else
            return e['fromId'].toString();
        }).toList();
      });
    } catch (e) {}

    if (friendList != null && friendList.isNotEmpty) {
      allUsers.removeWhere((element) => friendList.contains(element.docId));
    }
    allUsers = allUsers.where((element) => element.docId != userId).toList();
    return allUsers;
  }

  static Future<List<MUser>> getUsersData() async {
    List<MUser> users = [];
// get local data
    await _firestore
        .collection(_users)
        .orderBy(_updatedAt, descending: true)
        .get()
        .then((snapshot) {
      List<QueryDocumentSnapshot> docs = snapshot.docs;
      users = MUser.parseList(docs);
    });
    return users;
  }

  static Future<List<MUser>> getRequest(String userId, bool isFriend) async {
    List<MUser> users = [];
    List<String> uid = [];
    print(userId);
// get local data
    await _firestore
        .collection(_users)
        .doc(userId)
        .collection(_friends)
        .where('isAccept', isEqualTo: isFriend)
        // .where('toId', isEqualTo: userId)
        .get()
        .then((snapshot) {
      List<QueryDocumentSnapshot> docs = snapshot.docs;

      // uid = docs.map((e) => e.data()['fromId'].toString()).toList();
      uid = docs.map((e) => e.id).toList();
    });

    if (uid.isNotEmpty) {
      for (int i = 0; i < uid.length; i++) {
        MUser user = await getUser(uid[i]);
        users.add(user);
      }
    }

    return users;
  }

  static Future createGroup(String groupName, List<String> members) async {
    String id;
    final data = {
      'members': members,
      'title': groupName,
      'isGroup': true,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    };
    await _firestore.collection(_rooms).add(data).then((value) {
      id = value.id;
    });
    return id;
  }

  static void incrementUnseen(String userId, String roomId) {
    log('increment: $userId : $roomId', name: 'FIRESTORE');
    _firestore
        .doc('$_users/$userId/$_unseenMessages/$roomId')
        .set({'count': FieldValue.increment(1)}, SetOptions(merge: true));
  }

  static Future updateMessageSeen(
      String roomId, String messageId, String userId) async {
    print('call update seen : $userId : $messageId : $roomId}');
    Map<String, dynamic> map = {
      'seen': FieldValue.arrayUnion([userId])
    };

    _firestore
        .doc('$_rooms/$roomId/$_messages/$messageId')
        .update(map)
        .then((value) => print('SEEN DONE'))
        .catchError((e) {
      print('SEEN ERR: ${e.toString()}');
    });

    _firestore
        .doc('$_users/$userId/$_unseenMessages/$roomId')
        .set({'count': 0}, SetOptions(merge: true))
        .then((value) => print('count set to 0'))
        .catchError((e) {
          print('SEEN ERR: ${e.toString()}');
        });
  }

  static Future<void> updateUserStatus(bool isOnline) async {
    log('change status: $isOnline', name: 'FIRESTORE');
    MUser user = LocatorService.authService().getUser();
    if (user == null) return;
    await _firestore.collection(_users).doc(user.docId).update(
        {_isOnline: isOnline, _loginAt: DateTime.now()}).catchError((err) {
      log('${err}', name: 'UPDATE USER LOGIN');
    });
  }

  static Future<bool> createUser(MUser user) async {
    bool isSuccess = false;
    await _firestore
        .collection(_users)
        .doc(user.docId)
        .set(user.toMap(), SetOptions(merge: true))
        .then((value) {
      print("createUser ${user.email}");
      isSuccess = true;
    }).catchError((e) {});
    return isSuccess;
  }

  static Future sendRequest(String myId, String friendId) async {
    final data = {
      "fromId": myId,
      "toId": friendId,
      "isAccept": false,
      "createdAt": DateTime.now(),
    };
    await _firestore
        .collection(_users)
        .doc(friendId)
        .collection(_friends)
        .doc(myId)
        .set(data);
    await _firestore
        .collection(_users)
        .doc(myId)
        .collection(_friends)
        .doc(friendId)
        .set(data);
  }

  static Future acceptRequest(String fromUid, String toUid) async {
    await _firestore
        .collection(_users)
        .doc(fromUid)
        .collection(_friends)
        .doc(toUid)
        .update({'isAccept': true});
    await _firestore
        .collection(_users)
        .doc(toUid)
        .collection(_friends)
        .doc(fromUid)
        .update({'isAccept': true});
  }

  static Future sendMessage(
      String roomId, MMessage message, File imgFile, bool isGroup) async {
    String imgDownloadUrl;

    Map<String, dynamic> data = {
      'updatedAt': DateTime.now(),
      'lastMsg': message.message,
      'lastFromId': message.fromId,
    };

    // message.imgUrl = imgDownloadUrl;
    await _firestore
        .collection(_rooms)
        .doc(roomId)
        .collection(_messages)
        .add(message.toMap())
        .then((value) {
      String docId = value.id;
      print('Message docId: $docId');
      if (imgFile != null)
        FirebaseStorageService.uploadFile(imgFile, message, (url) {
          message.imgUrl = url;
          _firestore
              .collection(_rooms)
              .doc(roomId)
              .collection(_messages)
              .doc(docId)
              .update({'imgUrl': url});
        });
    });
    await _firestore.collection(_rooms).doc(roomId).update(data);
  }

  static Stream getMessages(String roomId) {
    return _firestore
        .collection(_rooms)
        .doc(roomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<MRoom> getRoom(String myId, String friendId) async {
    MRoom room;
    await _firestore
        .collection(_users)
        .doc(myId)
        .collection(_chatHistory)
        .where('fromId', isEqualTo: friendId)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        room = MRoom.fromMap(convertDocumentToMap(snapshot.docs[0]));
      }
    });
    if (room == null) {
      MUser fromUser = await getUser(myId);
      MUser toUser = await getUser(friendId);
      room = MRoom(
          members: [myId, friendId],
          isGroup: false,
          avatars: {
            fromUser.docId: Avatar.fromUser(fromUser).toMap(),
            toUser.docId: Avatar.fromUser(toUser).toMap(),
          });
      String roomId = _firestore.collection(_rooms).doc().id;
      room.docId = roomId;
      await _firestore.collection(_rooms).doc(roomId).set(room.toMap());
      await _firestore
          .collection(_users)
          .doc(friendId)
          .collection(_chatHistory)
          .doc(roomId)
          .set({'roomId': roomId, 'fromId': myId});
      await _firestore
          .collection(_users)
          .doc(myId)
          .collection(_chatHistory)
          .doc(roomId)
          .set({'roomId': roomId, 'fromId': friendId});
    }
    return room;
  }

  static Map<String, dynamic> convertDocumentToMap(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data();
    data['docId'] = doc.id;
    return data;
  }

  static Future<MUser> getUser(String uid) async {
    MUser user;
    await _firestore
        .collection(_users)
        .doc(uid)
        .get(GetOptions(source: Source.cache))
        .then((value) {
      Map<String, dynamic> map = convertDocumentToMap(value);
      user = MUser.fromMap(map);
    });
    if (user == null) {
      await _firestore
          .collection(_users)
          .doc(uid)
          .get(GetOptions(source: Source.server))
          .then((value) {
        Map<String, dynamic> map = convertDocumentToMap(value);
        user = MUser.fromMap(map);
      });
    }
    return user;
  }

  static Future<MUser> checkUser(String email) async {
    MUser user;
    await _firestore
        .collection(_users)
        .where('email', isEqualTo: email)
        .get()
        .then((value) {
      if (value != null && value.docs.isNotEmpty) {
        final doc = value.docs[0];
        user = MUser.fromMap(convertDocumentToMap(doc));
        LocatorService.authService().setUser(user);
        updateUserStatus(true);
      }
    }).catchError((err) {});
    return user;
  }

  static Future<List<MRoom>> getRooms(String userId) async {
    print(userId);
    List<MRoom> rooms;
    await _firestore
        .collection(_rooms)
        .where(_members, arrayContains: userId)
        .get()
        .then((value) {
      rooms = value.docs
          .map((e) => convertDocumentToMap(e))
          .map((e) => MRoom.fromMap(e))
          .toList();
    });

    if (rooms != null && rooms.isNotEmpty) {
      for (int i = 0; i < rooms.length; i++) {
        MRoom room = rooms[i];
        print('________RO ${room.title}');
        if (!room.isGroup) {
          String friendId =
              room.members.firstWhere((element) => element != userId);
          if (friendId != null) {
            MUser user = await getUser(friendId);
            rooms[i].user = user;
          }
        }
      }
    }

    return rooms;
  }

  static Future<List<String>> getActiveMembers(String roomId) async {
    List<String> activeMembers = [];
    await _firestore
        .collection(_rooms)
        .doc(roomId)
        .collection(_activeMembers)
        .get()
        .then((docSnapshot) {
      if (docSnapshot.docs != null && docSnapshot.docs.isNotEmpty)
        activeMembers =
            docSnapshot.docs.map((e) => e.data()['userId'].toString()).toList();
    });
    return activeMembers;
  }

  static Future<void> setActivityInRoom(
      String roomId, String userId, bool isActive) async {
    Map<String, dynamic> data = {
      'userId': userId,
      'updatedAt': DateTime.now(),
    };
    if (isActive)
      await _firestore
          .collection(_rooms)
          .doc(roomId)
          .collection(_activeMembers)
          .doc(userId)
          .set(data, SetOptions(merge: true));
    else
      await _firestore
          .collection(_rooms)
          .doc(roomId)
          .collection(_activeMembers)
          .doc(userId)
          .delete();
  }

  static void saveToken(String token) async {
    String userId = LocatorService.authService().getUser().docId;
    if (userId != null && userId.isNotEmpty)
      await _firestore
          .collection(_users)
          .doc(userId)
          .update({'token': token}).catchError((err) {
        print('ERR____$err - $userId');
        log('${err}', name: 'SAVE TOKEN');
      });
  }
}
