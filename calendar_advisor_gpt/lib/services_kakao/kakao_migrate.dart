import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as Kakao;

import '../services/database.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final Kakao.UserApi _userApi = Kakao.UserApi.instance;

Future kakaoMigrateUser(String kakaoId) async {
    try{
      await _auth.signInWithEmailAndPassword(
        email: "${kakaoId}@kakao.com", 
        password: "1");
    }catch(e){
      if(e.toString() == '[firebase_auth/wrong-password] The password is invalid or the user does not have a password.'){
        print("Previoulsy existing account");
        String currentUid = _auth.currentUser!.uid;
        String oldUid = "";
        final CollectionReference userCollection= FirebaseFirestore.instance.collection('userCollection');
        final CollectionReference meetingsCollection= FirebaseFirestore.instance.collection('meetingsCollection');
        
        // user collection
        await userCollection.get()
          .then((querySnapshot) {
            querySnapshot.docs.forEach((userData) {
              if(userData['email'] == "${kakaoId}@kakao.com") {
                oldUid = userData.id;
                // Migrating my user data
                DatabaseService(uid: currentUid).setUserData(
                  userData['name'], 
                  userData['email'], 
                  userData['flag'], 
                  userData['friends'], 
                  userData['reqReceived'], 
                  userData['reqSent'], 
                  userData['photoUrl'], 
                  userData['blockedUsers'],
                  userData['token'],
                  userData['openPrivacy'])
                    .onError((e, _) => print("Error Migrating kakao data: $e"));
              }

                // Migrating Friend Fields
                List<String> friendsParse =
                  userData['friends'].toString().substring(1, userData['involved'].toString().length - 1)
                    .replaceAll(' ', '').split(",");
                friendsParse.forEach((friend) { 
                  if(friend == oldUid){
                    userCollection.doc(userData.id).update({'friends' : FieldValue.arrayRemove([oldUid])});
                    userCollection.doc(userData.id).update({'friends' : FieldValue.arrayUnion([currentUid])});
                    userCollection.doc(userData.id).collection('friendships').get()
                      .then((querySnapshot) {
                        querySnapshot.docs.forEach((friendShipElement){
                          print("substring of friendship doc ${friendShipElement.id.substring(28, friendShipElement.id.length)}");
                          if(friendShipElement.id.substring(28, friendShipElement.id.length) == oldUid) {
                            
                          }
                        });
                      });
                  }
                });
            });
          });

        // meetings collection
        await meetingsCollection.get()
          .then((querySnapshot) {
            querySnapshot.docs.forEach((meetingData) {
            // migrating meeting data where user is owner
            if(meetingData['owner'] == oldUid){
              meetingsCollection.doc(meetingData.id).update({
                'owner': currentUid
              });
            }

            // migrating meeting data where user is an involvee
            List<String> involvedParse = 
              meetingData['involved'].toString().substring(1, meetingData['involved'].toString().length - 1)
                .replaceAll(' ', '').split(",");
            involvedParse.forEach((involvee) { 
              if(involvee == oldUid){
                meetingsCollection.doc(meetingData.id).update({'involved' : FieldValue.arrayRemove([oldUid])});
                meetingsCollection.doc(meetingData.id).update({'involved' : FieldValue.arrayUnion([currentUid])});
              }
            });
            });
          });
      }
    }    
  }
