import 'dart:math';

import 'package:calendar/models/user.dart';
import 'package:calendar/services/database.dart';
import 'package:calendar/services/firebase_auth_remote_data_source.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calendar/services_kakao/kakao_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calendar/shared/globals.dart' as globals;
import 'package:flutter/material.dart';

import '../models/profileInterest.dart';

class AuthService {
  final _firebaseAuthDataSource = FirebaseAuthRemoteDataSource();
  final FirebaseAuth _auth = FirebaseAuth
      .instance; // _means privat, only used in this file

  //create user object based on User(firebase)
  MyUser? _userFromFirebase(User? user) {
    return user != null ? MyUser(uid: user.uid, email: user.email!) : null;
  }
  //created a MyUser instance with uid from (firebase) User class

  // auth change user stream
  Stream<MyUser?> get my_user {
    //were setting up a stream were we 'get' <MyUser> data back
    return _auth.authStateChanges()
    //.map((User? my_user) => _userFromFirebase(my_user)); this functions the same as below
        .map(_userFromFirebase);
  }

  // authStateChanges() will retun me a User data, when authstate changes, 
  // I map the returned User data into MyUser data which only contains the info i need

  //sign in anon
  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? my_user = result.user;
      return _userFromFirebase(my_user);
    }
    catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email and pw
  Future signInWithEmailAndPw(String email, String password) async {
    try { //creating email and password user
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? my_user = result.user;
      print("UID: ${my_user?.uid}");
      return _userFromFirebase(my_user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email and pw
  Future registerWithEmailAndPw(String email, String password, bool isPersonal) async {
    if(isPersonal){
      try { //creating email and password user
        UserCredential result = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        User? my_user = result.user;
        MyUser myUser = MyUser(uid: my_user!.uid, email: my_user.email!);
        print("UID: ${my_user.uid}");
        await DatabaseService(uid: my_user.uid).setUserData(
            myUser.name,
            myUser.email,
            myUser.flag,
            myUser.friends,
            myUser.reqReceived,
            myUser.reqSent,
            myUser.photoUrl,
            myUser.blockedUsers,
            myUser.token,
            myUser.openPrivacy
        );
        return _userFromFirebase(my_user);
      } catch (e) {
        print(e.toString());
        return e.toString();
      }
    } else {
      const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      Random _rnd = Random();
      String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

      try {
        final tokenResponse = await _firebaseAuthDataSource.createToken({
        'uid': 'open:${getRandomString(23)}',
        'password' : password,
        'email': email,
        'userType' : 'open'
      });
      final UserCredential result = await _auth.signInWithCustomToken(tokenResponse["token"]!);
      User? my_user = result.user;
      MyUser myUser = MyUser(uid: my_user!.uid, email: my_user.email!);
      if (tokenResponse["new"] == "1") {
        await DatabaseService(uid: my_user.uid).setUserData(
            myUser.name,
            myUser.email,
            myUser.flag,
            myUser.friends,
            myUser.reqReceived,
            myUser.reqSent,
            myUser.photoUrl,
            myUser.blockedUsers,
            myUser.token,
            myUser.openPrivacy
        );
        await DatabaseService(uid: my_user.uid).getProfileInterest(ProfileInterest(profileUid: my_user.uid));
      }
      return _userFromFirebase(my_user);
      } catch (e) {
        print(e.toString());
        return e.toString();
      }

    }
  }

  // sign out 
  Future signOut() async {
    try {
      globals.bnbIndex = 0;
      if (FirebaseAuth.instance.currentUser?.email?.split('@')[1] ==
          'kakao.com') {
        print("kakaoLogOut");
        KakaoAuthService().kakaoLogOut();
      }
      return await _auth.signOut();
    }
    catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future deleteAccount(String email, String password) async {
    try {
      User? user = await _auth.currentUser;
      AuthCredential credentials = EmailAuthProvider.credential(email: email, password: password);
      // UserCredential credentials = await _auth.signInWithEmailAndPassword(
      //     email: email, password: password);
      UserCredential result = await user!.reauthenticateWithCredential(credentials);
      User? my_user = result.user;
      await DatabaseService(uid: result.user!.uid).deleteUser(); // called from database class
      await result.user?.delete();
      return true;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future deleteUser() async {
    try{
    User? user = await _auth.currentUser;
    user?.delete();} catch (e){
      print(e.toString());
      return null;
    }
  }

}
