import 'package:calendar/models/pendingTime.dart';
import 'package:calendar/models/meeting.dart';
import 'package:calendar/models/user.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/group/group_time_final.dart';
import 'package:calendar/pages/group/group_create.dart';
import 'package:calendar/pages/group/choose_preference_week.dart';
import 'package:calendar/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupPending extends StatefulWidget {
  GroupPending({Key? key}) : super(key: key);

  @override
  State<GroupPending> createState() => _GroupPendingState();
}

class _GroupPendingState extends State<GroupPending> {

  callback() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    return Dismissible(
      direction: DismissDirection.horizontal,
      key: const Key('key'),
      onDismissed: (_) => Navigator.of(context).pop(),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
              color: Colors.black
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          leading: BackButton(),
          title: Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              AppLocalizations.of(context)!.pending,
              style: TextStyle(
                fontSize: 22,
                color: Color.fromARGB(255, 50, 50, 50),
                fontFamily: 'Roboto', fontWeight:  FontWeight.bold,
              ),
            ),
          ),
          elevation: 0.0,
        ),

        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              FutureBuilder<List<Meeting>>(
                future: DatabaseService(uid: user.uid).getMeetings(),
                builder: (context, meetingSnapshot) {
                  if (meetingSnapshot.hasData) {
                    // Get all user involved/owned meetings and find the pending ones
                    List<Meeting>? userRaw = meetingSnapshot.data;
                    List<Meeting> meetings = [];
                    userRaw?.forEach((meeting) {
                      if (meeting.MID.substring(0,7) == 'pending') {
                        meetings.add(meeting);
                      }
                    });

                    if (meetings.length == 0) {
                      return Container(
                        alignment: Alignment.center,
                        height: MediaQuery.of(context).size.height / 1.5 , 
                        width: MediaQuery.of(context).size.width, 
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/icons/logo_icon_whiteBG.png'),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),
                            Text(AppLocalizations.of(context)!.agenda_noEvents, style: TextStyle( color: uiSettingColor.minimal_1, fontSize: 14.sp, fontFamily: 'Spoqa', fontWeight: FontWeight.w700),),
                          ],
                        ),
                      );
                    }
                    else{
                      return SizedBox(
                      height: meetings.length * 70,
                      child: ListView.builder (
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: meetings.length,
                        itemBuilder: (context, index) {
                          return pendingTile(meetings[index], context, callback);
                        }
                      ),
                    );
                    }
                  }
                  else {
                    return Container();
                  }
                }
              ),
            ],
          ),
        )
      ),
    );
  }

}

pendingTile(Meeting meeting, BuildContext context, Function callback) {
  final user = Provider.of<MyUser>(context);
  return FutureBuilder(
    future: DatabaseService(uid: user.uid).getPendingTime(meeting.MID),
    builder: (context, AsyncSnapshot pendingSnapshot) {
      if (pendingSnapshot.connectionState == ConnectionState.done) {
        if (pendingSnapshot.hasData) {
          Map<String, dynamic> pendingInstance = new Map<String, dynamic>.from(pendingSnapshot.data); //TODO good stuffs
          List<String> pendingMeetingInvolved = (new List.from(pendingInstance.keys));
          pendingMeetingInvolved.remove("mid");
          return StreamBuilder<MyUser>(
            stream: DatabaseService(uid: meeting.owner).userData,
            builder: (context, userSnapshot) {
              MyUser? ownerData = userSnapshot.data;
              if (userSnapshot.hasData) {
                return Container(
                  height: 70,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 27.0,
                      backgroundImage:ownerData!.photoUrl != '' ? CachedNetworkImageProvider(ownerData.photoUrl) : null,
                    ),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget> [
                        Text(ownerData.name),
                        Text("${meeting.MID.substring(7, 17)} - ${meeting.MID.substring(17, 25)}"),
                        Text(meeting.content),
                      ]
                    ),
                    onTap: () async {
                      if (pendingInstance["${user.uid}"]["isDone"] == false) {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => StreamProvider<MyUser>(
                              create: (context) => DatabaseService(uid: user.uid).userData,
                              initialData: MyUser(uid: user.uid),
                              builder: (context, child) => PreferredWeekly(meeting: meeting, pendingMeeting: pendingInstance, parentCallback: callback),
                            )
                          )
                        );
                      }

                      else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => GroupMeetings(pendingMeetData: pendingInstance, meeting: meeting)));
                        // TODO : Push to gorup times page
                      }
                    }
                  ),
                );
              }
        
              else {
                return Container();
              }
            }
        );
        }
        else {
          return Container();
        }
      } else {
        return Container();
      }
    }
  );
}