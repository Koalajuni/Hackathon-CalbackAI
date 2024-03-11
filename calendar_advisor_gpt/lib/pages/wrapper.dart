import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/chatgpt_stuff/backend/chat_api.dart';
import 'package:calendar/services/database.dart';
import 'package:calendar/services_kakao/kakao_link_with_dynamic_link.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import '../models/friendship.dart';
import '../models/meeting.dart';
import 'dart:io' show Platform;

import '../services/auth.dart';
import '../services/notification_services/push_notification.dart';
import 'chatgpt_stuff/frontend/chat_home_page.dart';

bool isDynamicOpening = false;

class Wrapper extends StatefulWidget {
  const Wrapper({ Key? key }) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> with WidgetsBindingObserver {
   late int _totalNotifications;
  PushNotification? _notificationInfo; 


  @override
  Widget build(BuildContext context) {
    
    final user = Provider.of<MyUser?>(navigatorKey.currentContext!);
    final eventProvider = Provider.of<EventMaker>(navigatorKey.currentContext!, listen:false);
    print('UserState: ${user}');
    
    //depending on authentication state, do i go to sign in page? or home page?
    // we're gonna be using stream
    if (user == null) {
      return LogIn();
    }
    else{
      String UID = user.uid;
      //provider.updateEvent(UID);
      print("in wrapper ${UID}");
      eventProvider.setCurrentDate(DateTime.now());
      eventProvider.updateEventMaker(UID);
      getToken(UID); 
      return StreamProvider<MyUser>(
        create: (_) => DatabaseService(uid: UID).userData,
        initialData: MyUser(uid:UID),
        child: ChatHome(chatApi: ChatApi()),
      );
    }
  }

  void fetchLinkData() async {
    // FirebaseDynamicLinks.getInitialLInk does a call to firebase to get us the real link because we have shortened it.
    var link = await FirebaseDynamicLinks.instance.getInitialLink();
    print("////fetchLinkData ${link.toString()}");
    // This link may exist if the app was opened fresh so we'll want to handle it the same way onLink will.
    handleLinkData(link);

    // This will handle incoming links if the application is already opened
    FirebaseDynamicLinks.instance.onLink.listen((
        PendingDynamicLinkData dynamicLink)
    async {
      if(isDynamicOpening == false)
      {
        isDynamicOpening = true;
        handleLinkData(dynamicLink);
        print(isDynamicOpening);
        await Future.delayed(Duration(seconds: 5));
        isDynamicOpening = false;
        print(isDynamicOpening);
      }
    });
  }

  void handleLinkData(PendingDynamicLinkData? data) async {
    Uri? uri;
    if (Platform.isIOS){
      try{
        uri = Uri.parse(data!.link.queryParameters["link"]!);
        print("successfully read kakao dynamic link ${data}");
      }catch(e){
        print("error handling Link Data in IOS");
      }
    }
    else{
      uri = data?.link;
      print("successfully read kakao dynamic link ${data}");
    }
    try {
      if(uri != null) {
        final queryParams = uri.queryParameters;
        if(queryParams != null) {
          // verify the username is parsed correctly
          final String UID = Provider.of<MyUser?>(navigatorKey.currentContext!, listen:false)!.uid;
          print("successfully read kakao dynamic link ${UID}");
          print("successfully read kakao dynamic link ${queryParams.keys}");
          KakaoLinkWithDynamicLink().readDynamicLink(queryParams, UID, navigatorKey.currentContext!);

        } else {
          showDialog(
              context: navigatorKey.currentContext!,
              builder: (BuildContext context){
                return AlertDialog(
                    title: Text("no parameters"));
              }
          );
        }
      }
    } catch (e) {
      print("Error on query Parameters ${e}");
      /*
      showDialog(
          context: navigatorKey.currentContext!,
          builder: (BuildContext context){
            return AlertDialog(
              title: Text("${e}"),
            );
          }
      );
      */
    }

  }

  void getToken(UID) async{
      await FirebaseMessaging.instance.getToken().then(
        (token) async {
            String? mtoken = token;
            
           DatabaseService(uid:UID).updateField({'token': (token != null) ? token : '',}); 
           print("Token is ${token}");
            
        }
      );
    }

  Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

// For handling notification when the app is in terminated state
 checkForInitialMessage() async {
  RemoteMessage? initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    PushNotification notification = PushNotification(
      title: initialMessage.notification?.title,
      body: initialMessage.notification?.body,
    );
    setState(() {
      _notificationInfo = notification;
      _totalNotifications++;
    });
  }
}



  @override
  void initState() {

  checkForInitialMessage();

  // For handling notification when the app is in background
  // but not terminated
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    PushNotification notification = PushNotification(
      title: message.notification?.title,
      body: message.notification?.body,
    );
    setState(() {
      _notificationInfo = notification;
      _totalNotifications++;
    });
  });
    
    //해당 클래스가 호출되었을떄
    super.initState();

    //observer
    WidgetsBinding.instance.addObserver(this);
    fetchLinkData();

  }

  @override
  void dispose() {
    super.dispose();

    //observer
    WidgetsBinding.instance.removeObserver(this);
    fetchLinkData();
  }
}

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

