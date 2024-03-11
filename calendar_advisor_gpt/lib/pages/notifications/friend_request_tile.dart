import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/friendship.dart';
import '../../models/meeting.dart';
import '../../models/user.dart';
import '../../services/database.dart';
import '../all_pages.dart';


class FriendRequestTile extends StatefulWidget {
  FriendRequestTile({Key? key, required this.myUid, required this.friendUid}) : super(key: key);
  String myUid;
  String friendUid;

  @override
  State<FriendRequestTile> createState() => _FriendRequestTileState();
}

class _FriendRequestTileState extends State<FriendRequestTile> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MyUser>(
      stream: DatabaseService(uid: widget.friendUid).userData,
      builder: (context, snapshot) {
        MyUser? userData = snapshot.data;
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                tileColor: Colors.white,
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0),
                ),
                leading: CircleAvatar(
                  radius: 26.0,
                  backgroundImage:userData!.photoUrl != '' ? CachedNetworkImageProvider(userData!.photoUrl) : null,
                ),
                title: Text(userData!.name, style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                trailing: Wrap(
                  children: <Widget> [
                    IconButton(
                      icon: Icon(Icons.check, color: uiSettingColor.minimal_1),
                      iconSize: 26,
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder:(context) =>  AlertDialog(
                              title: Text(AppLocalizations.of(context)!.notification_addedFriend),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: Text(AppLocalizations.of(context)!.ok),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // setState(() {});
                                  },
                                ),
                              ]
                          ),
                        );

                        await DatabaseService(uid: widget.myUid).acceptFriendReq(Friendship(myUid: widget.myUid, friendUid: widget.friendUid));
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.black),
                      iconSize: 27,
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder:(context) =>  AlertDialog(
                              title: Text(AppLocalizations.of(context)!.notification_rejectedFriend),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: Text(AppLocalizations.of(context)!.ok),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    // setState(() {});
                                  },
                                ),
                              ]
                          ),
                        );
                        await DatabaseService(uid: widget.myUid).declineFriendReq(Friendship(myUid: widget.myUid, friendUid: widget.friendUid));
                      },
                    ),
                  ],
                )
            ),
          );
        }

        else {
          return Container();
        }
      },
    );
  }
}