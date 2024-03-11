import 'package:calendar/pages/group/group_time_final.dart';
import 'package:calendar/pages/group/choose_preference_week.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/meeting.dart';
import '../../models/user.dart';
import '../../services/database.dart';
import '../all_pages.dart';
import 'package:intl/intl.dart';

class MeetRequestTile extends StatefulWidget {
  MeetRequestTile({Key? key, required this.myUid, required this.mid})
      : super(key: key);
  String myUid;
  String mid;

  @override
  State<MeetRequestTile> createState() => _MeetRequestTileState();
}

class _MeetRequestTileState extends State<MeetRequestTile> {
  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventMaker>(context, listen: false);
    String languageCode = Localizations.localeOf(context).languageCode;
    print('///// this is mid length ${widget.mid.length}');
    String friendUid =
        widget.mid.substring(widget.mid.length - 28, widget.mid.length);
    return StreamBuilder<MyUser>(
        stream: DatabaseService(uid: friendUid).userData,
        builder: (context, userSnapshot) {
          return FutureBuilder<Meeting>(
            future:
                DatabaseService(uid: friendUid).singleMeetingData(widget.mid),
            builder: (context, meetingSnapshot) {
              if (meetingSnapshot.hasData && userSnapshot.hasData) {
                MyUser? userData = userSnapshot.data;
                Meeting? meetingData = meetingSnapshot.data;
                String from = meetingData!.from.toString().substring(2, 16);
                print(from);
                // print("Datetime parsed from from is: ${DateTime.parse(from)}");
                // DateTime dtFrom = DateTime.parse(from);
                String to = meetingData.to.toString().substring(2, 16);
                // print("Datetime parsed from to is: ${DateTime.parse(to)}");
                // DateTime dtTo = DateTime.parse(to);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 126,
                    child: ListTile(
                        tileColor: Colors.white,
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                        ),
                        leading: Column(
                          children: [
                            SizedBox(height: 10),
                            CircleAvatar(
                              radius: 27.0,
                              backgroundImage: userData!.photoUrl != ''
                                  ? CachedNetworkImageProvider(
                                      userData!.photoUrl)
                                  : null,
                            ),
                            SizedBox(height: 10),
                            SizedBox(
                                height: 20,
                                width: 60,
                                child: Center(
                                    child: Text(userData.name,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.bold)))),
                          ],
                        ),
                        title: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              // given events end on the same day.
                              SizedBox(
                                  width: 100,
                                  height: 20,
                                  child: Center(
                                      child: Text(meetingData!.content,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 18,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.bold)))),
                              SizedBox(height: 6),
                              Text(from.substring(0, 8),
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  "${from.substring(
                                    8,
                                  )} ~${to.substring(
                                    8,
                                  )}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Roboto',
                                  )),
                              SizedBox(height: 10),
                            ]),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 26),
                            Wrap(
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(Icons.check,
                                      color: uiSettingColor.minimal_1),
                                  iconSize: 28,
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                          title: Text(
                                              AppLocalizations.of(context)!
                                                  .notification_addedMeeting),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .ok),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                // setState(() {});
                                              },
                                            ),
                                          ]),
                                    );
                                    await DatabaseService(uid: widget.myUid)
                                        .acceptMeetReq(widget.myUid, friendUid,
                                            widget.mid);
                                    await DatabaseService(uid: widget.myUid)
                                        .removePendingInvolved(
                                            widget.myUid, widget.mid);
                                    if (widget.mid.substring(0, 7) ==
                                        'pending') {
                                      await DatabaseService(uid: widget.myUid)
                                          .updatePendingTime(
                                              widget.myUid, widget.mid);
                                    }
                                    eventProvider
                                        .updateEventMaker(widget.myUid);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.black),
                                  iconSize: 28,
                                  onPressed: () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                          title: Text(AppLocalizations.of(
                                                  context)!
                                              .notification_rejectedMeeting),
                                          actions: <Widget>[
                                            ElevatedButton(
                                              child: Text(
                                                  AppLocalizations.of(context)!
                                                      .ok),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                // setState(() {});
                                              },
                                            ),
                                          ]),
                                    );
                                    await DatabaseService(uid: widget.myUid)
                                        .declineMeetReq(widget.myUid, friendUid,
                                            widget.mid);
                                    await DatabaseService(uid: widget.myUid)
                                        .removePendingInvolved(
                                            widget.myUid, widget.mid);
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        )),
                  ),
                );
              } else {
                return Container();
              }
            },
          );
        });
  }
}
