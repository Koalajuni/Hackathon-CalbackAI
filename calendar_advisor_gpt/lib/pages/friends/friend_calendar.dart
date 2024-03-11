import 'package:calendar/shared/globals.dart' as globals;
import 'package:calendar/models/meeting.dart';
import 'package:calendar/models/user.dart';
import 'package:calendar/services/database.dart';
import 'package:flutter/material.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class FriendCalendar extends StatefulWidget {
  const FriendCalendar({Key? key, required this.user}) : super(key: key);
  final MyUser user;

  @override
  FriendCalendarState createState() => FriendCalendarState();
}

class FriendCalendarState extends State<FriendCalendar> {
  final eventMaker = EventMaker();
  final uiSettingColor = ColorSetting();
  final uiSettingFont = FontSetting();
  final uiTime = TimeZone();

  @override
  Widget build(BuildContext context) {
    final meetings = DatabaseService(uid: widget.user.uid).getMeetings();
    final userFr = widget.user;

    return Dismissible(
      direction: DismissDirection.vertical,
      key: const Key('key'),
      onDismissed: (_) => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Color.fromRGBO(246, 245, 255, 1),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: AppBar(
            toolbarHeight: 60,
            bottomOpacity: 0,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Colors.white,
          ),
        ),
        body: Container(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    CircleAvatar(
                      radius: 30.0,
                      backgroundImage:  userFr!.photoUrl != '' ? CachedNetworkImageProvider(userFr!.photoUrl) : null
                    ),
                    SizedBox(width: 20),
                    Text(userFr.name, style: TextStyle(
                        fontSize: 22,
                        color: Colors.black, fontFamily: 'Roboto', fontWeight: FontWeight.bold
                    )),
                  ]
                ),
              ),
              FutureBuilder(
                future: meetings,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final events = snapshot.data as List<Meeting>;
                    return Expanded(
                      child: SfCalendar(
                        backgroundColor: Colors.white,
                        view: CalendarView.week,
                        headerHeight:32,
                        headerStyle:CalendarHeaderStyle(textStyle: TextStyle(fontSize: 28, fontFamily: 'Roboto-Black')),
                        viewHeaderStyle: ViewHeaderStyle(
                          dayTextStyle: TextStyle(color: uiSettingColor.minimal_1),
                        ),
                        timeZone: uiTime.current,
                        cellBorderColor:  Color.fromRGBO(242, 236, 233,1), //Light grey color
                        showCurrentTimeIndicator: false,
                        showWeekNumber: false,
                        todayHighlightColor: uiSettingColor.minimal_1,
                        showNavigationArrow: true,
                        timeSlotViewSettings:
                        TimeSlotViewSettings(
                          // startHour: 8,  // later enable settings to alter start time.
                          // endHour: 7,
                          timeInterval: Duration(hours: 1), timeFormat: 'HH:mm',
                          timeIntervalHeight: 30, // User 가 원하는 성향에 따라 변동 가능해야 함.
                          dateFormat: 'd', dayFormat: 'EEE',
                        ),
                        dataSource: MeetingDataSource(events),
                      )
                    );
                  }

                  else if (snapshot.hasError) {
                    return Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    );
                  }

                  else {
                    return CircularProgressIndicator();
                  }
                }
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _update(){
    setState(() {
    });
  }
}

