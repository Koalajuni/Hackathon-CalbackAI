import 'package:badges/badges.dart';
import 'package:calendar/pages/notifications/notifications_main.dart';
import 'package:calendar/pages/group/group_time_final.dart';
import 'package:flutter/material.dart';
import 'package:calendar/models/user.dart';
import 'package:calendar/services/database.dart';
import 'package:calendar/pages/friends/friend_search.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/friends/person_tile.dart';



class BlockedUsers extends StatefulWidget {
  const BlockedUsers({Key? key}) : super(key: key);

  @override
  State<BlockedUsers> createState() => _BlockedUsersState();
}


class _BlockedUsersState extends State<BlockedUsers> {

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    int blockedNum = user.blockedUsers.length;
    return Dismissible(
      direction: DismissDirection.horizontal,
      key: const Key('key'),
      onDismissed: (_) => Navigator.of(context).pop(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: uiSettingColor.minimal_1),
          title: Text("Blocked Users",
            style: TextStyle(
            fontSize: 32,
            color: Color.fromARGB(255, 50, 50, 50),
            fontFamily: 'Roboto-Bold',
          ),
          ),
        ),
        backgroundColor: Colors.white,
        //-------------------- body --------------------//

        body: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 6),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget> [
                SizedBox(height: 24),
                Text(
                    'Blocked Users ($blockedNum)',
                    style: TextStyle(
                      color: Color.fromARGB(255, 130, 130, 130),
                      fontSize: 13.0,
                    )
                ),
                SizedBox(height: 8),
                Expanded(
                  child:
                  ListView.builder(
                    itemCount: user.blockedUsers.length,
                    itemBuilder: (BuildContext context, int index) {
                      return BlockProfileTile(UID: user.blockedUsers[index]);
                    },
                  ),
                ),
              ]
          ),
        ),
      ),
    );
  }

}

