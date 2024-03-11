import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser{

  late final String uid;
  late final String email;
  late final String name;
  late int flag;
  late List friends;
  late List reqReceived;
  late List reqSent;
  late String photoUrl;
  late List blockedUsers;
  late String token;
  late bool openPrivacy;

  MyUser({
    required this.uid,
    this.email = 'asd@asd.com',
    this.name = 'New User', 
    this.flag = 0, 
    this.friends = const [], 
    this.reqReceived = const [], 
    this.reqSent = const [],
    this.photoUrl = '',
    this.blockedUsers = const [],
    this.token = '',
    this.openPrivacy = false,
  });


  factory MyUser.fromDocument(DocumentSnapshot doc) {
    return MyUser(
      uid: 'uid',
      name: doc['name'],
      flag: doc['flag'],
      friends: doc['friends'],
      reqReceived: doc['reqReceived'],
      reqSent: doc['reqSent'],
      photoUrl: doc['photoUrl'],
      blockedUsers: doc['blockedUsers'],
      token: doc['token'] ?? "",
      openPrivacy: doc['openPrivacy']
    );
  }
}