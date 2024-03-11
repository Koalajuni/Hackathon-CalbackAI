// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class LocalNotification{
//     LocalNotification._(); 


//     static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
//     FlutterLocalNotificationsPlugin(); 

//     static initialize() async {
//       AndroidInitializationSettings initializationSettingsAndroid = 
//       const AndroidInitializationSettings('mipmap/ic_launcher'); 


//       DarwinInitializationSettings initializationSettingsIOS = 
//       const DarwinInitializationSettings(
//         requestAlertPermission: false,
//         requestBadgePermission: false, 
//         requestSoundPermission: false, 
//       );

//     InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS
//     );
//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    
//     }
//     static void requestPermission(){
//       flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
//       ?.requestPermissions(
//         alert: true, 
//         badge: true,
//         sound: true,
//       );

//       FirebaseMessaging.instance.requestPermission(
//         alert: true,
//         announcement: false,
//         badge: true,
//         provisional: false,
//         sound: true,
//       );

    
//       Future<bool> appInitialize({required BuildContext context}) async{
//         LocalNotification.initialize();
//         return true; 
//       }


    
//     }


//     static Future<void> sampleNotification() async{
//       const AndroidNotificationDetails androidPlatformChannelSpecifics = 
//         AndroidNotificationDetails('chennel id', 'channel name',
//         channelDescription: 'channel description',
//         importance: Importance.max,
//         priority: Priority.max,
//         icon: "ic_notification",
//         showWhen: false);

//       const NotificationDetails platformChannelSpecifics = NotificationDetails(
//         android: androidPlatformChannelSpecifics,
//         iOS: DarwinNotificationDetails(
//           badgeNumber: 1,
//         ));

//         await flutterLocalNotificationsPlugin.show(
//           0, 'plain tile', 'plain body', platformChannelSpecifics, 
//           payload: 'item x'
//         );
//     }

//     }
