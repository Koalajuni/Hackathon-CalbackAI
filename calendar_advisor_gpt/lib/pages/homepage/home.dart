import 'package:badges/badges.dart' as origBadge;
import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/settings/user_settings.dart';
import 'package:calendar/services/database.dart';
import 'package:calendar/services/update_docs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:calendar/services/auth.dart';
import 'package:calendar/shared/globals.dart' as globals;
import 'package:flutter/services.dart';
import '../../models/meeting.dart';
import '../../models/user.dart';
import '../../services_kakao/kakao_link_with_dynamic_link.dart';
import '../events/event_viewer.dart';
import '../notifications/notifications_main.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

//widgets binding observer to return back to the app
class _HomeState extends State<Home> {
  @override
  void _onItemTapped(int index) {
    setState(() {
      globals.bnbIndex = index;
    });
  }

  Widget build(navigatorKey) {
    //AuthService().signOut();
    final user = Provider.of<MyUser>(context);
    final eventProvider = Provider.of<EventMaker>(context);
    final List<Widget> _widgetOptions = [
      Opening(),
      Friends(),
      Monthly(),
      Notifications(uid: user.uid, reqLength: user.reqReceived.length),
      SettingsForm(),
    ];

    // update new data field for existing documents
    // WARNING : Do not use unless databaseservices updateUserData()
    // has been properly updated to appropriate data fields/model
    // updateDocs();

    cleanBadge(user);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: _widgetOptions.elementAt(globals.bnbIndex),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: uiSettingColor.minimal_1,
        selectedFontSize: 14,
        unselectedItemColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: AppLocalizations.of(context)!.friends,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: AppLocalizations.of(context)!.calendar,
          ),
          BottomNavigationBarItem(
            icon: origBadge.Badge(
              showBadge: user.reqReceived.isEmpty ? false : true,
              position: origBadge.BadgePosition.bottomEnd(bottom: 5, end: 7),
              badgeContent: Text('${user.reqReceived.length}'),
              child: Icon(Icons.notifications_none_rounded),
            ),
            label: AppLocalizations.of(context)!.notification,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
        currentIndex: globals.bnbIndex,
        onTap: (index) {
          _onItemTapped(index);
          eventProvider.setDailyDate(DateTime.now());
        },
      ),

      // -------- activate when ready ---------- // 

      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.white,
      //   type: BottomNavigationBarType.fixed,
      //   iconSize: 30,
      //   showSelectedLabels: false,
      //   showUnselectedLabels: false,
      //   selectedItemColor: uiSettingColor.minimal_1,
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Image.asset('assets/icons/bnb_home.png', color: Color(0xffB2B1FF),),
      //       activeIcon: Image.asset('assets/icons/bnb_home.png', color: Color(0xff5E5CEC),),
      //       label: AppLocalizations.of(context)!.home,
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Image.asset('assets/icons/bnb_person.png', color: Color(0xffB2B1FF), ),
      //       activeIcon: Image.asset('assets/icons/bnb_person.png', color: Color(0xff5E5CEC),),
      //       label: AppLocalizations.of(context)!.friends,
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Image.asset('assets/icons/bnb_calendar.png', color: Color(0xffB2B1FF),),
      //       activeIcon: Image.asset('assets/icons/bnb_calendar.png', color: Color(0xff5E5CEC),),
      //       label: AppLocalizations.of(context)!.calendar,
      //     ),
      //     BottomNavigationBarItem(
      //       icon: origBadge.Badge(
      //         showBadge: user.reqReceived.isEmpty ? false : true,
      //         position: origBadge.BadgePosition.bottomEnd(bottom: 5, end: 7),
      //         badgeContent: Text('${user.reqReceived.length}'),
      //         child: Image.asset('assets/icons/bnb_notification.png', color: Color(0xffB2B1FF),),
      //       ),
      //       activeIcon: Image.asset('assets/icons/bnb_notification.png', color: Color(0xff5E5CEC),),
      //       label: AppLocalizations.of(context)!.notification,
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Image.asset('assets/icons/bnb_settings.png', color: Color(0xffB2B1FF),),
      //       activeIcon: Image.asset('assets/icons/bnb_settings.png', color: Color(0xff5E5CEC),),
      //       label: AppLocalizations.of(context)!.settings,
      //     ),
      //   ],
      //   currentIndex: globals.bnbIndex,
      //   onTap: (index) {
      //     _onItemTapped(index);
      //     eventProvider.setDailyDate(DateTime.now());
      //   },
      // ),   
    
    );
  }

  cleanBadge(MyUser providerUser) async {
    providerUser.reqReceived.forEach((request) async {
      DocumentSnapshot<Object?> checkMeeting =
          await DatabaseService(uid: providerUser.uid)
              .meetingsCollection
              .doc(request)
              .get();

      // Clean any ghost meeting notifications
      if (!checkMeeting.exists) {
        if (request.length > 28) {
          await DatabaseService(uid: providerUser.uid)
              .declineMeetReq(providerUser.uid, request.substring(31), request);
        }
      }
    });
  }
}
