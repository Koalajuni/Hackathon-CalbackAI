

import 'package:calendar/models/user.dart';

class Friendship {
  Friendship({
    required this.myUid,
    required this.friendUid,
    this.views = 0,
    this.timesMet = 0,
  });

  late final String myUid;
  late final String friendUid;
  late int views;
  late int timesMet;

  Map<String, dynamic> toDocument() {
    return {
      "myUid" : myUid,
      "friendUid": friendUid,
      "views": views,
      "timesMet": timesMet,
    };
  }
}