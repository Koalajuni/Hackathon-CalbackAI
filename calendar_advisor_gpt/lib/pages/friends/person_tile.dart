import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/friends/friend_calendar.dart';
import 'package:flutter/material.dart';
import 'package:calendar/services/auth.dart';
import 'package:calendar/services/database.dart';

class PersonTile extends StatelessWidget  {
  const PersonTile({Key? key, required this.UID}) : super(key: key);
  final String UID;

  @override
  Widget build(BuildContext context) {
    final currUser = Provider.of<MyUser>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: StreamBuilder<MyUser>(
        stream: DatabaseService(uid: UID).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            MyUser? userData = snapshot.data;
            return Row(
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    if (currUser.uid.substring(0,4) != 'open') {
                      DatabaseService(uid: UID).viewsIncr(currUser.uid);
                      Navigator.push(context,
                        CustomPageRoute(
                        child: MyProfile(
                            user: userData),
                        direction: AxisDirection.up
                        )
                      );
                    }

                    else {
                      if (UID.substring(0,4) == 'open') {
                        DatabaseService(uid: UID).viewsIncr(currUser.uid);
                        Navigator.push(context,
                          CustomPageRoute(
                          child: MyProfile(
                              user: userData),
                          direction: AxisDirection.up
                          )
                        );
                      }
                    }
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          image: userData!.photoUrl != '' ?  DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(userData!.photoUrl)
                          ) : null,
                          borderRadius: BorderRadius.all(Radius.circular(40/2.5)),
                          border: 1 != null ? Border.all(
                            color: ColorSetting().minimal_1,
                            width: 1,
                          ) : null,
                        ),
                      ),
                      SizedBox(width: 15),
                      SizedBox(
                        width: 100,
                        child: Text(userData!.name, style: uiSettingFont.head_6)
                      ),
                      SizedBox(width: 80),
                    ],
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 100,
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(
                            horizontal:20,
                            vertical: 20,
                          ),
                          child: Column(
                            children:<Widget> [
                              Text(
                                AppLocalizations.of(context)!.friend_options,
                                style: uiSettingFont.head_5,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton.icon(
                                      icon: Icon(Icons.close),
                                      label: Text(AppLocalizations.of(context)!.friend_optionsDelete),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.black,
                                      ),
                                      onPressed: () async {
                                        DatabaseService(uid: UID).removeFriend(currUser.uid,userData.uid);
                                        Navigator.pop(context);
                                      }
                                  ),
                                  ElevatedButton.icon(
                                      icon: Icon(Icons.flag),
                                      label: Text(AppLocalizations.of(context)!.friend_optionsReport),
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.black,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder:(context) => AlertDialog(
                                              title:  Text(AppLocalizations.of(context)!.friend_report),
                                              actions: <Widget>[
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    ElevatedButton(
                                                      child: Text(AppLocalizations.of(context)!.friend_reportBlock),
                                                      onPressed: () async {
                                                        DatabaseService(uid: UID).removeFriend(currUser.uid,userData.uid);
                                                        await DatabaseService(uid: UID).blockFriend(currUser.uid,userData.uid);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: const Text('Added to Blocked Users'),
                                                            action: SnackBarAction(
                                                              label: 'UnBlock',
                                                              onPressed: () {
                                                                DatabaseService(uid: UID).unblockFriend(currUser.uid,userData.uid);
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                    ElevatedButton(
                                                      child: Text(AppLocalizations.of(context)!.cancel),
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                        Navigator.of(context).pop();
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ]
                                          ),
                                        );
                                      }
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    );
                  }
                ),
              ]
            );
          }

          else {
            return Container();
          }
        }
      ),
    );
  }
}


class ProfileTile extends StatelessWidget  {
  const ProfileTile({Key? key, required this.UID}) : super(key: key);
  final String UID;

  @override
  Widget build(BuildContext context) {
    final currUser = Provider.of<MyUser>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: StreamBuilder<MyUser>(
        stream: DatabaseService(uid: UID).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            MyUser? userData = snapshot.data;
            return Row(
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    Navigator.push(context,
                      CustomPageRoute(
                      child: MyProfile(
                        user: userData
                      ),
                      direction: AxisDirection.up
                      )
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          image: userData!.photoUrl != '' ?  DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(userData!.photoUrl)) :  null,
                            borderRadius: BorderRadius.all(
                              Radius.circular(40/2.5)),
                              border: 1 != null ? Border.all(
                                color: ColorSetting().minimal_1,
                                width: 1,) : null,
                                ),
                                ),
                      SizedBox(width: 15),
                      SizedBox(
                          child: Text(userData!.name)),
                      SizedBox(width: 130),
                    ],
                  ),
                ),
              ]
            );
          }

          else {
            return Container();
          }
        }
      ),
    );
  }
}


class BlockProfileTile extends StatelessWidget  {
  const BlockProfileTile({Key? key, required this.UID}) : super(key: key);
  final String UID;

  @override
  Widget build(BuildContext context) {
    final currUser = Provider.of<MyUser>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: StreamBuilder<MyUser>(
          stream: DatabaseService(uid: UID).userData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              MyUser? userData = snapshot.data;
              return Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        DatabaseService(uid: UID).viewsIncr(currUser.uid);
                        Navigator.push(context,
                            CustomPageRoute(
                                child: MyProfile(
                                    user: userData),
                                direction: AxisDirection.up
                            )
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30.0,
                            backgroundImage: userData!.photoUrl != '' ? CachedNetworkImageProvider(userData!.photoUrl) : null,
                          ),
                          SizedBox(width: 15),
                          Text(userData!.name, style: uiSettingFont.head_6),
                          SizedBox(width: 130),
                        ],
                      ),
                    ),
                    Spacer(),
                    IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 100,
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(
                                  horizontal:20,
                                  vertical: 20,
                                ),
                                child: Column(
                                  children:<Widget> [
                                    Text(
                                      'Options',
                                      style: uiSettingFont.head_5,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton.icon(
                                            icon: Icon(Icons.close),
                                            label: Text("Delete"),
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.black,
                                            ),
                                            onPressed: () async {
                                              DatabaseService(uid: UID).removeFriend(currUser.uid,userData.uid);
                                              Navigator.pop(context);
                                            }
                                        ),
                                        ElevatedButton.icon(
                                            icon: Icon(Icons.block),
                                            label: Text("Unblock"),
                                            style: ElevatedButton.styleFrom(
                                              primary: Colors.black,
                                            ),
                                            onPressed: () {
                                              DatabaseService(uid: UID).unblockFriend(currUser.uid,userData.uid);
                                              Navigator.pop(context);
                                            }
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          );
                        }
                    ),
                  ]
              );
            }
            else {
              return Container();
            }
          }
      ),
    );
  }
}