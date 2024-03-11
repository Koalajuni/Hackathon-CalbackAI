import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/notifications/notifications_main.dart';
import 'package:calendar/services/google_calendar_services.dart';
import 'package:flutter/material.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/shared/globals.dart' as globals;
import 'package:calendar/pages/settings/language_settings.dart';

import '../../models/user.dart';
import '../../services/auth.dart';
import '../../services/database.dart';
import '../settings/account_settings.dart';
import '../settings/language_settings.dart';

class DrawerBuilder extends StatelessWidget {
  const DrawerBuilder({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) =>
      Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildHeader(context),
            buildMenu(context),
            buildBottomMenu(context)
          ],
        ),

      );



  Widget buildHeader(BuildContext context) {
    final user = Provider.of<MyUser>(context);
      return Material(
        color: uiSettingColor.minimal_2,
        child: Container(
          padding: EdgeInsets.only(top: 24 + MediaQuery.of(context).padding.top,bottom: 24,),
          child: Column(
            children: [
              CircleAvatar(
                  radius: 52,
                  backgroundImage: user!.photoUrl != ''? CachedNetworkImageProvider(user!.photoUrl) : null
              ),
              SizedBox(height: 12),
              Text(user!.name,style: TextStyle(fontSize: 16, color: Colors.black, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
            ],
          ),


        ),
      );
}

  Widget buildMenu(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    final AuthService _auth = AuthService();
    final eventProvider = Provider.of<EventMaker>(context);

    return Column(
    children: [
      ListTile(
        leading: const Icon(Icons.account_circle_outlined),
        title: Text(AppLocalizations.of(context)!.account),
        onTap:() {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AccountSettings()));
        } ,
      ),
      Divider(),
      // ListTile(
      //   leading: const Icon(Icons.abc),
      //   title: Text("Google Calendar"),
      //   onTap:() {
      //     GoogelCalendarServices().connectGoogleCalendar();
      //   } ,
      // ),
      Divider(),
      ListTile(
        leading: const Icon(Icons.language_outlined),
        title: Text(AppLocalizations.of(context)!.languages),
        onTap:() {
          Navigator.push(context, MaterialPageRoute(builder: (context) => LanguageSettings()));
        } ,
      ),
      Divider(),
    ],
  );
  }

  Widget buildBottomMenu(BuildContext context) {
    final AuthService _auth = AuthService();
    final eventProvider = Provider.of<EventMaker>(context);

    return Container(
      child: Align(
        alignment:  FractionalOffset.bottomCenter,
        child: Container(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: Text(AppLocalizations.of(context)!.logout,),
                onTap:() async {
                  globals.bnbIndex = 0;
                  eventProvider.resetEvent();
                  Navigator.of(context).pop();
                  await _auth.signOut();
                } ,
              ),
            ],
          ),
        ),
      ),
    );
  }


}