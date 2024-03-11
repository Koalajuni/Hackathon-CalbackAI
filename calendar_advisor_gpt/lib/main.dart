import 'dart:io' show Platform;
import 'package:calendar/l10n/change_language.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/authenticate/register.dart';
import 'package:calendar/pages/chatgpt_stuff/backend/chat_api.dart';
import 'package:calendar/pages/settings/user_settings.dart';
import 'package:calendar/pages/wrapper.dart';
import 'package:calendar/services/auth.dart';
import 'package:calendar/services/database.dart';
import 'package:calendar/services/notification_services/local_notification.dart';
import 'package:calendar/services/notification_services/push_notification.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:rxdart/rxdart.dart';

import 'pages/chatgpt_model/frontend/chat_home_page.dart';


final navigatorKey = GlobalKey<NavigatorState>();


  // used to pass messages from event handler to the UI
final _messageStreamController = BehaviorSubject<RemoteMessage>(); // TODO: Add stream controller

// TODO: Define the background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

 if (kDebugMode) {
   print("Handling a background message: ${message.messageId}");
   print('Message data: ${message.data}');
   print('Message notification: ${message.notification?.title}');
   print('Message notification: ${message.notification?.body}');
 }
}


void main() async {

  // next two lines are needed to use firebase_auth
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isIOS) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "falseapiKeyfordummyuseabcd12345",
            appId: "falseappIDfordummyuseabcd12345",
            messagingSenderId: "falsesenderIDfordummyuseabcd12345",
            projectId: "falseapi-fdeeb"));
  } else {
    await Firebase.initializeApp();
  }

Future requestPermission() async {

    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

     if (settings.authorizationStatus == AuthorizationStatus.authorized){
       print('User granted Permission');
  
       
     }
     else if (settings.authorizationStatus == AuthorizationStatus.provisional){
       print('User granted Provisional Permission');
     }
     else{
       print("User declined or has not granted permission ");
     }
  }

 // TODO: Set up foreground message handler
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
   if (kDebugMode) {
     print('Handling a foreground message: ${message.messageId}');
     print('Message data: ${message.data}');
     print('Message notification: ${message.notification?.title}');
     print('Message notification: ${message.notification?.body}');
   }

   _messageStreamController.sink.add(message);
 });
 

 // TODO: Set up background message handler

 FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);



  KakaoSdk.init(nativeAppKey: 'c7e2fb9565dbf2370d429195dadb0286');
  //KakaoLinkWithDynamicLink().setup();

  //await NotificationService().init();

  InAppUpdate.checkForUpdate().then((updateInfo) {
    if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
      if (updateInfo.immediateUpdateAllowed) {
        // Perform immediate update
        InAppUpdate.performImmediateUpdate().then((appUpdateResult) {
          if (appUpdateResult == AppUpdateResult.success) {
            //App Update successful
          }
        });
      } else if (updateInfo.flexibleUpdateAllowed) {
        //Perform flexible update
        InAppUpdate.startFlexibleUpdate().then((appUpdateResult) {
          if (appUpdateResult == AppUpdateResult.success) {
            //App Update successful
            InAppUpdate.completeFlexibleUpdate();
          }
        });
      }
    }
  });

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // LocalNotification.requestPermission();
  return OverlaySupport(
    child: ScreenUtilInit(
      designSize: Size(360, 780),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) =>  MultiProvider(
      providers: [
        StreamProvider(
          create: (context) => AuthService().my_user,
          // 1) value of StreamProvider is the Stream value my_user inside AuthService Class
          // 2) I'm listening to the my_user instance for authentication changes
          // 3)what kind of data type are we listening to?// 'MyUser' data
          initialData: null,
        ),
        ChangeNotifierProvider(create: (context) => EventMaker()),
        ChangeNotifierProvider(create: (context) => ChangeLanguage()),
      ],
      builder: (context, child) {
        final languageProvider = Provider.of<ChangeLanguage>(context);
        return  MaterialApp(
          scrollBehavior: MyBehavior(),
          navigatorKey: navigatorKey,
          navigatorObservers: [AnalyticsService().getAnalyticsObserver()],
          initialRoute: '/wrapper',
        
          routes: {
            '/wrapper': (context) => Wrapper(),
            '/loading': (context) => Loading(),
            '/login': (context) => LogIn(),
            '/home': (context) => ChatHome(chatApi: ChatApi(),),
            '/monthly': (context) => Monthly(),
            '/weekly': (context) => Weekly(),
            '/daily': (context) => Daily(),
            '/friends': (context) => Friends(),
            '/register': (context) => Register(),
            '/settings': (context) => SettingsForm(),
          },
          locale: languageProvider.locale,
          supportedLocales: L10n.all,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
        );
      }),
    ),
  );
  
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}