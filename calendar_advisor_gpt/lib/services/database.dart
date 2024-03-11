import 'package:calendar/models/friendship.dart';
import 'package:calendar/models/pendingTime.dart';
import 'package:calendar/models/meeting.dart';
import 'package:calendar/models/user.dart';
import '../models/profileInterest.dart';
import 'package:calendar/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../models/userSchedule.dart';
import '../pages/events/event_maker.dart';

class DatabaseService {
  late final String uid;

  DatabaseService({required this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('userCollection');
  final CollectionReference meetingsCollection =
      FirebaseFirestore.instance.collection('meetingsCollection');
  final CollectionReference pendingTimeCollection =
      FirebaseFirestore.instance.collection('pendingTimeCollection');

  Future deleteUser() {
    return userCollection.doc(uid).delete();
  }

  Future setUserData(
      String name,
      String email,
      int flag,
      List<dynamic> friends,
      List<dynamic> reqReceived,
      List<dynamic> reqSent,
      String photoUrl,
      List<dynamic> blockedUsers,
      String token,
      bool openPrivacy) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'email': email,
      'flag': flag,
      'friends': friends,
      'reqReceived': reqReceived,
      'reqSent': reqSent,
      'photoUrl': photoUrl,
      'blockedUsers': blockedUsers,
      'token': (token != null) ? token : '',
      'openPrivacy' : openPrivacy,
    });
  }

  Future updateField (Map<String, Object> data) async {
    await userCollection.doc(uid).update(data);
  } 

  Future addMeetings(Meeting event) async {
    await meetingsCollection
        .doc(event.MID)
        .set(event.toFirestore())
        .onError((e, _) => print("Error writing meetings document to DB: $e"));
    print("meeting added");
    await userCollection.doc(uid).update({"flag": FieldValue.increment(1)});
  }

  Future updateMeetings(Meeting newEvent, Meeting oldEvent) async {
    print(oldEvent.MID);
    await meetingsCollection
        .doc("${oldEvent.MID}")
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        meetingsCollection
            .doc("${oldEvent.MID}")
            .update(newEvent.toFirestore())
            .onError(
                (e, _) => print("Error updating meetings document to DB : $e"));
      }
    });
  }

  Future<List<Meeting>> getMeetings() async {
    List<Meeting> meetings = [];
    try {
      //calling  meetings from database
      await meetingsCollection.get().then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          //if owner of the meeting, get event
          if (element['owner'] == uid) {
            meetings.add(Meeting.fromFirestore(
                element as QueryDocumentSnapshot<Map<String, dynamic>>));
          }

          //if involved in the meeting, get event
          List<String> involvedParse = element['involved']
              .toString()
              .substring(1, element['involved'].toString().length - 1)
              .replaceAll(' ', '')
              .split(",");
          involvedParse.forEach((element2) {
            if (element2 == uid) {
              meetings.add(Meeting.fromFirestore(
                  element as QueryDocumentSnapshot<Map<String, dynamic>>));
            }
          });
        });
      });
      return meetings;
    } catch (e) {
      print("Error getting meetings from DB: $e");
      return meetings;
    }
  }

  
  Future deleteMeetings(String MID) async {
    await meetingsCollection
        .doc('${MID}')
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        meetingsCollection.doc('${MID}').delete().onError(
            (e, _) => print("Error deleting meetings document of DB: $e"));
        print("meeting deleted");
      }
    });
  }

  Future leaveInvolvedMeetings(String myUid, String mid) async {
    await meetingsCollection.doc(mid).update({
      'involved': FieldValue.arrayRemove([myUid])
    });
    print('Exited meeting: ${mid}');
  }

  List<Meeting> _meetingsFromSnapshot(QuerySnapshot querySnapshot) {
    List<Meeting> meetingsRef = [];
    querySnapshot.docs.forEach((meetingSnapshot) {
      if (meetingSnapshot["MID"].substring(0, 7) != "pending") {
        if (meetingSnapshot["owner"] == uid) {
          meetingsRef.add(Meeting.fromFirestore(
              meetingSnapshot as QueryDocumentSnapshot<Map<String, dynamic>>));
        }
        List<dynamic> involvedDynamic = meetingSnapshot['involved'] ?? [];
        List<String> involvedString = List<String>.from(involvedDynamic);
        involvedString.forEach((involvedElement) {
          if (involvedElement == uid) {
            meetingsRef.add(Meeting.fromFirestore(meetingSnapshot
                as QueryDocumentSnapshot<Map<String, dynamic>>));
            print("This is involved ");
          }
        });
      }
    });
    var eventProvider =
        Provider.of<EventMaker>(navigatorKey.currentContext!, listen: false);
    eventProvider.setLocalEvent(meetingsRef);
    print("-------- meetingsRef: $meetingsRef -------");
    return meetingsRef;
  }

  Stream<List<Meeting>> get meetingsData {
    return meetingsCollection.snapshots().map(_meetingsFromSnapshot);
  }

  Future<Meeting> singleMeetingData(String mid) async {
    late Meeting meeting;
    try {
      await meetingsCollection
          .doc(mid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        meeting = Meeting.fromFirestore(
            documentSnapshot as DocumentSnapshot<Map<String, dynamic>>);
      });
      return meeting;
    } catch (e) {
      print('Error getting single meetingdd data $e');
      return meeting;
    }
  }

  Future pullToMyCalendar(String mid) async {
    await meetingsCollection.doc(mid).update({
      'involved' : FieldValue.arrayUnion([uid])
    });
  }

//---------------Friends/Request related methods--------------------START
  Future sendFriendReq(String uid, String friendUid) async {
    print('${uid} sent ${friendUid}');
    await userCollection.doc(uid).update({
      'reqSent': FieldValue.arrayUnion([friendUid])
    });
    await userCollection.doc(friendUid).update({
      'reqReceived': FieldValue.arrayUnion([uid])
    });
    print('friend request sent');
  }

  Future sendMeetReq(String uid, String friendUid, String mid) async {
    print('${uid} sent ${friendUid} meeting req');
    await userCollection.doc(uid).update({
      'reqSent': FieldValue.arrayUnion(['${mid}:${friendUid}'])
    });
    await userCollection.doc(friendUid).update({
      'reqReceived': FieldValue.arrayUnion([mid])
    });
    print('meeting request sent');
  }

  Future deleteSentMeetReq(Friendship friendship) async {
    await userCollection.doc(friendship.myUid).update({
      'reqReceived': FieldValue.arrayRemove([friendship.friendUid])
    });
    await userCollection.doc(friendship.myUid).update({
      'reqSent': FieldValue.arrayRemove([friendship.friendUid])
    });

    await userCollection.doc(friendship.friendUid).update({
      'reqSent': FieldValue.arrayRemove([friendship.myUid])
    });
    await userCollection.doc(friendship.friendUid).update({
      'reqReceived': FieldValue.arrayRemove([friendship.myUid])
    });

    print('Declined friend request from: ${friendship.friendUid}');
  }

  Future acceptFriendReq(Friendship friendship) async {
    // Add to both friends list
    await userCollection.doc(friendship.myUid).update({
      'friends': FieldValue.arrayUnion([friendship.friendUid])
    });
    await userCollection.doc(friendship.friendUid).update({
      'friends': FieldValue.arrayUnion([friendship.myUid])
    });

    // Create friendship for currUser and deletes friend from request lists
    await userCollection
        .doc(friendship.myUid)
        .collection('friendships')
        .doc('${friendship.myUid}:${friendship.friendUid}')
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      print('Checking for friendship doc: ${documentSnapshot.exists}');
      if (!documentSnapshot.exists) {
        await userCollection
            .doc(friendship.myUid)
            .collection('friendships')
            .doc('${friendship.myUid}:${friendship.friendUid}')
            .set(friendship.toDocument())
            .onError(
                (e, _) => print("Error writing friendship document to DB: $e"));
      }

      await userCollection.doc(friendship.myUid).update({
        'reqReceived': FieldValue.arrayRemove([friendship.friendUid])
      });
      await userCollection.doc(friendship.myUid).update({
        'reqSent': FieldValue.arrayRemove([friendship.friendUid])
      });
      print("friendship added to me");
    });

    // Create friendship for friend and deletes currUser from request lists
    await userCollection
        .doc(friendship.friendUid)
        .collection('friendships')
        .doc('${friendship.friendUid}:${friendship.myUid}')
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      print('Checking for friendship doc: ${documentSnapshot.exists}');
      if (!documentSnapshot.exists) {
        await userCollection
            .doc(friendship.friendUid)
            .collection('friendships')
            .doc('${friendship.friendUid}:${friendship.myUid}')
            .set(friendship.toDocument())
            .onError(
                (e, _) => print("Error writing friendship document to DB: $e"));
      }

      await userCollection.doc(friendship.friendUid).update({
        'reqSent': FieldValue.arrayRemove([friendship.myUid])
      });
      await userCollection.doc(friendship.friendUid).update({
        'reqReceived': FieldValue.arrayRemove([friendship.myUid])
      });
      print("friendship added to friend");
    });

    print('Accepted friend request from: ${friendship.friendUid}');
  }

  Future declineFriendReq(Friendship friendship) async {
    await userCollection.doc(friendship.myUid).update({
      'reqReceived': FieldValue.arrayRemove([friendship.friendUid])
    });
    await userCollection.doc(friendship.myUid).update({
      'reqSent': FieldValue.arrayRemove([friendship.friendUid])
    });

    await userCollection.doc(friendship.friendUid).update({
      'reqSent': FieldValue.arrayRemove([friendship.myUid])
    });
    await userCollection.doc(friendship.friendUid).update({
      'reqReceived': FieldValue.arrayRemove([friendship.myUid])
    });

    print('Declined friend request from: ${friendship.friendUid}');
  }

  Future acceptMeetReq(String myUid, String friendUid, String mid) async {
    print("accepting meeting request: ${mid}");
    await meetingsCollection.doc(mid).update({
      'involved': FieldValue.arrayUnion([myUid])
    });

    await userCollection.doc(myUid).update({
      'reqReceived': FieldValue.arrayRemove([mid])
    });
    await userCollection.doc(friendUid).update({
      'reqSent': FieldValue.arrayRemove(['${mid}:${myUid}'])
    });

    print('Accepted meeting request from: ${friendUid}');
  }

  Future declineMeetReq(String myUid, String friendUid, String mid) async {
    await userCollection.doc(myUid).update({
      'reqReceived': FieldValue.arrayRemove([mid])
    });
    await userCollection.doc(friendUid).update({
      'reqSent': FieldValue.arrayRemove(['${mid}:${friendUid}'])
    });
    await meetingsCollection.doc(mid).update({
      'involved': FieldValue.arrayRemove([myUid])
    });

    print('Declined meeting request from: ${friendUid}');
  }

  Future removeFriend(String uid, String friendUid) async {
    await userCollection.doc(uid).update({
      'friends': FieldValue.arrayRemove([friendUid])
    });
    await userCollection.doc(friendUid).update({
      'friends': FieldValue.arrayRemove([uid])
    });
  }

  Future blockFriend(String uid, String friendUid) async {
    await userCollection.doc(uid).update({
      'blockedUsers': FieldValue.arrayUnion([friendUid])
    });
    print('Blocked friend: $friendUid');
  }

  Future unblockFriend(String uid, String friendUid) async {
    await userCollection.doc(uid).update({
      'blockedUsers': FieldValue.arrayRemove([friendUid])
    });
    print('Unblocked friend: $friendUid');
  }

  Future addPendingInvolved(String friendUid, String mid) async {
    try {
      await meetingsCollection.doc(mid).update({
        'pendingInvolved': FieldValue.arrayUnion([friendUid])
      });
      print('Adding this friend to pending: $friendUid');
    } catch (e) {
      print('Error implementing add pendingInvolved database: $friendUid');
    }
  }

  Future removePendingInvolved(String friendUid, String mid) async {
    try {
      await meetingsCollection.doc(mid).update({
        'pendingInvolved': FieldValue.arrayRemove([friendUid])
      });
      print('Removing this friend to pending: $friendUid');
    } catch (e) {
      print('Error implementing remove pendingInvolved database: $friendUid');
    }
  }

//---------------Friends/Request related methods--------------------END

  Future viewsIncr(String viewerUid) async {
    print('viewsIncr ${viewerUid}');
    await userCollection
        .doc(viewerUid)
        .collection('friendships')
        .doc('${viewerUid}:${uid}')
        .update({'views': FieldValue.increment(1)});
  }

  MyUser _myUserFromSnapshot(DocumentSnapshot snapshot) {
    return MyUser(
      uid: uid,
      email: (snapshot.data() as dynamic)['email'],
      name: (snapshot.data() as dynamic)['name'],
      flag: (snapshot.data() as dynamic)['flag'],
      friends: (snapshot.data() as dynamic)['friends'],
      reqReceived: (snapshot.data() as dynamic)['reqReceived'],
      reqSent: (snapshot.data() as dynamic)['reqSent'],
      photoUrl: (snapshot.data() as dynamic)['photoUrl'],
      blockedUsers: (snapshot.data() as dynamic)['blockedUsers'],
      token: (snapshot.data() as dynamic)['token'] ?? '',
      openPrivacy: (snapshot.data() as dynamic)['openPrivacy'],
    );
  }

//Setting up Stream of MyUser
  Stream<MyUser> get userData {
    return userCollection.doc(uid).snapshots().map(_myUserFromSnapshot);
  }

/*How to map a future?
  Future<MyUser> get userFutureData async {
    return await userCollection.doc(uid).get()
      .map(_MyUserFromSnapshot);
  }
*/
  Future loadImage(String Image) async {
    await userCollection
        .doc(uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      if (documentSnapshot.exists) {
        final firebase_storage.FirebaseStorage storage =
            firebase_storage.FirebaseStorage.instance;
        var url = await storage.ref('$uid').child(Image).getDownloadURL();
        userCollection.doc(uid).update({"photoUrl": url});
        print('image upload check');
        print(url);
      }
    });
  }

//---------------Group related methods--------------------START
  Future<List<Meeting>> getFilteredContentMeetings() async {
    List<Meeting> meetings = [];
    try {
      //calling  meetings from database
      await meetingsCollection.get().then((querySnapshot) {
        querySnapshot.docs.forEach((element) {
          if (element['MID'].substring(0, 7) != 'pending') {
            print(element['MID']);
            //if owner of the meeting, get event
            if (element['owner'] == uid) {
              meetings.add(Meeting.filteredContentFromFirestore(
                  element as QueryDocumentSnapshot<Map<String, dynamic>>));
            }

            //if involved in the meeting, get event
            List<String> involvedParse = element['involved']
                .toString()
                .substring(1, element['involved'].toString().length - 1)
                .replaceAll(' ', '')
                .split(",");
            involvedParse.forEach((element2) {
              if (element2 == uid) {
                meetings.add(Meeting.filteredContentFromFirestore(
                    element as QueryDocumentSnapshot<Map<String, dynamic>>));
              }
            });
          }
        });
      });
      return meetings;
    } catch (e) {
      print("Error getting meetings from DB: $e");
      return meetings;
    }
  }

  Future<Map<String, dynamic>> getPendingTime(String mid) async {
    Map<String, dynamic> pending = {};
    try {
      await pendingTimeCollection
          .doc(mid)
          .get()
          .then((DocumentSnapshot documentSnapshot) async {
        pending = documentSnapshot.data() as Map<String, dynamic>;
      });

      return pending;
    } catch (e) {
      print("Error getting pending time from DB: $e");
      return pending;
    }
  }

  updatePendingTime(String uid, String mid,
      {bool isDone = false, List<DateTime> timeList = const []}) async {
    await pendingTimeCollection
        .doc(mid)
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      print('Checking for pending time doc: ${documentSnapshot.exists}');

      // Create new document if doesn't exist
      if (!documentSnapshot.exists) {
        await pendingTimeCollection
            .doc(mid)
            .set(PendingTime(myUid: uid, mid: mid).toDocument())
            .onError((e, _) =>
                print("Error writing pending time document to DB: $e"));
      } else if (documentSnapshot.exists & isDone == true) {
        await pendingTimeCollection.doc(mid).update({
          uid: {
            'isDone': isDone,
            'individualTime': timeList,
          }
        }).onError(
            (e, _) => print("Error writing pending time document to DB: $e"));
        // If exists and field already exists, don't do anything (case for kakao dynamic link)
      } else if (documentSnapshot.exists &&
          (documentSnapshot.data() as Map<String, dynamic>)["$uid"] != null) {
      }
      // If exists, just add new data field for individual user
      else {
        await pendingTimeCollection.doc(mid).update({
          uid: {
            "isDone": false,
            "individualTime": [],
          }
        }).onError(
            (e, _) => print("Error writing pendting time document to DB: $e"));
      }
    });

    print("Pending time successfully added!");
  }
//---------------Group related methods--------------------END

  Future getOpenProfilesData() async {
    Map<String, List<String>> openProfilesData = {};
    QuerySnapshot<Object?> openProfiles = await userCollection.get();

    QuerySnapshot<Object?> openMeetings = await meetingsCollection.get();

    for (var user in openProfiles.docs) {
      if (user.id.substring(0,4) == 'open') {
        openProfilesData[user.id] = [user['name'], user['photoUrl']];

        for (var meeting in openMeetings.docs) {
          if (meeting['owner'] == user.id) {
            openProfilesData[user.id]!.add(meeting['MID']);
          }
        }
      }
    }
    
    return openProfilesData;
  }


  Future getProfileInterest(ProfileInterest profileInterest) async {
    // Add to both friends list
       // Create friendship for currUser and deletes friend from request lists
    await userCollection
        .doc(profileInterest.profileUid)
        .collection('profileInterest')
        .doc('Viewed Story-Calendar')
        .get()
        .then((DocumentSnapshot documentSnapshot) async {
      print('Checking for profileInterest doc: ${documentSnapshot.exists}');
      if (!documentSnapshot.exists) {
        await userCollection
            .doc(profileInterest.profileUid)
            .collection('profileInterest')
            .doc('Viewed Story-Calendar')
            .set(profileInterest.toDocument())
            .onError(
                (e, _) => print("Error writing profileInterest document to DB: $e"));
      }
    });
    // await userCollection.doc(friendship.myUid).update({
    //   'profileInterest': FieldValue.arrayUnion([friendship.friendUid])
    // });
} 

 Future profileInterestIncr(String viewerUid) async {
    print('viewsIncr ${viewerUid}');
    await userCollection
        .doc(viewerUid)
        .collection('profileInterest')
        .doc('Viewed Story-Calendar')
        .update({'views': FieldValue.increment(1)});
  }

  Future<UserSchedule> getUserSchedule(String uid) async {
  final doc = await userCollection.doc(uid).collection('userSchedule').doc('schedule').get();
  final data = doc.data();
  if (data == null) {
    return UserSchedule(profileUid: uid);
  }
  return UserSchedule(
    profileUid: uid,
    schedule: List<String>.from(data['schedule']),
  );
}

Future<void> addUserSchedule(UserSchedule userSchedule) async {
  await userCollection
      .doc(userSchedule.profileUid)
      .collection('userSchedule')
      .doc('schedule')
      .set({
        'schedule': userSchedule.schedule,
      });
}



}



