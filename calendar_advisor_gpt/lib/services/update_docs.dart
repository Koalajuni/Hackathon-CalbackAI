import 'package:calendar/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future setDocs() async {
  final CollectionReference userCollection= 
    FirebaseFirestore.instance.collection('userCollection');
  try {
    await userCollection
      .get()
      .then((QuerySnapshot querySnapshot) async {
        querySnapshot.docs.forEach((element) async {
          await DatabaseService(uid: element.id).setUserData(
            element['name'], 
            element['email'], 
            element['flag'], 
            element['friends'], 
            element['reqReceived'], 
            element['reqSent'], 
            element['photoUrl'],
            element['blockedUsers'],
            element['token'],
            element['openPrivacy']
          );
        });
      });
  } catch(e) {
    print('Error getting meetings from DB: $e');
  }
}

Future updateDocs() async {
  final CollectionReference userCollection= 
    FirebaseFirestore.instance.collection('userCollection');
  try {
    await userCollection
      .get()
      .then((QuerySnapshot querySnapshot) async {
        querySnapshot.docs.forEach((element) async {
          await DatabaseService(uid: element.id).updateField(
            {'openPrivacy': false}
          );
        });
      });
  } catch(e) {
    print('Error getting meetings from DB: $e');
  }
}

Future testupdateDocs() async {
  final CollectionReference userCollection= 
    FirebaseFirestore.instance.collection('userCollection');
  await userCollection.doc('fHjMxPKsuFhKnnhyWZBiyEyX4br1')
    .update({'openPrivacy' : false});
}