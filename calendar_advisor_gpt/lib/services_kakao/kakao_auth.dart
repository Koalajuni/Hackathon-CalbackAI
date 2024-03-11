import 'package:calendar/models/user.dart';
import 'package:calendar/services/firebase_auth_remote_data_source.dart';
import 'package:calendar/services/storage_service.dart';
import 'package:calendar/services_kakao/kakao_migrate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as Kakao;

import '../services/database.dart';

class KakaoAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Kakao.UserApi _userApi = Kakao.UserApi.instance;
  final _firebaseAuthDataSource = FirebaseAuthRemoteDataSource();

  MyUser? _userFromFirebase(User? user) {
    return user != null ? MyUser(uid: user.uid) : null;
  }

  Future kakaoLogin() async {
    try {
      Kakao.User kakaoUser = await _userApi.me();
      print("/////////////////////////////\n"
          "${kakaoUser.id.toString()}\n"
          "${kakaoUser.kakaoAccount?.profile?.nickname}\n"
          "${kakaoUser.kakaoAccount?.email}\n"
          "${kakaoUser.kakaoAccount?.profile?.profileImageUrl}\n");
      print("come onnnn\n");
      final tokenResponse = await _firebaseAuthDataSource.createCustomToken({
        'uid': kakaoUser.id.toString(),
        'email': kakaoUser.kakaoAccount!.email!,
        'userType' : 'kakao'
      });
      print("this is my token: ${tokenResponse}");
      UserCredential result =
          await _auth.signInWithCustomToken(tokenResponse["token"]!);
      User? my_user = result.user;
      if (tokenResponse["new"] == "1") {
        await DatabaseService(uid: my_user!.uid).setUserData(
          kakaoUser.kakaoAccount!.profile!.nickname!,
          kakaoUser.kakaoAccount!.email!,
          0,
          [],
          [],
          [],
          kakaoUser.kakaoAccount!.profile!.profileImageUrl != null
              ? kakaoUser.kakaoAccount!.profile!.profileImageUrl!
              : "",
          [],
          "", // blockedUsers
          false
        );
      }
      print("whats up bois");
      // todo await kakaoMigrateUser(kakaoUser.id.toString());
      print("kakao check: ${kakaoUser.id}@kakao.com");
      print("uid: ${my_user?.uid}");
      return _userFromFirebase(my_user);
    } catch (e) {
      print("error loginKakao: ${e}");
      return null;
    }
  }

  Future kakaoLogOut() async {
    await Kakao.UserApi.instance.logout();
    print("kakao unLink Success");
  }
}
