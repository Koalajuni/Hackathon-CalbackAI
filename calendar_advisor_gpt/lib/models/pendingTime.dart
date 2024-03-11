import 'package:cloud_firestore/cloud_firestore.dart';

class PendingTime {
  PendingTime({
    required this.myUid,
    required this.mid,
    this.individualTime = const [],
    this.isDone = false,
  });

  late final String myUid;
  late String mid;
  late Map pendingTimeMap;
  late List individualTime;
  late bool isDone;

  Map<String, dynamic> toDocument() {
    return {
      "mid" : mid,
      myUid : {
        "isDone" : isDone,
        "individualTime" : individualTime,
      },
    };
  }

}