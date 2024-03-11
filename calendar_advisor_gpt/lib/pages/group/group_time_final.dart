import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../models/meeting.dart';
import '../../models/user.dart';
import '../../services/database.dart';
import '../all_pages.dart';
import '../daily/view_model/check_box_state.dart';
import '../../shared/calendar_functions.dart';

class GroupMeetings extends StatefulWidget {
  const GroupMeetings({Key? key, this.pendingMeetData, required this.meeting}) : super(key: key);
  final Map<String, dynamic>? pendingMeetData;
  final Meeting meeting;
  @override
  State<GroupMeetings> createState() => _GroupMeetingsState();
}

class _GroupMeetingsState extends State<GroupMeetings> {

//-------------------- variables --------------------//
  Widget build(BuildContext context) {
    final currentUserUid = Provider.of<MyUser?>(context)!.uid;
    Meeting currentMeeting = widget.meeting;
    DateTime startDate = currentMeeting.from;
    DateTime endDate = currentMeeting.to;
    List<String> doneUsers = [];

    Map<String,dynamic> pendingMeetData = {};
    bool hasWantedTime = false;
    if (widget.pendingMeetData != null) {
      pendingMeetData = widget.pendingMeetData!;
      for(var wantedTimeList in pendingMeetData.values){
        if(wantedTimeList.runtimeType != String){
          if(wantedTimeList["individualTime"].isNotEmpty){
            print(wantedTimeList.runtimeType);
            hasWantedTime = true;
            break;
          }
        } 
      }   
    }

    pendingMeetData.forEach((user, value) {
      if(user != 'mid'){
        if(value['isDone'] == true)
        {
          doneUsers.add(user);
        }
      }
    });
    
    for(int i = 0; i < doneUsers.length; i ++){
      if(doneUsers[i] == currentMeeting.owner) {
        doneUsers.remove(currentMeeting.owner);
        doneUsers.insert(0, currentMeeting.owner);
      } 
      // else if (doneUsers[i] == currentUserUid){
      //   doneUsers.remove(currentUserUid);
      //   doneUsers.insert(1, currentUserUid);
      // }
    }

  @override
 //-------------------- providers --------------------//
    final user = Provider.of<MyUser>(context);
    return Dismissible(
      direction: DismissDirection.horizontal,
      key: const Key('key'),
      onDismissed: (_) => Navigator.of(context).pop(),

//-------------------- Scaffold Start --------------------//
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: AppBar(
            bottomOpacity: 0,
            elevation: 0,
            backgroundColor: Colors.white,
            toolbarHeight: 60,
            leading: BackButton(),
            iconTheme: IconThemeData(color: Colors.black,size: 30),
            actions: <Widget>[
              IconButton(
                icon: (currentMeeting.owner == user.uid) ? Icon(Icons.delete_rounded, color: Colors.black): Text(""),
                onPressed: () async{
                    if (currentMeeting.owner == user.uid) {// Enable edit if owner
                      showDialog(
                        context: context,
                        builder:(context) =>  AlertDialog(
                            title: Text(AppLocalizations.of(context)!.groupmeeting_deleteGroup),
                            content:Text(AppLocalizations.of(context)!.groupmeeting_deleteQuestion, style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Roboto'),),
                            actions: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    child: Text(AppLocalizations.of(context)!.delete),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.black,
                                    ),
                                    onPressed: () async {
                                      print("Start Deleeting with user idL ${user.uid}");
                                      await DatabaseService(uid: user.uid).deleteMeetings(currentMeeting.MID);
                                      print("Delete Meeting: ${currentMeeting.MID}");
                                      // await DatabaseService(uid:user.uid).leaveInvolvedMeetings(user.uid, event.MID);
                                      // eventProvider.updateEventMaker(user.uid);
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pop();  //todo

                                    },
                                  ),
                                  ElevatedButton(
                                    child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(color: Colors.black),),
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.white70,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      // setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ]
                        ),
                      );
                    }
                },
              ),
            ],
          ),
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    alignment: Alignment.topLeft,
                    height: 85,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: doneUsers.length,
                      itemBuilder: (BuildContext context, int index) {
                        return StreamBuilder<MyUser>(
                          stream: DatabaseService(uid: doneUsers[index]).userData,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              //Friend's Data
                              MyUser? userData = snapshot.data;
                              return Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SingleProfile(size: 60, photoUrl: userData!.photoUrl),
                                    Text(userData.name)
                                  ],        
                                )
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          }
                        );
                      }
                    ),
                  )
                )
              ),
//-------------------- Calendar --------------------//
              FutureBuilder(
                future: groupMeetingsFuture(user.uid, pendingMeetData, currentMeeting),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                  //if snapshot is fully called from DB and done
                    if (snapshot.hasData) {
                      List<Object> snapdata = snapshot.data as List<Object>;
                      List<Meeting> meetings = snapdata[0] as List<Meeting>;
                      List<List<Meeting>> wantedTimes = snapdata[1] as List<List<Meeting>>;
                      bool isCheckedAll = snapdata[2] as bool;
                      print("blaasdasdhhh $snapdata");
                      final groupObject = filterMeetings(meetings, wantedTimes, isCheckedAll, startDate, endDate, doneUsers.length);
                      final events = groupObject[0];
                      final unavailRegions = groupObject[1] as List<TimeRegion>;
                      return Expanded(
                        child: SfCalendar(
                          minDate: startDate,
                          maxDate: endDate,
                          specialRegions: unavailRegions,
                          view: CalendarView.week,
                          headerHeight:67,
                          headerStyle:CalendarHeaderStyle(textStyle: TextStyle(fontSize: 36, fontFamily: 'Roboto-Black')),
                          viewHeaderStyle: ViewHeaderStyle(
                            dayTextStyle: TextStyle(color: uiSettingColor.minimal_1),
                          ),
                          timeZone: TimeZone().current,
                          showCurrentTimeIndicator: false,
                          showWeekNumber: false,
                          showNavigationArrow: true,
                          todayHighlightColor: uiSettingColor.minimal_1,
                          timeSlotViewSettings:
                            TimeSlotViewSettings(
                              // startHour: 8,  // later enable settings to alter start time.
                              // endHour: 7,
                              timeInterval: Duration(hours: 1), timeFormat: 'HH:mm',
                              timeIntervalHeight: 30, // User 가 원하는 성향에 따라 변동 가능해야 함.
                              dateFormat: 'd', dayFormat: 'EEE',
                            ),
                          dataSource: MeetingDataSource(events as List<Meeting>),
                          onTap:(details) async {
                            if(currentMeeting.owner == currentUserUid && details.appointments != null){
                              final meeting2pass = details.appointments!.first; // Enable edit if owner
                              List<String> involved = [];
                              doneUsers.forEach((userIte) { 
                                if(userIte != currentUserUid) {
                                  involved.add(userIte);
                                }
                              });
                              meeting2pass.involved = involved;
                                await Navigator.push(context, MaterialPageRoute(builder: (context) => Daily(meeting: meeting2pass)));
                              }
                            }
                        )
                      );
                    } else if (snapshot.hasError) {
                      return Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}
