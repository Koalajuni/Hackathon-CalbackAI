import 'package:calendar/models/user.dart';
import 'package:flutter/material.dart';
import 'package:calendar/pages/all_pages.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../models/meeting.dart';
import '../../services/database.dart';


class Weekly extends StatefulWidget {
  const Weekly({Key? key}) : super(key: key);

  @override
  WeeklyState createState() => WeeklyState();
}

class WeeklyState extends State<Weekly> {
  final uiTime = TimeZone();

  @override
  Widget build(BuildContext context) {
    //-------------------- providers --------------------//
    final eventProvider = Provider.of<EventMaker>(context);
    final user = Provider.of<MyUser?>(context);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Scaffold(
        backgroundColor: Color.fromRGBO(246, 245, 255, 1),
        appBar: AppBar(
          bottomOpacity: 0,
          elevation: 0,
          backgroundColor: Colors.white,
          toolbarHeight: 50,
          leading: BackButton(),
          iconTheme: IconThemeData(
            color: Colors.black,
            size: 30,
          ),
          centerTitle: false,
        ),
//-------------------- floating action button --------------------//
        floatingActionButton: EventButton(),

//-------------------- body --------------------//
        body: Container(
          height: 650,
          child: Column(
            children: [
              SizedBox(height: 4),
              Expanded(
//-------------------- Calendar --------------------//
                child: StreamBuilder<List<Meeting>>(
                  stream: DatabaseService(uid: user!.uid).meetingsData,
                    builder: (context, snapshot) {
                    return SfCalendar(
                      backgroundColor: Colors.white,
                      view: CalendarView.week,
                      headerHeight:40,
                      headerStyle:CalendarHeaderStyle(textStyle: TextStyle(fontSize: 32, fontFamily: 'Roboto-Bold')),
                      viewHeaderStyle: ViewHeaderStyle(dayTextStyle: TextStyle(color: ColorSetting().minimal_1),),
                      timeZone: uiTime.current,
                      cellBorderColor:  Color.fromRGBO(242, 236, 233,1), //Light grey color
                      showCurrentTimeIndicator: false,
                      showWeekNumber: false,
                      todayHighlightColor: ColorSetting().minimal_1,
                      showNavigationArrow: true,
                      timeSlotViewSettings:
                      TimeSlotViewSettings(
                        // startHour: 8,  // later enable settings to alter start time.
                        // endHour: 7,
                        timeInterval: Duration(hours: 1), timeFormat: 'HH:mm',
                        timeIntervalHeight: 30, // User 가 원하는 성향에 따라 변동 가능해야 함.
                        dateFormat: 'd', dayFormat: 'EEE',
                      ),
                      dataSource: MeetingDataSource(snapshot.hasData ? snapshot.data as List<Meeting> : eventProvider.events),
              //Calendar on Tap  
                      onTap:(details) async {
                        eventProvider.setDate(details.date!);
                        if(details.appointments == null){
                          return;
                        }
                        else{
                          final event = details.appointments!.first; // Enable edit if owner
                          Meeting? tapMeeting;
                          
                          if (event.recurrenceRule != '') {
                            for (var meeting in eventProvider.events) {
                              if (meeting.MID == event.MID && 
                                meeting.recurrenceRule == event.recurrenceRule) 
                              {
                                tapMeeting = Meeting(
                                  owner: meeting.owner,
                                  content: event.subject,
                                  from: event.startTime,
                                  to: event.endTime,
                                  recurrenceRule: meeting.recurrenceRule,
                                  background: meeting.background,
                                  isAllDay: meeting.isAllDay,
                                  involved: meeting.involved,
                                  MID: meeting.MID,
                                  pendingInvolved: meeting.pendingInvolved,
                                );
                              }
                            }
                          }

                          else {
                            tapMeeting = event;
                          }

                          await Navigator.push(context, CustomPageRoute(
                            child: StreamProvider<MyUser>(
                                create: (context) => DatabaseService(uid: user!.uid).userData,
                                initialData: MyUser(uid: user!.uid),
                                builder: (context, child) => EventViewer(event: tapMeeting),
                              ),
                            ),
                          );
                        }
                      },
                    );
                    }
                )
              ),
              SizedBox(height: 80)
            ],
          ),
        ),
      ),
    );
  }
}

