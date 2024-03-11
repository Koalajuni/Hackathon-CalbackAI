
import 'package:calendar/models/user.dart';

class ProfileInterest {
  ProfileInterest({
    required this.profileUid,
    this.views = 0,
  });

  late final String profileUid;
  late int views;

  Map<String, dynamic> toDocument() {
    return {
      "profileUid" : profileUid,
      "views": views,
    };
  }
}