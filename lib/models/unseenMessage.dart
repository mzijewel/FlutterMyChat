class UnseenMessage {
  String roomId;
  int count;

  UnseenMessage(this.roomId, this.count);

  UnseenMessage.fromMap(Map<String, dynamic> map) {
    print('UNSEEN from map: $map');
    roomId = map['docId'];
    count = map['count'] ?? 0;
  }
}
