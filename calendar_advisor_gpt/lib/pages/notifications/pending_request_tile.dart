import 'package:calendar/pages/group/choose_preference_week.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/meeting.dart';
import '../../models/user.dart';
import '../../services/database.dart';
import '../all_pages.dart';

doNothing() {}

class PendingRequestTile extends StatefulWidget {
  PendingRequestTile({Key? key, required this.myUid, required this.mid, this.parentCallback = doNothing}) : super(key: key);
  String myUid;
  String mid;
  Function parentCallback;

  @override
  State<PendingRequestTile> createState() => _PendingRequestTileState();
}

class _PendingRequestTileState extends State<PendingRequestTile> {
  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventMaker>(context, listen:false);
    print('///// this is mid length ${widget.mid.length}');
    String friendUid = widget.mid.substring(widget.mid.length-28, widget.mid.length);
    return StreamBuilder<MyUser>(
        stream: DatabaseService(uid: friendUid).userData,
        builder: (context, userSnapshot) {
          return FutureBuilder<Meeting>(
            future: DatabaseService(uid: friendUid).singleMeetingData(widget.mid),
            builder: (context, meetingSnapshot) {
              if (meetingSnapshot.hasData && userSnapshot.hasData) {
                MyUser? userData = userSnapshot.data;
                Meeting? meetingData = meetingSnapshot.data;
                String from = meetingData!.from.toString().substring(2,11);
                String to = meetingData.to.toString().substring(2,11);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
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
                            backgroundImage:userData!.photoUrl != '' ? CachedNetworkImageProvider(userData!.photoUrl) : null,
                          ),
                          SizedBox(height: 10),
                          SizedBox(
                              height: 20,
                              width: 70,
                              child: Center(
                                  child: Text(userData.name, style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.bold) ))),
                        ],
                      ),
                      title: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget> [
                            SizedBox(
                                width: 100,
                                height: 20,
                                child: Center(
                                    child: Text(meetingData!.content, style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Roboto', fontWeight: FontWeight.bold)))),
                            Text("$from ~ $to", style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Roboto')),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 92,
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                    shape:
                                    new RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.circular(10.0),
                                    ),
                                    primary: uiSettingColor.minimal_1,
                                  ),
                                    onPressed:() async {
                                      await DatabaseService(uid: widget.myUid).acceptMeetReq(widget.myUid, friendUid, widget.mid);
                                      if (widget.mid.substring(0,7) == 'pending') {
                                        await DatabaseService(uid: widget.myUid).updatePendingTime(widget.myUid, widget.mid);
                                        Map<String, dynamic> pendingInstance = await DatabaseService(uid: widget.myUid).getPendingTime(widget.mid);
                                        widget.parentCallback(widget.myUid, widget.mid, meetingData, pendingInstance);
                                      }
                                      eventProvider.updateEventMaker(widget.myUid);
                                    },
                                    child: Text(AppLocalizations.of(context)!.notification_sendTime, style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.bold),),
                                ),
                                ),
                                SizedBox(width: 20),
                                SizedBox(
                                  width: 92,
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape:
                                      new RoundedRectangleBorder(
                                        borderRadius: new BorderRadius.circular(10.0),
                                      ),
                                      primary:  Colors.white70,
                                    ),
                                    onPressed:() async {showDialog(
                                      context: context,
                                      builder:(context) =>  AlertDialog(
                                          title: Text(AppLocalizations.of(context)!.reject),
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
                                    await DatabaseService(uid: widget.myUid).declineMeetReq(widget.myUid, friendUid, widget.mid);
                                    },
                                    child: Text(AppLocalizations.of(context)!.reject, style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Roboto', fontWeight: FontWeight.bold),),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height:20),
                          ]
                      ),
                  ),
                );
              }

              else {
                return Container(child: Text(""),);
              }
            },
          );
        }
    );
  }
}