import 'package:calendar/models/meeting.dart';
import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/group/choose_preference_week.dart';
import 'package:calendar/pages/notifications/pending_request_tile.dart';
import 'package:calendar/services/database.dart';
import 'package:flutter/material.dart';

import '../homepage/drawer_builder.dart';
import 'friend_request_tile.dart';
import 'meeting_request_tile.dart';

class Notifications extends StatefulWidget {
  Notifications({Key? key, required this.uid, required this.reqLength}) : super(key: key);
  String uid;
  int reqLength;

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  callback(String uid, String mid, Meeting meetingData, Map<String,dynamic> pendingInstance) async {
    setState(() {
      Navigator.push(context, MaterialPageRoute(builder: (context) => 
        PreferredWeekly(meeting: meetingData, pendingMeeting: pendingInstance),));
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);

    return Scaffold(
      backgroundColor: Color.fromRGBO(246, 245, 255, 1),
      appBar: AppBar(
        bottomOpacity: 0,
        iconTheme: IconThemeData(
          color: Colors.black,
          size: 30,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 60,
        automaticallyImplyLeading: false,
        title: Text(
            AppLocalizations.of(context)!.notification,
          style: TextStyle(
            fontSize: 24,
              color: Colors.black, fontFamily: 'Roboto', fontWeight: FontWeight.bold
          )
        ),
        centerTitle: false,
      ),
      endDrawer: DrawerBuilder(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Container(
              alignment: Alignment.center,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.notification_opening, style: TextStyle(fontSize: 20, color: Colors.black, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text(AppLocalizations.of(context)!.notification_openingUnder, style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(width: 14),
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/logo_icon_whiteBG.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            StreamBuilder<MyUser>(
              stream: DatabaseService(uid: widget.uid).userData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  MyUser? userData = snapshot.data;
                 var friendRequest = [];
                 var meetingRequest = [];
                 var pendingRequest = [];
                  // Divides all req received into Pending, Meeting and Friend Req
                  for(var i = 0; i < userData!.reqReceived.length; i++){
                    if (userData!.reqReceived[i].substring(0,6) == 'pendin'){
                      pendingRequest.add(userData!.reqReceived[i]);
                    } else if (userData!.reqReceived[i].length > 30){
                      meetingRequest.add(userData!.reqReceived[i]);
                    } else{
                      friendRequest.add(userData!.reqReceived[i]);
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            AppLocalizations.of(context)!.notification_friendRequest,
                            style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Roboto', fontWeight: FontWeight.bold)
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          height: friendRequest.length * 90,
                          child: ListView.builder (
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: friendRequest.length,
                            itemBuilder: (context, index) {
                              String friendUid = userData.reqReceived[index];
                                return(FriendRequestTile(myUid: widget.uid, friendUid: friendUid));
                            },
                          ),
                        ),
                        SizedBox(height: 30),
                        Divider(),
                        Text(
                            AppLocalizations.of(context)!.notification_meetingRequest,
                            style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Roboto', fontWeight: FontWeight.bold)
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          height: meetingRequest.length * 140,
                          child: ListView.builder (
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: meetingRequest.length,
                            itemBuilder: (context, index) {
                              String mid = meetingRequest[index];
                                return(MeetRequestTile(
                                  myUid: widget.uid,
                                  mid: mid,
                                ));                            
                            },
                          ),
                        ),
                        SizedBox(height: 30),
                        Divider(),
                        Row(
                          children: [
                            Text(
                                AppLocalizations.of(context)!.notification_pendingRequest,
                                style: TextStyle(color: Colors.black, fontSize: 18, fontFamily: 'Roboto', fontWeight: FontWeight.bold)
                            ),
                            Spacer(),
                            ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  shape:
                                  new RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(10.0),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                onPressed:() async {
                                  await  Navigator.push(context,
                                      CustomPageRoute(
                                        child: StreamProvider(
                                          create: (context) => DatabaseService(uid: user.uid).userData,
                                          initialData: MyUser(uid:user.uid),builder: (context, child) => GroupPending(),
                                        ),
                                        direction: AxisDirection.up,
                                      )
                                  );
                                },
                                label: Text(AppLocalizations.of(context)!.pending,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 50, 50, 50),
                                    fontFamily: 'Roboto', fontWeight:  FontWeight.bold,
                                  ),),
                                icon: Icon(Icons.hourglass_empty_rounded, color: Colors.black)
                            ),
                            SizedBox(width:20),
                          ],
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          height: pendingRequest.length * 140,
                          child: ListView.builder (
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: userData!.reqReceived.length,
                            itemBuilder: (context, index) {
                              String mid = userData.reqReceived[index];
                              String sharedCheck = mid.substring(0, 6);

                              if (sharedCheck == 'pendin') {
                                print("WE HAVE FOUND YOUR MEETING HERE!!!");
                                print("widget.uid is ${widget.uid}");
                                print("mid is $mid");
                                return(PendingRequestTile(
                                  myUid: widget.uid,
                                  mid: mid,
                                  parentCallback: callback,
                                ));
                              }
                              else {
                                return (
                                    Container(
                                    )
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }

                else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
