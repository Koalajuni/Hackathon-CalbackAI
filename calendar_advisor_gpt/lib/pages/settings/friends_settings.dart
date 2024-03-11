import 'package:flutter/material.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/services/auth.dart';

import '../blocked_users.dart';



class FriendSettings extends StatefulWidget {
  const FriendSettings({ Key? key }) : super(key: key);

  @override
  State<FriendSettings> createState() => _FriendSettingsState();
}

class _FriendSettingsState extends State<FriendSettings> {

  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    final eventProvider = Provider.of<EventMaker>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(
                      color: Colors.black
                    ),
        backgroundColor: Colors.white70,
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.friends,
            style:TextStyle(
              color: Colors.black,
            )),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: <Widget> [
              ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: const EdgeInsets.all(2),
                children:<Widget> [
                  ListTile(
                    leading: Icon(Icons.people),
                    title: Text(AppLocalizations.of(context)!.blocked_users,
                        style:TextStyle(
                          color: Colors.black,
                        )),
                    trailing: Icon(Icons.keyboard_arrow_right),
                    onTap:() async {
                      Navigator.push(context,
                          CustomPageRoute(
                              child: BlockedUsers(),
                              direction: AxisDirection.up
                          )

                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

  }

}