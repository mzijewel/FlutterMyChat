import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Utils {
  static DateTime getDateTime(Timestamp timestamp) {
    try {
      return DateTime.fromMicrosecondsSinceEpoch(timestamp.microsecondsSinceEpoch);
    } catch (e) {
      return DateTime.now();
    }
  }

  static String getDateTimeStr(DateTime dateTime) {
    return DateFormat('dd MMM, hh:mm a').format(dateTime);
  }

  static dynamic getData(Map<String, dynamic> json, String key) {
    if (json.containsKey(key)) return json[key];
    return null;
  }
}
