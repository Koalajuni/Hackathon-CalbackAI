import 'package:calendar/models/user.dart';
import 'package:calendar/pages/group/group_time_final.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../models/meeting.dart';
import '../../services/database.dart';
import '../../shared/alert_dialog_error.dart';
import '../../shared/calendar_functions.dart';

doNothing() {}

class PreferredWeekly extends StatefulWidget {
  const PreferredWeekly({Key? key, required this.meeting, required this.pendingMeeting, this.parentCallback = doNothing}) : super(key: key);
  final Meeting meeting;
  final Map<String, dynamic> pendingMeeting;
  final Function parentCallback;

  @override
  PreferredWeeklyState createState() => PreferredWeeklyState();
}

class PreferredWeeklyState extends State<PreferredWeekly> {
  final uiTime = TimeZone();
  late DateTime startDate;
  late DateTime endDate;
  late bool formCompletion;
  late Meeting currentMeeting;
  late Map<String, dynamic> pendingMeeting;
  late Function pendingCallback;

  //------------------- select mode variables ----------------------//
  final _specialTimeRegions = <TimeRegion>[];
  List<DateTime> wantedTimeList = [];   // list of all the times that user is available
  List<DateTime> unwantedTimeList = [];

  //------------------- drop down variable ----------------------//

  void initState() {
    currentMeeting = widget.meeting;
    pendingMeeting = widget.pendingMeeting;
    startDate = currentMeeting.from;
    endDate = currentMeeting.to;
    pendingCallback = widget.parentCallback;
    print("Event filter parameters start from $startDate and end at $endDate");
    formCompletion = false;
    super.initState();
  }

  late String dropdownValue = AppLocalizations.of(context)!.preferenceweek_checkAvailable;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<MyUser>(context);
    DateTime start = widget.meeting.from;
    return Dismissible(
      direction: DismissDirection.horizontal,
      key: const Key('key'),
      onDismissed: (_) => Navigator.of(context).pop(formCompletion),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.0),
            child: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(formCompletion),
              ),
              iconTheme: IconThemeData(color: Colors.black),
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: true,
              actions: [
                dropDownMode(context),
                // dropdownButtons(),
              ],
              bottomOpacity: 0.0,
              elevation: 0.0,
            ),
          ),
          body: Container(
            child: Column(
              children: [
                /*
                StreamBuilder<MyUser>(
                    stream: DatabaseService(uid: user.uid).userData,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        MyUser? userData = snapshot.data;
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SingleProfile(size: 60, photoUrl: userData!.photoUrl, borderSize: 3),
                              Text(userData.name)
                            ],
                          ),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    }
                ),
                */
                Expanded(
                    child: preferenceWeek(),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  width:168,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (dropdownValue == AppLocalizations.of(context)!.preferenceweek_checkAvailable) {
                        if(wantedTimeList.isNotEmpty){
                          print('Unsorted times $wantedTimeList');
                          wantedTimeList = joinBlocks(wantedTimeList);
                          print('Sorted times $wantedTimeList');
                          formCompletion = true;
                          print('Form status: $formCompletion');
                          await DatabaseService(uid: user.uid).updatePendingTime(user.uid, currentMeeting.MID, isDone: formCompletion, timeList: wantedTimeList);
                          pendingCallback();
                          Map<String, dynamic> pendingInstance = await DatabaseService(uid: user.uid).getPendingTime(currentMeeting.MID);
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (context) => GroupMeetings(pendingMeetData: pendingInstance, meeting: currentMeeting)));
                            } else {
                          showAlertDialog(context, AppLocalizations.of(context)!.empt_wt_error);
                        }
                      }

                      else {
                        formCompletion = true;
                        await DatabaseService(uid: user.uid).updatePendingTime(user.uid, currentMeeting.MID, isDone: formCompletion);
                        pendingCallback();
                        Map<String, dynamic> pendingInstance = await DatabaseService(uid: user.uid).getPendingTime(currentMeeting.MID);
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => GroupMeetings(pendingMeetData: pendingInstance, meeting: currentMeeting)));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        )
                      ),
                    child:
                      Text(
                        AppLocalizations.of(context)!.send,
                        style: TextStyle(color: Colors.white),
                      ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //-----------------------------END of Scaffold-------------------------//

  Widget preferenceWeek(){
    final user = Provider.of<MyUser?>(context);
    final eventProvider = Provider.of<EventMaker>(context);
      return  StreamBuilder<List<Meeting>>(
          stream: DatabaseService(uid: user!.uid).meetingsData,
          builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Object> calendarRegion = filterMeetings(snapshot.data as List<Meeting>, [], false, startDate, endDate, 0);
            final events = calendarRegion[0];
            final unavailRegions = calendarRegion[1] as List<TimeRegion>;
            if(_specialTimeRegions.isEmpty){
              _specialTimeRegions.addAll(unavailRegions);
            }
            if (dropdownValue == AppLocalizations.of(context)!.preferenceweek_checkAvailable){
              //------------check available Calendar
              return StatefulBuilder(
                  builder: (context, setCalendar) {
                  return SfCalendar( 
                    view: CalendarView.week,
                    headerHeight:67,
                    minDate: startDate ,
                    maxDate: endDate ,
                    headerStyle:CalendarHeaderStyle(textStyle: TextStyle(fontSize: 28, fontFamily: 'Roboto-Bold')),
                    viewHeaderStyle: ViewHeaderStyle(dayTextStyle: TextStyle(color: ColorSetting().minimal_1),),
                    timeZone: uiTime.current,
                    cellBorderColor:  Color.fromRGBO(242, 236, 233,1), //Light grey color
                    showCurrentTimeIndicator: false,
                    showWeekNumber: false,
                    todayHighlightColor: ColorSetting().minimal_1,
                    showNavigationArrow: false,
                    timeSlotViewSettings:
                    TimeSlotViewSettings(
                      timeInterval: Duration(minutes: 30), timeFormat: 'HH:mm',
                      timeIntervalHeight: 30, // User 가 원하는 성향에 따라 변동 가능해야 함.
                      dateFormat: 'd', dayFormat: 'EEE',
                    ),
                    specialRegions: _specialTimeRegions,
                    onTap: ((calendarTapDetails) {
                      setCalendar(() {
                        tapAvailableDays(calendarTapDetails);
                      });
                    }),
                  );
                }
              );
            } else{
              //------------ return orignal calendar
              return SfCalendar(
                view: CalendarView.week,
                headerHeight:67,
                minDate: startDate,
                maxDate: endDate,
                headerStyle: CalendarHeaderStyle(textStyle: TextStyle(fontSize: 28, fontFamily: 'Roboto-Bold')),
                viewHeaderStyle: ViewHeaderStyle(dayTextStyle: TextStyle(color: ColorSetting().minimal_1),),
                timeZone: uiTime.current,
                cellBorderColor:  Color.fromRGBO(242, 236, 233,1), //Light grey color
                showCurrentTimeIndicator: false,
                showWeekNumber: false,
                todayHighlightColor: ColorSetting().minimal_1,
                showNavigationArrow: false,
                timeSlotViewSettings:
                TimeSlotViewSettings(
                  timeInterval: Duration(hours: 1), timeFormat: 'HH:mm',
                  timeIntervalHeight: 30, // User 가 원하는 성향에 따라 변동 가능해야 함.
                  dateFormat: 'd', dayFormat: 'EEE',
                ),
                dataSource: MeetingDataSource(snapshot.hasData ? snapshot.data as List<Meeting> : eventProvider.events),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }
      );
  }

  Widget dropdownButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            textStyle: TextStyle(color: uiSettingColor.minimal_1, fontFamily:'Roboto-Bold',fontSize: 16),
            primary: Colors.white,
            backgroundColor: uiSettingColor.minimal_1
          ),
          onPressed: () {
            setState(() {
              dropdownValue = AppLocalizations.of(context)!.preferenceweek_checkAvailable;
            });
          },
          child: Text(AppLocalizations.of(context)!.preferenceweek_checkAvailable),
        ),
        SizedBox(width: 15),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: TextStyle(color: uiSettingColor.minimal_1, fontFamily:'Roboto-Bold',fontSize: 16),
            primary: Colors.white,
            backgroundColor: uiSettingColor.minimal_1
          ),
          onPressed: () {
            setState(() {
              dropdownValue = AppLocalizations.of(context)!.preferenceweek_myCalendar;
            });
          },
          child: Text(AppLocalizations.of(context)!.preferenceweek_myCalendar),
        ),
      ],
    );
  }

  Widget dropDownMode(BuildContext context){
    List<String> list = <String>[AppLocalizations.of(context)!.preferenceweek_checkAvailable,
      AppLocalizations.of(context)!.preferenceweek_myCalendar];
    return Container(
      alignment: Alignment.center,
      width: 220,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        focusColor: uiSettingColor.minimal_2,
        value: dropdownValue,
        style: TextStyle(color: uiSettingColor.minimal_1, fontFamily:'Roboto-Bold',fontSize: 18),
        icon: const Icon(Icons.arrow_drop_down_sharp),
        items: list.map<DropdownMenuItem<String>>((String value){
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (value){
          setState(() {
            dropdownValue = value!;
          });
        },
      ),
    );
  }


  //------------------- select mode function -----------------------//

  void tapAvailableDays(CalendarTapDetails calendarTapDetails){
    final wantedTime = TimeRegion(
      startTime: calendarTapDetails.date!,
      endTime: calendarTapDetails.date!.add(Duration(minutes: 30)),
      color: uiSettingColor.minimal_2,
    );
    if(wantedTimeList.contains(calendarTapDetails.date!)) {
      print("Contains!");
      _specialTimeRegions!.remove(TimeRegion(
        startTime: calendarTapDetails.date!,
        endTime: calendarTapDetails.date!.add(Duration(minutes: 30)),
        color: uiSettingColor.minimal_2,
      ));
      wantedTimeList.remove(wantedTime.startTime);
    }
    else {
      _specialTimeRegions!.add(TimeRegion(
        startTime: calendarTapDetails.date!,
        endTime: calendarTapDetails.date!.add(Duration(minutes: 30)),
        color: uiSettingColor.minimal_2,
      ));
      wantedTimeList.add(wantedTime.startTime);
    }
  }
}